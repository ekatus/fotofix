//VRYFFIXA JOB (AXXX),                                                  00000101
//        'MGROM',                                                      00000205
//         CLASS=A,                                                     00000300
//         MSGCLASS=A,                                                  00000405
//         MSGLEVEL=(1,1),                                              00000500
//         NOTIFY=EKATUS                                                00000600
/*JOBPARM ROOM=MAIL                                                     00000706
//DELV    EXEC PGM=IDCAMS                                               00000800
//SYSPRINT DD SYSOUT=*                                                  00000900
//TSO004   DD UNIT=3390,VOL=SER=TSO004,DISP=SHR                         00001002
//SYSIN    DD *                                                         00001100
 VERIFY DATASET(EKATUS.FOTOFIX.ORDER)                                   00001201
  PRINT INDATASET(EKATUS.FOTOFIX.ORDER) CHARACTER                       00001304
