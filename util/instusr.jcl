//INSTUSRA JOB (AXXX),                                                  00000100
//        'MICHAEL GROM',                                               00000200
//         CLASS=A,                                                     00000300
//         MSGCLASS=X,                                                  00000400
//         MSGLEVEL=(1,1),                                              00000500
//         NOTIFY=EKATUS                                                00000600
//COPYC    EXEC PGM=IEBCOPY                                             00000700
//INDD     DD   DSN=EKATUS.KICKS.V1R5M0.KIKRPL,DISP=SHR                 00000800
//OUTDD    DD   DSN=FOTOFX1.KICKS.V1R5M0.KIKRPL,DISP=SHR                00000900
//SYSUT3   DD   UNIT=SYSDA,SPACE=(TRK,(5,5))                            00001000
//SYSUT4   DD   UNIT=SYSDA,SPACE=(TRK,(5,5))                            00001100
//SYSPRINT DD   SYSOUT=*                                                00001200
//SYSIN    DD   *                                                       00001300
  COPY INDD=INDD,OUTDD=OUTDD                                            00001400
  SELECT MEMBER=((FFIXMMD,,R),                                         -00001500
                 (FFIXMSD,,R),                                         -00001600
                 (FFIXMSL,,R),                                         -00001700
                 (STDHMSD,,R),                                         -00001800
                 (STDHCOB,,R),                                         -00001900
                 (FOTOFIX,,R),                                         -00002000
                 (FOTOFX0,,R),                                         -00002100
                 (FOTOFX1,,R),                                         -00002200
                 (FOTOFX2,,R),                                         -00002300
                 (FOTOFX3,,R),                                         -00002400
                 (FOTOFX4,,R),                                         -00002500
                 (FOTORAKF,,R))                                         00002600
/*                                                                      00002700
