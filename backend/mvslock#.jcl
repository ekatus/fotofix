//MVSLOCKA JOB (KICKS),'ASM STUBS',CLASS=A,MSGCLASS=X,
//         NOTIFY=&SYSUID
//* --- 1. ASSEMBLER STUB 1: ENQ ---
//ASM1     EXEC PGM=IFOX00,PARM='OBJECT,NODECK'
//SYSLIB   DD   DSN=SYS1.MACLIB,DISP=SHR
//         DD   DSN=SYS2.MACLIB,DISP=SHR
//         DD   DSN=SYS1.AMODGEN,DISP=SHR
//SYSPUNCH DD   DUMMY
//SYSGO    DD DSN=EKATUS.TEST.OBJLIB(MVSLOCK),DISP=SHR
//SYSLIN   DD DUMMY
//SYSPRINT DD SYSOUT=*
//SYSUT1   DD UNIT=SYSDA,SPACE=(CYL,(2,2))
//SYSUT2   DD UNIT=SYSDA,SPACE=(CYL,(2,2))
//SYSUT3   DD UNIT=SYSDA,SPACE=(CYL,(2,2))
//SYSIN    DD *
         REGISTER
MVSLOCK  CSECT
         STM   R14,R12,12(R13)      Save registers
         BALR  R12,0                Establish base register
         USING *,R12
         ST    R13,SAVEAREA+4
         LA    R14,SAVEAREA
         ST    R14,8(R13)
         LR    R13,R14
         LA    R3,0
         ST    R3,SUBRC             * CODE = 0
         L     R2,0(R1)             * Reg 2 = Address of Function
         L     R3,4(R1)             * Reg 3 = Address of QNAME
         L     R4,8(R1)             Reg 4 = Address of RNAME
         N     R4,=X'7FFFFFFF'      Clear high bit of last param
         CLI   0(R2),C'E'           Is it ENQ?
*        WTO   '[LOCK] DISPATCH'
         BE    DOENQ
         CLI   0(R2),C'D'           Is it DEQ?
         BE    DODEQ
         WTO   '[LOCK] UNKNOWN FUNCTION'
         MVC   WTOENQF,=C'UNK '
         MVC   WTOQNAM(8),0(R3)
         MVC   WTORNAM(44),0(R4)
         BAL   R14,SAY
         LA    R15,12               * SET RC
         ST    R15,SUBRC
         B     RETURN               Invalid function, just exit
DOENQ    EQU   *
         ST    R14,SAVE14
         ST    R15,SAVE15
         WTO   '[LOCK] PERFORMING ENQ'
         MVC   WTOENQF,=C'ENQ '
         MVC   WTOQNAM(8),0(R3)
         MVC   WTORNAM(44),0(R4)
         L     R14,SAVE14
         L     R15,SAVE15
         BAL   R14,SAY
         SR    R15,R15
         ENQ   ((R3),(R4),E,44,SYSTEM),RET=HAVE
         ST    R15,SUBRC
         LTR   R15,R15
         BNZ   ERRENQ
***      WTO   '[LOCK] PERFORMED ENQ'
         B     RETURN
DODEQ    EQU   *
         WTO   '[LOCK] PERFORMING DEQ'
         MVC   WTOENQF,=C'DEQ '
         MVC   WTOQNAM(8),0(R3)
         MVC   WTORNAM(44),0(R4)
         BAL   R14,SAY
         SR    R15,R15
         DEQ   ((R3),(R4),44,SYSTEM),RET=HAVE
         ST    R15,SUBRC
         LTR   R15,R15
         BNZ   ERRDEQ
**       WTO   '[LOCK] PERFORMED DEQ'
         B     RETURN

RETURN   EQU   *
*        WTO   '[LOCK] RETURN FROM SUBROUTINE'
         SR    R15,R15                Set RC = 0
         L     R15,SUBRC
         L     R13,SAVEAREA+4
         ST    R15,16(,R13)
         LM    R14,R12,12(R13)        Restore registers
         BR    R14                    Return to Caller
ERRENQ   EQU   *
         ST    R15,SUBRC
         WTO   '[LOCK] ERROR IN ENQ'
         CH    R15,X'08'
         BE    HASRES
         B     RETURN
ERRDEQ   EQU   *
         ST    R15,SUBRC
         WTO   '[LOCK] ERROR IN DEQ'
         CH    R15,X'04'
         BE    NOTOWNER
         B     RETURN
NOTOWNER EQU   *
         WTO   '[LOCK] NOT RESOURCE OWNER'
         B     RETURN
HASRES   EQU   *
         WTO   '[LOCK] RESOURCE ALREADY LOCKED'
         B     RETURN
         DS    0F
SAY      EQU   *
         STM   R1,R15,WTOREGS
         WTO   MF=(E,WTOENQ)
         LM    R1,R15,WTOREGS
         BR    R14
QNAME    DC    CL8'FOTOFIX '       Your chosen global 8-byte QNAME
         DS    0F
SAVEAREA DS    18F
SAVE0    DS    F
SAVE1    DS    F
SAVE2    DS    F
SAVE3    DS    F
SAVE4    DS    F
SAVE14   DS    F
SAVE15   DS    F
SUBRC    DS    F
WTOREGS  DS    18F
         DS    0F
WTOENQ   DC    AL2(WTOENQL)
         DC    XL2'0000'
         DC    CL7'[LOCK] '
WTOENQF  DS    CL4
         DC    CL7'QNAME=['
WTOQNAM  DS    CL8
         DC    CL1']'
         DC    CL10'RESOURCE=['
WTORNAM  DS    CL44
         DC    CL1']'
WTOENQL  EQU   *-WTOENQ
         LTORG
         END
/*
//LINKSTUB EXEC PGM=IEWL,PARM='XREF,LIST,LET,MAP'
//SYSPRINT DD SYSOUT=*
//SYSUT1   DD UNIT=SYSDA,SPACE=(1024,(200,20))
//MYOBJ    DD DISP=SHR,DSN=EKATUS.TEST.OBJLIB
//SYSLMOD  DD DISP=SHR,DSN=EKATUS.LOADLIB(MVSLOCK)
//SYSLIN   DD *
 INCLUDE MYOBJ(MVSLOCK)
 ENTRY MVSLOCK
 NAME MVSLOCK(R)
