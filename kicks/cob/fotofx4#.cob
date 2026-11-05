//FOTOFX4A JOB (AXXXX),                                                 00000101
//         'MGROM',                                                     00000201
//         CLASS=A,                                                     00000301
//         MSGCLASS=X,                                                  00000401
//         MSGLEVEL=(1,1),                                              00000501
//         REGION=4096K,                                                00000601
//         NOTIFY=&SYSUID                                               00000701
/*JOBPARM  ROOM=MAIL                                                    00000801
//JOBPROC  DD DSN=DFHSIM.KICKSSYS.V1R5M0.PROCLIB,DISP=SHR               00000901
//COBOL    EXEC K2KCOBCS,KIKSUSR='EKATUS.KICKS'                         00001001
//COPY.SYSUT1 DD *                                                      00001101
       IDENTIFICATION DIVISION.                                         00001200
       PROGRAM-ID. FOTOFX4.                                             00001301
       ENVIRONMENT DIVISION.                                            00001401
       CONFIGURATION SECTION.                                           00001500
       SOURCE-COMPUTER. IBM-370.                                        00001600
       OBJECT-COMPUTER. IBM-370.                                        00001700
       DATA DIVISION.                                                   00001800
       WORKING-STORAGE SECTION.                                         00001900
       COPY FFXCOM.                                                     00002001
       COPY FFXRAKF.                                                    00002101
       COPY FFIXMSD.                                                    00002201
       COPY WTOMSG.                                                     00002301
       COPY DFHAID                                                      00002401
       COPY DFHBMSCA                                                    00002501
       LINKAGE SECTION.                                                 00002601
       01   DFHCOMMAREA PIC X(100).                                     00002701
       PROCEDURE DIVISION.                                              00002801
       MAIN.                                                            00002901
            IF EIBCALEN = 0                                             00003001
               MOVE LOW-VALUES TO WS-COMM                               00003101
               MOVE 'I' TO DISPATCH                                     00003202
               MOVE 'E' TO STDHFLAG                                     00003301
            ELSE                                                        00003401
               IF EIBCALEN NOT = LENGTH OF WS-COMM                      00003501
                  EXEC CICS ABEND ABCODE('COM4') END-EXEC               00003601
            ELSE                                                        00003701
               MOVE DFHCOMMAREA TO WS-COMM.                             00003801
           IF EIBAID = DFHPF3                                           00003901
               MOVE 'R' TO DISPATCH                                     00004001
               MOVE 'E' TO STDHFLAG                                     00004101
              EXEC CICS                                                 00004201
                 XCTL PROGRAM('FOTOFX3')                                00004301
              END-EXEC.                                                 00004401
           IF DISPATCH = 'R'                                            00004501
              PERFORM SEND-MAP                                          00004601
              MOVE LOW-VALUE TO DISPATCH                                00004701
              EXEC CICS                                                 00004801
                 RETURN TRANSID('FFX4') COMMAREA(WS-COMM)               00004901
              END-EXEC.                                                 00005001
           IF EIBAID = DFHCLEAR                                         00005101
              MOVE 'E' TO STDHFLAG                                      00005201
              PERFORM SEND-MAP                                          00005301
              EXEC CICS                                                 00005401
                 RETURN TRANSID('FFX4') COMMAREA(WS-COMM)               00005501
              END-EXEC.                                                 00005601
           IF EIBAID = DFHPF2                                           00005701
              EXEC CICS                                                 00005801
                   WRITE OPERATOR TEXT('PASSWORD CHECK')                00005901
              END-EXEC                                                  00006001
              PERFORM PROCESS-SECTION                                   00006102
              PERFORM PW-CHECK.                                         00006201
           IF EIBAID = DFHENTER                                         00006301
              PERFORM PROCESS-SECTION                                   00006402
              EXEC CICS                                                 00006501
                 RETURN TRANSID('FFX4') COMMAREA(WS-COMM)               00006601
              END-EXEC.                                                 00006701
           IF EIBAID NOT = DFHENTER                                     00006801
              IF EIBAID NOT = DFHPF3                                    00006901
                 IF EIBAID NOT = DFHPF2                                 00007001
                    PERFORM SEND-ERROR.                                 00007101
           EXEC CICS RETURN TRANSID('FFX4')                             00007201
              COMMAREA(WS-COMM)                                         00007301
           END-EXEC.                                                    00007401
       PW-CHECK.                                                        00007501
           MOVE FFXPASSI TO WS-PASSWORD.                                00007603
           MOVE 'EKATUS' TO WS-USERID.                                  00007704
           MOVE 'PWCHECK' TO WS-REQUEST.                                00007803
           EXEC CICS                                                    00007901
              LINK PROGRAM('FOTORAKF') COMMAREA(WS-RAKF)                00008001
           END-EXEC.                                                    00008101
           EXEC CICS                                                    00008201
              WRITE OPERATOR TEXT(WS-RAKF)                              00008301
           END-EXEC.                                                    00008401
           IF WS-RETCODE = 'OK'                                         00008501
              MOVE 'Y' TO ADMIN-FLAG                                    00008601
              EXEC CICS                                                 00008701
                 XCTL PROGRAM('FOTOFX3') COMMAREA(WS-COMM)              00008801
              END-EXEC.                                                 00008901
           MOVE 'ANMELDUNG NICHT ERFOLGREICH' TO                        00009001
              ERRMSG5O.                                                 00009101
           EXEC CICS                                                    00009201
              SEND MAP('FFIXADM') MAPSET('FFIXMSD') DATAONLY FREEKB     00009301
           END-EXEC.                                                    00009401
           EXEC CICS                                                    00009501
              RETURN TRANSID('FFX4') COMMAREA(WS-COMM)                  00009601
           END-EXEC.                                                    00009701
       PROCESS-SECTION.                                                 00009802
           IF DISPATCH = 'X'                                            00009902
              PERFORM RECEIVE-MAP                                       00010002
           ELSE                                                         00010102
              IF DISPATCH = 'I'                                         00010202
                 PERFORM SEND-MAP.                                      00010302
           MOVE 'X' TO DISPATCH.                                        00010402
       HEADER.                                                          00010501
           IF STDHFLAG NOT = 'X'                                        00010601
              EXEC CICS SEND CONTROL ERASE END-EXEC.                    00010701
           MOVE 'FOTOFX4' TO TPROGID                                    00010801
           EXEC CICS LINK PROGRAM('STDHCOB') COMMAREA(WS-COMM)          00010901
           END-EXEC.                                                    00011001
           MOVE 'X' TO STDHFLAG.                                        00011101
       RECEIVE-MAP.                                                     00011202
           MOVE LOW-VALUES TO FFIXADMO.                                 00011302
           MOVE WS-BUF-8 TO FFXPASSO.                                   00011402
           EXEC CICS                                                    00011502
              RECEIVE MAP('FFIXADM') MAPSET('FFIXMSD')                  00011602
           END-EXEC.                                                    00011702
           PERFORM HEADER.                                              00011802
           MOVE FFXPASSI TO WS-BUF-8.                                   00011902
           EXEC CICS                                                    00012002
              SEND MAP('FFIXADM') MAPSET('FFIXMSD') DATAONLY            00012102
           END-EXEC.                                                    00012202
       SEND-MAP.                                                        00012301
           PERFORM HEADER.                                              00012401
           MOVE LOW-VALUES TO FFIXADMO.                                 00012501
           MOVE FFXPASSI TO FFXPASSO.                                   00012601
           EXEC CICS                                                    00012701
                SEND MAP('FFIXADM') MAPSET('FFIXMSD')                   00012801
                   FREEKB                                               00012901
           END-EXEC.                                                    00013001
       SEND-ERROR.                                                      00013101
            MOVE 'UNGUELTIGE FUNKTIONSTASTE' TO ERRMSG5O.               00013202
            EXEC CICS SEND MAP('FFIXADM') MAPSET('FFIXMSD')             00013302
                 DATAONLY                                               00013401
            END-EXEC.                                                   00013501
/*                                                                      00013601
//LKED.SYSIN  DD *                                                      00013701
 INCLUDE SKIKLOAD(KIKCOBGL)                                             00013801
 ENTRY FOTOFX4                                                          00013901
 NAME FOTOFX4(R)                                                        00014001
/*                                                                      00014101
