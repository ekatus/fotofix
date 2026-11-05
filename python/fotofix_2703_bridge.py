import socket
import time
import sys
import os
import io
import struct
import json
import math
import traceback
import requests 
from enum import Enum
import socket

global TCP_PORT_IN
global TCP_PORT_OUT
global TCP_IP_IN
global TCP_IP_OUT
global ack_to_send
global last_ack_received
global EBN 
global blockState


REMOTE_SERVER_URL='http://fotofix.classic-computing.de'
REMOTE_PATH='ascii-print-host.txt'

TCP_IP_OUT = '192.168.178.157'       
TCP_IP_IN = '0.0.0.0'
TCP_PORT_IN = 2706          # Port
TCP_PORT_OUT= 2706

ENQ = b'\x2D'
BID = b'\x7C'
STAT= b'\x34'
TACK = b'\x2E'
TACK0= b'\x15'
DCHR= b'\xC4'
BLNK= b'\x40'
CR=   b'\0D'
LF=   b'\0A'
SYN = b'\x32'
STX = b'\x02'
ETX = b'\x03'
ETB = b'\x26'
EOT = b'\x37'
NUL = b'\x00'

PAD = b'\xFF' 
DLE = b'\0x10'

ACK0 = b'\x10\x70'
ACK1 = b'\x10\x61'
ODD = 0
EVEN = 1
BSTEXT = ['ODD','EVEN']


ack_to_send = ACK0
last_ack_received = None

class Conversation(Enum):
    IDLE = 1
    BID = 2
    FETCH = 3
    CMD = 4
    SEND = 5

class BlockState(Enum):
    EVEN = 1
    ODD = 2
    

class SocketStream:
    """ Hilfsklasse, um dem XMODEM-Modul ein file-artiges Interface für Sockets zu bieten """
    """ Helper Class to provide a file-lookalike interface of Sockets to the XMODEM-Module """
    def __init__(self, sock):
        self.sock = sock
        self.sock.settimeout(1.0)
    def read(self, size, timeout=1):
        self.sock.settimeout(timeout)
        data = b''
        start_time = time.time()        
        while len(data) < size:
            try:
                # Versuche den Rest der angeforderten Bytes zu lesen
                packet = self.sock.recv(size - len(data))
                if not packet:
                    # Verbindung wurde unterbrochen
                    return data if data else b''
                data += packet
            except socket.timeout:
                # Nur abbrechen, wenn das absolute Timeout-Limit ueberschritten ist
                if (time.time() - start_time) > timeout:
                    break
            except Exception:
                break
                
        return data
  
    def write(self, data, timeout=1):
        self.sock.settimeout(timeout)
        return self.sock.send(data)
        

