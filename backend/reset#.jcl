//RESET1A# JOB  (AXX,BXX,CXX),
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
//SYSPUNCH DD DSN=EKATUS.OBJLIB(RESET),DISP=OLD
//SYSIN    DD *
***********************************************************************
** MODULE RESET                                                      **
** CALL PARAMETERS                                                   **
**       R0    = FUNCTION CODE                                       **
**               1: UPDATE ALL ORDERS NEW                            **
**               2: UPDATE ALL ORDERS COMPLETE                       **
**               3: UPDATE ALL ORDERS CANCELLED                      **
**       R1    = PARMLIST                                            **
**       PARMLIST:                                                   **
**               ADDRESS TO ORDERREC   80 Bytes INPUT / OUTPUT       **
***********************************************************************
         START 0
RESET    CSECT
         SAVE  (14,12)
         BALR  12,0
         USING *,12
         LA    11,DAT1AREA
         USING DAT1AREA,11
         ST    13,SAV1AREA+4
         LA    14,SAV1AREA
         ST    14,8(13)
         LR    13,14
         ST    14,SAVE14
         ST    15,SAVE15
         L     2,0(1)                * R2 holds address to ORDERREC
         N     2,=X'7FFFFFFF'        * Clear out High BIT (0) Marker
         USING ORDERREC,2
         ST    0,SAVE0
         ST    1,SAVE1
         ST    2,SAVE2
         WTO   '[RESET] SUB MODULE RESET ORDER BOOK'
         ENQ   (QNAME,MYRNAME,E,44,SYSTEM),RET=USE
         LTR   15,15
         BNZ   ERRENQ
         WTO   '[RESET] LOCK OF ORDER BOOK SUCCESSFUL'
         OPEN  (ORDERBK,INOUT)       * VSAM ORDER BOOK
         LTR   15,15
         BNZ   ERRVSAM
         WTO   '[RESET] ORDER BOOK OPENED'
*-------------------------------------------------------------------*
* FUNCTION CODE ## - FETCH NEXT OPEN ORDER FROM VSAM CLUSTER        *
*-------------------------------------------------------------------*
         L     0,SAVE0
         CH    0,=H'0'               *  INFO
         BE    INFOVSAM
         CH    0,=H'1'               *  UPDATE NEW
         BE    UPDNEW
         CH    0,=H'2'               *  UPDATE PRINTED
         BE    UPDPRT
         CH    0,=H'3'               *  UPDATE CANCELLED
         BE    UPDCAN
         WTO   '[RESET] UNKNOWN FUNCTION CODE'
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
         WTO   '[RESET] THIS IS THE ORDER BOOK RESET MODULE'
         B     EXIT
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
ERRMOD1  EQU   *
         WTO   '[RESET] ERROR MODIFYING RPL FOR UPDATE AS PRINTED'
         SR    6,6
         LA    6,16
         B     EXIT
ERRMOD2  EQU   *
         WTO   '[RESET] ERROR MODIFYING RPL FOR UPDATE AS CANCELLED'
         SR    6,6
         LA    6,16
         B     EXIT
ERRUPDG  EQU   *
         WTO   '[RESET] RECORD NOT FOUND FOR UPDATE'
         LA    6,4
         ST    6,SUBRC
         B     EXIT
ERRUPD   EQU   *
         WTO   '[RESET] ERROR WRITING RECORD ON UPDATE'
         LA    6,8
         ST    6,SUBRC
         B     ERREXIT
ERRRDR   EQU   *
         WTO   '[RESET] ERROR READING RECORD FOR UPDATE'
         LA    6,8
         ST    6,SUBRC
         B     ERREXIT
UPDPRT EQU *
         WTO   '[RESET] UPDATING ORDER AS PRINTED'
         MVC   UPDCODE(1),=C'C'
         B     UPDLOOP
UPDCAN EQU *
         WTO   '[RESET] UPDATING ORDER AS CANCELLED'
         MVC   UPDCODE(1),=C'D'
         B     UPDLOOP
UPDNEW EQU *
         WTO   '[RESET] UPDATING ORDER AS NEW'
         MVC   UPDCODE(1),=C'P'
UPDLOOP EQU *
         ST    14,SAVE14
         MVC   VSAMKEY,=XL16'00000000000000000000000000000000'
         POINT RPL=RPLREAD
         LTR   15,15
         BNZ   CHECKEOF
NEXTREC  EQU    *
         WTO   '[RESET] READING NEXT RECORD'
         GET   RPL=RPLUPDT
         LTR   15,15
         BNZ   CHECKEOF
         MVC   VSAMSTAT(1),UPDCODE
         MODCB RPL=RPLUPDT,RECLEN=80
         PUT   RPL=RPLUPDT
         LTR   15,15
         BNZ   ERRUPD
         BAL   14,PRSTAT
         BAL   14,PRINTREC
         B     NEXTREC
NOORDER  EQU   *
         WTO   '[RESET] NO ORDERS'
         LA     6,4
         ST     6,SUBRC
         ST     6,REGSAV
         MVC   WTOREGN(3),=CL8'R15'
         B     EXIT
         DS    0F
EXIT     EQU   *
         CLOSE (ORDERBK)                 * CLOSE VSAM ACB
         WTO   '[RESET] ORDER BOOK CLOSED'
         DEQ   (QNAME,MYRNAME,44,SYSTEM),RET=HAVE  *UNLOCK ACCESS
         LTR   15,15
         BNZ   ERRDEQ
         WTO   '[RESET] UNLOCKING OF ORDER BOOK SUCCESSFUL'
