//DYNALLC# JOB  (AXX,BXX,CXX),
//          CLASS=A,MSGLEVEL=(1,1),
//          MSGCLASS=X,NOTIFY=&SYSUID
//ASM   EXEC PGM=IFOX00,PARM=(OBJECT,NODECK,XREF)
//SYSLIB   DD DSN=SYS1.MACLIB,DISP=SHR
//         DD DSN=SYS2.MACLIB,DISP=SHR
//         DD DSN=SYS1.AMODGEN,DISP=SHR
//SYSPRINT DD SYSOUT=*
//SYSUT1   DD UNIT=SYSDA,SPACE=(CYL,(2,1))
//SYSUT2   DD UNIT=SYSDA,SPACE=(CYL,(2,1))
//SYSUT3   DD UNIT=SYSDA,SPACE=(CYL,(2,1))
//SYSLIN   DD DUMMY
//SYSPUNCH DD DUMMY
//SYSGO    DD DSN=EKATUS.TEST.OBJLIB(DYNALLC),DISP=OLD
//SYSIN    DD *
         START 0
         REGISTER
DYNALLC  CSECT
         SAVE  (14,12)
         BALR  R12,0
         USING *,R12
         LA    R11,DATAAREA
         USING DATAAREA,R11
         ST    R13,SAVEAREA+4
         LA    R14,SAVEAREA
         ST    R14,8(R13)
         LR    R13,R14
         ST    R13,SAVE13
         L     R2,0(R1)                  * FUNCTION AN,AL,FN,FL
*        L     R3,4(R1)                  * DDNLEN
         L     R4,4(R1)                  * DDNAME
*        L     R5,12(R1)                 * DSNLEN
         L     R6,8(R1)                  * DSNAME
         N     R6,=X'7FFFFFFF'
         CLC   0(2,R2),=C'AN'
         BNE   CHECKAL
         LA    R0,1
         B     FUNCOK
CHECKAL  EQU   *
         CLC   0(2,R2),=C'AL'
         BNE   CHECKF
         LA    R0,3
         B     FUNCOK
CHECKF   EQU   *
         CLC   0(2,R2),=C'FN'
         BNE   CHECKFL
         LA    R0,2
         B     FUNCOK
CHECKFL  EQU   *
         CLC   0(2,R2),=C'FL'
         BNE   NOFUNC
         LA    R0,4
FUNCOK   EQU   *
         XC    FUNCTION,FUNCTION
         ST    R0,FUNCTION               * FUNCTION 1=ALLOC, 2=FREE
*                                                   3=ALLOC/ENQ
*                                                   4=FREE/DEQ
         ST    R2,SAVE2                  FUNCTION CODE
         ST    R3,SAVE3                  DDNAME LEN
         ST    R4,SAVE4                  DDNAME
         ST    R5,SAVE5                  DSNAME LEN
         ST    R6,SAVE6                  DSNAME
*        B     EXITOK
*        WTO   'SUB MODULE DYNALLC'
         L     R0,FUNCTION               FUNCTION 1=ALLOC, 2=FREE
         L     R2,SAVE2                  FUNCTION CODE
         L     R3,SAVE3                  DDNAME LEN
         L     R4,SAVE4                  DDNAME
         L     R5,SAVE5                  DSNAME LEN
         L     R6,SAVE6                  DSNAME
         MVC   DDNAME(8),0(R4)
         MVC   QNAME(8),0(R4)
         MVC   TUFREEDD(8),0(R4)
         MVC   TUDSNAME(44),0(R6)
         MVC   RNAME(44),0(R6)
         MVC   WTODDN(8),0(R4)
         MVC   WTODSN(44),0(R6)
*        LH    R7,0(R3)                  DDNAME LEN
*        STH   R7,TUFREDDL
*        STH   R7,DDNLEN
*        LH    R7,0(R5)                  DSNAME LEN
*        STH   R7,TUDSNLEN
         ST    R15,SAVE15
         ST    R14,SAVE14
         LA    R3,DDNAME
         LA    R1,DDNAME+8
         BAL   R14,TRIMLEN
         STH   R1,DDNLEN
         STH   R1,TUFREDDL
         LA    R3,TUDSNAME
         LA    R1,TUDSNAME+44
         BAL   R14,TRIMLEN
         STH   R1,TUDSNLEN
