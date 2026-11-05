//FOTOFX3A JOB (AXXXX),                                                 00000101
//         'MGROM',                                                     00000204
//         CLASS=A,                                                     00000304
//         MSGCLASS=X,                                                  00000404
//         MSGLEVEL=(1,1),                                              00000504
//         REGION=4096K,                                                00000604
//         NOTIFY=&SYSUID                                               00000704
/*JOBPARM  ROOM=MAIL                                                    00000804
//JOBPROC  DD DSN=DFHSIM.KICKSSYS.V1R5M0.PROCLIB,DISP=SHR               00000904
//COBOL    EXEC K2KCOBCS,KIKSUSR='EKATUS.KICKS'                         00001007
//COPY.SYSUT1 DD *                                                      00001104
       IDENTIFICATION DIVISION.                                         00001200
       PROGRAM-ID. FOTOFX3.                                             00001301
       ENVIRONMENT DIVISION.                                            00001400
       CONFIGURATION SECTION.                                           00001500
       SOURCE-COMPUTER. IBM-370.                                        00001600
       OBJECT-COMPUTER. IBM-370.                                        00001700
       DATA DIVISION.                                                   00001800
       WORKING-STORAGE SECTION.                                         00001900
       COPY FFXCOM.                                                     00002004
       COPY FFIXMSD.                                                    00002104
       COPY WTOMSG.                                                     00002204
       COPY DFHAID                                                      00002304
       COPY DFHBMSCA                                                    00002404
       01   WS-USERID                     PIC X(8) VALUE LOW-VALUE.     00002504
       LINKAGE SECTION.                                                 00002604
       01   DFHCOMMAREA PIC X(100).                                     00002704
       PROCEDURE DIVISION.                                              00002804
       MAIN.                                                            00002904
            IF EIBCALEN = 0                                             00003004
               MOVE LOW-VALUES TO WS-COMM                               00003104
               MOVE 'R' TO DISPATCH                                     00003201
               MOVE 'E' TO STDHFLAG                                     00003301
            ELSE                                                        00003404
               IF EIBCALEN NOT = LENGTH OF WS-COMM                      00003504
                  EXEC CICS ABEND ABCODE('COM3') END-EXEC               00003601
            ELSE                                                        00003704
               MOVE DFHCOMMAREA TO WS-COMM.                             00003804
           IF EIBAID = DFHPF3                                           00003908
              EXEC CICS                                                 00004008
                 XCTL PROGRAM('FOTOFIX')                                00004108
              END-EXEC.                                                 00004208
           IF EIBAID = DFHPF5                                           00004311
              MOVE 'R' TO DISPATCH                                      00004411
              MOVE 'E' TO STDHFLAG                                      00004512
              EXEC CICS                                                 00004611
                 XCTL PROGRAM('FOTOFX4') COMMAREA(WS-COMM)              00004711
              END-EXEC.                                                 00004811
           IF EIBAID = DFHPF4                                           00004911
              MOVE ' ' TO STDHFLAG.                                     00005011
              PERFORM SEND-MAP                                          00005111
              MOVE LOW-VALUE TO DISPATCH                                00005211
              IF ADMIN-FLAG = 'Y'                                       00005311
                 EXEC CICS                                              00005411
                      WRITE OPERATOR TEXT('SHUTDOWN FFIX')              00005511
                 END-EXEC                                               00005611
                 EXEC CICS                                              00005711
                   XCTL PROGRAM('KSSFPGM')                              00005811
                 END-EXEC.                                              00005911
               PERFORM ADMIN-CHECK.                                     00006011
           IF DISPATCH = 'R'                                            00006101
              MOVE ' ' TO STDHFLAG.                                     00006211
              PERFORM SEND-MAP                                          00006301
              MOVE LOW-VALUE TO DISPATCH                                00006401
              EXEC CICS                                                 00006501
                 RETURN TRANSID('FFX3') COMMAREA(WS-COMM)               00006601
              END-EXEC.                                                 00006701
           IF EIBAID = DFHCLEAR                                         00006804
              MOVE 'E' TO STDHFLAG                                      00006901
              PERFORM SEND-MAP                                          00007001
              EXEC CICS                                                 00007101
                 RETURN TRANSID('FFX3') COMMAREA(WS-COMM)               00007201
              END-EXEC.                                                 00007301
           IF EIBAID = DFHENTER                                         00007404
              EXEC CICS                                                 00007501
                 RETURN TRANSID('FFX3') COMMAREA(WS-COMM)               00007601
              END-EXEC.                                                 00007701
           IF EIBAID NOT = DFHENTER                                     00007804
              IF EIBAID NOT = DFHPF3                                    00007904
                 IF EIBAID NOT = DFHPF4                                 00008001
                    PERFORM SEND-ERROR.                                 00008104
           EXEC CICS RETURN TRANSID('FFX3')                             00008201
              COMMAREA(WS-COMM)                                         00008304
           END-EXEC.                                                    00008404
       ADMIN-CHECK.                                                     00008506
           MOVE 'ADMIN RECHTE ERFORDERLICH' TO ERRMSG4O.                00008610
           EXEC CICS                                                    00008706
                SEND MAP('FFIXMEX') MAPSET('FFIXMSD')                   00008806
                   FREEKB                                               00008911
           END-EXEC.                                                    00009010
           EXEC CICS RETURN TRANSID('FFX3')                             00009110
              COMMAREA(WS-COMM)                                         00009210
           END-EXEC.                                                    00009310
       HEADER.                                                          00009404
           IF STDHFLAG NOT = 'X'                                        00009504
              EXEC CICS SEND CONTROL ERASE END-EXEC.                    00009604
           MOVE 'FOTOFX3' TO TPROGID                                    00009701
           EXEC CICS LINK PROGRAM('STDHCOB') COMMAREA(WS-COMM)          00009804
           END-EXEC.                                                    00009904
           MOVE 'X' TO STDHFLAG.                                        00010004
       SEND-MAP.                                                        00010104
           PERFORM HEADER.                                              00010204
           MOVE LOW-VALUES TO FFIXMEXO                                  00010304
           EXEC CICS                                                    00010404
                SEND MAP('FFIXMEX') MAPSET('FFIXMSD')                   00010501
                   FREEKB                                               00010604
           END-EXEC.                                                    00010704
       SEND-ERROR.                                                      00010804
            MOVE 'UNGUELTIGE FUNKTIONSTASTE' TO ERRMSG4O.               00010904
            EXEC CICS SEND MAP('FFIXMEX') MAPSET('FFIXMSD')             00011001
                 DATAONLY                                               00011104
            END-EXEC.                                                   00011204
/*                                                                      00011304
//LKED.SYSIN  DD *                                                      00011404
 INCLUDE SKIKLOAD(KIKCOBGL)                                             00011504
 ENTRY FOTOFX3                                                          00011601
 NAME FOTOFX3(R)                                                        00011701
/*                                                                      00011804
