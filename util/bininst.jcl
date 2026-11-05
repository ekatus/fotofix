//BININSTF JOB (AXXX),                                                  00000101
//        'MICHAEL GROM',                                               00000200
//         CLASS=A,                                                     00000300
//         MSGCLASS=X,                                                  00000400
//         MSGLEVEL=(1,1),                                              00000500
//         NOTIFY=EKATUS                                                00000600
//COPYA    EXEC PGM=IEBCOPY                                             00000701
//INDD     DD   DSN=EKATUS.LOADLIB,DISP=SHR                             00000801
//OUTDD    DD   DSN=FOTOFIX.LOADLIB,DISP=OLD                            00000901
//SYSUT3   DD   UNIT=SYSDA,SPACE=(TRK,(5,5))                            00001001
//SYSUT4   DD   UNIT=SYSDA,SPACE=(TRK,(5,5))                            00001101
//SYSPRINT DD   SYSOUT=*                                                00001201
//SYSIN    DD   *                                                       00001301
  COPY INDD=INDD,OUTDD=OUTDD                                            00001401
  SELECT MEMBER=((FOTOFIXB,,R),(FOTOSRV1,,R))                           00001506
/*                                                                      00001601
//COPYB    EXEC PGM=IEBCOPY                                             00001701
//INDD     DD   DSN=EKATUS.KICKS.V1R5M0.KIKRPL,DISP=SHR                 00001801
//OUTDD    DD   DSN=FOTOFIX.KICKS.V1R5M0.KIKRPL,DISP=SHR                00001901
//SYSUT3   DD   UNIT=SYSDA,SPACE=(TRK,(5,5))                            00002001
//SYSUT4   DD   UNIT=SYSDA,SPACE=(TRK,(5,5))                            00002101
//SYSPRINT DD   SYSOUT=*                                                00002201
//SYSIN    DD   *                                                       00002301
  COPY INDD=INDD,OUTDD=OUTDD                                            00002401
  SELECT MEMBER=((FFIXMMD,,R),                                         -00002501
                 (FFIXMSD,,R),                                         -00002601
                 (FFIXMSL,,R),                                         -00002702
                 (STDHMSD,,R),                                         -00002801
                 (STDHCOB,,R),                                         -00002901
                 (FOTOFIX,,R),                                         -00003001
                 (FOTOFX0,,R),                                         -00003101
                 (FOTOFX1,,R),                                         -00003201
                 (FOTOFX2,,R),                                         -00003302
                 (FOTOFX3,,R),                                         -00003404
                 (FOTOFX4,,R),                                         -00003505
                 (FOTORAKF,,R))                                         00003604
/*                                                                      00003701
//COPYC    EXEC PGM=IEBCOPY                                             00003807
//INDD     DD   DSN=EKATUS.KICKS.V1R5M0.KIKRPL,DISP=SHR                 00003907
//OUTDD    DD   DSN=FOTOFX1.KICKS.V1R5M0.KIKRPL,DISP=SHR                00004007
//SYSUT3   DD   UNIT=SYSDA,SPACE=(TRK,(5,5))                            00004107
//SYSUT4   DD   UNIT=SYSDA,SPACE=(TRK,(5,5))                            00004207
//SYSPRINT DD   SYSOUT=*                                                00004307
//SYSIN    DD   *                                                       00004407
  COPY INDD=INDD,OUTDD=OUTDD                                            00004507
  SELECT MEMBER=((FFIXMMD,,R),                                         -00004607
                 (FFIXMSD,,R),                                         -00004707
                 (FFIXMSL,,R),                                         -00004807
                 (STDHMSD,,R),                                         -00004907
                 (STDHCOB,,R),                                         -00005007
                 (FOTOFIX,,R),                                         -00005107
                 (FOTOFX0,,R),                                         -00005207
                 (FOTOFX1,,R),                                         -00005307
                 (FOTOFX2,,R),                                         -00005407
                 (FOTOFX3,,R),                                         -00005507
                 (FOTOFX4,,R),                                         -00005607
                 (FOTORAKF,,R))                                         00005707
/*                                                                      00005807
//COPYD    EXEC PGM=IEBCOPY                                             00005908
//INDD     DD   DSN=EKATUS.KICKS.V1R5M0.KIKRPL,DISP=SHR                 00006008
//OUTDD    DD   DSN=FOTOFX2.KICKS.V1R5M0.KIKRPL,DISP=SHR                00006108
//SYSUT3   DD   UNIT=SYSDA,SPACE=(TRK,(5,5))                            00006208
//SYSUT4   DD   UNIT=SYSDA,SPACE=(TRK,(5,5))                            00006308
//SYSPRINT DD   SYSOUT=*                                                00006408
//SYSIN    DD   *                                                       00006508
  COPY INDD=INDD,OUTDD=OUTDD                                            00006608
  SELECT MEMBER=((FFIXMMD,,R),                                         -00006708
                 (FFIXMSD,,R),                                         -00006808
                 (FFIXMSL,,R),                                         -00006908
                 (STDHMSD,,R),                                         -00007008
                 (STDHCOB,,R),                                         -00007108
                 (FOTOFIX,,R),                                         -00007208
                 (FOTOFX0,,R),                                         -00007308
                 (FOTOFX1,,R),                                         -00007408
                 (FOTOFX2,,R),                                         -00007508
                 (FOTOFX3,,R),                                         -00007608
                 (FOTOFX4,,R),                                         -00007708
                 (FOTORAKF,,R))                                         00007808
/*                                                                      00007908
