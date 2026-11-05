//DEQCMDA# JOB  (AXX,BXX,CXX),
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
//SYSGO    DD DSN=EKATUS.TEST.OBJLIB(DEQCMD),DISP=OLD
//SYSIN    DD *
         START 0
         REGISTER
DEQCMD   CSECT
         STM   R14,R12,12(R13)       SAVE REGISTERS
         BALR  R12,0                 SET UP BASE
         USING DEQCMD,R12
         LR    R12,R15
         LR    R8,R1                 * R1 = CCPL
         GETMAIN RU,LV=DEQWKSZ
         LR    R10,R1
         LR    R1,R0                 COPY LENGTH
         LR    R2,R0                 COPY LENGTH
         LR    R0,R10                -> NEW STG AREA
         SR    R15,R15               SET PAD
         MVCL  R0,R14                CLEAR THE PAGE
         USING DEQWK,R10
         ST    R13,DEQSA+4
         LA    R1,DEQSA
         ST    R1,8(,R13)
         LR    R13,R1
         MVC   DEQEYE,=CL4'DEQF'
         ST    R2,DEQWKLEN
         ST    R8,CPARMS
         LM    R2,R5,0(R8)             GET TSO COMMAND ENTRY PARAMETERS
*                                       R2 -> COMMAND BUFFER
*                                       R3 -> UPT
*                                       R4 -> PSCB
*                                       R5 -> ECT
*
         WTO   'PARSING PREPARE...'
PARS000  EQU   *
         LA    R8,PPLSTG
         USING PPL,R8
         ST    R3,PPLUPT               SET UPT ADDR
         ST    R5,PPLECT               SET ECT ADDR
         LA    R3,PARSECB              -> PARSE ECB
         ST    R3,PPLECB               SET IT
         LA    R3,ANSWER               -> IKJPARS "ANSWER AREA"
         ST    R3,PPLANS               SET IT
         ST    R10,PPLUWA              SET USER WORK AREA ADDR
*                                   ** PROCESS COMMAND LINE
         ST    R2,PPLCBUF              SET TSO COMMAND BUFFER ADDR
         L     R3,=A(PCLDEFS)          -> COMMAND PARMS DEFINITIONS
         ST    R3,PPLPCL               SET IT
PARS020  EQU   *
         WTO   'PARSING START...'
         CALLTSSR EP=IKJPARS,MF=(E,PPLSTG)   PARSE COMMAND LINE
         LTR   R0,R15                  ANY PARSE ERRORS?
         BNZ   XITDEQ12                YES
         DROP  R8                      PPL
         WTO   'PARSING DONE'
         L     R4,ANSWER               -> IKJPARS BUILT PCES
         USING PRDSECT,R4
         LA    R2,QNAPCE               -> QNAME ### PCE DATA
         TM    6(R2),X'80'             WAS QNAME ### SPECIFIED?
         BZ    PARS040                 NO
         L     R3,0(,R2)               -> WORD CONTAINING QNAME #
         LH    R1,4(,R2)               LENGTH OF QNAME
         MVC   QNAME,BLANKS            INIT RECEIVING FIELD
         BCTR  R1,0                    ADJUST FOR EXECUTE
         EX    R1,MVQNAME              MOVE THE QNAME
         OI    FLAGS3,F3QNAME          INDICATE QNAME VALID
PARS040  EQU   *
         LA    R2,RNAPCE               -> RNAME PCE
         TM    6(R2),X'80'             WAS RNAME SPECIFIED?
         BZ    PARS130                 NO
         L     R3,0(,R2)               -> RNAME  STRING
         LH    R1,4(,R2)               LENGTH OF RNAME
         MVC   RNAME,BLANKS            INIT RECEIVING FIELD
         BCTR  R1,0                    ADJUST FOR EXECUTE
         EX    R1,MVRNAME              MOVE THE RNAME
         OI    FLAGS3,F3RNAME          INDICATE RNAME  VALID
PARS130  EQU   *
         B     XITDEQ00                ALL DONE
         DROP  R4                      PRDSECT
MVQNAME  MVC   QNAME(0),0(R3)          EXECUTED INSTR
MVRNAME  MVC   RNAME(0),0(R3)          EXECUTED INSTR
XITDEQ00 EQU   *
         LA    R1,ANSWER               -> IKJPARS "ANSWER PLACE"
         IKJRLSA (1)                   RELEASE PARSING STORAGE
