      *///////////////////////////////////////////////////////////////
      * 'BMS' map for use with 'KICKS for TSO'
      *   generated 10/10/26 at 19:34:22 with mapgen version V1R5M0(0)
      *
      * 'KICKS for TSO'
      *  Copyright 2008-2014, Michael Noel, All Rights Reserved.
      *
      * Assuming the input belongs to you this generated map is also
      * your property and you may do whatever you like with it.
      *   HOWEVER
      *
      * Usage of 'KICKS for TSO' is subject to license.
      * See http://www.kicksfortso.com
      * for most current information regarding licensing options,
      *//1/////////2/////////3/////////4/////////5/////////6/////////7

       01  FFIXMAPI.
           02  FILLER PIC X(12).
           02  LAUFZNL COMP PIC S9(4).
           02  LAUFZNF PIC X.
           02  LAUFZNC PIC X.
           02  LAUFZNH PIC X.
           02  LAUFZNI PIC X(8).
           02  MESSAGEL COMP PIC S9(4).
           02  MESSAGEF PIC X.
           02  MESSAGEC PIC X.
           02  MESSAGEH PIC X.
           02  MESSAGEI PIC X(40).
           02  ERRMSGL COMP PIC S9(4).
           02  ERRMSGF PIC X.
           02  ERRMSGC PIC X.
           02  ERRMSGH PIC X.
           02  ERRMSGI PIC X(40).
           02  PFKEYSL COMP PIC S9(4).
           02  PFKEYSF PIC X.
           02  PFKEYSC PIC X.
           02  PFKEYSH PIC X.
           02  PFKEYSI PIC X(50).

       01  FFIXMAPO REDEFINES FFIXMAPI.
           02  FILLER PIC X(12).
           02  FILLER PIC X(2).
           02  LAUFZNA PICTURE X.
           02  FILLER PIC X(2).
           02  LAUFZNO PIC X(8).
           02  FILLER PIC X(2).
           02  MESSAGEA PICTURE X.
           02  FILLER PIC X(2).
           02  MESSAGEO PIC X(40).
           02  FILLER PIC X(2).
           02  ERRMSGA PICTURE X.
           02  FILLER PIC X(2).
           02  ERRMSGO PIC X(40).
           02  FILLER PIC X(2).
           02  PFKEYSA PICTURE X.
           02  FILLER PIC X(2).
           02  PFKEYSO PIC X(50).

       01  FFIXMP2I.
           02  FILLER PIC X(12).
           02  VSAMRC1L COMP PIC S9(4).
           02  VSAMRC1F PIC X.
           02  VSAMRC1C PIC X.
           02  VSAMRC1H PIC X.
           02  VSAMRC1I PIC X(2).
           02  VSAMRC2L COMP PIC S9(4).
           02  VSAMRC2F PIC X.
           02  VSAMRC2C PIC X.
           02  VSAMRC2H PIC X.
           02  VSAMRC2I PIC X(2).
           02  MESSAG2L COMP PIC S9(4).
           02  MESSAG2F PIC X.
           02  MESSAG2C PIC X.
           02  MESSAG2H PIC X.
           02  MESSAG2I PIC X(40).
           02  ERRMSG2L COMP PIC S9(4).
           02  ERRMSG2F PIC X.
           02  ERRMSG2C PIC X.
           02  ERRMSG2H PIC X.
           02  ERRMSG2I PIC X(40).

       01  FFIXMP2O REDEFINES FFIXMP2I.
           02  FILLER PIC X(12).
           02  FILLER PIC X(2).
           02  VSAMRC1A PICTURE X.
           02  FILLER PIC X(2).
           02  VSAMRC1O PIC X(2).
           02  FILLER PIC X(2).
           02  VSAMRC2A PICTURE X.
           02  FILLER PIC X(2).
           02  VSAMRC2O PIC X(2).
           02  FILLER PIC X(2).
           02  MESSAG2A PICTURE X.
           02  FILLER PIC X(2).
           02  MESSAG2O PIC X(40).
           02  FILLER PIC X(2).
           02  ERRMSG2A PICTURE X.
           02  FILLER PIC X(2).
           02  ERRMSG2O PIC X(40).

       01  FFIXMEXI.
           02  FILLER PIC X(12).
           02  MESSAG3L COMP PIC S9(4).
           02  MESSAG3F PIC X.
           02  MESSAG3C PIC X.
           02  MESSAG3H PIC X.
           02  MESSAG3I PIC X(40).
           02  ERRMSG4L COMP PIC S9(4).
           02  ERRMSG4F PIC X.
           02  ERRMSG4C PIC X.
           02  ERRMSG4H PIC X.
           02  ERRMSG4I PIC X(40).

       01  FFIXMEXO REDEFINES FFIXMEXI.
           02  FILLER PIC X(12).
           02  FILLER PIC X(2).
           02  MESSAG3A PICTURE X.
           02  FILLER PIC X(2).
           02  MESSAG3O PIC X(40).
           02  FILLER PIC X(2).
           02  ERRMSG4A PICTURE X.
           02  FILLER PIC X(2).
           02  ERRMSG4O PIC X(40).

       01  FFIXADMI.
           02  FILLER PIC X(12).
           02  FFXPASSL COMP PIC S9(4).
           02  FFXPASSF PIC X.
           02  FFXPASSC PIC X.
           02  FFXPASSH PIC X.
           02  FFXPASSI PIC X(8).
           02  MESSAG5L COMP PIC S9(4).
           02  MESSAG5F PIC X.
           02  MESSAG5C PIC X.
           02  MESSAG5H PIC X.
           02  MESSAG5I PIC X(40).
           02  ERRMSG5L COMP PIC S9(4).
           02  ERRMSG5F PIC X.
           02  ERRMSG5C PIC X.
           02  ERRMSG5H PIC X.
           02  ERRMSG5I PIC X(40).

       01  FFIXADMO REDEFINES FFIXADMI.
           02  FILLER PIC X(12).
           02  FILLER PIC X(2).
           02  FFXPASSA PICTURE X.
           02  FILLER PIC X(2).
           02  FFXPASSO PIC X(8).
           02  FILLER PIC X(2).
           02  MESSAG5A PICTURE X.
           02  FILLER PIC X(2).
           02  MESSAG5O PIC X(40).
           02  FILLER PIC X(2).
           02  ERRMSG5A PICTURE X.
           02  FILLER PIC X(2).
           02  ERRMSG5O PIC X(40).

