//FOTOSRV# JOB  (AXX,BXX,CXX),
//          CLASS=A,MSGLEVEL=(1,1),
//          MSGCLASS=X,NOTIFY=&SYSUID
//ASM   EXEC PGM=IFOX00,PARM=(NOOBJECT,DECK,XREF)
//SYSLIB   DD DSN=SYS1.MACLIB,DISP=SHR
//         DD DSN=SYS2.MACLIB,DISP=SHR
//         DD DSN=SYS1.AMODGEN,DISP=SHR
//SYSPRINT DD SYSOUT=*
//SYSUT1   DD UNIT=SYSDA,SPACE=(CYL,(2,1))
//SYSUT2   DD UNIT=SYSDA,SPACE=(CYL,(2,1))
//SYSUT3   DD UNIT=SYSDA,SPACE=(CYL,(2,1))
//SYSLIN   DD DUMMY
//SYSGO    DD DUMMY
//SYSPUNCH DD DSN=&&PNCH,DISP=(NEW,PASS,DELETE),
//            UNIT=SYSDA,SPACE=(TRK,(10,10)),
//            DCB=(RECFM=FB,LRECL=80,BLKSIZE=400)
//SYSIN    DD *
         START 0
         REGISTER
IOTIMSV  EQU   500
IOTIMLV  EQU   3000
NAPSLICE EQU   15
ONESEC   EQU   100
FOTOSRV1 CSECT
         SAVE  (14,12)
         BALR  R12,0
         USING *,R12,R10
         LA    R10,4095(,R12)
         LA    R10,1(,R10)
         LA    R11,DATAAREA
         USING DATAAREA,R11
         ST    R13,SAVEAREA+4
         LA    R14,SAVEAREA
         ST    R14,8(R13)
         LR    R13,R14
*-------------------------------------------------------------------*
* INIT - READ COMM AREA                                             *
*-------------------------------------------------------------------*
         LA    R7,BSC2703
         USING IHADCB,R7
         ESTAE FFRECOV
         WTO   '[MAIN] FOTOFIX START'
         MVI   STOPFLAG,C'N'
         EXTRACT COMPTR,'S',FIELDS=(COMM)
         L     R2,COMPTR
         LTR   R2,R2
         BZ    NOCOMM
         USING COMAREA,R2
         ICM   R3,15,COMCIBPT
         BZ    SETCTR
         QEDIT ORIGIN=COMCIBPT,BLOCK=(R3)
SETCTR   QEDIT ORIGIN=COMCIBPT,CIBCTR=1
         DROP  R2
         ST    R3,COMMR3
         B     COMMOK
NOCOMM   EQU   *
         WTO   '[MAIN] NO COMM PTR'
COMMOK   EQU   *
         EJECT
MAIN     EQU   *
*        OPEN  (SNAPDCB,(OUTPUT))
         OPEN  (CTRLINP,INPUT)
         LTR   R15,R15
         BNE   ERRCTRL
         ST    R14,CTRL14
         ST    R15,CTRL15
         BAL   R14,PARSCTRL            * parse and process ctl file
         CLOSE (CTRLINP)
         B     POLLLOOP                * enter main loop
ERRCTRL  EQU    *
         WTO '[MAIN] ERROR OPENING CONTROL FILE'
         B     POLLLOOP
SHUTDOWN EQU   *
         WTO   '[MAIN] SHUTDOWN REQUESTED'
         B     CLOSEALL
CONNERR  EQU   *
         MVC   WTORTXT(8),=CL8'READ'
CONNWTO  EQU   *
         ST    15,WTOSAV15
         ST    14,WTOSAV14
         UNPK  WTOR15(9),SAVE15(5)
         TR    WTOR15(8),HEXTAB
         WTO   MF=(E,WTOWRTER)
         L     15,WTOSAV15
         L     14,WTOSAV14
         BR    14
OLNERR   EQU   *
         MVC   WTORTXT(8),=CL8'OPEN LIN'
         BAL   14,CONNWTO
         CLI   STOPFLAG,C'Y'
         BE    SHUTDOWN
         B     FIXLINE
OPENLINE EQU   *
         ST    14,SAVE14
         ST    15,SAVE15
         OPEN  (BSC2703,(INOUT))     * 2703 BSC LINE
         TM    DCBOFLGS,X'10'
         BO    LINOPEN
         B     OLNERR
LINOPEN  EQU   *
         MVI   LINESTAT,X'01'
         WTO   '[MAIN] COMMUNICATIONS LINE OPENED'
         L     14,SAVE14
         L     15,SAVE15
         BR    14
CLOSELIN EQU   *
         CLOSE (BSC2703)
         ST    14,SAVE14
         ST    15,SAVE15
         WTO   '[MAIN] COMMUNICATIONS LINE CLOSED'
         L     14,SAVE14
         L     15,SAVE15
         MVI   LINESTAT,X'00'
         BR    R14
EOF      EQU   *
         WTO   '[MAIN] ORDER BOOK REPORTED EOF'
         BAL   R14,NAPWAIT
         CLI   STOPFLAG,C'Y'
         BE    SHUTDOWN
         B     POLLLOOP
