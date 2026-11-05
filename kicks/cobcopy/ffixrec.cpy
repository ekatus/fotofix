       01   VSAM-RECORD.                                                00000100
            05 VSAM-KEY.                                                00000200
               10 VSAM-TYPE               PIC X(1) VALUE 'O'.           00000300
               10 VSAM-LAUFZN             PIC X(8).                     00000400
               10 VSAM-SEQ                PIC 9(7).                     00000500
            05 VSAM-REC.                                                00000600
               10 VSAM-STAT               PIC X(1) VALUE 'P'.           00000700
               10 VSAM-DEL                PIC X(1) VALUE 'N'.           00000800
               10 FILLER                  PIC X(1) VALUE '#'.           00000901
               10 VSAM-TERM               PIC X(4).                     00001000
               10 FILLER                  PIC X(1) VALUE '#'.           00001101
               10 VSAM-USERID             PIC X(8).                     00001200
               10 FILLER                  PIC X(1) VALUE '#'.           00001301
               10 VSAM-SYSID              PIC X(4).                     00001400
               10 FILLER                  PIC X(1) VALUE '#'.           00001501
               10 VSAM-PRINT-DATE         PIC X(10) VALUE SPACE.        00001601
               10 FILLER                  PIC X(1) VALUE '#'.           00001701
               10 VSAM-PRINT-TIME         PIC X(8) VALUE SPACE.         00001801
               10 FILLER                  PIC X(1) VALUE '#'.           00001901
               10 VSAM-ORDER-DATE         PIC X(10) VALUE SPACE.        00002001
               10 FILLER                  PIC X(1) VALUE '#'.           00002101
               10 VSAM-ORDER-TIME         PIC X(8) VALUE SPACE.         00002201
               10 FILLER                  PIC X(1) VALUE '#'.           00002301