*
         SR    R0,R0                   SET SECONDARY RC=0;
         SR    R15,R15                 SET RC=0;
         BAL   R14,DODEQ               PERFORM DEQ
         BAL   R14,SHOWDEQ
         B     XITDEQ
SHOWDEQ  EQU   *
         SR    R15,R15
         MVC   WTOQNAMD(8),QNAME
         MVC   WTORNAMD(44),RNAME
         ST    R10,SAVE10
         ST    R11,SAVE11
         ST    R14,SAVE14
         ST    R15,SAVE15
         WTO   MF=(E,WTOPARMS)
         L     R10,SAVE10
         L     R11,SAVE11
         L     R14,SAVE14
         L     R15,SAVE15
         LA    R0,TPUTLEN
         LA    R1,TPUTSTRT
         TPUT  (1),(0),R
         BR    R14
XITDEQ12 EQU   *
         LA    R15,12              SET RC=12; R0 ALREADY SET BY IKJPARS
         B     XITDEQ
*
XITDEQ   EQU   *
         LR    R1,R10
         FREEMAIN RU,LV=DEQWKSZ,A=(1)
         L     R13,4(,R13)         -> PREV S.A.
         L     R14,12(,R13)        LOAD R14
         LM    R1,R12,24(R13)      RELOAD CALLERS REGS
         BR    R14                 RETURN WITH RCS IN R0/R15
*
DODEQ    EQU   *
         ST    R14,SAVE14
         LA    R3,QNAME
         LA    R4,RNAME
         DEQ   ((R3),(R4),44,SYSTEM),RET=HAVE
         ST    R15,SAVE15
         LTR   R15,R15
         BNE   DEQERR
         SR    R15,R15
         STH   R15,SAVERC
         MVC   TMSGTXT(2),=C'OK'
         B     TPUTMSG
DEQERR   EQU   *
*        LA    R15,4
*        ST    R15,SAVE15
         STH   R15,SAVERC
         MVC   TMSGTXT(5),=C'ERROR'
         UNPK  WORK9(9),SAVE15(5)
         TR    WORK9(8),HEXTAB
         MVC   WTOR15D(8),WORK9
         WTO   MF=(E,WTOR15)
TPUTMSG  EQU   *
         UNPK  WORK3(3),SAVERC(2)
         TR    WORK3(2),HEXTAB
         MVC   TMSGCODE(2),WORK3
         LA    R0,TMSGLEN
         LA    R1,TMSGSTRT
         TPUT  (1),(0),R
         L     R14,SAVE14
         BR    R14
BLANKS   DC    CL44' '
         DS    0F
WORK3    DC    CL3' '
         DS    0F
WORK9    DC    CL9' '
         DS    0F
SAVERC   DC    XL2'0000'
         DS    0F
WTOR15   DC    AL2(WTOR15L)
         DC    XL2'0000'
         DC    CL4'R15='
WTOR15D  DC    CL8'00000000'
         DC    CL1' '
WTOR15L  EQU   *-WTOR15
         DS    0F
WTOPARMS DC    AL2(WTOPARML)
         DC    XL2'0000'
         DC    CL4'DEQ '
TPUTSTRT DC    CL6'QNAME='
WTOQNAMD DC    CL8'        '
         DC    CL4' -- '
         DC    CL6'RNAME='
WTORNAMD DC    CL44' '
WTOPARML EQU   *-WTOPARMS
TPUTLEN  EQU   *-TPUTSTRT
TMSGSTRT DC    CL4'RC=('
TMSGCODE DC    CL3'00)'
TMSGTXT  DC    CL5'     '
TMSGLEN  EQU   *-TMSGSTRT
         DS    0F
HEXTAB   EQU   *-X'F0'
         DC    C'0123456789ABCDEF'
         LTORG
***********************************************************************
*                                                                     *
***********************************************************************
PCLDEFS  IKJPARM DSECT=PRDSECT
QNAMPCE  IKJKEYWD
         IKJNAME  'QNAME',SUBFLD=QNAMFLD
RNAMPCE  IKJKEYWD
         IKJNAME  'RNAME',SUBFLD=RNAMFLD