*        WTO   '[DYNA] TRANSFERRED FIELD LENGTHS'
         UNPK  WORK5(5),DDNLEN(3)
         TR    WORK5(4),HEXTAB
         MVC   WTODDNL(4),WORK5
         UNPK  WORK5(5),TUDSNLEN(3)
         TR    WORK5(4),HEXTAB
         MVC   WTODSNL(4),WORK5
         ST    R14,SAVE14
         ST    R15,SAVE15
         L     R14,SAVE14
         L     R15,SAVE15
         WTO   MF=(E,WTOPARM)
         SR    R15,R15
         LH    R15,DDNLEN
*        BAL   R14,DUMPR15
         SR    R15,R15
         LH    R15,TUDSNLEN
*        BAL   R14,DUMPR15
         L     R14,SAVE14
         L     R15,SAVE15
*        WTO   '[DYNA] PARAMS SHOWN'
         L     R14,SAVE14
         L     R15,SAVE15
         L     R14,SAVE14
         L     R15,SAVE15
         L     R0,FUNCTION
         CH    R0,F1
         BE    PERFALLC
         CH    R0,F3
         BE    PERFALLE
         CH    R0,F2
         BE    PERFFREE
         CH    R0,F4
         BE    PERFFRED
NOFUNC   EQU   *
         WTO   '[DYNA] UNKNOWN FUNCTION CODE'
         B     EXIT
PERFALLE EQU   *
         MVC   WTOFUNCA,=C'ALLOC'
         MVC   WTOFUNCB,=C'LOCK  '
         BAL   R14,SHOWFNC
         WTO   '[DYNA] ALLOC WITH ENQ REQUESTED'
         MVI   ENQFUNC,C'E'
         ST    R14,SAVE14
         LA    R1,PARMS
         LA    R13,SAVEARE2
         L     R15,=V(MVSLOCK)
         BALR  R14,R15
         L     R13,SAVE13
         LTR   R15,R15
         BZ    LOCKOK
         WTO   '[DYNA] ERROR ENQ RESOURCE'
LOCKOK   EQU   *
         B     PERFALLC
PERFFRED EQU   *
         MVC   WTOFUNCA,=C'FREE '
         MVC   WTOFUNCB,=C'UNLOCK'
         BAL   R14,SHOWFNC
         WTO   '[DYNA] DE-ALLOC WITH DEQ REQUESTED'
         MVI   ENQFUNC,C'D'
         ST    R14,SAVE14
         LA    R1,PARMS
         LA    R13,SAVEARE2
         L     R15,=V(MVSLOCK)
         BALR  R14,R15
         L     R13,SAVE13
         LTR   R15,R15
         BZ    UNLOCKOK
         WTO   '[DYNA] ERROR DEQ RESOURCE'
UNLOCKOK EQU   *
         B     PERFFREE
PERFALLC EQU   *
         MVC   WTOFUNCA,=C'ALLOC'
         MVC   WTOFUNCB,=C'NOLOCK'
         BAL   R14,SHOWFNC
         WTO   '[DYNA] PERFORMING ALLOCATION'
         SR    R1,R1
         LA    R1,RBALLOC
         SVC   99
         ST    R15,TEMPR15
         MVC   SAVERR(2),S99ERRA
         MVC   SAVEINF(2),S99INFOA
         L     R15,TEMPR15
         LTR   R15,R15
         BZ    EXITOK
         ST    R14,SAVE14
         WTO   '[DYNA] ALLOC WITH ERROR'
         UNPK  WTOHEX15(9),TEMPR15(5)
         TR    WTOHEX15(8),HEXTAB
         UNPK  WTOHEXER(5),S99ERRA(3)
         TR    WTOHEXER(4),HEXTAB
         UNPK  WTOHEXIN(5),S99INFOA(3)
         TR    WTOHEXIN(4),HEXTAB
         WTO   MF=(E,WTOSVCER)
         L     R14,SAVE14
         LA    R15,8
         ST    R15,SUBRC
         B     EXIT