PARSCTRL EQU   *
         ST    14,PARS14
         WTO   '[MAIN] PARSING CONTROL INPUT'
         GET   CTRLINP,CTRLBUF
         CLI   EOFCTL,X'01'
         BE    CLOSEALL
         CLC   CTRLBUF(5),=C'RESET'
         BNE   POLLLOOP
         WTO   '[MAIN] RESETTING ORDERS'
         LA    R0,1
         LA    R1,PARMORDR
         SR    R15,R15            * clear out R15
         L     15,=V(RESET)
         BALR  14,15
         ST    15,SUBRC
         LTR   15,15
         BZ    RSUCCESS
         WTO   '[MAIN] RESET OF ORDERS NOT SUCCESSFUL'
         L     14,PARS14
         BR    14                 * Return to caller
RSUCCESS EQU   *
         WTO   '[MAIN] RESET OF ORDER BOOK SUCCESSFUL'
         L     14,PARS14
         BR    14                 * Return to caller
SKIPORD  EQU   *
         WTO   '[MAIN] NO ELIGIBLE ORDERS IN ORDER BOOK'
         BAL   R14,NAPWAIT
POLLLOOP EQU   *
         WTO   '[MAIN] START LOOP'
         CLI   STOPFLAG,C'Y'
         BE    SHUTDOWN
NEXTREC  EQU   *
*        WTO   'READING NEXT ORDER FROM ORDER BOOK'
         MVI   ORDERSTA,C'X'
         SR    R0,R0
         LA    R0,1               * FUNCTION CODE IN R1 GET ORDER
         LA    R1,PARMORDR
         SR    R15,R15            * clear out R15
         L     15,=V(ORDERS)
         BALR  14,15
         ST    15,SUBRC
*        ST    14,SAVE14
*        ST    15,SAVE15
*        UNPK  WTORET15(9),SAVE15(5)
*        TR    WTORET15(8),HEXTAB
*        MVC   WTOWFNC(8),=CL8'ORDER'
*        WTO   MF=(E,WTOWRET)
         L     15,SUBRC
         LTR   15,15
         CH    15,=X'0004'             * END OF FILE
         BE    EOF
         CLI   ORDERSTA,C'P'           * PROCESSING MARKER SET?
         BNE   SKIPORD
         ST    R14,SAVE14
         MVC   WTOLAUFN(8),ORDERNUM
         WTO   MF=(E,WTOPROFT)
         L     R14,SAVE14
         CLC   ORDERNUM,=CL8'SHUTDOWN'  *CHECK FOR SHUTDOWN
         BE    CLOSEALL
         BAL   R14,OPENLINE
*        CLC   LASTORDR,ORDERNUM
*        BE    NEXTREC
*
         WTO   '[MAIN] PRINT ORDER DETECTED'
         MVC   WTOLAUFN(8),ORDERNUM
         MVC   LASTORDR(8),ORDERNUM
         WTO   MF=(E,WTOPROFT)
         B     FETCH
HELLOFIX EQU   *
         WTO   '[MAIN] INITIALIZING LINE (START TERMINAL)'
         XC    INITOUT(4),INITOUT
         WRITE INITOUT,TI,BSC2703,INITBUF,18,TRMLST,1,                 X
               MF=(E,INITOUT)
         LTR   15,15
         BNE   ERRWRITE
         WAIT  ECB=INITOUT
         BR    14
FIXLINE  EQU   *
         CLI   STOPFLAG,C'Y'
         BE    SHUTDOWN
         ST    R14,SAVE14
         WTO   '[MAIN] ATTEMPTING TO FIX THE COMMUNICATIONS LINE'
         BAL   R14,CLOSELIN
         ST    R1,SAVE1
         ST    R2,SAVE2
         ST    R3,SAVE3
         ST    R4,SAVE4
         ST    R14,SAVE14
         L     R15,=V(CCWIO)
         BALR  R14,R15
NAPTIM2  BAL   R14,NAPWAIT
         BAL   R14,OPENLINE
         LTR   R15,R15
         BZ    ENABLOK
         B     ERRWRITE
ENABLOK  EQU   *
         WTO   '[MAIN] ENABLING COMMUNICATIONS LINE SUCCESSFUL'
         B     FETCH
         XC    MSGOUT(4),MSGOUT
         MVI   WRECORD,X'37'
         XC    MSGIN(4),MSGIN
         READ  MSGIN,TIR,BSC2703,CMDBUF,1,TRMLST,1,                    X
               MF=(E,MSGIN)
         LTR   R15,R15
         BNE   ERRWRITE
         WAIT  ECB=MSGIN
         CLI   MSGIN,X'7F'
         BNE   ERRBTAM
         BAL   R14,CLOSELIN
         BAL   R14,OPENLINE
         L     R14,SAVE14
