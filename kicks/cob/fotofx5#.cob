//FOTOFX5A JOB (AXXXX),                                                 00000101
//         'MGROM',                                                     00000202
//         CLASS=A,                                                     00000302
//         MSGCLASS=X,                                                  00000402
//         MSGLEVEL=(1,1),                                              00000502
//         REGION=4096K,                                                00000602
//         NOTIFY=&SYSUID                                               00000702
/*JOBPARM  ROOM=MAIL                                                    00000802
//JOBPROC  DD DSN=DFHSIM.KICKSSYS.V1R5M0.PROCLIB,DISP=SHR               00000902
//COBOL    EXEC K2KCOBCS,KIKSUSR='EKATUS.KICKS'                         00001002
//COPY.SYSUT1 DD *                                                      00001102
       IDENTIFICATION DIVISION.                                         00001200
       PROGRAM-ID. FOTOFX5.                                             00001301
       ENVIRONMENT DIVISION.                                            00001400
       CONFIGURATION SECTION.                                           00001500
       SOURCE-COMPUTER. IBM-370.                                        00001600
       OBJECT-COMPUTER. IBM-370.                                        00001700
       DATA DIVISION.                                                   00001800
       WORKING-STORAGE SECTION.                                         00001900
       77  WS-ABSTIME          PIC S9(15) COMP-3.                       00002002
       COPY FFXCOM.                                                     00002102
       COPY FFIXMSD.                                                    00002200
       COPY WTOMSG.                                                     00002302
       COPY FFIXREC.                                                    00002403
       COPY DFHAID                                                      00002500
       COPY DFHBMSCA                                                    00002600
       01   VSAM-FUNCT         PIC X(2) VALUE 'AL'.                     00002702
       01   VSAM-DDNAME        PIC X(8) VALUE 'FFIXORD'.                00002802
       01   VSAM-DSNAME   PIC X(44) VALUE 'FOTOFIX.ORDERBK.CLUSTER'.    00002902
       01   WS-ERR-MSG.                                                 00003000
            05  FILLER                    PIC X(25)                     00003100
                                      VALUE 'VSAM WRITE ERROR. RESP = '.00003200
            05  WS-ERR-RESP-DISP          PIC 9(4).                     00003300
            05  FILLER                    PIC X VALUE '/'.              00003400
            05  WS-ERR-RESP2-DISP         PIC 9(4).                     00003500
            05  FILLER                    PIC X(11) VALUE ' CHECK FCT.'.00003600
       01   WS-FLAGS.                                                   00003700
            05 WS-RESP                    PIC 9(4) COMP VALUE 0.        00003800
            05 WS-RESP2                   PIC 9(4) COMP VALUE 0.        00003900
       COPY FFIXREC.                                                    00004002
       01   WS-CONSTANTS.                                               00004100
            05  END-TEXT                  PIC X(04) VALUE 'FFIX'.       00004200
            05  WS-REC-LEN                PIC 9(4) COMP VALUE 80.       00004300
            05  WS-MSG-LEN                PIC 9(4) COMP VALUE 22.       00004400
       LINKAGE SECTION.                                                 00004500
       01   DFHCOMMAREA PIC X(100).                                     00004600
       PROCEDURE DIVISION.                                              00004700
       MAIN.                                                            00004800
            IF EIBCALEN = 0                                             00004902
               EXEC CICS                                                00005002
                  ABEND ABCODE('COM5')                                  00005101
               END-EXEC                                                 00005202
            ELSE                                                        00005302
               MOVE DFHCOMMAREA TO WS-COMM.                             00005402
            MOVE EIBTRMID TO VSAM-TERM.                                 00005502
            MOVE EIBSYSID TO VSAM-SYSID.                                00005602
            EXEC CICS ASSIGN USERID(VSAM-USERID) END-EXEC.              00005702
            MOVE ORDERNUM TO WTO-ORD.                                   00005802
            MOVE 'FOTOFX5' TO WTO-PROG.                                 00005901
            EXEC CICS WRITE OPERATOR TEXT(WTO-MSG)                      00006002
            END-EXEC.                                                   00006102
            PERFORM PROCESS-INPUT.                                      00006202
            EXEC CICS                                                   00006302
               RETURN                                                   00006402
            END-EXEC.                                                   00006502
        PROCESS-INPUT.                                                  00006602
            EXEC CICS ASKTIME ABSTIME(WS-ABSTIME) END-EXEC.             00006702
            EXEC CICS FORMATTIME ABSTIME(WS-ABSTIME)                    00006802
             TIME(VSAM-ORDER-TIME) TIMESEP(':')                         00006902
            END-EXEC.                                                   00007002
            EXEC CICS FORMATTIME ABSTIME(WS-ABSTIME)                    00007102
              YYYYMMDD(VSAM-ORDER-DATE) DATESEP('-')                    00007202
            END-EXEC.                                                   00007302
            MOVE ORDERNUM TO VSAM-LAUFZN.                               00007402
            MOVE DELFLAG TO VSAM-DEL.                                   00007502
            MOVE EIBTIME TO VSAM-SEQ.                                   00007602
            MOVE 'AL' TO VSAM-FUNCT.                                    00007702
            CALL 'DYNALLC' USING VSAM-FUNCT, VSAM-DDNAME, VSAM-DSNAME.  00007802
            MOVE SPACES TO VSAM-KEY.                                    00007901
            MOVE 'O' TO VSAM-STAT.                                      00008003
            EXEC CICS                                                   00008101
                 STARTBR FILE(VSAM-DDNAME)                              00008201
                 RIDFLD(VSAM-KEY) KEYLENGTH(16)                         00008301
                 GTEQ                                                   00008401
                 RESP(WS-RESP)                                          00008501
                 RESP2(WS-RESP2)                                        00008601
            END-EXEC.                                                   00008701
            PERFORM CHCK-BLANK UNTIL WS-EOF = 1.                        00008801
            EXEC CICS ENDBR FILE(VSAM-DDNAME)                           00008901
                 RESP(RC-1)                                             00009002
                 RESP2(RC-2)                                            00009102
            END-EXEC.                                                   00009202
            MOVE 'FL' TO VSAM-FUNCT.                                    00009302
            CALL 'DYNALLC' USING VSAM-FUNCT, VSAM-DDNAME, VSAM-DSNAME.  00009402
            EXEC CICS                                                   00009501
                 RETURN                                                 00009601
            END-EXEC.                                                   00009701
        CHCK-BLANK.                                                     00009803
            EXEC CICS                                                   00009901
                 READ FILE(VSAM-DDNAME)                                 00010001
                 INTO(VSAM-REC)                                         00010101
                 RIDFLD(VSAM-KEY) KEYLENGTH(16)                         00010201
                 GTEQ UPDATE                                            00010303
                 RESP(WS-RESP)                                          00010401
            END-EXEC.                                                   00010501
            IF WS-RESP = DFHRESP(ENDFILE)                               00010603
               MOVE 1 TO WS-EOF.                                        00010701
            IF VSAM-LAUFZNR = SPACES                                    00010801
               EXEC CICS DELETE FILE(VSAM-DDNAME)                       00010901
               RIDFLD(VSAM-KEY) KEYLENGTH(16)                           00011001
            END-EXEC.                                                   00011101
/*                                                                      00011202
//LKED.SYSLIB DD                                                        00011302
//            DD DSN=EKATUS.LOADLIB(DYNALLC),DISP=SHR                   00011402
 INCLUDE SKIKLOAD(KIKCOBGL)                                             00011502
 ENTRY FOTOFX5                                                          00011602
 NAME FOTOFX5(R)                                                        00011702
/*                                                                      00011802
