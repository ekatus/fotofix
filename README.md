# fotofix
The implementation of the FOTOFIX client for MVS 3.8j bridging the vintage OS into the modern world.

The source code has been - except for the Python bridge part, been entirely created on MVS 3.8j using MVS tools. Don't expect the code to build or run in your environment. It also greatly depends on ASCII art provided to the FOTOFIX client through the Python bridge. Feel free to mock this by providing a 132 cols x 66 lines ASCII art file of your own by your own access method. 
When it comes to JES2 printout, I adapted this to my printer handling code outside Hercules. The code here just puts the print to a SYSOUT class and JES2 may try to put it on one printer you have defined. 