EXITRET  EQU   *
         L     15,REGSAV
         BAL   14,LOGREG
         L     13,4(,13)
         LM    14,12,12(13)
         L     15,SUBRC                  * LOAD return code
         DROP  2
         BR    14
CHECKEOF EQU   *
         C     15,=F'4'
         BE    EOF
         C     15,=F'8'
         BNE   ERRRDR
         WTO   '[RESET] CHECKING RPL'
*        B     RPLPASS
         L     3,RPLADDR
         XR    15,15
         IC    15,15(,3)
RPLPASS  EQU   *
         ST    15,REGSAV
         MVC   WTOREGN(3),=CL8'RPL'
         B     EXIT
EOF      EQU   *
         WTO   '[RESET] END OF FILE'
         LA     6,4
         ST     6,SUBRC
         ST     6,REGSAV
         MVC   WTOREGN(3),=CL8'R15'
         B     EXIT
ERREXIT  EQU   *
         LA     6,8
         ST     6,SUBRC
         ST     6,REGSAV
         MVC   WTOREGN(3),=CL8'R15'
         B     EXIT
ERRVSAM EQU    *
         MVC   WTORTXT(8),=CL8'VSAM :'
         BAL   14,ERRWTOIO
         B     ERREXIT
ERRENQ   EQU   *
         ST    15,REGSAV
         WTO   '[RESET] ERROR ENQ RESOURCE'
         B     ERREXIT
ERRDEQ   EQU   *
         ST    15,REGSAV
         WTO   '[RESET] ERROR DEQ RESOURCE'
         B     ERREXIT
ERRWTOIO EQU   *
         ST    0,SAVE0
         ST    1,SAVE1
         ST    2,SAVE2
         ST    3,SAVE3
         ST    4,SAVE4
         ST    15,SAVE15
         ST    14,SAVE14
         UNPK  WTOR15(9),SAVE15(5)
         TR    WTOR15(4),HEXTAB
         WTO   MF=(E,WTOWRTER)
         L     0,SAVE0
         L     1,SAVE1
         L     2,SAVE2
         L     3,SAVE3
         L     4,SAVE4
         L     15,SAVE15
         L     14,SAVE14
         BR    14
PRSTAT   EQU   *
         ST    0,SAVE0
         ST    1,SAVE1
         ST    2,SAVE2
         ST    3,SAVE3
         ST    4,SAVE4
         ST   14,SAVE14
         ST   15,SAVE15
         MVC   WTOSTATT(1),VSAMSTAT
         WTO   MF=(E,WTOSTAT)
         L     0,SAVE0
         L     1,SAVE1
         L     2,SAVE2
         L     3,SAVE3
         L     4,SAVE4
         L    14,SAVE14
         L    15,SAVE15
         BR    14
LOGREG   EQU   *
         ST    0,SAVE0
         ST    1,SAVE1
         ST    2,SAVE2
         ST    3,SAVE3
         ST    4,SAVE4
         ST    15,SAVE15
         ST    14,SAVE14
         UNPK  WTOREGV(9),REGSAV(5)
         TR    WTOREGV(4),HEXTAB
         WTO   MF=(E,WTOREG)
         L     0,SAVE0
         L     1,SAVE1
         L     2,SAVE2
         L     3,SAVE3
         L     4,SAVE4
         L     15,SAVE15
         L     14,SAVE14
         BR    14
         LTORG
DAT1AREA EQU   *
         DS    0F
SAV1AREA DC    18F'0'
SAVE0    DS    F
SAVE1    DS    F
SAVE2    DS    F
SAVE3    DS    F
SAVE4    DS    F
SAVE13   DS    F
SAVE14   DS    F
SAVE15   DS    F
REGSAV   DS    F
SUBRC    DS    F
         DS    0F
ORDERBK  ACB   AM=VSAM,DDNAME=FORDERS,MACRF=(KEY,SEQ,DIR,IN,OUT)
RPLREAD  RPL   AM=VSAM,ACB=ORDERBK,AREA=VSAMREC,AREALEN=80,            X
               ARG=VSAMKEY,KEYLEN=16,RECLEN=80,                        X
               OPTCD=(KEY,DIR,SYN,NUP,KGE,FWD)
RPLUPDT  RPL   AM=VSAM,ACB=ORDERBK,AREA=VSAMREC,AREALEN=80,            X
               ARG=VSAMKEY,KEYLEN=16,RECLEN=80,                        X
               OPTCD=(KEY,SEQ,SYN,UPD,KEQ,FWD,MVE)
         DS    0F
RPLADDR  DC    A(RPLUPDT)
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
RPLKEY   DS    CL1'X'
UPDCODE  DC    CL1'P'
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
         DC    CL22'[RESET] KEY FOR UPDATE:'
WTOKEYR  DS    CL16
WTOKEYL  EQU   *-WTOKEY
         DS    0F
WTOORD   DC    AL2(WTOORDL)
         DC    XL2'0000'
         DC    CL17'[RESET] ORDER NO:['
WTORESET DC    CL8' '
         DC    CL1']'
WTOORDL  EQU   *-WTOORD
         DS    0F
WTOWRTER DC    AL2(WTOWRTEL)
         DC    XL2'0000'
         DC    CL26'[RESET] I/O FAILED!   R15='
WTOR15   DC    CL8'********'
         DC    CL2'   '
WTORTXT  DC    CL8'--------'
WTOWRTEL EQU   *-WTOWRTER
         DS    0F
WTOREC   DC    AL2(WTORECL)
         DC    XL2'0000'
         DC    CL12'[RESET] REC:'
WTORECM  DC    CL44' '
WTORECL  EQU   *-WTOREC
         DS    0F
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
