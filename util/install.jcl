//INSTALLF JOB (AXXX),                                                  00000101
//        'MICHAEL GROM',                                               00000200
//         CLASS=A,                                                     00000300
//         MSGCLASS=X,                                                  00000400
//         MSGLEVEL=(1,1),                                              00000500
//         NOTIFY=EKATUS                                                00000600
//COPYA    EXEC PGM=IEBCOPY                                             00000701
//INDD     DD   DSN=EKATUS.FOTOFIX.CNTL,DISP=SHR                        00000801
//OUTDD    DD   DSN=FOTOFIX.CNTL,DISP=OLD                               00000902
//SYSUT3   DD   UNIT=SYSDA,SPACE=(TRK,(5,5))                            00001002
//SYSUT4   DD   UNIT=SYSDA,SPACE=(TRK,(5,5))                            00001102
//SYSPRINT DD   SYSOUT=*                                                00001201
//SYSIN    DD   *                                                       00001301
  COPY INDD=INDD,OUTDD=OUTDD                                            00001401
/*                                                                      00001501
