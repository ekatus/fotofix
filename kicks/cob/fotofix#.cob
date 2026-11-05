//FOTOFIXA JOB (AXXXX),                                                 00000119
//         'MGROM',                                                     00000219
//         CLASS=A,                                                     00000319
//         MSGCLASS=X,                                                  00000419
//         MSGLEVEL=(1,1),                                              00000519
//         REGION=4096K,                                                00000619
//         NOTIFY=&SYSUID                                               00000719
/*JOBPARM  ROOM=MAIL                                                    00000819
//JOBPROC  DD DSN=DFHSIM.KICKSSYS.V1R5M0.PROCLIB,DISP=SHR               00000919
//COBOL    EXEC K2KCOBCS,KIKSUSR='EKATUS.KICKS'                         00001028
//COPY.SYSUT1 DD *                                                      00001119
       IDENTIFICATION DIVISION.                                         00001200
       PROGRAM-ID. FOTOFIX.                                             00001301
       ENVIRONMENT DIVISION.                                            00001400
       CONFIGURATION SECTION.                                           00001500
       SOURCE-COMPUTER. IBM-370.                                        00001600
       OBJECT-COMPUTER. IBM-370.                                        00001700
       DATA DIVISION.                                                   00001800
       WORKING-STORAGE SECTION.                                         00001900
       COPY FFXCOM.                                                     00002006
       COPY FFXRAKF.                                                    00002126
       COPY FFIXMSL.                                                    00002205
       COPY DFHAID                                                      00002300
       COPY DFHBMSCA                                                    00002400
       01   DY-PARAMS.                                                  00002532
            05 DY-FUNC                    PIC X(2) VALUE 'AN'.          00002632
            05 DY-DDNAME                  PIC X(8) VALUE 'FFIXORD'.     00002732
            05 DY-DSNAME   PIC X(44) VALUE 'FOTOFIX.ORDERBK.CLUSTER'.   00002832
       01   WS-FIRST                      PIC X(1) VALUE 'Y'.           00002929
       01   MSG                           PIC X(40) VALUE LOW-VALUE.    00003023
       LINKAGE SECTION.                                                 00003100
       01   DFHCOMMAREA PIC X(100).                                     00003200
       PROCEDURE DIVISION.                                              00003300
       MAIN.                                                            00003400
            IF EIBCALEN = 0                                             00003505
               MOVE LOW-VALUES TO WS-COMM                               00003605
               MOVE 'DE' TO LANGUAGE                                    00003721
               PERFORM DEALLOC                                          00003832
            ELSE                                                        00003905
            IF EIBCALEN NOT = LENGTH OF WS-COMM                         00004005
               EXEC CICS ABEND ABCODE('COMM') END-EXEC                  00004105
            ELSE                                                        00004205
               MOVE 'N' TO WS-FIRST                                     00004329
               MOVE DFHCOMMAREA TO WS-COMM.                             00004405
            EXEC CICS ASSIGN USERID(WS-USERID) END-EXEC.                00004523
            IF WS-FIRST = 'Y'                                           00004629
               PERFORM CHECK-RAKF.                                      00004729
            IF EIBAID = DFHCLEAR                                        00004805
               MOVE 'R' TO DISPATCH                                     00004926
               MOVE 'E' TO STDHFLAG                                     00005026
               EXEC CICS                                                00005126
                  XCTL PROGRAM('FOTOFX3') COMMAREA(WS-COMM)             00005226
               END-EXEC.                                                00005326
            IF EIBAID = DFHENTER                                        00005427
               EXEC CICS                                                00005528
                  WRITE OPERATOR TEXT('[FFIX]NORMAL STARTUP')           00005631
               END-EXEC                                                 00005729
               IF WS-FIRST = 'N'                                        00005829
                  MOVE 'I' TO DISPATCH                                  00005929
                  MOVE 'E' TO STDHFLAG                                  00006029
                  EXEC CICS                                             00006129
                     XCTL PROGRAM('FOTOFX0') COMMAREA(WS-COMM)          00006229
                  END-EXEC.                                             00006329
            PERFORM INITIAL-DISPLAY.                                    00006426
            EXEC CICS                                                   00006526
               RETURN TRANSID('FFIX') COMMAREA(WS-COMM)                 00006626
            END-EXEC.                                                   00006726
       CHECK-RAKF.                                                      00006829
           EXEC CICS                                                    00006929
                LINK PROGRAM('FOTORAKF')                                00007029
                COMMAREA(WS-RAKF)                                       00007129
           END-EXEC.                                                    00007229
           IF WS-RETCODE = 'OK'                                         00007329
              MOVE 'Y' TO ADMIN-FLAG                                    00007429
           ELSE                                                         00007529
              MOVE 'N' TO ADMIN-FLAG.                                   00007629
           EXEC CICS                                                    00007729
                WRITE OPERATOR TEXT(WS-RAKF)                            00007829
           END-EXEC.                                                    00007929
       INITIAL-DISPLAY.                                                 00008026
           EXEC CICS SEND MAP('FFIXLOGA') MAPSET('FFIXMSL')             00008126
                CURSOR                                                  00008226
                ERASE                                                   00008326
           END-EXEC.                                                    00008426
       DEALLOC.                                                         00008532
           MOVE 'FN' TO DY-FUNC.                                        00008632
           CALL 'DYNALLC' USING DY-FUNC, DY-DDNAME, DY-DSNAME.          00008732
/*                                                                      00008832
//LKED.SYSLIB DD                                                        00008932
//            DD DSN=EKATUS.LOADLIB(DYNALLC),DISP=SHR                   00009032
//LKED.SYSIN  DD *                                                      00009119
 INCLUDE SKIKLOAD(KIKCOBGL)                                             00009219
 ENTRY FOTOFIX                                                          00009319
 NAME FOTOFIX(R)                                                        00009419
/*                                                                      00009519
