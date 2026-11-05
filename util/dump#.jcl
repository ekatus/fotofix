//DSSDUMP  JOB (AXX,BXX,SXX),'DSSDUMP',                                 00000100
//         CLASS=S,MSGCLASS=X,NOTIFY=&SYSUID                            00000200
//DSSDUMP  EXEC PGM=DSSDUMP,REGION=4096K                                00000300
//SYSPRINT  DD SYSOUT=*                                                 00000400
//SYSIN     DD *                                                        00000500
  DUMP FOTOFIX.**                                                       00000601
//TAPE      DD DSN='DUMP.EKATUS.FOTOFIX',                               00000700
//             UNIT=(TAPE,,DEFER),DISP=(NEW,KEEP),                      00000800
//             DCB=(LRECL=18448,BLKSIZE=18452,RECFM=V)                  00000900
//                                                                      00001000
