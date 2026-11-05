//RAKFCHK# JOB  (AXX,BXX,CXX),
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
//SYSIN    DD *
         START 0
         REGISTER
RAKFCHK  CSECT
         SAVE  (14,12)
         BALR  R12,0
         USING *,R12
         ST    R13,SAVEAREA+4
         LA    R14,SAVEAREA
         ST    R14,8(R13)
         LR    R13,14
         ST    R14,SAVE14
         ST    R15,SAVE15
         L     R2,0(R1)
         ST    R2,RETURNR          * CL8 RETURN MSG
         L     R3,4(R1)            * GROUP NAME OR PASSWORD
         L     R4,8(R1)            * USERID
         N     R4,=X'7FFFFFFF'
         MVC   FUNCTION(8),0(R2)   * FUNCTION CODE, IF ANY
         MVC   GROUPNAM(8),0(R3)
         MVC   USERID(8),0(R4)
         SR    R15,R15
         SR    R0,R0
         SR    R1,R1
         LA    R1,1
         LA    R0,0
         SVC   244
         LTR   R15,R15
         BNZ   AUTHERR
         WTO   '[RAKF] CHECKING JSCBAUTH'
         L     R5,16                LOAD CVT ADDRESS
         L     R5,0(,R5)            LOAD TCB
         L     R5,4(,R5)
         USING TCB,R5
         L     R3,TCBJSCB
         DROP  R5
         USING IEZJSCB,R3
         TM    JSCBOPTS,JSCBAUTH
         BO    AUTHOK
         B     AUTHERR
AUTHOK   EQU   *
         DROP  R3
         ST    R15,SAVE15
         WTO   '[RAKF] ENTERED AUTHORIZED MODE'
         L     R15,SAVE15
         GETMAIN R,LV=512
         ST    R1,SAVEWK
         LR    R4,R1
         CLC   FUNCTION(8),=CL8'PWCHECK '
         BE    PWCHECK
         ST    R15,SAVE15
         WTO   '[RAKF] CHECK GROUP OR PASSWORD'
         L     R15,SAVE15
         MVC   WTOFNCR(8),FUNCTION
         MVC   WTOGRPR(8),GROUPNAM
         ST    R14,SAVE14
         ST    R15,SAVE15
         WTO   MF=(E,WTOGRP)
         L     R14,SAVE14
         L     R15,SAVE15
         SR    R15,R15
*-------------------------------------------------------------------*
* SUBROUTINE: CHECK IF ADDRESS SPACE IS CONNECTED TO GROUP          *
*-------------------------------------------------------------------*
CHECKGRP EQU *
         L     R2,548                * ASCB FROM PSA
         LTR   R2,R2
         BZ    ERRASCB
         L     R2,108(,R2)
         LTR   R2,R2
         BZ    ERRASXB
         L     R3,200(,R2)
         LTR   R3,R3
         BZ    ERRACEE
         CLC   30(8,R3),GROUPNAM
         MVC   WTOGRPR(8),30(R3)
         ST    R14,SAVE14
         ST    R15,SAVE15
         BNE   NOTMEMB
         WTO   '[RAKF] USER IS A MEMBER OF'
         WTO   MF=(E,WTOGRP)
         L     R14,SAVE14
         L     R15,SAVE15
         XR    R15,R15
         ST    R15,SUBRC
         B     EXIT
NOTMEMB  EQU    *
         ST    R14,SAVE14
         WTO   '[RAKF] NOT A MEMBER'
         WTO   MF=(E,WTOGRP)
         L     R14,SAVE14
         XR    R15,R15
         LA    R15,4
         ST    R15,SUBRC
         B     EXIT
ERRACEE  EQU   *
         ST    R14,SAVE14
         WTO   '[RAKF] ACEE BLOCK NOT FOUND'
         L     R14,SAVE14
         XR    R15,R15
         LA    R15,8
         ST    R15,SUBRC
         B     EXIT
ERRASXB  EQU   *
         WTO   '[RAKF] ASXB BLOCK NOT FOUND'
         XR    R15,R15
         LA    R15,12
         ST    R15,SUBRC
         B     EXIT
ERRASCB  EQU   *
         WTO   '[RAKF] ASCB BLOCK NOT FOUND'
         XR    R15,R15
         LA    R15,16
         ST    R15,SUBRC
         B     EXIT
         DS    0F
REXIT    EQU   *
         TM    SW,$CREATE
         BNO   FEXIT
         ST    R14,SAVE14
         ST    R15,SAVE15
         WTO   '[RAKF] RELEASING ACEE'
         L     R14,SAVE14
         L     R15,SAVE15
         L     R4,SAVEWK
         RACROUTE REQUEST=VERIFY,                                      X
               ENVIR=DELETE,                                           X
               ACEE=ACEEADR,                                           X
               WORKA=(4)
         NI    SW,255-$CREATE
         WTO   '[RAKF] CLEARED LOGON ADDR'
         SR    R15,R15
         B     FEXIT
         DS    0F
