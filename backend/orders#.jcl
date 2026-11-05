//ORDERS1# JOB  (AXX,BXX,CXX),
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
//SYSPUNCH DD DSN=EKATUS.OBJLIB(ORDERS),DISP=OLD
//SYSIN    DD *
***********************************************************************
** MODULE ORDERS                                                     **
** CALL PARAMETERS                                                   **
**       R0    = FUNCTION CODE                                       **
**               1: GET NEXT OPEN ORDER                              **
**               2: UPDATE OPEN ORDER COMPLETE                       **
**               3: UPDATE OPEN ORDER CANCELED                       **
**       R1    = PARMLIST                                            **
**       PARMLIST:                                                   **
**               ADDRESS TO ORDERREC   80 ytes INPUT / OUTPUT        **
***********************************************************************
         START 0
         REGISTER
ORDERS   CSECT
         SAVE  (14,12)
         BALR  R12,0
         USING *,R12
         LA    R11,DAT1AREA
         USING DAT1AREA,R11
         ST    R13,SAV1AREA+4
         LA    R14,SAV1AREA
         ST    R14,8(R13)
         LR    R13,R14
         ST    R14,SAVE14
         ST    R15,SAVE15
         L     R2,0(R1)                * R2 holds address to ORDERREC
         N     R2,=X'7FFFFFFF'        * Clear out High BIT (0) Marker
         USING ORDERREC,R2
         ST    R0,SAVE0
         ST    R1,SAVE1
         ST    R2,SAVE2
         WTO   '[ORDR] SUB MODULE ORDER BOOK'
         ENQ   (QNAME,MYRNAME,E,44,SYSTEM),RET=HAVE
         LTR   15,15
         BNZ   ERRENQ
         WTO   '[ORDR] LOCK OF ORDER BOOK SUCCESSFUL'
         BAL   R14,ALLOC
         LTR   R15,R15
         BNZ   ERRALLOC
         WTO   '[ORDR] ALLOCATION OF ORDER BOOK SUCCESSFUL'
*-------------------------------------------------------------------*
* FUNCTION CODE ## - FETCH NEXT OPEN ORDER FROM VSAM CLUSTER        *
*-------------------------------------------------------------------*
         L     0,SAVE0
         CH    0,=H'0'               *  INFO
         BE    INFOVSAM
         CH    0,=H'1'               *  FETCH NEXT
         BE    FETCHNXT
         CH    0,=H'2'               *  UPDATE
         BE    UPDATEBK
         CH    0,=H'3'               *  CANCEL
         BE    CANCELBK
         WTO   '[ORDR] UNKNOWN FUNCTION CODE'
         L      0,SAVE0
         ST     0,WORKREG
         UNPK  HEXOUT8(9),WORKBYTE(5)
         TR    HEXOUT8(8),HEXTAB
         MVC   WTOREGN(2),=C'R0'
         MVC   WTOREGV(8),HEXOUT8
         WTO   MF=(E,WTOREG)
         L      1,SAVE1
         ST     1,WORKREG
         UNPK  HEXOUT8(9),WORKBYTE(5)
         TR    HEXOUT8(8),HEXTAB
         MVC   WTOREGN(2),=C'R1'
         MVC   WTOREGV(8),HEXOUT8
         WTO   MF=(E,WTOREG)
         L      2,SAVE2
         ST     2,WORKREG
         UNPK  HEXOUT8(9),WORKBYTE(5)
         TR    HEXOUT8(8),HEXTAB
         MVC   WTOREGN(2),=C'R2'
         MVC   WTOREGV(8),HEXOUT8
         WTO   MF=(E,WTOREG)
         B     EXIT
INFOVSAM EQU   *
         WTO   'THIS IS THE VSAM ORDER ACCESS MODULE'
         B     EXIT
***********************************************************************
*                                                                     *
* DYNAMIC ALLOCATION AND DEALLOCATION OF THE ORDERBOOK VSAM CLUSTER   *
* INCLUDING RESOURCE LOCKING VIA ENQ AND DEQ                          *
*                                                                     *
***********************************************************************
ALLOC    EQU   *
         MVC   FUNC,=C'AL'       * ALLOCATE WITH LOCK
         B     DYNCALL