FETCH    EQU   *
*        BAL   14,HELLOFIX
         WTO   '[MAIN] WRITING FETCH COMMAND TO FOTOFIX BACKEND'
         XC    MSGOUT(4),MSGOUT
         MVC   WRECORD(16),=CL16'FETCH:********  '
         MVC   WRECORD+6(8),ORDERNUM
         WRITE MSGOUT,TI,BSC2703,WRITEBUF,18,TRMLST,1,                 X
               MF=(E,MSGOUT)
         LTR   15,15
         BNE   ERRWRITE
         LA    R1,MSGOUT
         BAL   R14,IOWAITS
         LTR   R15,R15
         BNE   ERRWTIM
*        WAIT  ECB=MSGOUT
*        CLI   MSGOUT,X'7F'
         B     READINIT
ERRWTIM  EQU   *
         WTO   '[MAIN] FETCH WRITE TIMED OUT'
         B     FIXLINE
READINIT EQU   *
         WTO   '[MAIN] READING INITIAL DATA  FROM BACKEND'
         XC    CMDIN(4),CMDIN
         READ  CMDIN,TI,BSC2703,CMDBUF,18,TRMLST,1,                    X
               MF=(E,CMDIN)
         LTR   15,15
         BNE   ERRREAD
         WAIT  ECB=CMDIN
         CLI   CMDBUF,X'2D'            *Bidding the line?
         BNE   INTRPRET
         WTO   '[MAIN] RECEIVED BIDDING THE LINE NOT HANDLED BY BTAM'
INTRPRET EQU   *
         CLC   CRECORD(6),=C'NOTFND'
         BE    NOTFOUND
         CLC   CRECORD(4),=C'OPEN'
         BE    OPENDATA
         MVC   WTOL40M(16),CRECORD
         ST    R14,SAVE14
         ST    R15,SAVE15
         WTO   '[MAIN] UNKNOWN FEEDBACK FROM REMOTE'
         WTO   MF=(E,WTOL40)
         L     R14,SAVE14
         L     R15,SAVE15
         B     READINIT
NOTFOUND EQU   *
         WTO   '[MAIN] ORDER NOT FOUND AT BACKEND'
         SR    R0,R0
         LA    R0,3               * FUNCTION CODE IN R1 CANCEL ORDER
         LA    R1,PARMORDR
         SR    R15,R15            * clear out R15
         L     15,=V(ORDERS)
         BALR  14,15
         LTR   15,15
         BNZ   ERRCANC
         BAL   R14,NAPWAIT
         B     POLLLOOP
ERRCANC  EQU   *
         WTO   '[MAIN] ERROR CANCELLING ORDER'
         BAL   R14,NAPWAIT
         B     POLLLOOP
OPENDATA EQU   *
         ZAP   RCOUNT,=P'1'                   * RESET RECORD COUNTER
         ST     R1,SAVE1
         ST     R2,SAVE2
         ST    R13,SAVE13
         ST    R14,SAVE14
         ST    R15,SAVE15
         LA    R1,PARMLIST
         L     R15,=V(ALLOCFI)
         BALR  14,15
         L     14,SAVE14
         L     15,SAVE15
         L      1,SAVE1
         L      2,SAVE2
         L     13,SAVE13
         WTO   '[MAIN] OPEN OUTPUT FOR PRINT RECORDS'
         OPEN  (DYNPRINT,OUTPUT)
         LA    4,DYNPRINT
         LA    5,0(,4)
         TM    48(5),X'10'          * DCB IS OPEN?
         BZ    ERROPEN
