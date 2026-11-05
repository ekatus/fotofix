//GTFBASEA JOB (AXXX),                                                  00000101
//        'MICHAEL GROM',                                               00000200
//         CLASS=A,                                                     00000300
//         MSGCLASS=X,                                                  00000400
//         MSGLEVEL=(1,1),                                              00000500
//         NOTIFY=&SYSUID                                               00000601
//GTFB    EXEC PGM=IDCAMS                                               00000701
//SYSPRINT DD SYSOUT=*                                                  00000800
//SYSIN    DD *                                                         00000900
*DELETE GTF.TRACE GDG FORCE                                             00001001
 DEFINE GDG (NAME(GTF.TRACE)                                           -00001101
         LIMIT(255)                                                    -00001201
         NOEMPTY                                                       -00001301
         SCRATCH)                                                       00001401
