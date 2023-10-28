         .MODEL SMALL
         .STACK 64H

         .DATA

BLANK    DW    ?
LIVE     DW    0FF20H
DEAD     DW    002EH
BORN     DW    002CH

         .CODE
MAIN     PROC  FAR

         MOV   AX, @DATA
         MOV   DS, AX

         MOV   AX, 0B800h            ; VIDEO SEGMENT
         MOV   ES, AX                ; USE ES AS VIDEO SEGMENT

         MOV   AX, 3H                ; SET VIDEO MODE
         INT   10H                   ; CLEAR SCREEN

         MOV   CX, 2607H             ; HIDE CURSOR
         MOV   AH, 01H
         INT   10H

         MOV   DI, 520H
         MOV   AX, ES:[DI]
         MOV   BLANK, AX              ; SET BLANK

         MOV   DI, 1990
         MOV   AX, LIVE
         
         ; Pentadecathlon
         MOV   ES:[DI], AX
         MOV   ES:[DI + 2], AX
         MOV   ES:[DI + 6], AX
         MOV   ES:[DI + 8], AX
         MOV   ES:[DI + 10], AX
         MOV   ES:[DI + 12], AX
         MOV   ES:[DI + 14], AX
         MOV   ES:[DI + 18], AX
         MOV   ES:[DI - 156], AX
         MOV   ES:[DI + 164], AX
         MOV   ES:[DI - 144], AX
         MOV   ES:[DI + 176], AX
         

GAME:    CALL  SLEEP
         CALL  ITERATE
         CALL  SETCELLS
         CALL  INPUT

         JMP   GAME   

         CALL  EXIT

MAIN     ENDP


ITERATE  PROC

         MOV   DI, 162                ; SET STARTING POS
         MOV   CH, 23                 ; DRAW FOR 23 ROWS

ILOOP1:  MOV   CL, 78                 ; 78 COLS

ILOOP2:  MOV   BX, 0
         CALL  ITERNS                 ; NOW BX HOLD N COUNT

         MOV   AX, ES:[DI]

         CMP   BX, 3
         JE    STBORN

         CMP   BX, 2
         JNE   STDEAD
         
ICONT:   ADD   DI, 2
         DEC   CL
         JNZ   ILOOP2

         ADD   DI, 4                  ; GO TO NEXT ROWS 2ND CHAR
         DEC   CH
         JNZ   ILOOP1

         RET

STBORN:  CMP   AX, LIVE
         JE    ICONT
         MOV   AX, BORN
         MOV   ES:[DI], AX
         JMP   ICONT

STDEAD:  CMP   AX, BLANK
         JE    ICONT
         MOV   AX, DEAD
         MOV   ES:[DI], AX
         JMP   ICONT

ITERATE  ENDP



ITERNS   PROC
         PUSH  DI
         
         MOV   AX, ES:[DI - 162]      ; TOP LEFT
         CALL  COUNTN

         MOV   AX, ES:[DI - 160]      ; TOP
         CALL  COUNTN
         
         MOV   AX, ES:[DI - 158]      ; TOP RIGHT
         CALL  COUNTN
         
         MOV   AX, ES:[DI - 2]        ; LEFT
         CALL  COUNTN
         
         MOV   AX, ES:[DI + 2]        ; RIGHT
         CALL  COUNTN

         MOV   AX, ES:[DI + 158]      ; BOTTOM LEFT
         CALL  COUNTN

         MOV   AX, ES:[DI + 160]      ; BOTTOM
         CALL  COUNTN
         
         MOV   AX, ES:[DI + 162]      ; BOTTOM RIGHT
         CALL  COUNTN

         POP   DI
         RET
ITERNS   ENDP

COUNTN   PROC
         CMP   AX, LIVE
         JE    ISN

         CMP   AX, DEAD
         JE    ISN

         RET

ISN:     INC   BX
         RET
COUNTN   ENDP


SETCELLS PROC

         MOV   DI, 162                ; SET STARTING POS
         MOV   CH, 23                 ; DRAW FOR 23 ROWS

SLOOP1:  MOV   CL, 78                 ; 78 COLS 

SLOOP2:  MOV   AX, ES:[DI]

         CMP   AX, BORN
         JE    STLIVE

         CMP   AX, DEAD
         JE    STBLANK

SCONT:   ADD   DI, 2
         DEC   CL
         JNZ   SLOOP2

         ADD   DI, 4                  ; GO TO NEXT LINE
         DEC   CH
         JNZ   SLOOP1

         RET

STLIVE:  MOV   AX, LIVE
         MOV   ES:[DI], AX
         JMP   SCONT

STBLANK: MOV   AX, BLANK
         MOV   ES:[DI], AX
         JMP   SCONT

SETCELLS ENDP


INPUT    PROC

         MOV   AH, 01H                 ; CHECK IF A KEY IS PRESSED
         INT   16H
         JZ    ENDIN                   ; ZERO MEANS NOT PRESSED

         MOV   AH, 00H                 ; GET THE KEY
         INT   16H

         CMP   AH, 01H                 ; ESC TO EXIT
         JE    EXIT

ENDIN:   RET

INPUT    ENDP


SLEEP    PROC
         MOV     CX, 0003H            ; CX : HIGH WORD 
         MOV     DX, 0000H            ; DX : LOW WORD
         MOV     AH, 86H              ; DELAY
         INT     15H

         RET
SLEEP    ENDP


EXIT     PROC
         MOV   AX, 3H
         INT   10H                    ; CLEAR SCREEN

         MOV   AX, 4C00H 
         INT   21H
EXIT     ENDP

         END   MAIN