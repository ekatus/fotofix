//SUBMITJ# JOB  (AXX,BXX,CXX),
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
//SYSPUNCH DD DSN=EKATUS.OBJLIB(SUBMITJ),DISP=OLD
//SYSIN    DD *
         START 0
SUBMITJ  CSECT
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
         WTO   'SUB MODULE SUBMITJOB'
         MVC   ORDERNUM(8),0(2)
         MVC   DSNAME(33),0(3)
         MVC   WTODSNR(33),DSNAME
         ST    14,SAVE14
         ST    15,SAVE15
         WTO   MF=(E,WTODSN)
         L     14,SAVE14
         L     15,SAVE15
         SR    15,15
*        B     EXIT
*-------------------------------------------------------------------*
* SUBROUTINE: SEND JCL TO INTERNAL READER                           *
*-------------------------------------------------------------------*
SUBMITJB EQU *
         ST    14,SUBRC
         OPEN  (JCLTEMPL,INPUT)
         LTR   15,15
         BNZ   ERRJCLIN
         OPEN  (INTRDR,OUTPUT)
         LTR   15,15
         BNZ   ERRINTRD
         WTO   'ENTERING JCL LOOP'
JCLLOOP  EQU    *
         GET   JCLTEMPL,JCLBUF
         CLC   JCLBUF(10),=C'//PXXXXXXA'
         BNE   JCLDDCHK
         WTO   '[SUBMIT] FOUND JOB CARD'
         MVC   JCLBUF+3(6),ORDERNUM
         B     WRITEJCL
JCLDDCHK EQU   *
         CLC   JCLBUF(17),=C'//*INSERT_DD_HERE'
         BNE   WRITEJCL

* Generate dynamic DD Statement
         MVI   JCLBUF,C' '
         MVC   JCLBUF+1(79),JCLBUF
         MVC   JCLBUF(18),=C'//SYSUT1   DD DSN='
         MVC   JCLBUF+18(33),DSNAME   * Inserts generated DSNAME
         MVC   JCLBUF+51(1),=C','     * continuation required
         PUT   INTRDR,JCLBUF
         MVI   JCLBUF,C' '
         MVC   JCLBUF+1(79),JCLBUF
         MVC   JCLBUF(38),=C'//            DISP=(MOD,DELETE,DELETE)'

WRITEJCL EQU   *
         PUT   INTRDR,JCLBUF
*        ST    14,SAVE14
*        ST    15,SAVE15
*        WTO   'WRITING JCL LINE TO INTRDR'
*        L     14,SAVE14
*        L     15,SAVE15
         B     JCLLOOP

JCLEOF   EQU   *
         WTO   '[SUBMIT] END OF JCL TEMPLATE'
         CLOSE (JCLTEMPL)
         CLOSE (INTRDR)          * JES2 picks up cards upon close
         WTO   '[SUBMIT] INTRDR CLOSED'
         L     14,SUBRC
EXIT     EQU   *
         L     13,4(,13)
         LM    14,12,12(13)
*        SR    15,15
         BR    14
ERREXIT  EQU   *
         B     EXIT
ERRJCLIN EQU   *
         MVC   WTORTXT(8),=CL8'JCL IN'
         BAL   14,ERRWTOIO
         B     ERREXIT
ERRINTRD EQU   *
         MVC   WTORTXT(8),=CL8'INTRDR'
         BAL   14,ERRWTOIO
         B     ERREXIT
ERRWTOIO EQU   *
         ST    15,SAVE15
         ST    14,SAVE14
         UNPK  WTOR15(9),SAVE15(5)
         TR    WTOR15(4),HEXTAB
         WTO   MF=(E,WTOWRTER)
         L     14,SAVE14
         L     15,SAVE15
         BR    14
         LTORG
DATAAREA EQU   *
         DS    0F
SAVEAREA DC    18F'0'
SAVE14   DS    F
SAVE15   DS    F
SUBRC    DS    F
         DS    0F
DSNAME   DS    CL33' '
         DS    0F
ORDERNUM DS    CL8' '
JCLBUF   DS    CL80
JCLTEMPL DCB   DSORG=PS,MACRF=GM,DDNAME=JCLTMPL,                       X
               RECFM=FB,LRECL=80,EODAD=JCLEOF
INTRDR   DCB   DSORG=PS,MACRF=PM,DDNAME=JESINTRD,RECFM=FB,LRECL=80
         DS    0F
WTODSN   DC    AL2(WTODSNL)
         DC    XL2'0000'
         DC    CL12'[SUBMIT]DSN='
WTODSNR  DC    CL40' '
WTODSNL  EQU   *-WTODSN
         DS    0F
WTOWRTER DC    AL2(WTOWRTEL)
         DC    XL2'0000'
         DC    CL27'[SUBMIT]I/O FAILED!    R15='
WTOR15   DC    CL8'********'
         DC    CL2'   '
WTORTXT  DC    CL8'--------'
WTOWRTEL EQU   *-WTOWRTER
         DS    0F
HEXTAB   EQU   *-X'F0'
         DC    C'0123456789ABCDEF'
         END