def bsc_state_machine(client_socket):
    print("Starte synchronisierte BSC-Schleife...")
    
    # Das Flip-Flop für die Quittungen (Wir starten mit ACK1 für den ersten Datenblock)
    next_ack = b'\x10\x61' # ACK1
    
    buffer = bytearray()
    
    while True:
        # Wir lesen immer nur ein kleines Stück, um nichts zu verpassen
        chunk = client_socket.recv(1)
        if not chunk:
            print("Verbindung von Host getrennt.")
            break
            
        buffer.extend(chunk)
        
        # --- ZUSTAND 1: Der Host schickt ein einzelnes ENQ (0x2D) ---
        if len(buffer) == 1 and buffer[0] == 0x2D:
            print("[RECEIVE] Reines ENQ erhalten. Antworte mit ACK0...")
            client_socket.send(b'\x10\x70') # Auf Leitungs-Initialisierung immer ACK0
            buffer.clear()
            continue
            
        # --- ZUSTAND 2: Der Host schickt das Leitungs-Freigabezeichen EOT (0x37) ---
        if len(buffer) == 1 and buffer[0] == 0x37:
            print("[RECEIVE] EOT erhalten. Host gibt Leitung frei. Keine Antwort nötig.")
            buffer.clear()
            continue

        # --- ZUSTAND 3: Ein Datenblock vom WRITE des Hosts ---
        # Da wir wissen, dass Ihre WRITE-Texte mit Text gefüllt sind (und nicht mit Steuercodes),
        # sammeln wir so lange, bis ein ENQ am Ende auftaucht ODER der Host aufhört zu senden.
        
        # Trick: Wenn das letzte Byte ein ENQ (0x2D) ist, hat BTAM nach den Daten ein ENQ geschickt,
        # oder der Block ist zu Ende.
        if buffer.endswith(b'\x2D'):
            # Wir schneiden das ENQ am Ende ab, um den reinen Text zu sehen
            payload = buffer[:-1]
            try:
                text = payload.decode('cp500')
                print(f"[DATA] Datenblock empfangen: '{text}' (Hex: {payload.hex().upper()})")
            except:
                print(f"[DATA] Binärer Datenblock empfangen (Hex: {payload.hex().upper()})")
            
            # Jetzt die präzise Quittung für diesen Block senden!
            print(f"[SEND] Sende Quittung: {next_ack.hex().upper()}")
            client_socket.send(next_ack)
            
            # --- HIER SCHIEBEN WIR DIE ANTWORT FÜR DAS READ NACH ---
            if "FETCH" in text:
                print("FETCH erkannt! Bereite READ-Antwort vor...")
                # Sofort den 133-Byte Record generieren
                record1 = b'\x40' + b'A' * 132 # Beispiel-Record (EBCDIC)
                
                print("[SEND] Schiebe Record 1 direkt in den Puffer für das READ...")
                client_socket.send(record1)
                
                # Das nächste erwartete ACK vom Host für unseren Record wird ein ACK0 sein!
                # (Da wir gerade mit ACK1 geantwortet haben, ist der Host im nächsten Schritt dran)
            
            # Wechsel das ACK für den NÄCHSTEN empfangenen Host-Block
            next_ack = b'\x10\x70' if next_ack == b'\x10\x61' else b'\x10\x61'
            
            buffer.clear()
            continue
            
        # Sicherheitsnetz: Wenn der Puffer zu groß wird ohne Trennzeichen
        if len(buffer) > 200:
            print(f"WARNUNG: Puffer läuft voll ohne Protokollzeichen: {buffer.hex()}")
            buffer.clear()

def receive_full_block(sock, expected_length):
    global last_ack_received
    stxReceived = False
    buffer = bytearray()
    print(f"[receive_full_block]fetching {expected_length} byte block")
    while len(buffer) < expected_length:
        chunk = sock.recv(1)
        if not chunk:
            raise ConnectionError("[receive_full_block]connection terminated")
        print(".",end="")
        if chunk.startswith(EOT):
            print("[receive_full_block]HOST has sent EOT")
            buffer = bytearray()
            buffer.extend(chunk)
            print("")
            return buffer
        if chunk.startswith(ENQ):
            buffer = bytearray()
            buffer.extend(chunk)
            print("")
            print("[receive_full_block]Host has sent ENQ")
            return buffer
        if chunk.startswith(DLE):
            print("")
            print("[receive_full_block]DLE received")
            buffer.extend(chunk);
            continue;
        if chunk == b'\x70':
            buffer.extend(chunk)
            if buffer.startswith(ACK0):
                print("[receive_full_block]ACK0 received, returning")
                last_ack_received = ACK0
                print("")
                return buffer
        if chunk == b'\x61':
            buffer.extend(chunk)
            if buffer.startswith(ACK1):
                print("[receive_full_block]ACK1 received, returning")
                last_ack_received=ACK1
                print("")
                return buffer
        if chunk.startswith(STX):
            stxReceived = True
            print("")
            print("[receive_full_block]STX received")
            continue
        if chunk.startswith(ETX):
            print("")
            print(f"[receive_full_block]ETX received. Buffer = {buffer.hex()}, length={len(buffer)}")
            stxReceived = False
            #send_ack(sock)            
            #toggleBlockState()
            return buffer
        if stxReceived == True:
            buffer.extend(chunk)
    print("[receive_full_block]length limit exhausted, returning buffer")
    if stxReceived:
        print("")
        print("[receive_full_block]dangling STX")
    print("")
    return buffer

     
def read_exact_bytes(client_socket, num_bytes):
    buffer = b""
    while len(buffer) < num_bytes:
        #chunk = client_socket.recv(num_bytes - len(buffer))
        chunk = client_socket.recv(1)
        if not chunk:
            raise ConnectionError("[read_exact_bytes]Connection to host has been unexpectedly lost.")
        buffer += chunk
        if chunk == ENQ:
            print(f"[read_exact_bytes]ENQ received, premature return from reading {num_bytes} bytes from socket")
            return buffer
    return buffer
def bid_line(conn):
    global EBN
    print("[bid_line]bidding the line from host")
    conn.sendall(ENQ);
    resp = read_exact_bytes(conn,2)
    EBN +=1
    if resp == ACK0:
        print("Host granted the line.")
        blockState=ODD
        return True
    else:
        print(f"Host did not grant the line: 0x{resp.hex().upper()}")
        return False
