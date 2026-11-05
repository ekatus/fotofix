//ALCFFIXA JOB (AXXX),                                                  00000101
//        'MICHAEL GROM',                                               00000200
//         CLASS=A,                                                     00000300
//         MSGCLASS=X,                                                  00000400
//         MSGLEVEL=(1,1),                                              00000500
//         NOTIFY=EKATUS                                                00000600
//DELV    EXEC PGM=IDCAMS                                               00000700
//SYSPRINT DD SYSOUT=*                                                  00000800
//TSO004   DD UNIT=3390,VOL=SER=TSO004,DISP=SHR                         00000902
//SYSIN    DD *                                                         00001000
 DEFINE CLUSTER (NAME(EKATUS.FOTOFIX.ORDER) VOLUMES(TSO004)            -00001102
    TRACKS(25,25) INDEXED                                              -00001204
    KEYS(16 0)                                                         -00001301
    RECORDSIZE(80 80)                                                  -00001406
    SHAREOPTIONS(3 3) UNIQUE )                                         -00001513
    DATA (NAME(ETAKUS.FOTOFIX.ORDER.DATA))                             -00001601
    INDEX (NAME(ETAKUS.FOTOFIX.ORDER.INDEX))                            00001701
