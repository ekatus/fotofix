//FOTOFX1A JOB (AXXXX),                                                 00000110
//         'MGROM',                                                     00000210
//         CLASS=A,                                                     00000310
//         MSGCLASS=X,                                                  00000410
//         MSGLEVEL=(1,1),                                              00000510
//         REGION=4096K,                                                00000610
//         NOTIFY=&SYSUID                                               00000710
/*JOBPARM  ROOM=MAIL                                                    00000810
//JOBPROC  DD DSN=DFHSIM.KICKSSYS.V1R5M0.PROCLIB,DISP=SHR               00000910
//COBOL    EXEC K2KCOBCS,KIKSUSR='EKATUS.KICKS'                         00001025
//COPY.SYSUT1 DD *                                                      00001110
       IDENTIFICATION DIVISION.                                         00001200
       PROGRAM-ID. FOTOFX1.                                             00001301
       ENVIRONMENT DIVISION.                                            00001400
       CONFIGURATION SECTION.                                           00001500
       SOURCE-COMPUTER. IBM-370.                                        00001600
       OBJECT-COMPUTER. IBM-370.                                        00001700
       DATA DIVISION.                                                   00001800
       WORKING-STORAGE SECTION.                                         00001900
       77  WS-ABSTIME          PIC S9(15) COMP-3.                       00002012
       COPY FFXCOM.                                                     00002106
       COPY FFIXMSD.                                                    00002200
       COPY WTOMSG.                                                     00002319
       COPY DFHAID                                                      00002400
       COPY DFHBMSCA                                                    00002500
       01   VSAM-FUNCT         PIC X(2) VALUE 'AL'.                     00002628
       01   VSAM-DDNAME        PIC X(8) VALUE 'FFIXORD'.                00002726
       01   VSAM-DSNAME   PIC X(44) VALUE 'FOTOFIX.ORDERBK.CLUSTER'.    00002824
       01   WS-ERR-MSG.                                                 00002900
            05  FILLER                    PIC X(25)                     00003000
                                      VALUE 'VSAM WRITE ERROR. RESP = '.00003100
            05  WS-ERR-RESP-DISP          PIC 9(4).                     00003200
            05  FILLER                    PIC X VALUE '/'.              00003300
            05  WS-ERR-RESP2-DISP         PIC 9(4).                     00003400
            05  FILLER                    PIC X(11) VALUE ' CHECK FCT.'.00003500
       01   WS-FLAGS.                                                   00003600
            05 WS-RESP                    PIC 9(4) COMP VALUE 0.        00003700
            05 WS-RESP2                   PIC 9(4) COMP VALUE 0.        00003800
       COPY FFIXREC.                                                    00003915
       01   WS-CONSTANTS.                                               00004000
            05  END-TEXT                  PIC X(04) VALUE 'FFIX'.       00004100
            05  WS-REC-LEN                PIC 9(4) COMP VALUE 80.       00004200
            05  WS-MSG-LEN                PIC 9(4) COMP VALUE 22.       00004300
       LINKAGE SECTION.                                                 00004400
       01   DFHCOMMAREA PIC X(100).                                     00004500
       PROCEDURE DIVISION.                                              00004600
       MAIN.                                                            00004700
            IF EIBCALEN = 0                                             00004813
               EXEC CICS                                                00004913
                  ABEND ABCODE('COM1')                                  00005017
               END-EXEC                                                 00005121
            ELSE                                                        00005221
               MOVE DFHCOMMAREA TO WS-COMM.                             00005321
            MOVE EIBTRMID TO VSAM-TERM.                                 00005408
            MOVE EIBSYSID TO VSAM-SYSID.                                00005508
            EXEC CICS ASSIGN USERID(VSAM-USERID) END-EXEC.              00005608
            MOVE ORDERNUM TO WTO-ORD.                                   00005719
            MOVE 'FOTOFX1' TO WTO-PROG.                                 00005820
            EXEC CICS WRITE OPERATOR TEXT(WTO-MSG)                      00005919
            END-EXEC.                                                   00006019
            PERFORM PROCESS-INPUT.                                      00006108
            EXEC CICS                                                   00006213
               RETURN                                                   00006313
            END-EXEC.                                                   00006408
        PROCESS-INPUT.                                                  00006502
            EXEC CICS ASKTIME ABSTIME(WS-ABSTIME) END-EXEC.             00006611
            EXEC CICS FORMATTIME ABSTIME(WS-ABSTIME)                    00006711
             TIME(VSAM-ORDER-TIME) TIMESEP(':')                         00006812
            END-EXEC.                                                   00006911
            EXEC CICS FORMATTIME ABSTIME(WS-ABSTIME)                    00007011
              YYYYMMDD(VSAM-ORDER-DATE) DATESEP('-')                    00007116
            END-EXEC.                                                   00007211
            MOVE ORDERNUM TO VSAM-LAUFZN.                               00007312
            MOVE DELFLAG TO VSAM-DEL.                                   00007418
            MOVE EIBTIME TO VSAM-SEQ.                                   00007513
            MOVE 'AL' TO VSAM-FUNCT.                                    00007628
            CALL 'DYNALLC' USING VSAM-FUNCT, VSAM-DDNAME, VSAM-DSNAME.  00007728
            EXEC CICS WRITE FILE(VSAM-DDNAME)                           00007826
                 FROM(VSAM-RECORD)                                      00007912
                 LENGTH(WS-REC-LEN)                                     00008012
                 KEYLENGTH(16)                                          00008112
                 RIDFLD(VSAM-KEY)                                       00008212
                 RESP(RC-1)                                             00008313
                 RESP2(RC-2)                                            00008413
            END-EXEC.                                                   00008513
            MOVE 'FL' TO VSAM-FUNCT.                                    00008628
            CALL 'DYNALLC' USING VSAM-FUNCT, VSAM-DDNAME, VSAM-DSNAME.  00008728
/*                                                                      00008810
//LKED.SYSLIB DD                                                        00008927
//            DD DSN=EKATUS.LOADLIB(DYNALLC),DISP=SHR                   00009028
 INCLUDE SKIKLOAD(KIKCOBGL)                                             00009110
 ENTRY FOTOFX1                                                          00009210
 NAME FOTOFX1(R)                                                        00009310
/*                                                                      00009410