FEXIT    EQU   *
         WTO   '[RAKF] RELEASING WORK AREA'
         L     R1,SAVEWK
         FREEMAIN R,LV=512,A=(1)
         WTO   '[RAKF] WORK AREA RELEASED'
EXIT     EQU   *
         L     R15,SUBRC
         LR    R3,R15
         L     R2,RETURNR          * LOAD ADDRESS OF RETURN AREA
         L     R4,CODETAB(R3)
         MVC   0(8,R2),0(R4)         * SHOULD BE THE RETURN MSG
         MVC   WTOMSGO(8),0(R4)
         BAL   R14,WTOMSG
         SR    R15,R15
         SR    R0,R0
         SR    R1,R1
         LA    R1,0
         LA    R0,0
         SVC   244
         LTR   R15,R15
         BZ    SVCOK
         WTO   '[RAKF] CANNOT LEAVE AUTH MODE'
         B     EXIT2
SVCOK    EQU   *
         ST    R14,SAVE14
         WTO   '[RAKF] HAVING LEFT AUTHORIZED MODE'
         L     R14,SAVE14
EXIT2    EQU   *
         L     R13,4(,R13)
         LM    R14,R12,12(R13)
         L     R15,SUBRC
         BR    R14
*-------------------------------------------------------------------*
* SUBROUTINE: ADJUST PARAMETER LENGTHS REMOVE TRAILING BLANKS       *
*             R5 = ADDRESS OF INPUT FIELD                           *
*             R6 = OUTPUT LENGTH FIELD ADDRESS                      *
*-------------------------------------------------------------------*
         DS    0F
TRIMFLD  EQU   *
         ST    R14,SAVE14
         ST    R15,SAVE15
         WTO   '[RAKF] ADJUSTING INPUT FIELD LENGTHS'
         L     R14,SAVE14
         L     R15,SAVE15
         LA    R1,USERID+8
         TRT   USERID,TRTAB
         LA    R2,USERID
         SLR   R1,R2
         STC   R1,USER
         LA    R1,GROUPNAM+8
         TRT   GROUPNAM,TRTAB
         LA    R2,GROUPNAM
         SLR   R1,R2
         STC   R1,PWD
TRIMEXIT EQU   *
         ST    R14,SAVE14
         WTO   '[RAKF] LENGTH ADJUSTED'
         L     R14,SAVE14
         BR    R14            * RETURN TO CALLER
*-------------------------------------------------------------------*
* SUBROUTINE: CHECK PASSWORD STORED IN GROUPNAME FIELD              *
*-------------------------------------------------------------------*
PWCHECK  EQU   *
         WTO   '[RAKF] PERFORMING PWCHECK'
         BAL   R14,TRIMFLD
         WTO   '[RAKF] FIELD LENGTHS ADJUSTED'
CHKPASS  EQU   *
         LA    R8,USER
         LA    R7,PWD
         ST    R14,SAVE14
         RACROUTE REQUEST=VERIFY,                                      X
               ENVIR=CREATE,                                           X
               ACEE=ACEEADR,                                           X
               USERID=(8),                                             X
               PASSWRD=(7),                                            X
               WORKA=(4),                                              X
               PASSCHK=YES,                                            X
               TERMID=LUDUMMY,                                         X
               MF=(E,VFYLIST)
         XC    GROUPNAM,GROUPNAM
         ST    R15,SAFRC
         WTO  '[RAKF] RACROUTE COMPLETE'
         L     R14,SAVE14
         L     R15,SAFRC
         B     CHECKRET
         DS    0D
CHECKRET EQU   *
         L     R15,SAFRC
         LTR   R15,R15
         BZ    CHKERR
         WTO  '[RAKF] PASSED CHKERR TEST'
         L     R15,SAFRC
         B     PASSOK
         DS    0F
CHKERR   EQU   *
*        SR    R15,R15
*        B     REXIT
         WTO  '[RAKF] CHKERR LOADING LIST FORM'
         LA    R3,VFYLIST
         L     R15,0(,R3)
         ST    R15,RAKFRC
         WTO   '[RAKF] CHECKING FOR SYSERR'
         SR    R15,R15
         L     R15,SAFRC
         MVC   WTOR15S(8),=CL8'SAFRC'
         BAL   R14,DUMPR15
         CLC   SAFRC,=F'8'
         BH    SYSERR
         BE    PASSERR
         SR    R15,R15
         L     R15,RAKFRC
         MVC   WTOR15S(8),=CL8'RAKFRC'
         BAL   R14,DUMPR15
         CLC   RAKFRC,=F'28'
         BE    USERERR
         CLC   RAKFRC,=F'20'
         BE    BYPRAK
         CLC   RAKFRC,=F'0'
         BNE   SYSERR
         WTO   '[RAKF] ALL ERROR CHECKS PASSED'
         B     PASSOK
