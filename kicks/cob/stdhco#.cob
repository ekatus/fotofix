       IDENTIFICATION DIVISION.                                         00000100
       PROGRAM-ID. STDHCOB.                                             00000200
       ENVIRONMENT DIVISION.                                            00000300
       CONFIGURATION SECTION.                                           00000400
       SOURCE-COMPUTER. IBM-370.                                        00000500
       OBJECT-COMPUTER. IBM-370.                                        00000600
       DATA DIVISION.                                                   00000700
       WORKING-STORAGE SECTION.                                         00000800
       77  WS-ABSTIME          PIC S9(15) COMP-3.                       00000900
       01  WS-COMM.                                                     00001000
           05  TTRANID         PIC X(4).                                00001100
           05  TPROGID         PIC X(8).                                00001200
           05  STDHFLAG        PIC X.                                   00001300
       COPY STDHMSD.                                                    00001400
       COPY DFHAID                                                      00001500
       COPY DFHBMSCA                                                    00001600
       LINKAGE SECTION.                                                 00001700
       01  DFHCOMMAREA PIC X(100).                                      00001800
       PROCEDURE DIVISION.                                              00001900
           IF EIBCALEN = 0                                              00002000
              MOVE LOW-VALUES TO WS-COMM                                00002100
              MOVE 'SMF0' TO TPROGID                                    00002200
           ELSE                                                         00002300
           IF EIBCALEN NOT = LENGTH OF WS-COMM                          00002400
              EXEC CICS ABEND ABCODE('COMM') END-EXEC                   00002500
           ELSE                                                         00002600
              MOVE DFHCOMMAREA TO WS-COMM.                              00002700
              IF EIBAID = DFHCLEAR                                      00002800
                 EXEC CICS RETURN END-EXEC.                             00002900
           PERFORM FILL-IN-MAP.                                         00003000
           MOVE 'X' TO STDHFLAG.                                        00003100
           EXEC CICS                                                    00003200
               XCTL PROGRAM(TPROGID) COMMAREA(WS-COMM)                  00003300
           END-EXEC.                                                    00003400
       FILL-IN-MAP SECTION.                                             00003500
           MOVE LOW-VALUES TO STDHMAPO.                                 00003600
           MOVE EIBTRNID TO FTRANIDO.                                   00003700
           EXEC CICS ASSIGN USERID(FUSERIDO) END-EXEC.                  00003800
           MOVE EIBTRMID TO FTERMIDO.                                   00003900
           MOVE EIBSYSID TO FSYSIDO.                                    00004000
           EXEC CICS ASKTIME ABSTIME(WS-ABSTIME) END-EXEC.              00004100
           EXEC CICS FORMATTIME ABSTIME(WS-ABSTIME)                     00004200
            TIME(FTIMEO) TIMESEP(':')                                   00004300
           END-EXEC.                                                    00004400
           EXEC CICS FORMATTIME ABSTIME(WS-ABSTIME)                     00004500
             MMDDYY(FDATEO) DATESEP('/')                                00004600
           END-EXEC.                                                    00004700
           EXEC CICS                                                    00004800
              SEND MAP('STDHMAP') MAPSET('STDHMSD') ERASE               00004900
           END-EXEC.                                                    00005000
       FILL-IN-MAP-EXIT.                                                00005100
           EXIT.                                                        00005200