DUMPR15  EQU   *
         ST    R15,DMPR15
         ST    R14,DMPR14
         UNPK  WTODMP15(9),DMPR15(5)
         TR    WTODMP15(8),HEXTAB
         WTO   MF=(E,WTODUMP)
         L     R14,DMPR14
         BR    R14
PERFFREE EQU   *
         MVC   WTOFUNCA,=C'FREE '
         MVC   WTOFUNCB,=C'NOLOCK'
         BAL   R14,SHOWFNC
         WTO   '[DYNA] PERFORMING DE-ALLOCATION'
         LA    R1,RBFREE
         SVC   99
         ST    R15,TEMPR15
         MVC   SAVERR(2),S99ERRD
         MVC   SAVEINF(2),S99INFOD
         L     R15,TEMPR15
         LTR   R15,R15
         BZ    EXITOK
         UNPK  WTOHEX15(9),TEMPR15(5)
         TR    WTOHEX15(8),HEXTAB
         UNPK  WTOHEXER(5),S99ERRA(3)
         TR    WTOHEXER(4),HEXTAB
         UNPK  WTOHEXIN(5),S99INFOA(3)
         TR    WTOHEXIN(4),HEXTAB
         WTO   MF=(E,WTOSVCER)
         L     R14,SAVE14
         LA    R15,4
         ST    R15,SUBRC
         B     EXIT
EXITOK   EQU   *
         ST    R14,SAVE14
         SR    R15,R15
         ST    R15,SUBRC
*        WTO   '[DYNA] SUBROUTINE COMPLETE WITHOUT ERRORS'
         L     R14,SAVE14
EXIT     EQU   *
         L     R13,4(,R13)
         ST    R15,16(,R13)
         LM    14,12,12(R13)
         BR    R14
SHOWFNC  EQU   *
         ST    R15,SHOW15
         ST    R14,SHOW14
         UNPK  WTOFUNCC(9),FUNCTION(5)
         TR    WTOFUNCC(8),HEXTAB
         WTO   MF=(E,WTOFUNC)
         L     R15,SHOW15
         L     R14,SHOW14
         BR    R14
***********************************************************************
* TRIMLEN SUBROUTINE
* R3=A(STRING)
* R1=R3+STRLENGTH
* R4=REAL LEN
* R14=RET ADDR
*
* LA    R1,DDNAME+8
***********************************************************************
TRIMLEN  EQU   *
         LA    R6,TRTAB
         BCTR  R5,0
*        WTO   '[DYNA] EXEC TRT'
         EX    R5,MYTRT
         LR    R2,R3
         SLR   R1,R2
         LR    R4,R1
         BR    R14
MYTRT    EQU   *
         TRT   0(0,R3),0(R6)
         DS    0F
SUBRC    DS    F
RBALLOC  DC    A(X'80000000'+RBALLC)
RBALLC   DC    AL1(20)
         DC    X'01'
         DC    X'0000'
S99ERRA  DC    H'0'
S99INFOA DC    H'0'
         DC    A(TUPTRALC)
         DC    F'0'
         DC    F'0'
         DS    0F
TUPTRALC DC    A(TUDDNA)
         DC    A(TUDSN)
         DC    A(X'80000000'+TUSHR)
         DS    0F
TUDDNA   DC    X'0001'
         DC    X'0001'