BYPRAK   EQU   *
         WTO   'RAKF NOT ACTIVE'
         B     SYSERR
AUTHERR  EQU   *
         WTO   '[RAKF] CANNOT SWITCH TO AUTH MODE'
         B     EXIT
PASSERR  EQU   *
         WTO   '[RAKF] PASSERR - CHECKING RAKFRC'
         DS    0H
         CLC   RAKFRC,=F'8'
         BE    PASSNMAT
         CLC   RAKFRC,=F'20'
         BNE   SYSERR
         WTO   '[RAKF] PW EXPIRED'
         LA    R15,4
         ST    R15,SUBRC
         B     REXIT
PASSNMAT EQU   *
         WTO   '[RAKF] WRONG PASSWORD'
         LA    R15,4
         ST    R15,SUBRC
         B     REXIT
USERERR  EQU   *
         WTO   '[RAKF] USER UNKNOWN'
         LA    R15,4
         ST    R15,SUBRC
         B     EXIT
SYSERR   EQU   *
         CLC   SAFRC,=F'28'
         BE    USERERR
         WTO   '[RAKF] SYSTEM ERROR'
         LA    R15,4
         ST    R15,SUBRC
         B     REXIT
PASSOK   EQU   *
         ST    R15,SAVE15
         ST    R14,SAVE14
         WTO   '[RAKF] PASS OK'
         L     R15,SAVE15
         L     R14,SAVE14
         OI    SW,$CREATE
         SR    R15,R15
         ST    R15,SUBRC
         B     REXIT
WTOMSG   EQU   *
         ST    R15,SAVE15
         ST    R14,SAVE14
         WTO   MF=(E,WTOMSGR)
         L     R15,SAVE15
         L     R14,SAVE14
         BR    R14
* --------------------------------------------------------------------
*  SUBROUTINE: KONVERTIERT 32 BYTES IN 64 HEX-ZEICHEN
*  INPUT:  R4 = QUELL-ADRESSE, R5 = ZIEL-ADRESSE
*  KAPUTT: R6, R7, R8, R9
* --------------------------------------------------------------------
*
HEXSUB   DS    0H
         LA    R6,32               ZHLER: 32 BYTES VERARBEITEN
HEXLOOP  EQU   *
         XR    R7,R7
         IC    R7,0(R4)            HOLE 1 BYTE QUELLCODEDATEN
*  OBERES NIBBLE (HALBBYTE) ISOLIEREN
         LR    R8,R7
         SRL   R8,4                RECHTSSCHUB UM 4 BIT
         LA    R9,HEXTAB
         AR    R9,R8
         MVC   0(1,R5),0(R9)       SCHREIBE 1. HEX-ZEICHEN
*  UNTERES NIBBLE ISOLIEREN
         LR    R8,R7
         N     R8,=F'15'           MASKIERE DIE OBEREN 4 BIT (X'0F')
         LA    R9,HEXTAB
         AR    R9,R8
         MVC   1(1,R5),0(R9)       SCHREIBE 2. HEX-ZEICHEN
*  ZEIGER UND ZHLER AKTUALISIEREN
         LA    R4,1(R4)            NCHSTES QUELL-BYTE
         LA    R5,2(R5)            NCHSTE 2 ZIEL-BYTES
         BCT   R6,HEXLOOP          SCHLEIFE WIEDERHOLEN
         BR    R14                 ZURCK ZUM AUFRUFER
*
DUMPREG  EQU   *
         UNPK  UNPKWRK(9),TEMPREG(5)
         TR    UNPKWRK(8),HEXTAR
         MVC   0(8,R6),UNPKWRK
         BR    14
DUMPR15  EQU   *
         ST    R15,DUMP15S
         ST    R14,DUMP14S
         UNPK  WTOR15R(9),DUMP15S(5)
         TR    WTOR15R(8),HEXTAR
         WTO   MF=(E,WTOR15)
         L     R15,DUMP15S
         L     R14,DUMP14S
         BR    14
DATAAREA EQU   *
         DS    0F
HEXTAR   EQU   *-X'F0'
         DC    C'0123456789ABCDEF'
         DS    0F
HEXTAB   DC    C'0123456789ABCDEF'  HEX-BERSETZUNGS-STRING
         DS    0F
TRTAB    DC    256X'00'                XLATE TABLE TO CHECK DELIMITERS
         ORG   TRTAB
         DC    X'01'                   00 IS A DELIMITER
         ORG   TRTAB+64
         DC    X'01'                   40 (A BLANK) IS A DELIMITER
         ORG   ,