def send_records(conn,records):
    global EBN
    global blockState
    print(f"[send_records]sending records: #{len(records)}")
    #toggleBlockState() # 
    for i, rec in enumerate(records):
        if blockState == ODD:
            print("[send_records]BlockState is ODD. Expecting ACK1")
            expected_ack = ACK1
        else:
            print("[send_records]BlockState is EVEN. Expecting ACK0")
            expected_ack = ACK0

        # 1. Datensatz senden
        conn.sendall(STX+rec+ETX)
        time.sleep(0.1)
        toggleBlockState()
        print(f"[send_records] EBN={EBN} record {i+1} has been sent. Waiting for ACK 0x{expected_ack.hex().upper()}")
        # 2. Auf das ACK vom Host warten (2 Bytes)
        host_ack = read_exact_bytes(conn,2)
        if len(host_ack) == 1 and host_ack == ENQ:
            print(f"[send_records]mainframe has sent an ENQ. ack_to_send = {ack_to_send}")
            conn.sendall(ack_to_send)
        if host_ack != expected_ack:
            print(f"[send_records]error: Host did not answer as expected! Received: {host_ack.hex()} Expected: {expected_ack.hex()}")
        EBN +=1 
    print("[send_records]sending End Record")
    eor = '*END*'
    buf = STX+eor.encode('cp500')+ETX+EOT+b'\x00'+b'\x00'
    #buf = STX+eor.encode('cp500')+EOT+b'\x00'+b'\x00'
    print(f"[send_records]sending closing record: 0x{buf.hex().upper()} length={len(buf)}")
    conn.sendall(buf)
    #we assume as EOT is part of the transmission, no ACK is to be expected from the
    #host side
    #host_ack = read_exact_bytes(conn,2)
    #if host_ack == ACK0 or host_ack == ACK1:
    #    print(f"HOST acked end of transmission: 0x{host_ack.hex().upper()}")  
    #if host_ack == ENQ:
    #    print(f"HOST send ENQ, reply with ACK0")
    #    conn.sendall(ACK0) 
    #    time.sleep(0.1)     
    blockState = EVEN 
    EBN = 0
    
def send_dummy_line(n,char):
    dummy_line = " "+(str(n)+char * 131)
    return dummy_line.encode("cp500")
def send_ack(conn):
    global ack_to_send
    global EBN
    global blockState
    
    if blockState == EVEN:
        expected_ack = ACK0
        ack_to_send = ACK0
        textBlockState = 'EVEN'
    else:
        expected_ack = ACK1
        ack_to_send = ACK1 
        textBlockState = 'ODD'
    
    print(f"[send_ack]sending ACK to HOST - EBN = {EBN}  Block State: {textBlockState} Sending ACK: 0x{ack_to_send.hex().upper()}")
    conn.send(ack_to_send)
    EBN +=1
    
