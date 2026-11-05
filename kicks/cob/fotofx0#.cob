//FOTOFX0A JOB (AXXXX),                                                 00000160
//         'MGROM',                                                     00000260
//         CLASS=A,                                                     00000360
//         MSGCLASS=X,                                                  00000460
//         MSGLEVEL=(1,1),                                              00000560
//         REGION=4096K,                                                00000660
//         NOTIFY=&SYSUID                                               00000760
/*JOBPARM  ROOM=MAIL                                                    00000860
//JOBPROC  DD DSN=DFHSIM.KICKSSYS.V1R5M0.PROCLIB,DISP=SHR               00000960
//COBOL    EXEC K2KCOBCS,KIKSUSR='EKATUS.KICKS'                         00001084
//COPY.SYSUT1 DD *                                                      00001160
       IDENTIFICATION DIVISION.                                         00001200
       PROGRAM-ID. FOTOFX0.                                             00001334
       ENVIRONMENT DIVISION.                                            00001400
       CONFIGURATION SECTION.                                           00001500
       SOURCE-COMPUTER. IBM-370.                                        00001600
       OBJECT-COMPUTER. IBM-370.                                        00001700
       DATA DIVISION.                                                   00001800
       WORKING-STORAGE SECTION.                                         00001900
       77   ORDER-OK-DE   PIC X(25) VALUE 'AUFTRAG ENTGEGEN GENOMMEN'.  00002068
       77   ORDER-OK-EN   PIC X(25) VALUE 'ORDER HAS BEEN ACCEPTED'.    00002168
       77   ORDER-NAK-DE  PIC X(25) VALUE 'FEHLER BEI AUFTRAG'.         00002268
       77   ORDER-NAK-EN  PIC X(25) VALUE 'ERROR SUBMITTING ORDER'.     00002368
       COPY FFXCOM.                                                     00002435
       COPY FFIXMSD.                                                    00002535
       COPY WTOMSG.                                                     00002672
       COPY DFHAID                                                      00002735
       COPY DFHBMSCA                                                    00002835
       01   WS-AUF-SAV                    PIC X(8) VALUE LOW-VALUE.     00002950
       01   WS-LOE-SAV                    PIC X(1) VALUE LOW-VALUE.     00003050
       01   WS-INFO.                                                    00003135
            05  TRANID                    PIC X(04) VALUE 'FFX0'.       00003235
            05  WS-MSG                    PIC X(40) VALUE LOW-VALUE.    00003335
            05  WS-MSG-LEN                PIC 9(4) COMP VALUE 40.       00003435
       LINKAGE SECTION.                                                 00003535
       01   DFHCOMMAREA PIC X(100).                                     00003635
       PROCEDURE DIVISION.                                              00003735
       MAIN.                                                            00003835
            IF EIBCALEN = 0                                             00003941
               MOVE LOW-VALUES TO WS-COMM                               00004041
               MOVE 'I' TO DISPATCH                                     00004157
            ELSE                                                        00004241
               IF EIBCALEN NOT = LENGTH OF WS-COMM                      00004361
                  EXEC CICS ABEND ABCODE('COM0') END-EXEC               00004461
            ELSE                                                        00004541
               MOVE DFHCOMMAREA TO WS-COMM.                             00004641
           IF EIBAID = DFHCLEAR                                         00004741
              MOVE 'R' TO DISPATCH                                      00004886
              MOVE 'E' TO STDHFLAG                                      00004986
              EXEC CICS                                                 00005086
                 XCTL PROGRAM('FOTOFX3') COMMAREA(WS-COMM)              00005186
              END-EXEC.                                                 00005286
      *       MOVE 'OPERATOR INTERVENTION' TO WS-MSG                    00005386
      *       EXEC CICS SEND TEXT FROM(WS-MSG) ERASE END-EXEC           00005486
      *       EXEC CICS RETURN END-EXEC.                                00005586
           IF EIBAID = DFHPF5 AND ADMIN-FLAG = 'Y'                      00005685
              MOVE 'B' TO DISPATCH                                      00005779
              MOVE ' ' TO STDHFLAG                                      00005879
              MOVE 'DE' TO LANGUAGE                                     00005979
              EXEC CICS                                                 00006070
                XCTL PROGRAM('FOTOFX2') COMMAREA(WS-COMM)               00006170
              END-EXEC.                                                 00006270
           IF EIBAID = DFHPF2                                           00006342
              PERFORM PROCESS-SECTION                                   00006473
              IF DISPATCH = 'X'                                         00006543
                 PERFORM WRITE-DATA                                     00006671
                 PERFORM POST-PROCESS                                   00006766
              ELSE                                                      00006859
                 EXEC CICS                                              00006959
                   RETURN TRANSID('FFIX')                               00007059
                 END-EXEC.                                              00007159
           IF EIBAID = DFHENTER                                         00007248
              PERFORM PROCESS-SECTION.                                  00007362
           IF EIBAID = DFHPF3                                           00007461
              EXEC CICS                                                 00007561
                 XCTL PROGRAM('FOTOFIX')                                00007661
              END-EXEC.                                                 00007762
           IF EIBAID NOT = DFHENTER                                     00007862
              IF EIBAID NOT = DFHPF3                                    00007962
                 IF EIBAID NOT = DFHPF2                                 00008062
                    PERFORM SEND-ERROR.                                 00008183
           EXEC CICS RETURN TRANSID('FFX0')                             00008241
              COMMAREA(WS-COMM)                                         00008355
           END-EXEC.                                                    00008441
       WRITE-DATA.                                                      00008571
           IF ORDERNUM = SPACES                                         00008688
              EXEC CICS                                                 00008788
                   RETURN                                               00008888
              END-EXEC.                                                 00008988
           MOVE ORDERNUM TO WTO-ORD.                                    00009072
           MOVE 'FOTOFX0' TO WTO-PROG.                                  00009173
           EXEC CICS WRITE OPERATOR TEXT(WTO-MSG) END-EXEC.             00009272
           EXEC CICS                                                    00009371
              LINK PROGRAM('FOTOFX1') COMMAREA(WS-COMM)                 00009471
           END-EXEC.                                                    00009571
       PROCESS-SECTION.                                                 00009662
           IF DISPATCH = 'X'                                            00009762
              PERFORM RECEIVE-MAP                                       00009862
           ELSE                                                         00009962
           IF DISPATCH = 'I'                                            00010062
              PERFORM SEND-MAP.                                         00010162
           MOVE 'X' TO DISPATCH.                                        00010262
       RECEIVE-MAP.                                                     00010357
           MOVE LOW-VALUES TO FFIXMAPO.                                 00010458
           MOVE WS-AUF-SAV TO LAUFZNO.                                  00010558
      *    MOVE WS-LOE-SAV TO DELFLAGO.                                 00010687
           EXEC CICS                                                    00010757
              RECEIVE MAP('FFIXMAP') MAPSET('FFIXMSD')                  00010857
           END-EXEC.                                                    00010958
           MOVE SPACES TO MESSAGEO.                                     00011063
           MOVE SPACES TO ERRMSGO.                                      00011163
           PERFORM HEADER.                                              00011263
           MOVE LAUFZNI TO WS-AUF-SAV.                                  00011358
           MOVE LAUFZNI TO WTO-ORD.                                     00011473
      *    MOVE DELFLAGI TO DELFLAG.                                    00011587
           MOVE LAUFZNI TO ORDERNUM.                                    00011674
           MOVE 'FX0-RECM' TO WTO-PROG                                  00011774
           EXEC CICS                                                    00011873
                WRITE OPERATOR TEXT(WTO-MSG)                            00011973
           END-EXEC.                                                    00012073
      *    IF DELFLAGI = 'Y'                                            00012187
      *       MOVE 'J' TO DELFLAGI.                                     00012287
      *    IF DELFLAGI NOT = 'J'                                        00012387
      *       MOVE 'N' TO DELFLAGI.                                     00012487
      *    MOVE DELFLAGI TO DELFLAGO.                                   00012587
      *    MOVE DELFLAGI  TO WS-LOE-SAV.                                00012687
           MOVE WS-AUF-SAV TO LAUFZNO.                                  00012774
      *    MOVE WS-LOE-SAV TO DELFLAGO.                                 00012887
           EXEC CICS SEND MAP('FFIXMAP') MAPSET('FFIXMSD')              00012964
              DATAONLY                                                  00013064
           END-EXEC.                                                    00013164
       HEADER.                                                          00013263
           IF STDHFLAG NOT = 'X'                                        00013363
              EXEC CICS SEND CONTROL ERASE END-EXEC.                    00013463
           MOVE 'FOTOFX0' TO TPROGID                                    00013563
           EXEC CICS LINK PROGRAM('STDHCOB') COMMAREA(WS-COMM)          00013663
           END-EXEC.                                                    00013763
           MOVE 'X' TO STDHFLAG.                                        00013863
       SEND-MAP.                                                        00013957
           PERFORM HEADER.                                              00014063
           MOVE LOW-VALUES TO FFIXMAPO.                                 00014185
           IF ADMIN-FLAG = 'Y'                                          00014285
              MOVE 'PF2=ABSENDEN PF3=VERLASSEN PF5=BEARBEITEN'          00014385
              TO PFKEYSO.                                               00014485
           EXEC CICS                                                    00014557
                SEND MAP('FFIXMAP') MAPSET('FFIXMSD')                   00014657
                   FREEKB                                               00014757
           END-EXEC.                                                    00014858
       POST-PROCESS.                                                    00014966
           MOVE RC-1 TO VSAMRC1O.                                       00015067
           MOVE RC-2 TO VSAMRC2O.                                       00015167
           IF RC-1 = 0 AND RC-2 = 0                                     00015267
              IF LANGUAGE = 'DE'                                        00015368
                 MOVE ORDER-OK-DE TO MESSAG2O                           00015468
              ELSE                                                      00015568
                 MOVE ORDER-OK-EN TO MESSAG2O                           00015668
           ELSE                                                         00015767
              IF LANGUAGE = 'DE'                                        00015868
                 MOVE ORDER-NAK-DE TO MESSAG2O                          00015968
              ELSE                                                      00016068
                 MOVE ORDER-NAK-EN TO MESSAG2O.                         00016168
           MOVE ' ' TO STDHFLAG.                                        00016268
           PERFORM HEADER.                                              00016368
           EXEC CICS                                                    00016466
              SEND MAP('FFIXMP2') MAPSET('FFIXMSD')                     00016566
                 FREEKB                                                 00016668
           END-EXEC.                                                    00016768
           MOVE 'I' TO DISPATCH.                                        00016868
           MOVE ' ' TO STDHFLAG.                                        00016969
           EXEC CICS                                                    00017066
             RETURN TRANSID('FFX0') COMMAREA(WS-COMM)                   00017168
           END-EXEC.                                                    00017266
       SEND-ERROR.                                                      00017357
            MOVE 'UNGUELTIGE FUNKTIONSTASTE' TO ERRMSGO.                00017457
            EXEC CICS SEND MAP('FFIXMAP') MAPSET('FFIXMSD')             00017557
                 DATAONLY                                               00017657
            END-EXEC.                                                   00017757
/*                                                                      00017860
//LKED.SYSIN  DD *                                                      00017960
 INCLUDE SKIKLOAD(KIKCOBGL)                                             00018060
 ENTRY FOTOFX0                                                          00018160
 NAME FOTOFX0(R)                                                        00018260
/*                                                                      00018360
