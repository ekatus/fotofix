       01  WS-COMM.                                                     00000100
           05  TTRANID         PIC X(4).                                00000200
           05  TPROGID         PIC X(8).                                00000300
           05  STDHFLAG        PIC X.                                   00000400
           05  DISPATCH        PIC X.                                   00000501
           05  DELFLAG         PIC X.
           05  ORDERNUM        PIC X(8).                                00000601
           05  RC-1            PIC 9(2) COMP.                           00000804
           05  RC-2            PIC 9(2) COMP.                           00000904
           05  FIRST-KEY       PIC X(16) VALUE LOW-VALUE.               00001003
           05  LAST-KEY        PIC X(16) VALUE LOW-VALUE.               00001003
           05  KEY-LEN         PIC 9(2) COMP VALUE 0.
           05  PAGE-NO         PIC 9(2) COMP VALUE 0.                   00001103
           05  LANGUAGE        PIC X(2) VALUE 'DE'.                     00001206
           05  WS-EOF          PIC 9(2) COMP VALUE 0.
           05  WS-ITEM-NO      PIC 9(2) COMP VALUE 0.
           05  ADMIN-FLAG      PIC X(1) VALUE 'N'.
           05  WS-BUF-8        PIC X(8) VALUE LOW-VALUE.
           05  FILLER          PIC X(22).                               00001305
