import asyncio
import logging

logging.basicConfig(level=logging.INFO, format="%(asctime)s [%(levelname)s] %(message)s")

# --- KONFIGURATION ---
LISTEN_HOST = "0.0.0.0"
LISTEN_PORT = 2706
DEST_HOST = "127.0.0.1"
DEST_PORT = 2705

MAX_BUFFER_PACKETS = 1000  # Max. Anzahl an Datenpaketen in der Queue (OOM-Schutz)
RETRY_INTERVAL = 2.0       # Sekunden zwischen den Wiederholungsversuchen


async def handle_client(client_reader, client_writer):
    client_addr = client_writer.get_extra_info('peername')
    logging.info(f"Client verbunden: {client_addr}")

    # Queue für Daten vom Client zur Destination
    client_to_dest_queue = asyncio.Queue(maxsize=MAX_BUFFER_PACKETS)
    
    # Event, das signalisiert, ob die Destination-Verbindung aktuell bereit ist
    dest_ready_event = asyncio.Event()
    
    # Zustandshalter für den aktuellen Destination_Writer
    dest_writer_box = [None]

    # Task 1: Liest kontinuierlich vom Client und packt es in die Queue
    async def read_from_client():
        try:
            while True:
                data = await client_reader.read(4096)
                if not data:
                    logging.info(f"Client {client_addr} hat die Verbindung geschlossen.")
                    break
                
                # Wenn die Queue voll ist, blockiert dies hier (Backpressure)
                await client_to_dest_queue.put(data)
        except Exception as e:
            logging.error(f"Fehler beim Lesen vom Client {client_addr}: {e}")
        finally:
            # Signalisiere das Ende der Client-Verbindung
            await client_to_dest_queue.put(None)

    # Task 2: Versucht die Verbindung zur Destination zu halten/wiederherzustellen
    async def maintain_destination_connection():
        while True:
            try:
                logging.info(f"Verbinde zu Destination {DEST_HOST}:{DEST_PORT}...")
                dest_reader, dest_writer = await asyncio.open_connection(DEST_HOST, DEST_PORT)
                logging.info(f"Erfolgreich mit Destination verbunden für Client {client_addr}.")
                
                dest_writer_box[0] = dest_writer
                dest_ready_event.set()  # Signalisiert Task 3, dass gesendet werden kann

                # Hilfs-Task: Liest von Destination und leitet direkt an den Client weiter
                async def read_from_dest():
                    try:
                        while True:
                            data = await dest_reader.read(4096)
                            if not data:
                                logging.warning("Destination hat die Verbindung geschlossen.")
                                break
                            client_writer.write(data)
                            await client_writer.drain()
                    except Exception as e:
                        logging.error(f"Fehler beim Lesen von Destination: {e}")
                    finally:
                        dest_ready_event.clear()

                    # Starte den Lese-Loop für die Destination
                await read_from_dest()

            except (ConnectionRefusedError, OSError, asyncio.TimeoutError) as e:
                logging.warning(f"Destination nicht erreichbar ({e}). Erneuter Versuch in {RETRY_INTERVAL}s...")
                dest_ready_event.clear()
                if dest_writer_box[0]:
                    try:
                        dest_writer_box[0].close()
                    except: pass
                    dest_writer_box[0] = None
                
                # Prüfen, ob der Client überhaupt noch da ist. Wenn nicht, können wir abbrechen.
                if client_writer.is_closing():
                    break
                
                await asyncio.sleep(RETRY_INTERVAL)
            
            if client_writer.is_closing():
                break

    # Task 3: Nimmt Daten aus der Queue und sendet sie an die Destination (sofern bereit)
    async def write_to_destination():
        try:
            while True:
                data = await client_to_dest_queue.get()
                if data is None:
                    # Client hat geschlossen, wir sind fertig
                    break
                
                # Warten, bis die Destination-Verbindung (wieder) bereit ist
                await dest_ready_event.wait()
                
                try:
                    writer = dest_writer_box[0]
                    if writer:
                        writer.write(data)
                        await writer.drain()
                except Exception as e:
                    logging.error(f"Senden an Destination fehlgeschlagen: {e}. Daten gehen zurück in die Queue.")
                    # Paket wieder ganz vorne anstellen oder Event abwarten. 
                    # Um die Reihenfolge zu wahren, simulieren wir hier das Warten auf den Reconnect.
                    dest_ready_event.clear()
                    # Wir warten kurz und lassen die Schleife das Paket beim nächsten Versuch senden
                    await dest_ready_event.wait()
                    if dest_writer_box[0]:
                        dest_writer_box[0].write(data)
                        await dest_writer_box[0].drain()
                
                client_to_dest_queue.task_done()
        except Exception as e:
            logging.error(f"Fehler im Destination-Writer-Loop: {e}")

    # Starte alle drei Sub-Tasks parallel für diesen Client
    client_reader_task = asyncio.create_task(read_from_client())
    dest_maintenance_task = asyncio.create_task(maintain_destination_connection())
    dest_writer_task = asyncio.create_task(write_to_destination())

    # Warten, bis der Client-Reader fertig ist (Client hat die Verbindung geschlossen)
    await client_reader_task
    
    # Aufräumen
    dest_maintenance_task.cancel()
    dest_writer_task.cancel()
    
    if dest_writer_box[0]:
        dest_writer_box[0].close()
        await dest_writer_box[0].wait_closed()
        
    client_writer.close()
    await client_writer.wait_closed()
    logging.info(f"Verbindung für Client {client_addr} vollständig beendet.")


async def main():
    server = await asyncio.start_server(handle_client, LISTEN_HOST, LISTEN_PORT)
    addr = server.sockets[0].getsockname()
    logging.info(f"Proxy läuft auf {addr}")

    async with server:
        await server.serve_forever()

if __name__ == "__main__":
    try:
        asyncio.run(main())
    except KeyboardInterrupt:
        logging.info("Proxy manuell gestoppit.")