def handle_bsc_transmission(conn, addr):
    global EBN
    global blockState
    global line_granted
    line_granted = False
    
    print("Ready for bidirectional Communication over BSC...")
    conn.settimeout(None)
    hello_received = False
    fetch_received = False
  
    print("Entering main loop")
    subsequentENQ=False
    enqCount=0
    while True:
        print("Start of main loop")
        if enqCount > 3:
            subsequentENQ = True
        data = receive_full_block(conn,18) # includes block brackets STX + ETX
        data_len = len(data)
        print(f"[main loop]Length of data: {data_len} -> 0x{data.hex().upper()}")
        if data_len == 0:
            # Statt break werfen wir hier eine Exception, um den Reconnect zu triggern
            #raise socket.error("Hercules hat den Socket geschlossen (MVS lauscht vermutlich noch nicht).")
            continue
        if data.startswith(EOT):
            line_granted = bid_line(conn)
            continue
        if data.startswith(ENQ):
           print(f"[main loop]ENQ received in main loop, sending ACK0")
           enqCount+=1
           if subsequentENQ:
                conn.sendall(ACK1)
                blockState = ODD
           else:
                conn.sendall(ACK0)
                blockState = EVEN
           toggleBlockState()
           #conn.sendall(STX+EOT)
           #toggleBlockState()
           continue
        else:
            enqCount = 0
            subsequentENQ = False
        if data.startswith(ACK0):
            print("[main loop]HOST sent ACK0")
            if fetch_received == True:
                print("[main loop]in fetch received state")
                print("[main loop]start Read loop")
                send_order(conn,order)
                fetch_received = False
        if data.startswith(ACK1):
            print("[main loop]HOST sent ACK1")
            time.sleep(0.1)
            if fetch_received == True:
                print("in fetch received state")
                print("start Read loop")
                send_order(conn,order)
                fetch_received = False
        ascii = data.decode('cp500')
        print(f"[main loop]: EBN={EBN} length={data_len} 0x{data.hex().upper()} -> {data} ->ASCII {ascii}")
        if ascii.startswith("HELLO"):
            print("[main loop] HELLO received")
            hello_received = True
            send_ack(conn)
            toggleBlockState()
            EBN+=1
        if ascii.startswith("FETCH"):
            print("[main loop] FETCH received")    
            fetch_received = True
            send_ack(conn)
            toggleBlockState()
            EBN+1
            if not line_granted:
                line_granted = bid_line(conn)
                print(f"[main loop]HOST granted line: {line_granted}")
            ascii = ascii[0:16]
            (head,_order) = ascii.split(":")
            order = _order.strip(' ')
            if line_granted == True:
                print("[main loop]line granted, we have the right to send")
                print(f"[main loop]FETCH detected - fetching  order [{order}]") 
                time.sleep(0.1)
                success = send_order(conn,order)
                if success == False:
                    print("[main loop]Sent NOTfOUND to Host")
                line_granted = False
                fetch_received = False
                blockState = EVEN
                EBN = 0
            else:
                print("We do not have the line being granted to us")
                fetch_received = False
def send_command(conn,command):
    global EBN
    o = STX + command.encode("cp037")+ETX
    print(f"[send_command] sending command {command}, length={len(o)}")
    conn.sendall(o);
    #toggleBlockState()
    ack = read_exact_bytes(conn,2)
    EBN +=1
    print(f"[send_command] sent command {command}, received {ack.hex().upper()}")
    if ack == ACK0:
        blockState = ODD
    else:
        blockState = EVEN
    return ack          
def toggleBlockState():
    global blockState
    oldState = blockState
    if blockState == EVEN:
        blockState = ODD
    else:
        blockState = EVEN
    print(f"[toggleBlockState]: old block state: {BSTEXT[oldState]} new block state: {BSTEXT[blockState]}")

def send_order(conn,order):
    global EBN
    print(f"[send_order] sending order [{order}]")
    try:
        lines = get_order(order)
        #send_command(conn,"OPEN:"+order+"  ")
        ack = send_command(conn,"OPEN:"+order+" ")
        #ack = read_exact_bytes(conn,2)
        if ack == ACK0:
            print(f"[send_order]HOST sent ACK0 for our open command")  
        if ack == ACK1:
            print(f"[send_order]HOST sent ACK1 for our open command")  
        if ack == ENQ:
            print("[send_order]HOST sent ENQ after OPEN")
            conn.sendall(ACK0)
            line_granted = bid_line(conn)
            toggleBlockState()
        if len(lines) <=3:
            records = (send_dummy_line(1,'A'),send_dummy_line(2,'B'),send_dummy_line(3,'C'))
            send_records(conn,records)
        else:
            send_records(conn,lines)
             
        return True
    except FileNotFoundError:
        print(f"[send_order]File not found for order {order}")
        cmd = "NOTFND:"+order.strip(" ")
        print(f"[send_order] CMD {cmd} len={len(cmd)}")
        b = cmd.encode("cp037")
        s = STX+b+NUL+ETX# was ETX+EOT
        print(f"[send_order] CMD {cmd} len s={len(s)}")
        conn.sendall(s)
        if not ETX in s:
            print("[send_order] await ACK")
            ack = read_exact_bytes(conn,2)
            if ack == ACK0 or ack == ACK1:
                print("[send_order]HOST acked our negative reply")
        EBN = 0
        blockState = EVEN
        return False
        
def get_order(ordernum):
    result = []
    try:
        print(f"fetching order {ordernum} from network")
        result = get_order_net(ordernum)
    except FileNotFoundError as e:
        print(f"file not found for {ordernum}, searching disk")
        result = get_order_file(ordernum)
    return result
        
