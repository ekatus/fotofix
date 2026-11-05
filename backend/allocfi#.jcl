//ALLOCFI# JOB  (AXX,BXX,CXX),
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
//SYSPUNCH DD DSN=EKATUS.OBJLIB(ALLOCFI),DISP=OLD
//SYSIN    DD *
         START 0
ALLOCFI  CSECT
         SAVE  (14,12)
         BALR  12,0
         USING *,12
         LA    11,DATAAREA
         USING DATAAREA,11
         ST    13,SAVEAREA+4
         LA    14,SAVEAREA
         ST    14,8(13)
         LR    13,14
         ST    14,SAVE14
         ST    15,SAVE15
         L     2,0(1)
         L     3,4(1)
         N     3,=X'7FFFFFFF'
         ST    2,SAVE2
         ST    3,SAVE3
         MVC   WTOLAUFN(8),0(2)
         WTO   'SUB MODULE ALLOCFI'
         WTO   MF=(E,WTOPROFT)
         L     14,SAVE14
         L     15,SAVE15
         BAL   14,PUNCHORD
         L      3,SAVE3
         MVC   0(33,3),DSNAME        * MOVE GENERATED DSNAME TO CALLER
         LA    1,S99RBPTR
         SVC   99
         ST    15,TEMPR15
         MVC   SAVERR(2),S99ERR
         MVC   SAVEINF(2),S99INFO
         L     15,TEMPR15
         LTR   15,15
         BZ    EXITOK
         UNPK  WTOHEX15(9),TEMPR15(5)
         TR    WTOHEX15(8),HEXTAB
         UNPK  WTOHEXER(5),S99ERR(3)
         TR    WTOHEXER(4),HEXTAB
         UNPK  WTOHEXIN(5),S99INFO(3)
         TR    WTOHEXIN(4),HEXTAB
         WTO   MF=(E,WTOSVCER)
         L     14,SAVE14
EXIT     EQU   *
         L     13,4(,13)
         LM    14,12,12(13)
*        SR    15,15
         BR    14
EXITOK   EQU   *
         WTO   'ALLOCATED FILE'
         L     14,SAVE14
         B     EXIT
PUNCHORD EQU   *
         L     2,SAVE2
         ST    14,SAVE14
         ST    15,SAVE15
         WTO   'PUNCHING ORDER NO. TO DSNAME'
         MVC   DSNAME+17(6),0(2)
         LA    4,DSNAME+15
         LA    5,8
         ALR   4,5
         BCTR  4,0
FIXLOOP  EQU   *
         CLI   0(4),X'40'
         BNE   FIXDONE
         MVI   0(4),C'#'
         BCTR  4,0
FIXDONE  EQU   *
FIXEXIT  L     14,SAVE14
         L     15,SAVE15
         L      2,SAVE2
         BR    14
         DS    0F
S99RBPTR DC    A(X'80000000'+S99RB)
S99RB    DC    AL1(20)
S99VERB  DC    X'01'
S99FLAG1 DC    X'0000'
S99ERR   DC    H'0'
S99INFO  DC    H'0'
S99TXTPP DC    A(TXTPTRS)
         DC    F'0'
         DC    F'0'
TXTPTRS  DC    A(TUDDN)
         DC    A(TUCLOSE)
         DC    A(TUDSN)
         DC    A(TUSTAT)
         DC    A(TUNDISP)
         DC    A(TUCDISP)
         DC    A(TUDSORG)
         DC    A(TURECFM)
         DC    A(TULRECL)
         DC    A(TUBLKSZ)
         DC    A(TUTRK)
         DC    A(X'80000000'+TUPRI)
TXTOLDPT DC    A(TUDDN)
         DC    A(TUCLOSE)
         DC    A(TUDSN)
         DC    A(X'80000000'+TUSTAT)
         DS    0F
TUDDN    DC    X'0001'
         DC    X'0001'
         DC    AL2(L'S99DDN)
S99DDN   DC    CL8'DYNPRINT'
TUCLOSE  DC    X'001C'
         DC    X'0000'
TUDSN    DC    X'0002'
         DC    X'0001'
         DC    AL2(L'DSNAME)
DSNAME   DC    C'FOTOFIX.EBCDIC.ZZXXXXXX.PRINT.OUT'
TUSTAT   DC    X'0004'
         DC    X'0001'
         DC    AL2(1)
S99STAT  DC    X'04'       * NEW
TUNDISP  DC    X'0005'
         DC    X'0001'
         DC    AL2(1)
S99DISP  DC    X'02'       * CATLG
TUCDISP  DC    X'0006'
         DC    X'0001'
         DC    AL2(1)
S99DISA  DC    X'04'       * CATLG
TUDSORG  DC    X'003C'
         DC    X'0001'
         DC    AL2(2)
S99DSO   DC    XL2'4000'
TURECFM  DC    X'0049'
         DC    X'0001'
         DC    AL2(1)
         DC    X'94'       * FBA
TULRECL  DC    X'0042'
         DC    X'0001'
         DC    AL2(2)
         DC    X'0085'    * 133 Bytes
TUTRK    DC    X'0007'
         DC    X'0000'
TUBLKSZ  DC    X'0030'
         DC    X'0001'                  NUMBER: 1
         DC    AL2(2)                   LENGTH: 2 Bytes
         DC    XL2'0532'                PARM: Hex 0532 (= 1330 dezimal)
TUPRI    DC    X'000A'
         DC    X'0001'
         DC    AL2(3)
         DC    XL3'00000A'
DATAAREA DS    0F
SAVEAREA DC    18F'0'
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
TEMPR15  DS    F
         DS    0F
WTOSVCER DS    AL2(WTOSVCEL)
         DC    XL2'0000'
         DC    CL19'+SVC99 FAILED! R15='
WTOHEX15 DC    CL8'********'
         DC    CL7' ERROR='
WTOHEXER DC    CL4'****'
         DC    CL6' INFO='
WTOHEXIN DC    CL4'****'
WTOSVCEL EQU   *-WTOSVCER
         DS    0F
WTOPROFT DC    AL2(WTOPELEN)
         DC    XL2'0000'
         DC    C'OUTPUT FILE IDENT:    ['
WTOLAUFN DC    CL8'********'
         DC    C']'
WTOPELEN EQU   *-WTOPROFT
HEXTAB   EQU   *-X'F0'
         DC    C'0123456789ABCDEF'
         DS    0F
SAVERR   DS    XL2
SAVEINF  DS    XL2
         LTORG
         END
/*
