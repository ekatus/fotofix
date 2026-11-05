       01   WS-RAKF.
            05 WS-RETCODE                 PIC X(8) VALUE LOW-VALUE.
            05 WS-REQUEST REDEFINES WS-RETCODE PIC X(8).
            05 WS-GROUPNAM                PIC X(8) VALUE 'ADMIN   '.
            05 WS-PASSWORD REDEFINES WS-GROUPNAM PIC X(8).
            05 WS-USERID                  PIC X(8) VALUE SPACES.