def get_order_net(ordernum):
    url = REMOTE_SERVER_URL+'/'+ordernum.strip()+'/'+REMOTE_PATH
    print(f"Fetching order {ordernum} from network {url}")
    spool = './ascii/'+ordernum.strip(" ")+".txt"
    response = requests.get(url)
    if response.status_code == 200:
        print(f"received remote file, spooling to disk {spool}")
        with open(spool,"wb") as file:
            file.write(response.content)
        print("Download successful")
        data =  get_order_file(ordernum)
        try:
            os.remove(spool)
            print(f"Spool file {spool} has been unlinked")
        except FileNotFoundError:
            print(f"Spool file {spool} not found")
        return data
    if response.status_code == 404:
        raise FileNotFoundError
        
def get_order_file(ordernum):
    filename = "./ascii/"+ordernum.strip(" ")+".txt"
    newList = []
    tmpList = []
    first = True
    c = " ";
    lnum=1
    with open(filename,"r") as file:
        for line in file:
            if first:
                c="1"
                first=False
            else:
                c=" "
            line = line.replace('\r','').replace('\n','')
            if len(line) < 132:
                print(f"[get_order]Short line warning at line: {lnum} len={len(line)}")
                continue
            l = c+line
            lnum += 1
            if lnum > 66:
                continue
            newList.append(l.encode("cp037"))
        file.close()
        print(f"[get_order]{lnum} lines read from file {filename}. Orderlist entries: {len(newList)}")
    newList[-1] = " ".encode('cp037') + newList[-1][1:]
    return newList
    
def dial_out():

    while True:
        try:
            sock = socket.socket(socket.AF_INET,socket.SOCK_STREAM)
            sock.connect((TCP_IP_OUT,TCP_PORT_OUT))
            sock.settimeout(None)
            print("FOTOFIX Connected")
            #sock.sendall(b'\r\n')
            #sock.sendall(STX+"HELLO".encode("cp037")+ETX)
            buf = sock.recv(129)
            print("129 bytes prolog has been received")
            time.sleep(0.1)
           # sock.sendall(ACK0)
           # sock.sendall(STX+ETX+EOT)
            rec = read_exact_bytes(sock,2)
            print(f"HOST reply: 0x{rec.hex().upper()}")
            if rec == ACK0:
                print("HOST has acknowledged the bidding, sending HELLO")
                sock.sendall(STX+"HELLO".encode("cp037")+"ETX")
                rec = read_exact_bytes(sock,2)
                print(f"HOST acked with 0x{rec.hex().upper()}")
                handle_bsc_transmission(sock,None)
            if rec == NUL + NUL:
                print("HOST replied with NUL+NUL")
                handle_bsc_transmission(sock,None)
            else:
                print("Unknown answer")
        except KeyboardInterrupt:
            print("\nTerminating Server")
            break
        except Exception as e:
            print(f"Server Error {e}")

def dial_in():
    server_sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server_sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    server_sock.bind((TCP_IP_IN, TCP_PORT_IN))
    server_sock.listen(1)
    while True:
        try:
            print("FOTOFIX waiting for connection")
            conn, addr = server_sock.accept()
            print("FOTOFIX accepted incoming connection")
            handle_bsc_transmission(conn,addr)
        except KeyboardInterrupt:
            print("\n[Server] Stopping Server upon user request.")
            break
        except ConnectionError as c:
            print(f"[Server-Error]: Client disconnected {c}")
        except Exception as e:
            print(f"[Server-Error] in main loop: {e}")
            traceback.print_exc()
            break

if __name__ == "__main__":
    print("FOTOFIX Server starting...")
    lines = get_order("A1234567")
    global EBN
    global blockState
    blockState = EVEN
    EBN = 0                                             # exchange block number
    arglen = len(sys.argv)
    if sys.argv[1] == "in":
        if arglen == 3:
            if ":" in sys.argv[2]:
                (a,p) = sys.argv[2].split(':')
                TCP_PORT_IN=int(p)
                TCP_IP_IN=a
            else:
                TCP_PORT_IN = int(sys.argv[2])
        print(f"Listening on <addr>:<port> {TCP_IP_IN}:{TCP_PORT_IN}")
        dial_in()
    elif sys.argv[1] == "out":
        if arglen == 3:
            if ':' in sys.argv[2]:
                (a,p) = sys.argv[2].split(':')
                TCP_PORT_OUT=int(p)
                TCP_IP_OUT=a
            else:
                TCP_PORT_OUT = int(sys.argv[2])
        print(f"Dialing out to <addr>:<port> = {TCP_IP_OUT}:{TCP_PORT_OUT}")
        dial_out()
    else:
        print(f"Unknown parameter {sys.argv[2]}")
        
    