QNAMFLD  IKJSUBF
QNAPCE   IKJIDENT QNAME,MAXLNTH=8,FIRST=ALPHANUM,OTHER=ALPHANUM
RNAMFLD  IKJSUBF
RNAPCE   IKJPOSIT DSNAME,                                              X
               PROMPT='ENTER THE RESOURCE NAME'
         IKJENDP
         IKJPPL
IKJPPLSZ EQU   (*-PPL)/4
         IKJCPPL
         LTORG
DEQWK    DSECT
DEQEYE   DS    CL4'DEQF'           EYECATCHER
DEQWKLEN DS    F                   GETMAIN SIZE OF THIS AREA
*
DBLE     DS    D                   WORK AREA
TWRK     DS    2D                  WORK AREA
*
*
MACLIST  DS    CL96                   MACRO EXPANSION AREA
STAXLIST DS    CL20                   STAX PARAMETER LIST
*
CPARMS   DS    A                      -> INPUT CPPL (ENTRY PARMS)
PUTECB   DS    F                      ECB FOR PUTLINE/PUTGET
IOPLAREA DS    4A                     IOPL FOR PUTLINE/PUTGET
DEVINFO  DS    A                      -> ENTRY SELECTED FROM DISKS TBL
SV14CTL  DS    A                      R14 SAVE AREA
SV14GB   DS    A                      R14 SAVE AREA
SV14GET  DS    A                      R14 SAVE AREA
SV14LN   DS    A                      R14 SAVE AREA
SV14PUR  DS    A                      R14 SAVE AREA
SVR0CTL  DS    F                      R0 SAVE OF # VALUE FOR A KEY
SAVE10   DS    F
SAVE11   DS    F
SAVE14   DS    F
PAD0     DC    XL1'00'
SAVE15   DS    F
PAD1     DC    XL1'00'
SUBRC    DS    F
PAD2     DC    XL1'00'
SVR0R15  DS    16F                    R0-R15 SAVE
OLD      DS    F                      FOR PUTGET, # SEGMENTS
OLDMSGAD DS    A                      -> MSG LEN/TEXT
*
PARSECB  DS    F                      IKJPARS ECB
ANSWER   DS    F                      IKJPARS ANSWER AREA
PPLSTG   DS    (IKJPPLSZ)A            SPACE FOR PPL
QNAME    DS    CL8                    USER SPECIFIED QNAME
RNAME    DS    CL44                   USER SPECIFIED RNAME
FLAGS3   DS    X                      FLAG BITS FROM CMD LINE PARSE
F3QNAME  EQU   X'80'  1... ....       QNAME SPECIFIED
F3RNAME  EQU   X'40'  .1.. ....       RNAME SPECIFIED
DEQSA    DS    18F                    ENQCMD OS SAVE AREA
*
         DS    0D                     FORCE DOUBLEWORD SIZE
DEQWKSZ  EQU   *-DEQWK
*
         CVT   DSECT=YES,PREFIX=NO
         IEFZB4D0
         IEFZB4D2
         END DEQCMD
/*
//LINK     EXEC PGM=IEWL,PARM='XREF,LIST,LET,MAP'
//SYSPRINT DD SYSOUT=*
//SYSUT1   DD UNIT=SYSDA,SPACE=(1024,(200,20))
//SYSLIN   DD DISP=SHR,DSN=EKATUS.TEST.OBJLIB(DEQCMD)
//SYSLMOD  DD DISP=SHR,DSN=EKATUS.LOADLIB(DEQCMD)
//SYSIN    DD *
 ENTRY DEQCMD
 NAME DEQCMD(R)
/*
//COPY     EXEC PGM=IEBCOPY
//SYSPRINT  DD SYSOUT=*
//INDD      DD DSN=EKATUS.LOADLIB,DISP=SHR
//OUTDD     DD DSN=SYS1.CMDLIB,DISP=SHR
//SYSUT3    DD  UNIT=SYSDA,SPACE=(TRK,(5,5))
//SYSUT4    DD  UNIT=SYSDA,SPACE=(TRK,(5,5))
//SYSIN     DD *
  COPY INDD=INDD,OUTDD=OUTDD
  SELECT MEMBER=((DEQCMD,DEQ,R))
/*