DDNLEN   DC    AL2(L'DDNAME)
DDNAME   DC    CL8'FFIXORD'
         DS    0F
TUDSN    DC    X'0002'
         DC    X'0001'
TUDSNLEN DC    AL2(L'TUDSNAME)
TUDSNAME DC    CL44'EKATUS.FOTOFIX.ORDER'
         DS    0F
TUSHR    DC    X'0004'     * WAS 4
         DC    X'0001'
         DC    AL2(1)
         DC    X'08'       * SHR
         DS    0F
RBFREE   DC    A(X'80000000'+FREERB)
FREERB   DC    AL1(20)
         DC    X'02'
         DC    X'0000'
S99ERRD  DC    H'0'
S99INFOD DC    H'0'
         DC    A(TUPTRFRE)
         DC    F'0'
         DC    F'0'
TUPTRFRE DC    A(X'80000000'+TUFREE)
TUFREE   DC    XL2'0001'
         DC    XL2'0001'
TUFREDDL DC    AL2(L'TUFREEDD)
TUFREEDD DC    C'FFIXORD'
DATAAREA DS    0F
SAVEAREA DC    18F'0'
SAVEARE2 DC    18F'0'
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
SAVE10   DS    F
SAVE13   DS    F
SAVE14   DS    F
SAVE15   DS    F
SHOW14   DS    F
SHOW15   DS    F
DMPR14   DS    F
DMPR15   DS    F
TEMPR15  DS    F
FUNCTION DS    F
         DS    0F
F1       DC    H'1'
F2       DC    H'2'
F3       DC    H'3'
F4       DC    H'4'
         DS    0F
PARMS    EQU *
         DC    A(ENQFUNC)
         DC    A(QNAME)
         DC    A(RNAME+X'80000000')
         DS    0F
ENQFUNC  DC    CL1'X'
         DS    0F
WTOSVCER DC    AL2(WTOSVCEL)
         DC    XL2'0000'
         DC    CL19'+SVC99 FAILED! R15='
WTOHEX15 DC    CL9'********'
         DC    CL7' ERROR='
WTOHEXER DC    CL5'****'
         DC    CL6' INFO='
WTOHEXIN DC    CL5'****'
WTOSVCEL EQU   *-WTOSVCER
         DS    0F
WTOFUNC  DC    AL2(WTOFUNCL)
         DC    XL2'0000'
         DC    CL12'[DYNA] CODE='
WTOFUNCC DC    CL9'         '
         DC    CL9'FUNCTION='
WTOFUNCA DC    CL5'     '
         DC    CL1'/'
WTOFUNCB DC    CL6'      '
WTOFUNCL EQU   *-WTOFUNC
         DS    0F
WTODUMP  DC    AL2(WTODUMPL)
         DC    XL2'0000'
         DC    CL11'[DYNA] R15='
WTODMP15 DC    CL4'    '
WTODUMPL EQU   *-WTODUMP
         DS    0F
WTOPROFT DC    AL2(WTOPELEN)
         DC    XL2'0000'
         DC    C'OUTPUT FILE IDENT:    ['
WTOLAUFN DC    CL8'********'
         DC    C']'
WTOPELEN EQU   *-WTOPROFT
         DS    0F
WTOPARM  DC    AL2(WTOPARML)
         DC    XL2'0000'
         DC    CL14'[DYNA] DDNAME='
WTODDN   DC    CL8'        '
         DC    CL1' '
         DC    CL6'DDLEN='
WTODDNL  DC    CL4'    '
         DC    CL2'  '
         DC    CL8'DSNAME= '
WTODSN   DC    CL44' '
         DC    CL2'  '
         DC    CL6'DSLEN='
WTODSNL  DC    CL4'   '
WTOPARML EQU   *-WTOPARM
         DS    0F
WORK5    DS    CL5
         DS    0F
QNAME    DC    CL8' '
RNAME    DC    CL44' '
         DS    0F
HEXTAB   EQU   *-X'F0'
         DC    C'0123456789ABCDEF'
         DS    0F
TRTAB    DC    256X'00'                XLATE TABLE TO CHECK DELIMITERS
         ORG   TRTAB
         DC    X'01'                   00 IS A DELIMITER
         ORG   TRTAB+64
         DC    X'01'                   40 (A BLANK) IS A DELIMITER
         ORG   ,
*
SAVERR   DS    XL2
SAVEINF  DS    XL2
         LTORG
         END
/*
//LINKSTUB EXEC PGM=IEWL,PARM='XREF,LIST,LET,MAP'
//SYSPRINT DD SYSOUT=*
//SYSUT1   DD UNIT=SYSDA,SPACE=(1024,(200,20))
//MYOBJ    DD DISP=SHR,DSN=EKATUS.TEST.OBJLIB
//SYSLMOD  DD DISP=SHR,DSN=EKATUS.LOADLIB(DYNALLC)
//SYSLIN    DD *
 INCLUDE MYOBJ(DYNALLC)
 INCLUDE MYOBJ(MVSLOCK)
 ENTRY DYNALLC
 NAME DYNALLC(R)