DEALLOC  EQU   *
         MVC   FUNC,=C'FL'       * DEALLOCATE AND UNLOCK
DYNCALL  EQU   *
         LA    R1,PARMS          * SET UP PARMS REGISTER
         L     R15,=V(DYNALLC)   * LOAD SUBPROGRAM ADDRESS
         ST    R14,SAVE14        * SAVE OWN CALLERS ADDRESS
         BALR  R14,R15
         L     R14,SAVE14        * RESTORE OWN CALLERS ADDRESS
         BR    R14               * RETURN TO CALLER
PRINTKEY EQU   *
         MVC   WTOKEYR,VSAMKEY
         ST     1,SAVE1
         ST     2,SAVE2
         ST     3,SAVE3
         ST     4,SAVE4
         ST    14,SAVE14
         ST    15,SAVE15
         WTO   MF=(E,WTOKEY)
         L      1,SAVE1
         L      2,SAVE2
         L      3,SAVE3
         L      4,SAVE4
         L     14,SAVE14
         L     15,SAVE15
         BR    14
PRINTREC EQU   *
         ST     1,SAVE1
         ST     2,SAVE2
         ST     3,SAVE3
         ST     4,SAVE4
         ST    14,SAVE14
         ST    15,SAVE15
         MVC   WTORECM(44),VSAMREC
         WTO   MF=(E,WTOREC)
         L      1,SAVE1
         L      2,SAVE2
         L      3,SAVE3
         L      4,SAVE4
         L     14,SAVE14
         L     15,SAVE15
         BR    14