*
SAVEAREA DC    18F'0'
ACEEADR  DS    F
SAVE14   DS    F
SAVE15   DS    F
DUMP14S  DS    F
DUMP15S  DS    F
SAVEWK   DS    F
TEMPREG  DS    F
SUBRC    DS    F
SAFRC    DS    F
RAKFRC   DS    F
RETURNR  DS    F
BLANKS   DC    CL8' '
         DS    0F
LUDUMMY  DC    CL8'LURAKFC'
         DS    0F
USER     DC    AL1(8)
USERID   DC    CL8'        '
         DS    0F
PWD      DC    AL1(8)
GROUPNAM DC    CL8'        '        * WILL ALSO HOLD THE PASSWORD
         DS    0F
FUNCTION DS    CL8' '
         DS    0F
CODETAB  EQU   *
         DC    A(OKMSG)
         DC    A(NAKMSG)
         DC    A(AXSBMSG)
         DC    A(ACEEMSG)
         DC    A(ASCBMSG)
OKMSG    DC    CL8'OK      '
NAKMSG   DC    CL8'NOACCESS'
AXSBMSG  DC    CL8'NOAXSB  '
ACEEMSG  DC    CL8'NOACEE  '
ASCBMSG  DC    CL8'NOASCB  '
         DS    0F
WTOR15   DC    AL2(WTOR15L)
         DC    XL2'0000'
         DC    CL8'SOURCE= '
WTOR15S  DC    CL8'        '
         DC    CL2'  '
         DC    CL4'R15='
WTOR15R  DC    CL8'        '
         DC    CL1' '
WTOR15L  EQU   *-WTOR15
         DS    0F
WTOREG   DC    AL2(WTOREGL)
         DC    XL2'0000'
         DC    CL3'R0='
WTOREG0O DC    CL10'          '
         DC    CL3'R1='
WTOREG1O DC    CL10'          '
         DS    0F
         DC    CL3'R2='
WTOREG2O DC    CL10'          '
         DS    0F
         DC    CL3'R3='
WTOREG3O DC    CL10'          '
WTOREGL  EQU   *-WTOREG
         DS    0F
WTOGRP   DC    AL2(WTOGRPL)
         DC    XL2'0000'
         DC    CL9'FUNCTION='
WTOFNCR  DC    CL8'        '
         DC    CL1' '
         DC    CL6'GROUP='
WTOGRPR  DC    CL8'        '
         DS    0F
WTOGRPL  EQU   *-WTOGRP
WTODMP   DC    AL2(WTODMPL)
         DC    XL2'0000'
         DC    CL6'BLOCK='
WTOBLKN  DC    CL8'        '
         DC    CL1' '
WTODMPB  DS    CL64
         DC    CL1' '
         DS    0F
WTODMPL  EQU   *-WTODMP
WTOMSGR  DC    AL2(WTOMSGL)
         DC    XL2'0000'
         DC    CL12'[RAKF]  MSG='
WTOMSGO  DC    CL8'        '
WTOMSGL  EQU   *-WTOMSGR
         DS    0F
RAKFUNC  DC    AL1(3)
         DC    XL3'000000'
         DS    0F
UNPKWRK  DS    CL10
         DS    0F
SW       DS    XL1'00'                 FLAGS
$CREATE  EQU   128                     1... .... ACEE CREATED
         DS    0F
RAKWORK  DS    CL512
         DS    0D
VFYLIST RACROUTE REQUEST=VERIFY,                                       X
               ENVIR=,                                                 X
               USERID=,                                                X
               PASSWRD=,                                               X
               WORKA=,                                                 X
               TERMID=LUDUMMY,                                         X
               MF=L
         LTORG ,
         IKJTCB
         IEZJSCB
         END
/*
//SYSLIN   DD DUMMY
//SYSPUNCH DD DSN=EKATUS.TEST.OBJLIB(RAKFCHK),DISP=SHR
//SYSPRINT DD SYSOUT=*
//SYSUT1   DD UNIT=SYSDA,SPACE=(CYL,(2,2))
//SYSUT2   DD UNIT=SYSDA,SPACE=(CYL,(2,2))
//SYSUT3   DD UNIT=SYSDA,SPACE=(CYL,(2,2))
//LINKSTUB EXEC PGM=IEWL,PARM='XREF,LIST,LET,MAP,AC=1'
//SYSPRINT DD SYSOUT=*
//SYSUT1   DD UNIT=SYSDA,SPACE=(1024,(200,20))
//MYOBJ    DD DISP=SHR,DSN=EKATUS.TEST.OBJLIB
//SYSLMOD  DD DISP=SHR,DSN=EKATUS.LOADLIB(RAKFCHK)
//SYSLIN   DD *
 SETCODE AC(1)
 INCLUDE MYOBJ(RAKFCHK)
 ENTRY RAKFCHK
 NAME RAKFCHK(R)
