//FOTORAKF JOB (AXXXX),                                                 00000101
//         'MGROM',                                                     00000201
//         CLASS=A,                                                     00000301
//         MSGCLASS=X,                                                  00000401
//         MSGLEVEL=(1,1),                                              00000501
//         REGION=4096K,                                                00000601
//         NOTIFY=&SYSUID                                               00000701
/*JOBPARM  ROOM=MAIL                                                    00000801
//JOBPROC  DD DSN=DFHSIM.KICKSSYS.V1R5M0.PROCLIB,DISP=SHR               00000901
//COBOL    EXEC K2KCOBCS,KIKSUSR='EKATUS.KICKS'                         00001002
//COPY.SYSUT1 DD *                                                      00001101
       IDENTIFICATION DIVISION.                                         00001200
       PROGRAM-ID. FOTORAKF.                                            00001301
       ENVIRONMENT DIVISION.                                            00001400
       CONFIGURATION SECTION.                                           00001500
       SOURCE-COMPUTER. IBM-370.                                        00001600
       OBJECT-COMPUTER. IBM-370.                                        00001700
       DATA DIVISION.                                                   00001800
       WORKING-STORAGE SECTION.                                         00001900
       COPY FFXRAKF.                                                    00002001
       COPY DFHAID                                                      00002101
       COPY DFHBMSCA                                                    00002201
       LINKAGE SECTION.                                                 00002301
       01   DFHCOMMAREA PIC X(24).                                      00002404
       PROCEDURE DIVISION.                                              00002501
       MAIN.                                                            00002601
            IF EIBCALEN = 0                                             00002701
               MOVE LOW-VALUES TO WS-RAKF                               00002801
               MOVE 'ADMIN' TO WS-GROUPNAM                              00002901
            ELSE                                                        00003001
               IF EIBCALEN NOT = LENGTH OF WS-RAKF                      00003101
                  EXEC CICS ABEND ABCODE('RAKF') END-EXEC               00003201
            ELSE                                                        00003301
               MOVE DFHCOMMAREA TO WS-RAKF.                             00003401
           CALL 'RAKFCHK' USING WS-RETCODE, WS-GROUPNAM, WS-USERID.     00003503
           MOVE WS-RAKF TO DFHCOMMAREA.                                 00003602
           EXEC CICS                                                    00003704
             RETURN                                                     00003804
           END-EXEC.                                                    00003901
/*                                                                      00004001
//LKED.SYSLIB DD                                                        00004101
//            DD DSN=EKATUS.LOADLIB(RAKFCHK),DISP=SHR                   00004201
//LKED.SYSIN  DD *                                                      00004301
 INCLUDE SKIKLOAD(KIKCOBGL)                                             00004401
 ENTRY FOTORAKF                                                         00004501
 NAME FOTORAKF(R)                                                       00004601
/*                                                                      00004701