RCVLOOP  EQU   *
*        WTO   '[MAIN]  PRINT RECORD FROM BACKEND'
         MVI   RRECORD,C' '
         MVC   RRECORD+1(L'RRECORD-1),RRECORD
         XC    MSGIN(4),MSGIN
         READ  MSGIN,TT,BSC2703,READBUF,135,TRMLST,1,                  X
               MF=(E,MSGIN)
         LTR   15,15
         BNE   ERRREAD
         LA    R1,MSGIN
         BAL   R14,IOWAIT
         LTR   R15,R15
         BZ    READOK
         WTO   '[MAIN] TIME OUT READING FROM BACKEND'
         BNE   ERRREAD
*        WAIT  ECB=MSGIN             * Wait for Operation to complete
*        ST    14,SAVE14
*        ST    15,SAVE15
*        WTO   '[MAIN] RETURNED FROM RECEIVE'
*        MVC   WTOL40M(20),RRECORD
*        WTO   MF=(E,WTOL40)
*        L     14,SAVE14
*        L     15,SAVE14
READOK   EQU   *
         CLI   RRECORD,X'03'          * CHECK FOR STRAY ETX
         BNE   RCONT
         WTO   '[MAIN] STRAY ETX DETECTED'
         B     RCVLOOP
RCONT    EQU   *
* Check, if the script has sent the EOT signal
*        LA    3,RCHAN
*        CLI   0(3),C'1'              * CHECK if Channel has set to 1
*        BNE   CRETX
*        BAL   R14,PCHAN
*RETX    EQU   *
         LA    3,RETX
         CLI   0(3),X'37'
         BE    DATAEND                * if EOT -> exit read loop
         LA    3,RRECORD
         CLC   0(5,3),=C'*END*'
         BE    DATAEND
         PUT   DYNPRINT,RRECORD       * WRITE RECORD TO OUTPUT FILE
         BAL   R14,PRLINE
         AP    RCOUNT,ONE
         B     RCVLOOP
DATAEND  EQU    *
         WTO   '[MAIN] DATA END'
         SP    RCOUNT,ONE             * ADJUST RECORD COUNTER
         BAL   R14,PREC               * PRINT READ COUNT
         CLOSE (DYNPRINT)             * CLOSE OUTPUT FILE
         ST     1,SAVE1
         ST     2,SAVE2
         ST    13,SAVE13
         ST    14,SAVE14
         ST    15,SAVE15
         LA    1,PARMLIST
         L     15,=V(SUBMITJ)
         BALR  14,15
         WTO   '[MAIN] PRINT JOB SUBMITTED'
         L      1,SAVE1
         L      2,SAVE2
         L     13,SAVE13
         L     14,SAVE14
         L     15,SAVE15
         BAL   14,CLOSELIN
         SR    R0,R0
         LA    R0,2               * FUNCTION CODE IN R1 UPDATE ORDER
         LA    R1,PARMORDR
         SR    R15,R15            * clear out R15
         L     15,=V(ORDERS)
         BALR  14,15
         LTR   15,15
         BNZ   ERRUPDT
         BAL   R14,NAPWAIT
         B     POLLLOOP
ERRUPDT  EQU   *
         WTO   '[MAIN] ERROR UPDATING ORDER'
         B     POLLLOOP
ERRWRITE EQU   *
         MVC   WTORTXT(8),=CL8'WRITE'
         ST    15,SAVE15
         UNPK  WTOR15(9),SAVE15(5)
         TR    WTOR15(4),HEXTAB
         WTO   MF=(E,WTOWRTER)
         WTO '[MAIN] ERROR WRITING TO COMMUNICATIONS LINE'
         L     15,SAVE15
         B     CLOSEALL
ERRREAD  EQU   *
         MVC   WTORTXT(8),=CL8'READ '
         ST    15,SAVE15
         UNPK  WTOR15(9),SAVE15(5)
         TR    WTOR15(4),HEXTAB
         WTO   MF=(E,WTOWRTER)
         WTO '[MAIN] ERROR READING FROM COMMUNICATIONS LINE'
         L     15,SAVE15
         B   CLOSEALL
ERROPEN  EQU   *
         WTO   '[MAIN] ERROR OPENING TEMP FILE'
         B   CLOSEALL
ERRWTOIO EQU   *
         ST    15,SAVE15
         ST    14,SAVE14
         UNPK  WTOR15(9),SAVE15(5)
         TR    WTOR15(4),HEXTAB
         WTO   MF=(E,WTOWRTER)
         L     15,SAVE15
         L     14,SAVE14
         BR    14
ERRBTAM  EQU   *
         UNPK  HEXWORK(5),MSGOUT(3)
         TR    HEXWORK(4),HEXTAB
         MVC   WTOMSGE(2),HEXWORK
         MVC   WTOMSTS(2),HEXWORK+2
         WTO   MF=(E,WTOPLIST)
         WTO   '[MAIN] ERROR WRITING TO COMMUNICATIONS LINE (ERRBTAM)'
         B    CLOSEALL
CLOSEALL EQU *
         WTO '[MAIN] SHUTTING DOWN'
*        RESETPL BSC2703
*        WAIT  ECB=MSGOUT
         CLI   LINESTAT,X'00'
         BE    LINCLOS
         WTO '[MAIN] CLOSING THE COMMUNICATIONS LINE'
         CLOSE (BSC2703)
         WTO '[MAIN] COMMUNICATIONS LINE CLOSED'
LINCLOS  EQU   *
         CLOSE (CTRLINP)
         WTO '[MAIN] CLOSED CONTROL INPUT FILE'
*        CLOSE (SNAPDCB)
EXIT     EQU   *
         L     13,4(,13)
         LM    14,12,12(13)
         SR    15,15           * CLEAR ERROR
         BR    14
WTOOUTBF EQU   *
         ST    15,WTOSAV14
         UNPK  WTOL40M(11),READBUF(6)
         UNPK  WTOL40M+10(11),READBUF+5(6)
         TR    WTOL40M(20),HEXTAB
         WTO   MF=(E,WTOL40)
         L     14,WTOSAV14
         BR    14

CTRLEOF  EQU    *
         ST    15,SAVE15
         ST    14,SAVE14
         WTO   '[MAIN] END OF CONTROL INPUT'
         L     15,SAVE15
         L     14,SAVE14
         MVI   EOFCTL,X'01'
         BR    14
MYSYNAD  DS    0H
         USING *,15
         STM   14,12,12(13)
         LR    11,15
         DROP  15
         USING MYSYNAD,11
         LR    2,1
         CLI   12(2),X'00'
         BNE   ERRHARD
         TM    13(2),X'02'
         BO    SETUEXFL
         B     ERRUNK
FFRECOV  EQU   *
         CH    0,=H'12'
         BNE   EXRECOV
EXRECOV  SR    15,15
         BR    14
SETUEXFL DS    0H
         MVI   UNITEXF,X'01'
         B     EXITSYN
ERRHARD  DS    0H
         ABEND 99,DUMP
ERRUNK   DS    0H
         ABEND 98,DUMP
EXITSYN  DS    0H
         LM    14,12,12(13)
         DROP  11
         BR    14
NAPWAIT  ST    R14,NAPSAVE
         LA    R6,NAPSLICE
NAPLOOP  EQU   *
         BAL   R14,CHKCMD
*        WTO   'RETURN CMD CHECKED'
         CLI   STOPFLAG,C'Y'
         BE    NAPEND
         STIMER WAIT,BINTVL=ONESECX
         BCT   R6,NAPLOOP
NAPEND   L     R14,NAPSAVE
         BR    R14
*HKSTOP  ST    R14,STPSAVE
*        L     R2,COMPTR
*        LTR   R2,R2
*        BZ    STPEND              NO COMMAND INTERFACE AT ALL
*        USING COMAREA,R2
*        ICM   R3,15,COMCIBPT
*        BZ    STPEND              NOTHING QUEUED
*        USING CIBAREA,R3
*        CLI   CIBVERB,CIBSTOP
*        BNE   STPOTHER
*        MVI   STOPFLAG,C'Y'
*        QEDIT ORIGIN=COMCIBPT,BLOCK=(R3)
*        DROP  R2,R3
*        B     STPEND
CHKCMD   EQU   *
*        WTO   'CHECKING MODIFY'
         ST    R14,CMDSAV
*        SNAP  DCB=SNAPDCB,ID=1,PDATA=(REGS),STORAGE=(CMDSAV,CMDSAV+4)
         L     R2,COMPTR
         LTR   R2,R2
         BZ    CMDEND
         USING COMAREA,R2
         ICM   R3,15,COMCIBPT
         BZ    CMDEND
         USING CIBAREA,R3
         WTO   '[MAIN] CHECKING STOP VERB'
         CLI   CIBVERB,CIBSTOP
         BNE   CHKMOD
         WTO   '[MAIN] STOP COMMAND RECEIVED'
         MVI   STOPFLAG,C'Y'
         B     CMDEND
OTHRCMD  EQU   *
         WTO   '[MAIN] OTHER CMD RECEIVED'
         B     CMDEND
CHKMOD   EQU   *
         CLI   CIBVERB,CIBMODFY
         BNE   OTHRCMD
         WTO   '[MAIN] MODIFY COMMAND RECEIVED'
         MVI   MODFLAG,C'Y'
         L     R5,COMCIBPT
         USING CIBAREA,R5
         MVC   CMDWRKLN(1),CIBDATLN
         MVC   CMDWRKA(32),CIBDATA
         DROP  R5
         B     CMDEND
         BAL   R14,PARSEMOD
         WTO   '[MAIN] RETURN FROM PARSE'
CMDEND   EQU   *
         L     R3,COMMR3
         QEDIT ORIGIN=COMCIBPT,BLOCK=(R3)
         DROP  R2,R3
*        WTO   'CMD CHECKING END'
         L     R14,CMDSAV
*        SNAP  DCB=SNAPDCB,ID=2,PDATA=(REGS),STORAGE=(CMDSAV,CMDSAV+4)
         BR    R14
PARSEMOD EQU   *
         ST    R14,PARSE14
         WTO   '[MAIN] PARSING COMMAND LINE'
         BE    MODEMPTY
         TR    WORK5(4),HEXTAB
         MVC   WTOCMDLN(4),WORK5
         ST    R14,SAVE14
         ST    R13,SAVE13
         ST    R15,SAVE15
         ST    R2,SAVE2
         ST    R3,SAVE3
         ST    R4,SAVE4
         ST    R5,SAVE5
         ST    R6,SAVE6
         WTO   MF=(E,WTOCMD)
         L     R14,SAVE14
         L     R13,SAVE13
         L     R15,SAVE15
         L     R2,SAVE2
         L     R3,SAVE3
         L     R4,SAVE4
         L     R5,SAVE5
         L     R6,SAVE6
         CLC   CMDWRKA(6),=C'PRINT='
         BE    MODPRINT
         CLC   CMDWRKA(6),=C'RESET='
         BE    MODRESET
         WTO   '[MAIN] OTHER MODIFY COMMAND'
         B     PARSEEND
MODEMPTY EQU   *
         WTO   '[MAIN] EMPTY ARGUMENT'
         B     PARSEEND
MODPRINT EQU   *
         MVI   MODFLAG,C'P'
         B     PARSEARG
MODRESET EQU   *
         MVI   MODFLAG,C'R'
PARSEARG EQU   *
         WTO   '[MAIN] PARSING ARGS'
         LA    R7,CMDWRKA
         BCTR  R6,0
         EX    R6,TRTMOD
         BZ    ERRTRT
         LR    R8,R1
         SR    R8,R7
         LA    R9,1(R1)
         LH    R10,CMDWRKLN
         SR    R10,R8
         BCTR  R10,0
         WTO   '[MAIN] ARGUMENTS PARSED'
         CH    R10,=H'6'      * LEN=6?
         BNE   MODARGER
         MVC   ORDERNUM(6),0(R9)
         WTO   '[MAIN] ORDER ACCEPTED'
         B     PARSEEND
ERRTRT   EQU   *
         WTO   '[MAIN] ERROR EXECUTING TRT'
         MVI   MODFLAG,C'N'
         B     PARSEEND
MODARGER EQU   *
         WTO   '[MAIN] ERROR IN ARGUMENT'
*        MVI   MODFLAG,C'N'
         B     PARSEEND
PARSEEND EQU   *
         WTO   '[MAIN] PARSE END'
         L     R14,PARSE14
         BR    R14
MODCOM   EQU   *
         WTO   '[MAIN] NO COMM AREA'
         B     CMDEND
MODCOM2  EQU   *
         WTO   '[MAIN] NO COMM DATA'
         B     CMDEND
MODNMOD  EQU   *
         WTO   '[MAIN] NO MODIFY COMMAND'
         B     CMDEND
PREC     EQU   *
         ST    R14,SAVE14
         ST    R15,SAVE15
         MVC   WTORRCR,EDMASK
         ED    WTORRCR,RCOUNT
         WTO   MF=(E,WTORCNT)
         L     R14,SAVE14
         L     R15,SAVE15
         BR    R14
PCHAN    EQU   *
         ST    R14,SAVE14
         ST    R15,SAVE15
         MVC   WTORPCOR(8),ORDERNUM
         MVC   WTORPCCR,EDMASK
         ED    WTORPCCR,RCOUNT
         WTO   MF=(E,WTORPCHN)
         L     R14,SAVE14
         L     R15,SAVE15
         BR    R14
PRLINE   EQU   *
         ST    R14,SAVE14
         ST    R15,SAVE15
         MVC   WTORRECN,EDMASK
         ED    WTORRECN,RCOUNT
         MVC   WTORCHAN(1),RRECORD
         MVC   WTORRBUF(22),RTEXT
         WTO   MF=(E,WTOREADR)
         L     R14,SAVE14
         L     R15,SAVE15
         BR    R14
         EJECT
IOWAITS  MVC   IOTIMEA,IOTIMES     SHORT LIMIT
         B     IOWGO
IOWAIT   MVC   IOTIMEA,IOTIMEL     NORMAL LIMIT
IOWGO    ST    R14,IOWSAVE
         ST    R1,WAITLST          FIRST ENTRY - THE OPERATION ECB
         XC    TIMERECB,TIMERECB
         LA    R1,TIMERECB
         O     R1,HIBIT            HIGH BIT MARKS THE LAST ENTRY
         ST    R1,WAITLST+4
         STIMER REAL,TIMEXIT,BINTVL=IOTIMEA
         WAIT  1,ECBLIST=WAITLST
         TM    TIMERECB,X'40'      DID THE TIMER GET THERE FIRST ?
         BO    IOWLATE
         TTIMER CANCEL             NO - STAND THE TIMER DOWN
         SR    R15,R15
         B     IOWEND
IOWLATE  EQU   *
         WTO   'IOWAIT TIMER TIMED OUT'
         LA    R15,4
IOWEND   L     R14,IOWSAVE
         BR    R14
         EJECT
TIMEXIT  SAVE  (14,12)
         LR    R12,R15             R15 = OUR OWN ENTRY POINT
         USING TIMEXIT,R12
         L     R2,TXECBP
         POST  (R2)
         RETURN (14,12)
TXECBP   DC    A(TIMERECB)
         SPACE 1
*        PUT THE PROGRAM BASES BACK.  THE USING ABOVE OVERRODE R12 FOR
*        THE EXIT , AND DROPPING IT WITHOUT RESTORING LEAVES THE REST
*        OF THE PROGRAM WITH ONLY R11 AND R10 - SO EVERYTHING IN THE
*        FIRST 4096 BYTES BECOMES UNADDRESSABLE.  THAT LOOKS LIKE A
*        SIZE PROBLEM IN THE DIAGNOSTICS AND IS NOT ONE.
         SPACE 1
         DROP  R12
         USING FOTOSRV1,R12,R11
         SPACE 2
DATAAREA DS    0F
LINESTAT DC    X'00'
         DS    0F
SAVEAREA DC    18F'0'
CALLAREA DC    18F'0'
SUBRC    DS    F
         DS    0F
TRMLST   DFTRMLST OPENLST,(0000)
         SPACE 2
         DS 0F
PARSE14  DS    F
LERBLK   DC    XL16'00'
         DS 0F
SNAPDCB  DCB   DSORG=PS,RECFM=VBA,LRECL=125,BLKSIZE=1632,              X
               DDNAME=SNAPDD,MACRF=(W)
         DS 0F
BSC2703  DCB   DSORG=CX,MACRF=(R,W),BUFNO=2,BUFL=256,BFALN=D,          X
               BFTEK=S,DDNAME=BSCDDN,DEVD=BS,LERB=LERBLK
         DS    0F
DECBWR   WRITE MSGOUT,TT,BSC2703,WRITEBUF,18,TRMLST,1,MF=L
         DS    0F
DECBRD   READ  MSGIN,TT,BSC2703,READBUF,135,TRMLST,1,MF=L
         DS    0F
DECBINIT WRITE INITOUT,TI,BSC2703,INITBUF,18,TRMLST,1,MF=L
         DS    0F                  Force fullword alignment
DECBCMD  READ  CMDIN,TI,BSC2703,CMDBUF,18,TRMLST,1,MF=L
         DS    0F                  Force fullword alignment
READBUF  DS    0CL135
RSTX     DS    CL1
RRECORD  DS    0CL133
RCHAN    DS    CL1
RTEXT    DS    CL132
RETX     DS    CL1
ONE      DC    PL4'1'
         DS    0D
RCOUNT   DC    PL4'0'
         DS    0F
WTOCMD   DC    AL2(WTOCMDL)
         DC    XL2'0000'
         DC    CL7'CMDLEN='
WTOCMDLN DC    CL6'    '
         DC    CL4'CMD='
WTOCMDR  DC    CL16'        '
WTOCMDL  EQU   *-WTOCMD
         DS    0F
WTORCNT  DC    AL2(WTORCNTL)
         DC    XL2'0000'
         DC    CL8'RECORDS:'
WTORRCR  DS    CL8
WTORCNTL EQU   *-WTORCNT
         DS    0F
WTORPCHN DC    AL2(WTORPCHL)
         DC    XL2'0000'
         DC    CL8'ORDER: ['
WTORPCOR DS    CL9
         DC    CL32'] CHANNEL 1 - DETECTED AT RECORD:'
WTORPCCR DS    CL8
WTORPCHL EQU   *-WTORPCHN
         DS    0F
WTOREADR DC    AL2(WTOREADL)
         DC    XL2'0000'
         DC    CL4'REC:'
WTORRECN DS    CL8
         DC    CL6' CHAN:'
WTORCHAN DS    CL1
         DC    CL5' BUF:'
WTORRBUF DS    CL22
WTOREADL EQU   *-WTOREADR
         DS    0F
EDMASK   DC    X'4020202020202020'
* READBUF  DS    0CL135
* RSTX     DS    CL1
* RRECORD  DS    CL133
* RETX     DS    CL1
WRITEBUF DS    0CL18
WSTX     DC    X'02'
WRECORD  DS    CL16
WETX     DC    X'03'
INITBUF  DS    0CL18
ISTX     DC    X'02'
IRECORD  DC    CL16'HELLO FOTOFIX***'
IETX     DC    X'03'
CMDBUF   DS    0CL18
CSTX     DC    X'02'
CRECORD  DS    CL16
CETX     DC    X'03'
         DS    0F
HELLO    DC    CL8'HELLO'
RBUF     DC    CL4' '
WTORECB  DC    F'0'


DYNPRINT DCB   DSORG=PS,MACRF=(PM),DDNAME=DYNPRINT,                    X
               RECFM=FBA,LRECL=133,SYNAD=MYSYNAD
CTRLINP DCB    DSORG=PS,MACRF=GM,DDNAME=SYSIN,                         X
               RECFM=FB,LRECL=80,EODAD=CTRLEOF
         DS    0F
EOFCTL   EQU   *
         DC    X'00'
         DS    0F
CTRLBUF  DS    CL80
         DS    0F
ORDERREC DS    0CL80
ORDERTYP DC    CL1' '
ORDERNUM DC    CL8'        '
ORDERSEQ DS    CL7
ORDERSTA DS    CL1
ORDERDEL DS    CL1
         DS    CL1
ORDERTRM DS    CL4
         DS    CL1
ORDERUSR DS    CL8
         DS    CL1
ORDERSYS DS    CL4
         DS    CL1
ORDPRTDT DS    CL10
         DS    CL1
ORDPRTTM DS    CL8
         DS    CL1
ORDERTXT DS    CL22
         DS    0F
DSNAME   DC    CL33' '
         DS    0F
LASTORDR DS    CL8                 * FOTOFIX ORDER/ROUTING SLIP NO.
         DS    0F
TEMPR15  DS    F
         DC    X'00'
         DS    0F
SAVE1    DS    F
SAVE2    DS    F
SAVE3    DS    F
SAVE4    DS    F
SAVE5    DS    F
SAVE6    DS    F
SAVE13   DS    F
SAVE14   DS    F
SAVE15   DS    F
CTRL14   DS    F
CTRL15   DS    F
PARS14   DS    F
COMMR3   DS    F
CMDSAV   DS    F
WTOSAV14 DS    F
WTOSAV15 DS    F
COMPTR   DS    F
STPSAVE  DS    F
NAPSAVE  DS    F
         DC    X'00'
HEXTAB   EQU   *-X'F0'
         DC    C'0123456789ABCDEF'
         DS    0F
TREQTAB  DC    256X'00'
         ORG   TREQTAB+X'7E'
         DC    X'FF'
         ORG   ,
         DS    0F
TRTMOD   TRT 0(0,R7),TREQTAB
SAVERR   DS    XL2
SAVEINF  DS    XL2
LINENUM  DC    X'00'
DIALNUM  DC    AL1(4)
         DC    C'123'
         DC    X'FC'
         DS    0F
WTOL40   DC    AL2(WTOL40L-WTOL40)
         DC    XL2'0000'
         DC    C'REC:'
WTOL40M  DS    CL40
WTOL40L  EQU   *
         DS    0F
WTOPLIST DC    AL2(WTOLEND-WTOPLIST)
WTOMSCG  DC    H'0'
WTOMSG   DC    C'*** BTAM ERROR:  ECB='
WTOMSGE  DS    CL2
         DC    C' STATUS1='
WTOMSTS  DS    CL2
WTOLEND  EQU   *
         DS    0F
WTOWRTER DC    AL2(WTOWRTEL)
         DC    XL2'0000'
         DC    CL19'I/O FAILED!    R15='
WTOR15   DC    CL8'********'
         DC    CL2'   '
WTORTXT  DC    CL8'--------'
WTOWRTEL EQU   *-WTOWRTER
         DS    0F
WTOWRET  DC    AL2(WTOWRETL)
         DC    XL2'0000'
         DC    CL6'FUNC:['
WTOWFNC  DC    CL8'########'
         DC    CL2'] '
         DC    CL5'R15= ['
WTORET15 DC    CL8'********'
         DC    CL2'   ]'
WTOWRETL EQU   *-WTOWRET
         DS    0F
WTOPROFT DC    AL2(WTOPELEN)
         DC    XL2'0000'
         DC    C'INPUT ORDER NUMBER IS:['
WTOLAUFN DC    CL8'********'
         DC    C']'
WTOPELEN EQU   *-WTOPROFT
         DS    0F
UNITEXF  EQU   *
         DC    X'00'
         DS    0F
HEXWORK  DS    CL5
         DS    0F
CMDBYTE  DC    X'00'
         DS    0F
PARMLIST EQU   *
         DC    A(ORDERNUM)
         DC    A(DSNAME+X'80000000')
         DS    0F
PARMORDR EQU   *
         DC    A(ORDERREC)
         DC    A(CMDBYTE+X'80000000')
         DS    0F
WORK5    DC    CL5'     '
         DS    0F
CMDWRKLN DC    H'0'
         DS    0F
CMDWRKA  DC    CL32' '
         DS    0F
IOWSAVE  DS    F
WAITLST  DS    2F                  OPERATION ECB , THEN THE TIMER ECB
TIMERECB DS    F
HIBIT    DC    X'80000000'         LAST ENTRY MARKER FOR AN ECB LIST
IOTIMEL  DC    AL4(IOTIMLV)        LIMIT FOR WAITING ON THE PARTNER
IOTIMES  DC    AL4(IOTIMSV)        LIMIT FOR A BID
IOTIMEA  DS    F                   THE ONE IN FORCE FOR THIS OPERATION
SLBSAVE  DS    F
ONESECX  DC    X'00000064'         100 = ONE SECOND IN 1/100 UNITS
OUTOPEN  DC    C'N'
OUTPERF  DC    C'N'
STOPFLAG DC    C'N'
MODFLAG  DC    C'N'
         LTORG
         DCBD DSORG=BX,DEVD=BS
         IECTDECB
COMAREA  DSECT
         IEZCOM
         SPACE 1
CIBAREA  DSECT
         IEZCIB
         END FOTOSRV1
/*
//LINKPRG EXEC PGM=IEWL,PARM='XREF,LIST,LET,MAP',COND=(4,LT,ASM)
//SYSPRINT DD SYSOUT=*
//SYSUT1   DD UNIT=(SYSDA,SEP=(SYSLMOD,SYSLIN)),
//            SPACE=(1024,(200,20))
//SYSLIN   DD DISP=(OLD,DELETE),
//            DCB=(LRECL=80,RECFM=FB,BLKSIZE=400),
//            DSN=*.ASM.SYSPUNCH
//         DD DSN=EKATUS.OBJLIB(ORDERS),DISP=SHR
//         DD DSN=EKATUS.OBJLIB(ALLOCFI),DISP=SHR
//         DD DSN=EKATUS.OBJLIB(SUBMITJ),DISP=SHR
//         DD DSN=EKATUS.OBJLIB(CCWIO),DISP=SHR
//         DD DSN=EKATUS.OBJLIB(RESET),DISP=SHR
//         DD DSN=EKATUS.TEST.OBJLIB(DYNALLC),DISP=SHR
//         DD DSN=EKATUS.TEST.OBJLIB(MVSLOCK),DISP=SHR
//SYSLMOD  DD DISP=SHR,DSN=EKATUS.LOADLIB(FOTOSRV1)
//SYSIN    DD *
 ENTRY FOTOSRV1
 NAME  FOTOSRV1(R)
/*