UPDATEBK EQU *
         OPEN  (ORDERBK,INOUT)       * VSAM ORDER BOOK
         LTR   15,15
         BNZ   ERRVSAM
         MVI    VSAMREC,C' '
         MVC    VSAMREC+1(L'VSAMREC-1),VSAMREC    * CLEARING OUT THE
         ST     1,SAVE1                           * VSAM BUFFER
         ST     2,SAVE2
         ST     3,SAVE3
         ST     4,SAVE4
         ST    14,SAVE14
         ST    15,SAVE15
         WTO   '[ORDR] UPDATING ORDER'
         MVC   WTOORDR(8),ORDERNUM
         WTO   MF=(E,WTOORD)
         L      1,SAVE1
         L      2,SAVE2
         L      3,SAVE3
         L      4,SAVE4
         L     14,SAVE14
         L     15,SAVE15
         MVC   VSAMTYP,ORDERTYP
         MVC   VSAMORD,ORDERNUM
         MVC   VSAMSEQ,ORDERSEQ
         BAL   14,PRINTKEY
         GET   RPL=RPLUPDT
         LTR   15,15
         BNZ   ERRUPDG
         MVC   VSAMSTAT,=C'C'
         BAL   14,PRINTREC
         MODCB RPL=RPLUPDT,RECLEN=80
         LTR   15,15
         BNZ   ERRMOD1
         PUT   RPL=RPLUPDT
         LTR   15,15
         BNZ   ERRUPDP
         WTO   '[ORDR] UPDATE SUCCESSFUL'
         SR    6,6
         ST    6,SUBRC
         B     EXIT
ERRMOD1  EQU   *
         WTO   '[ORDR] ERROR MODIFYING RPL FOR UPDATE'
         SR    6,6
         LA    6,16
         B     EXIT
ERRMOD2  EQU   *
         WTO   '[ORDR] ERROR MODIFYING RPL FOR CANCEL'
         SR    6,6
         LA    6,16
         B     EXIT
ERRUPDG  EQU   *
         WTO   '[ORDR] RECORD NOT FOUND FOR UPDATE'
         LA    6,4
         ST    6,SUBRC
         B     EXIT
ERRUPDP  EQU   *
         WTO   '[ORDR] ERROR WRITING RECORD ON UPDATE'
         LA    6,8
         ST    6,SUBRC
         B     EXIT
CANCELBK EQU *
         OPEN  (ORDERBK,INOUT)       * VSAM ORDER BOOK
         LTR   15,15
         BNZ   ERRVSAM
         MVC   VSAMORD,ORDERNUM
         MVC   VSAMTYP,ORDERTYP
         MVC   VSAMSEQ,ORDERSEQ
         BAL   14,PRINTKEY
         GET   RPL=RPLUPDT
         LTR   15,15
         BNZ   ERRCANG
         MVC   VSAMSTAT,=C'D'
         BAL   14,PRINTREC
         MODCB RPL=RPLUPDT,RECLEN=80
         LTR   15,15
         BNZ   ERRMOD2
         PUT   RPL=RPLUPDT
         LTR   15,15
         BNZ   ERRCANP
         WTO   '[ORDR] CANCEL SUCCESSFUL'
         SR    6,6
         ST    6,SUBRC
         B     EXIT
ERRCANG  EQU   *
         WTO   '[ORDR] RECORD NOT FOUND FOR CANCEL'
         LA    6,4
         ST    6,SUBRC
         B     EXIT
ERRCANP  EQU   *
         WTO   '[ORDR] ERROR WRITING RECORD ON CANCEL'
         LA    6,8
         ST    6,SUBRC
         B     EXIT
FETCHNXT EQU *
         SR    R9,R9                 * RESET COUNTER
         OPEN  (ORDERBK,INPUT)       * VSAM ORDER BOOK
         LTR   R15,R15
         BNZ   ERRVSAM
         ST    R14,SAVE14
         WTO   '[ORDR] ORDER BOOK OPENED'
         MVI   RPLKEY,C'O'
         POINT RPL=RPLREAD
         LTR   R15,R15
         BNZ   NOORDER
NEXTREC  EQU    *
*        WTO   '[ORDR] READING NEXT RECORD'
         GET   RPL=RPLREAD
         LTR   15,15
         BNZ   EOF
         LA    R9,1(R9)
*        BAL   14,PRSTAT             * Increase record counter
         CLI   VSAMSTAT,C'P'         * Pending order?
         BNE   NEXTREC
ORDERFND EQU   *
         ST    R2,SAVE2
         ST    R3,SAVE3
         ST    R4,SAVE4
         ST    R9,SAVE9
         ST    R14,SAVE14
         WTO   '[ORDR] PENDING ORDER FOUND'
         MVC   ORDERREC(80),VSAMREC
         MVC   WTORECM(44),VSAMREC
         WTO   MF=(E,WTOREC)
         MVC   WTOORDR(8),VSAMORD
         WTO   MF=(E,WTOORD)
         L     R2,SAVE2
         L     R3,SAVE3
         L     R4,SAVE4
         L     R9,SAVE9
         L     R14,SAVE14
         BAL   R14,RECSTAT
*        MVC   0(8,2),VSAMORD
*        MVC   0(8,3),VSAMTERM
*        MVC   0(1,4),VSAMCMD
         LA     R6,0
         ST     R6,SUBRC
         ST     R6,REGSAV
         MVC   WTOREGN(3),=CL8'R15'
         B     EXIT
NOORDER  EQU   *
         WTO   '[ORDR] NO ORDERS'
         LA     R6,4
         ST     R6,SUBRC
         ST     R6,REGSAV
         MVC   WTOREGN(3),=CL8'R15'
         B     EXIT
         DS    0F
EXIT     EQU   *
         CLOSE (ORDERBK)                 * CLOSE VSAM ACB
         WTO   '[ORDR] ORDER BOOK CLOSED'
         BAL   R14,DEALLOC               * DEALLOCATE CLUSTER
         LTR   R15,R15
         BNZ   ERRDALC
         WTO   '[ORDR] DE-ALLOCATION OF ORDER BOOK SUCCESSFUL'
         DEQ   (QNAME,MYRNAME,44,SYSTEM),RET=HAVE *Unlock access
         LTR   R15,R15
         BNZ   ERRDEQ
         WTO   '[ORDR] UNLOCKING OF ORDER BOOK SUCCESSFUL'
EXITRET  EQU   *
         L     R15,REGSAV
*        BAL   R14,LOGREG
         L     R15,SUBRC                  * LOAD return code
         L     R13,4(,R13)
         ST    R15,16(,R13)
         LM    R14,R12,12(R13)
         DROP  R2
         BR    R14
EOF      EQU   *
         WTO   '[ORDR] END OF FILE'
         LA     R6,4
         ST     R6,SUBRC
         ST     R6,REGSAV
         MVC   WTOREGN(3),=CL8'R15'
         B     EXIT
ERREXIT  EQU   *
         LA    R6,8
         ST    R6,SUBRC
         ST    R6,REGSAV
         MVC   WTOREGN(3),=CL8'R15'
         B     EXIT
ERRVSAM EQU    *
         MVC   WTORTXT(8),=CL8'VSAM :'
         BAL   R14,ERRWTOIO
         B     ERREXIT
ERRALLOC EQU   *
         ST    R15,REGSAV
         WTO   '[ORDR] ERROR ALLOCATING THE ORDER BOOK'
         B     ERREXIT
ERRDALC  EQU   *
         WTO   '[ORDR] ERROR DE-ALLOCATING THE ORDER BOOK'
         ST    R15,REGSAV
         B     ERREXIT
ERRENQ   EQU   *
         ST    R15,REGSAV
         WTO   '[ORDR] ERROR ENQ RESOURCE'
         B     ERREXIT
ERRDEQ   EQU   *
         ST    R15,REGSAV
         WTO   '[ORDR] ERROR DEQ RESOURCE'
         B     ERREXIT
ERRWTOIO EQU   *
         ST    R0,SAVE0
         ST    R1,SAVE1
         ST    R2,SAVE2
         ST    R3,SAVE3
         ST    R4,SAVE4
         ST    R5,SAVE15
         ST    R4,SAVE14
         UNPK  WTOR15(9),SAVE15(5)
         TR    WTOR15(4),HEXTAB
         WTO   MF=(E,WTOWRTER)
         L     R0,SAVE0
         L     R1,SAVE1
         L     R2,SAVE2
         L     R3,SAVE3
         L     R4,SAVE4
         L     R15,SAVE15
         L     R14,SAVE14
         BR    R14
RECSTAT  EQU   *
         ST    R14,SAVE14
         ST    R15,SAVE15
         ST    R9,WORKREG
         UNPK  HEXOUT8(9),WORKREG(5)
         TR    HEXOUT8(8),HEXTAB
         MVC   WTORNUMR(8),HEXOUT
         WTO   MF=(E,WTORNUM)
         L     R14,SAVE14
         L     R15,SAVE15
         BR    R14
PRSTAT   EQU   *
         ST    R0,SAVE0
         ST    R1,SAVE1
         ST    R2,SAVE2
         ST    R3,SAVE3
         ST    R4,SAVE4
         ST   R14,SAVE14
         ST   R15,SAVE15
         MVC   WTOSTATT(1),VSAMSTAT
         WTO   MF=(E,WTOSTAT)
         L     R0,SAVE0
         L     R1,SAVE1
         L     R2,SAVE2
         L     R3,SAVE3
         L     R4,SAVE4
         L    R4,SAVE14
         L    R5,SAVE15
         BR   R14
LOGREG   EQU   *
         ST    R0,SAVE0
         ST    R1,SAVE1
         ST    R2,SAVE2
         ST    R3,SAVE3
         ST    R4,SAVE4
         ST    R15,SAVE15
         ST    R14,SAVE14
         UNPK  WTOREGV(9),REGSAV(5)
         TR    WTOREGV(4),HEXTAB
         WTO   MF=(E,WTOREG)
         L     R0,SAVE0
         L     R1,SAVE1
         L     R2,SAVE2
         L     R3,SAVE3
         L     R4,SAVE4
         L     R15,SAVE15
         L     R14,SAVE14
         BR    R14
         LTORG
DAT1AREA EQU   *
         DS    0F
SAV1AREA DC    18F'0'
SAVE0    DS    F
SAVE1    DS    F
SAVE2    DS    F
SAVE3    DS    F
SAVE4    DS    F
SAVE5    DS    F
SAVE6    DS    F
SAVE7    DS    F
SAVE8    DS    F
SAVE9    DS    F
SAVE13   DS    F
SAVE14   DS    F
SAVE15   DS    F
REGSAV   DS    F
SUBRC    DS    F
         DS    0F
ORDERBK  ACB   AM=VSAM,DDNAME=FFIXORD,MACRF=(KEY,SEQ,DIR,IN,OUT)
RPLREAD  RPL   AM=VSAM,ACB=ORDERBK,AREA=VSAMREC,AREALEN=80,            X
               ARG=RPLKEY,KEYLEN=1,RECLEN=80,                          X
               OPTCD=(KEY,SEQ,SYN,NUP,GEN)
RPLUPDT  RPL   AM=VSAM,ACB=ORDERBK,AREA=VSAMREC,AREALEN=80,            X
               ARG=VSAMKEY,KEYLEN=16,RECLEN=80,                        X
               OPTCD=(KEY,DIR,SYN,UPD,GEN)
VSAMREC  DS    0CL80
VSAMKEY  DS    CL16
         ORG   VSAMKEY
VSAMTYP  DS    C                   * 'O'
VSAMORD  DS    CL8                 * FOTOFIX ORDER NUMBER
VSAMSEQ  DS    CL7                 * Sequence Number (Timestamp)
VSAMSTAT DS    C                   * Status-Byte ('P' or 'C')
VSAMDELF DS    C                   * DELETE FLAG ('Y' or 'N')
         DS    C
VSAMTERM DS    CL4                 * TERMINAL ID
VSAMUSER DS    CL8
         DS    C
VSAMSYS  DS    CL4
         DS    C
VSAMPRTD DS    CL10
         DS    C
VSAMPRTT DS    CL8
         DS    C
VSAMDATA DS    CL22
         ORG
RPLKEY   DS    CL1
         DS    0F
WTOREG   DC    AL2(WTOREGL)
         DC    XL2'0000'
         DC    CL12'[ORDER] REG '
WTOREGN  DC    CL2'--'
         DC    CL2'= '
WTOREGV  DC    CL8'--------'
WTOREGL  EQU   *-WTOREG
         DS    0F
WTOSTAT  DC    AL2(WTOSTATL)
         DC    XL2'0000'
         DC    CL10'VSAMSTAT=['
WTOSTATT DS    CL1
         DC    CL1']'
WTOSTATL EQU   *-WTOSTAT
         DS    0F
WTOKEY   DC    AL2(WTOKEYL)
         DC    XL2'0000'
         DC    CL22'[ORDR] KEY FOR UPDATE:'
WTOKEYR  DS    CL16
WTOKEYL  EQU   *-WTOKEY
         DS    0F
WTOORD   DC    AL2(WTOORDL)
         DC    XL2'0000'
         DC    CL17'[ORDR] ORDER NO:['
WTOORDR  DC    CL8' '
         DC    CL1']'
WTOORDL  EQU   *-WTOORD
         DS    0F
WTOWRTER DC    AL2(WTOWRTEL)
         DC    XL2'0000'
         DC    CL26'[ORDR] I/O FAILED!    R15='
WTOR15   DC    CL8'********'
         DC    CL2'   '
WTORTXT  DC    CL8'--------'
WTOWRTEL EQU   *-WTOWRTER
         DS    0F
WTOREC   DC    AL2(WTORECL)
         DC    XL2'0000'
         DC    CL12'[ORDR]  REC:'
WTORECM  DC    CL44' '
WTORECL  EQU   *-WTOREC
         DS    0F
WTORNUM  DC    AL2(WTORNUML)
         DC    XL2'0000'
         DC    CL22'# OF RECORDS SEARCHED:'
WTORNUMR DC    CL8'        '
WTORNUML EQU   *-WTORNUM
HEXTAB   EQU   *-X'F0'
         DC    C'0123456789ABCDEF'
         DS    0F
WORKREG  DS    XL4
PADDING  DC    X'00'
HEXOUT8  DS    CL8
TRAIL8   DS    XL1
         DS    0F
WORKBYTE DS    XL1
PADBYTE  DC    X'00'
HEXOUT   DS    CL2
TRAIL    DS    XL1
         DS    0F
PARMS    EQU *
         DC    A(FUNC)
         DC    A(DDNAME)
         DC    A(DSNAME+X'80000000')
         DS    0F
FUNC     DC    CL2'AN'
         DS    0F
DDNAME   DC    CL8'FFIXORD '
DSNAME   DC    CL44'FOTOFIX.ORDERBK.CLUSTER                     '
QNAME    DC    CL8'FOTOFIX '
MYRNAME  DC    CL44'FOTOFIX.ORDERBK.CLUSTER                     '
         DS    0F
         LTORG
ORDERREC DSECT
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
         END
