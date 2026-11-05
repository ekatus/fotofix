//FOTOFX2A JOB (AXXXX),                                                 00000101
//         'MGROM',                                                     00000201
//         CLASS=A,                                                     00000301
//         MSGCLASS=X,                                                  00000401
//         MSGLEVEL=(1,1),                                              00000501
//         REGION=4096K,                                                00000601
//         NOTIFY=&SYSUID                                               00000701
/*JOBPARM  ROOM=MAIL                                                    00000801
//JOBPROC  DD DSN=DFHSIM.KICKSSYS.V1R5M0.PROCLIB,DISP=SHR               00000901
//COBOL    EXEC K2KCOBCS,KIKSUSR='EKATUS.KICKS'                         00001037
//COPY.SYSUT1 DD *                                                      00001101
       IDENTIFICATION DIVISION.                                         00001200
       PROGRAM-ID. FOTOFX2.                                             00001301
       ENVIRONMENT DIVISION.                                            00001400
       CONFIGURATION SECTION.                                           00001500
       SOURCE-COMPUTER. IBM-370.                                        00001600
       OBJECT-COMPUTER. IBM-370.                                        00001700
       DATA DIVISION.                                                   00001800
       WORKING-STORAGE SECTION.                                         00001900
       77  WS-ABSTIME          PIC S9(15) COMP-3.                       00002001
       COPY FFXCOM.                                                     00002108
       COPY FFIXMSD.                                                    00002204
       COPY FFIXMMD.                                                    00002304
       COPY FFIXTAB.                                                    00002404
       COPY FFXORDT.                                                    00002533
       COPY DFHAID                                                      00002600
       COPY DFHBMSCA                                                    00002700
       01   WS-TSQ-NAME.                                                00002833
            05 WS-TERM-ID                 PIC X(4).                     00002933
            05 FILLER                     PIC X(4) VALUE 'WORK'.        00003033
       01   VSAM-FUNC     PIC X(2) VALUE 'AL'.                          00003141
       01   VSAM-DDNAME   PIC X(8)  VALUE 'FFIXORD'.                    00003239
       01   VSAM-DSNAME   PIC X(44) VALUE 'FOTOFIX.ORDERBK.CLUSTER'.    00003332
       01   WS-ERR-MSG.                                                 00003400
            05  FILLER                    PIC X(25)                     00003500
                                      VALUE 'VSAM WRITE ERROR. RESP = '.00003600
            05  WS-ERR-RESP-DISP          PIC 9(4).                     00003700
            05  FILLER                    PIC X VALUE '/'.              00003800
            05  WS-ERR-RESP2-DISP         PIC 9(4).                     00003900
            05  FILLER                    PIC X(11) VALUE ' CHECK FCT.'.00004000
       01   WS-FLAGS.                                                   00004100
            05 WS-RESP                    PIC 9(4) COMP VALUE 0.        00004200
            05 WS-RESP2                   PIC 9(4) COMP VALUE 0.        00004300
       COPY FFIXREC.                                                    00004401
       01   WS-CONSTANTS.                                               00004500
            05  WS-REC-LEN                PIC 9(4) COMP VALUE 80.       00004600
            05  WS-MSG-LEN                PIC 9(4) COMP VALUE 22.       00004700
       01   WS-COUNTER                    PIC 9(4) COMP VALUE 13.       00004803
       01   WS-DIR                        PIC X(1) VALUE 'F'.           00004909
         88 WS-DIR-FORWARD                VALUE 'F'.                    00005009
         88 WS-DIR-BACKWARD               VALUE 'B'.                    00005109
       01   WTO-ORD-REC.                                                00005236
         05 FILLER                        PIC X(10) VALUE 'ORDERTAB: '. 00005336
         05 WTO-ORD-NUM                   PIC X(8).                     00005436
         05 FILLER                        PIC X(1) VALUE '-'.           00005536
         05 WTO-ORD-KEY                   PIC X(16).                    00005636
       01   WTO-RESP.                                                   00005736
         05 FILLER                        PIC X(5) VALUE 'CODE:'.       00005836
         05 WTO-RESP-CODE                 PIC X(4).                     00005936
         05 FILLER                        PIC X(1) VALUE ' '.           00006036
         05 FILLER                        PIC X(8) VALUE 'DFHRESP:'.    00006136
         05 WTO-RESP-1                    PIC 9(2).                     00006236
         05 FILLER                        PIC X(1) VALUE '-'.           00006336
         05 WTO-RESP-2                    PIC 9(2).                     00006436
       01   CURRENT-REC.                                                00006516
         05 FILLER            PIC X(12) VALUE 'CURRENT KEY:'.           00006616
         05 CURRENT-KEY       PIC X(16) VALUE LOW-VALUE.                00006716
         05 FILLER            PIC X(1)  VALUE '-'.                      00006828
         05 FILLER            PIC X(4)  VALUE 'EOF:'.                   00006928
         05 CURRENT-EOF       PIC 9(1)  VALUE 0.                        00007028
         05 FILLER            PIC X(8)  VALUE '-ACTION:'.               00007128
         05 CURRENT-ACTION    PIC X(16) VALUE LOW-VALUE.                00007228
       01   SKIP-BACK-MSG.                                              00007316
         05 FILLER            PIC X(19) VALUE 'SKIPPING BACK PAGE:'.    00007416
         05 SB-PAGE-NO        PIC 9(2) VALUE 0.                         00007516
         05 FILLER            PIC X(13) VALUE 'BY ONE RECORD'.          00007616
       01   WS-CURSOR.                                                  00007733
         05 CURSOR-ABS        PIC 9(2)  COMP VALUE 0.                   00007833
         05 CURSOR-ROW        PIC 9(2)  COMP VALUE 0.                   00007933
         05 CURSOR-COL        PIC 9(2)  COMP VALUE 0.                   00008033
       01   WTO-CURSOR.                                                 00008136
         05 FILLER            PIC X(4) VALUE 'ROW:'.                    00008236
         05 WTO-CURSOR-ROW    PIC 9(2).                                 00008336
         05 FILLER            PIC X(1) VALUE ' '.                       00008436
         05 FILLER            PIC X(4) VALUE 'COL:'.                    00008536
         05 WTO-CURSOR-COL    PIC 9(2).                                 00008636
         05 FILLER            PIC X(1) VALUE ' '.                       00008736
         05 FILLER            PIC X(4) VALUE 'IDX:'.                    00008836
         05 WTO-ITEM-IDX      PIC 9(2).                                 00008936
       01   WS-ITEM-IDX       PIC 9(2)  COMP VALUE 1.                   00009033
       LINKAGE SECTION.                                                 00009100
       01   DFHCOMMAREA PIC X(100).                                     00009200
       PROCEDURE DIVISION.                                              00009300
       MAIN.                                                            00009400
            IF EIBCALEN = 0                                             00009501
               MOVE 'B' TO DISPATCH                                     00009612
               MOVE ' ' TO STDHFLAG                                     00009712
               MOVE 'DE' TO LANGUAGE                                    00009812
            ELSE                                                        00009912
               MOVE DFHCOMMAREA TO WS-COMM.                             00010012
            MOVE EIBTRMID TO WS-TERM-ID.                                00010133
            IF EIBAID = DFHCLEAR                                        00010238
               MOVE 'R' TO DISPATCH                                     00010338
               MOVE 'E' TO STDHFLAG                                     00010438
               EXEC CICS                                                00010538
                  XCTL PROGRAM('FOTOFX3') COMMAREA(WS-COMM)             00010638
               END-EXEC.                                                00010738
            IF DISPATCH  = 'B'                                          00010812
               EXEC CICS                                                00010901
                 SEND CONTROL ERASE                                     00011001
               END-EXEC                                                 00011101
               MOVE ' ' TO STDHFLAG                                     00011202
               MOVE 'N' TO DISPATCH                                     00011328
               PERFORM INIT.                                            00011411
            IF EIBAID = DFHPF6                                          00011536
               PERFORM UNLOCK-ITEM                                      00011635
               EXEC CICS                                                00011735
                 RETURN TRANSID('FFX2') COMMAREA(WS-COMM)               00011835
               END-EXEC.                                                00011935
            IF EIBAID = DFHPF8                                          00012002
               PERFORM NEXT-PAGE.                                       00012102
            IF EIBAID = DFHPF7                                          00012204
               PERFORM PREV-PAGE.                                       00012304
            IF EIBAID = DFHPF3                                          00012401
               PERFORM END-FFX2.                                        00012504
            EXEC CICS                                                   00012601
               RETURN TRANSID('FFX2') COMMAREA(WS-COMM)                 00012708
            END-EXEC.                                                   00012801
       INIT.                                                            00012911
            MOVE 0 TO PAGE-NO.                                          00013016
            MOVE LOW-VALUES TO FIRST-KEY.                               00013116
            MOVE LOW-VALUES TO LAST-KEY.                                00013216
            PERFORM SHOW-MAP.                                           00013311
            PERFORM NEXT-PAGE.                                          00013411
       END-FFX2.                                                        00013504
            MOVE 'I' TO DISPATCH.                                       00013604
            MOVE 'E' TO STDHFLAG.                                       00013704
            EXEC CICS SEND CONTROL ERASE                                00013804
            END-EXEC.                                                   00013904
            PERFORM HEADER.                                             00014004
            EXEC CICS SEND MAP('FFIXMAP') MAPSET('FFIXMSD')             00014104
               FREEKB                                                   00014204
            END-EXEC.                                                   00014304
            PERFORM FREE-PAGE.                                          00014433
            EXEC CICS                                                   00014504
               XCTL  PROGRAM('FOTOFX0') COMMAREA(WS-COMM)               00014635
            END-EXEC.                                                   00014704
       END-BR.                                                          00014801
            PERFORM WTO-ENDBR.                                          00014928
            EXEC CICS                                                   00015001
               ENDBR FILE(VSAM-DDNAME)                                  00015140
               RESP(WS-RESP)                                            00015206
            END-EXEC.                                                   00015301
            PERFORM UNLOCK-SECT.                                        00015431
       DIR-SELECT.                                                      00015515
            PERFORM 100-DIR-SELECT THRU 100-DIR-SELECT-EXIT.            00015615
       100-DIR-SELECT.                                                  00015715
            IF WS-DIR-FORWARD                                           00015815
               MOVE LAST-KEY TO VSAM-KEY                                00015915
            ELSE                                                        00016015
               MOVE FIRST-KEY TO VSAM-KEY.                              00016116
       100-DIR-SELECT-EXIT.                                             00016215
            EXIT.                                                       00016315
       START-BR.                                                        00016401
            PERFORM LOCK-SECT.                                          00016531
            MOVE LOW-VALUES TO VSAM-RECORD.                             00016601
            MOVE 16 TO KEY-LEN.                                         00016715
            IF PAGE-NO = 1 OR PAGE-NO = 0                               00016805
               MOVE LOW-VALUES TO VSAM-KEY                              00016913
               MOVE 16 TO KEY-LEN                                       00017013
            ELSE                                                        00017104
               PERFORM DIR-SELECT.                                      00017215
            PERFORM WTO-STARTBR.                                        00017328
            EXEC CICS STARTBR                                           00017404
                FILE(VSAM-DDNAME)                                       00017540
                RIDFLD(VSAM-KEY)                                        00017604
                KEYLENGTH(KEY-LEN)                                      00017704
                GTEQ                                                    00017812
                RESP(WS-RESP)                                           00017906
            END-EXEC.                                                   00018004
       SKIP-BACK.                                                       00018114
            PERFORM 100-SKIP-BACK THRU 100-SKIP-BACK-EXIT.              00018215
       100-SKIP-BACK.                                                   00018315
            IF WS-DIR-BACKWARD AND PAGE-NO > 0                          00018417
               MOVE PAGE-NO TO SB-PAGE-NO                               00018516
               EXEC CICS READPREV FILE(VSAM-DDNAME)                     00018640
                    INTO(VSAM-RECORD) RIDFLD(VSAM-KEY)                  00018714
                    KEYLENGTH(16)                                       00018814
                    RESP(WS-RESP)                                       00018914
               END-EXEC.                                                00019025
       100-SKIP-BACK-EXIT.                                              00019115
            EXIT.                                                       00019215
       READ-NEXT.                                                       00019310
            MOVE LOW-VALUES TO VSAM-REC.                                00019402
            MOVE 0 TO WS-EOF.                                           00019506
      *     PERFORM WTO-READNXT.                                        00019631
            EXEC CICS READNEXT FILE(VSAM-DDNAME)                        00019740
               INTO(VSAM-RECORD) RIDFLD(VSAM-KEY)                       00019801
               KEYLENGTH(16)                                            00019901
               RESP(WS-RESP)                                            00020006
            END-EXEC.                                                   00020101
            IF WS-RESP = DFHRESP(ENDFILE)                               00020206
               MOVE 1 TO WS-EOF.                                        00020306
            IF WS-RESP = DFHRESP(NORMAL)                                00020407
               MOVE 0 TO WS-EOF.                                        00020507
            PERFORM 100-PROC-REC-START THRU 100-PROC-REC-EXIT.          00020606
       READ-PREV.                                                       00020714
            MOVE LOW-VALUES TO VSAM-REC.                                00020814
            MOVE 0 TO WS-EOF.                                           00020914
      *     PERFORM WTO-READPRV.                                        00021031
            EXEC CICS READPREV FILE(VSAM-DDNAME)                        00021140
               INTO(VSAM-RECORD) RIDFLD(VSAM-KEY)                       00021214
               KEYLENGTH(16)                                            00021314
               RESP(WS-RESP)                                            00021414
            END-EXEC.                                                   00021514
            IF WS-RESP = DFHRESP(ENDFILE)                               00021614
               MOVE 1 TO WS-EOF.                                        00021714
            IF WS-RESP = DFHRESP(NORMAL)                                00021814
               MOVE 0 TO WS-EOF.                                        00021914
            PERFORM 100-PROC-REC-START THRU 100-PROC-REC-EXIT.          00022014
       WTO-SHOW-RESP.                                                   00022136
            MOVE WS-RESP TO WTO-RESP-1.                                 00022236
            MOVE WS-RESP2 TO WTO-RESP-2.                                00022336
            EXEC CICS WRITE OPERATOR TEXT(WTO-RESP)                     00022436
            END-EXEC.                                                   00022536
       SHOW-MAP.                                                        00022604
            MOVE PAGE-NO TO PAGENOO.                                    00022704
            PERFORM HEADER.                                             00022804
            EXEC CICS                                                   00022904
                 SEND MAP('FFIXMTP') MAPSET('FFIXMMD')                  00023004
                 FREEKB                                                 00023104
            END-EXEC.                                                   00023204
       100-PROC-REC-START.                                              00023306
            MOVE SPACES TO ERRMSG3O.                                    00023406
            IF WS-COUNTER = 1 AND WS-EOF = 1                            00023518
               SUBTRACT 1 FROM PAGE-NO.                                 00023618
            IF WS-EOF = 1                                               00023706
               MOVE '*DATEIENDE*' TO ERRMSG3O                           00023806
               GO TO 100-PROC-REC-EXIT.                                 00023906
            IF WS-COUNTER = 5                                           00024010
               MOVE VSAM-KEY TO LAST-KEY.                               00024113
            IF WS-COUNTER = 1                                           00024210
               MOVE VSAM-KEY TO FIRST-KEY.                              00024313
            MOVE VSAM-LAUFZN TO OT-ORDNUM OF ORDTABL (WS-COUNTER).      00024433
            MOVE VSAM-STAT TO OT-ORDSTA OF ORDTABL (WS-COUNTER).        00024533
            MOVE VSAM-KEY  TO OT-ORDKEY OF ORDTABL (WS-COUNTER).        00024633
            MOVE VSAM-LAUFZN TO ORDERI OF FFIXTABL (WS-COUNTER).        00024706
            MOVE VSAM-STAT TO STATUSI OF FFIXTABL (WS-COUNTER).         00024806
            MOVE VSAM-ORDER-DATE TO DATUMI OF FFIXTABL (WS-COUNTER).    00024906
            MOVE VSAM-TERM TO TERMI OF FFIXTABL (WS-COUNTER).           00025006
            MOVE VSAM-ORDER-TIME TO UHRI OF FFIXTABL (WS-COUNTER).      00025106
            MOVE VSAM-SYSID TO SYSI OF FFIXTABL (WS-COUNTER).           00025206
            MOVE VSAM-USERID TO USERI OF FFIXTABL (WS-COUNTER).         00025306
       100-PROC-REC-EXIT.                                               00025406
            EXIT.                                                       00025506
       HEADER.                                                          00025604
            MOVE 'FOTOFX2' TO TPROGID.                                  00025724
            EXEC CICS LINK PROGRAM('STDHCOB') COMMAREA(WS-COMM)         00025824
            END-EXEC.                                                   00025924
            MOVE 'X' TO STDHFLAG.                                       00026004
       SHOW-TAB.                                                        00026104
            MOVE PAGE-NO TO PAGENOO.                                    00026204
            EXEC CICS                                                   00026304
                SEND MAP('FFIXMTP') MAPSET('FFIXMMD')                   00026409
            END-EXEC.                                                   00026504
       PREV-PAGE.                                                       00026613
            PERFORM 100-PREV-PAGE THRU 100-PREV-PAGE-EXIT.              00026713
       100-PREV-PAGE.                                                   00026813
            IF PAGE-NO = 1                                              00026913
               GO TO 100-PREV-PAGE-EXIT.                                00027013
            MOVE 'B' TO WS-DIR.                                         00027109
            IF PAGE-NO < 1                                              00027213
               MOVE 1 TO PAGE-NO.                                       00027313
            IF PAGE-NO > 1                                              00027413
               PERFORM START-BR                                         00027517
               PERFORM SKIP-BACK.                                       00027617
            IF PAGE-NO > 1                                              00027713
               MOVE LOW-VALUES TO FFIXTAB                               00027813
               PERFORM READ-PREV VARYING WS-COUNTER FROM 5 BY -1        00027916
               UNTIL WS-COUNTER < 1                                     00028033
               PERFORM STORE-PAGE.                                      00028133
            IF PAGE-NO > 0                                              00028214
               PERFORM END-BR                                           00028313
               SUBTRACT 1 FROM PAGE-NO.                                 00028413
            PERFORM HEADER.                                             00028513
            PERFORM SHOW-TAB.                                           00028613
       100-PREV-PAGE-EXIT.                                              00028713
            EXIT.                                                       00028813
       NEXT-PAGE.                                                       00028901
            PERFORM 100-NEXT-PAGE THRU 100-NEXT-PAGE-EXIT.              00029013
       100-NEXT-PAGE.                                                   00029113
            IF WS-EOF = 1                                               00029213
               GO TO 100-NEXT-PAGE-EXIT.                                00029313
            MOVE 'F' TO WS-DIR.                                         00029413
            ADD 1 TO PAGE-NO                                            00029504
            PERFORM START-BR.                                           00029612
            MOVE LOW-VALUES TO FFIXTAB.                                 00029704
            IF PAGE-NO > 1                                              00029825
               PERFORM READ-NEXT.                                       00029925
            PERFORM READ-NEXT VARYING WS-COUNTER FROM 1 BY 1            00030010
              UNTIL WS-COUNTER > 5 OR WS-EOF = 1.                       00030133
            PERFORM STORE-PAGE.                                         00030233
            PERFORM HEADER.                                             00030304
            PERFORM SHOW-TAB.                                           00030404
            PERFORM END-BR.                                             00030512
       100-NEXT-PAGE-EXIT.                                              00030613
            EXIT.                                                       00030713
       WTO-STARTBR.                                                     00030828
            MOVE 'STARTBR' TO CURRENT-ACTION.                           00030928
            PERFORM WTO-REC.                                            00031028
       WTO-READNXT.                                                     00031128
            MOVE 'READNXT' TO CURRENT-ACTION.                           00031228
            PERFORM WTO-REC.                                            00031328
       WTO-READPRV.                                                     00031428
            MOVE 'READPRV' TO CURRENT-ACTION.                           00031528
            PERFORM WTO-REC.                                            00031628
       WTO-ENDBR.                                                       00031728
            MOVE 'ENDBR' TO CURRENT-ACTION.                             00031828
            PERFORM WTO-REC.                                            00031928
       WTO-REC.                                                         00032016
            MOVE WS-EOF TO CURRENT-EOF.                                 00032128
            MOVE VSAM-KEY TO CURRENT-KEY.                               00032216
            EXEC CICS                                                   00032325
               WRITE OPERATOR TEXT(CURRENT-REC)                         00032425
            END-EXEC.                                                   00032525
       LOCK-SECT.                                                       00032631
            MOVE 'AL' TO VSAM-FUNC.                                     00032741
            CALL 'DYNALLC' USING VSAM-FUNC, VSAM-DDNAME, VSAM-DSNAME.   00032841
       UNLOCK-SECT.                                                     00032931
            MOVE 'FL' TO VSAM-FUNC.                                     00033041
            CALL 'DYNALLC' USING VSAM-FUNC, VSAM-DDNAME, VSAM-DSNAME.   00033141
       COMP-CURPOS.                                                     00033233
            MOVE EIBCPOSN TO CURSOR-ABS.                                00033333
            DIVIDE CURSOR-ABS BY 80 GIVING CURSOR-ROW                   00033433
               REMAINDER CURSOR-COL.                                    00033533
            ADD 1 TO CURSOR-ROW.                                        00033633
            ADD 1 TO CURSOR-COL.                                        00033733
       COMP-INDEX.                                                      00033833
            PERFORM 100-COMP-INDEX THRU 100-COMP-INDEX-EXIT.            00033934
       100-COMP-INDEX.                                                  00034034
            SUBTRACT 10 FROM CURSOR-ROW GIVING WS-ITEM-IDX.             00034133
            ADD 1 TO WS-ITEM-IDX.                                       00034236
            IF WS-ITEM-IDX < 1                                          00034336
               MOVE 1 TO WS-ITEM-IDX.                                   00034433
            IF WS-ITEM-IDX > 5                                          00034533
               MOVE 5 TO WS-ITEM-IDX.                                   00034633
            MOVE WS-ITEM-IDX TO WTO-ITEM-IDX.                           00034736
            MOVE CURSOR-ROW TO WTO-CURSOR-ROW.                          00034836
            MOVE CURSOR-COL TO WTO-CURSOR-COL.                          00034936
            EXEC CICS                                                   00035036
            WRITE OPERATOR TEXT(WTO-CURSOR)                             00035136
            END-EXEC.                                                   00035236
       100-COMP-INDEX-EXIT.                                             00035334
            EXIT.                                                       00035434
       READ-PAGE.                                                       00035533
            EXEC CICS                                                   00035633
                READQ TS                                                00035733
                QUEUE(WS-TSQ-NAME)                                      00035833
                LENGTH(130)                                             00035936
                NEXT                                                    00036036
                INTO(ORDERTAB)                                          00036133
                RESP(WS-RESP)                                           00036233
                RESP2(WS-RESP2)                                         00036336
            END-EXEC.                                                   00036433
            MOVE 'READ' TO WTO-RESP-CODE.                               00036536
            PERFORM WTO-SHOW-RESP.                                      00036636
       FREE-PAGE.                                                       00036733
            EXEC CICS                                                   00036833
                DELETEQ TS                                              00036933
                QUEUE(WS-TSQ-NAME)                                      00037033
                RESP(WS-RESP)                                           00037133
                RESP2(WS-RESP2)                                         00037236
            END-EXEC.                                                   00037333
            MOVE 'FREE' TO WTO-RESP-CODE.                               00037436
            PERFORM WTO-SHOW-RESP.                                      00037536
       STORE-PAGE.                                                      00037633
            PERFORM FREE-PAGE.                                          00037733
            EXEC CICS                                                   00037833
                WRITEQ TS                                               00037933
                QUEUE(WS-TSQ-NAME)                                      00038033
                LENGTH(130)                                             00038136
                FROM(ORDERTAB)                                          00038233
                NOSUSPEND                                               00038333
                MAIN                                                    00038433
                RESP(WS-RESP)                                           00038533
                RESP2(WS-RESP2)                                         00038636
            END-EXEC.                                                   00038733
            MOVE 'WRTE' TO WTO-RESP-CODE.                               00038836
            PERFORM WTO-SHOW-RESP.                                      00038936
       UNLOCK-ITEM.                                                     00039033
            PERFORM COMP-CURPOS.                                        00039133
            PERFORM COMP-INDEX.                                         00039233
            PERFORM READ-PAGE.                                          00039333
            MOVE OT-ORDNUM OF ORDTABL (WS-ITEM-IDX) TO WTO-ORD-NUM.     00039436
            MOVE OT-ORDKEY OF ORDTABL (WS-ITEM-IDX) TO WTO-ORD-KEY.     00039536
            EXEC CICS WRITE OPERATOR TEXT(WTO-ORD-REC)                  00039636
            END-EXEC.                                                   00039736
            MOVE LOW-VALUES TO VSAM-RECORD.                             00039833
            MOVE OT-ORDKEY OF ORDTABL (WS-ITEM-IDX) TO VSAM-KEY.        00039936
            EXEC CICS                                                   00040033
               READ FILE(VSAM-DDNAME)                                   00040140
               INTO(VSAM-RECORD)                                        00040233
               LENGTH(80)                                               00040333
               RIDFLD(VSAM-KEY) KEYLENGTH(16)                           00040433
               EQUAL UPDATE                                             00040533
               RESP(WS-RESP)                                            00040633
               RESP2(WS-RESP2)                                          00040736
            END-EXEC.                                                   00040833
            MOVE 'RUPD' TO WTO-RESP-CODE.                               00040936
            PERFORM WTO-SHOW-RESP.                                      00041036
            IF WS-RESP NOT = DFHRESP(NORMAL)                            00041134
               GO TO UNLOCK-ITEM-EXIT.                                  00041233
            MOVE 'P' TO VSAM-STAT.                                      00041333
            EXEC CICS REWRITE FILE(VSAM-DDNAME)                         00041440
                 FROM(VSAM-RECORD) LENGTH(80)                           00041536
                 RESP(WS-RESP)                                          00041636
                 RESP2(WS-RESP2)                                        00041736
            END-EXEC.                                                   00041833
            MOVE 'RWRT' TO WTO-RESP-CODE.                               00041936
            PERFORM WTO-SHOW-RESP.                                      00042036
       UNLOCK-ITEM-EXIT.                                                00042133
            EXIT.                                                       00042233
/*                                                                      00042301
//LKED.SYSLIB DD                                                        00042431
//            DD DSN=EKATUS.LOADLIB(DYNALLC),DISP=SHR                   00042541
//LKED.SYSIN  DD *                                                      00042601
 INCLUDE SKIKLOAD(KIKCOBGL)                                             00042701
 ENTRY FOTOFX2                                                          00042801
 NAME FOTOFX2(R)                                                        00042901
/*                                                                      00043001
