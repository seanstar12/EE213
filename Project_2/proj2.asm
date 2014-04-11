; ==========================================================
;
;     LED.1 : RED : P2.4            SW.1 : P2.0 
;     LED.2 : YEL : P0.5            SW.2 : P0.1
;     LED.3 : GRN : P2.7            SW.3 : P2.3
;     LED.4 : AMB : P0.6            SW.4 : P0.2
;     LED.5 : BLU : P1.6            SW.5 : P1.4
;     LED.6 : RED : P0.4            SW.6 : P0.0
;     LED.7 : YEL : P2.5            SW.7 : P2.1
;     LED.8 : GRN : P0.7            SW.8 : P0.3
;     LED.9 : AMB : P2.6            SW.9 : P2.2
;
;     Frequency of Note EQ: R3.R4 = 65536 - 3686400/(2F)
; ==========================================================


#include <reg932.inc>

CSEG at 0x0000                    ; start our program here. at 0
  SJMP init                       ; jump over interrupt and go to init
  
CSEG AT 0x000B                    ; Interrupt Vector Address for TIMER 0
  CPL P1.7                        ; compliments P1.4 to produce sound from speaker
  CLR C
  MOV A, R5                       ; Reads upper byte of 16-bit timer re-load value
  MOV TH0, A                      ; into A and puts it into the upper byte of TIMER 0
  MOV A, R6                       ; Reads lower byte of 16-bit timer re-load value
  MOV TL0, A                      ; into A and puts it into the lower byte of TIMER 0
  RETI                            ; Returns from the interrupt

init:
  MOV 60H, #0                     ; Clear Storage Registers
  MOV 61H, #0
  MOV 62H, #0
  MOV 63H, #0
  MOV 64H, #0
  MOV 65H, #0
  SETB P2.4 					  ; Clear LEDS incase of reset
  SETB P0.5
  SETB P2.7
  SETB P0.4
  ACALL UPDATEDISPLAY
  MOV R7, #0
  MOV P0M1,#0                    ; Set ports to bi-directional
  MOV P1M1,#0
  MOV P2M1,#0
  MOV TMOD,#0x01                  ; Set TIMER 0 into mode 1

main:
  JNB P2.0,project 				  ; code for project
  JNB P0.1,hacky 				  ; extra code for more points
  JNB P2.2,resetHandle 			  ; reset switch handler
  ACALL UPDATEDISPLAY 			  ; 7segment updater
SJMP main

hacky: LJMP song 				 ; Dirty hack to get further down the page

project:
    MOV R0,#21                    ; timeout function here
  tout_0:                         ; waits for X secods then starts to run MATHS on button presses
    MOV R1,#255                   ; T= ((21*255*255)+11)(.000001085) = 1.4816 seconds
  tout_1:                         ; Scope gave us 1.468 seconds
    MOV R2,#255
	
  tout_2:
    JNB P2.0,buttonHandle         ; if button 1 is pressed,
    DJNZ R2, tout_2
    DJNZ R1, tout_1
    DJNZ R0, tout_0
	ACALL MATHS 				  ; primary logic functions that perform
	ACALL BCDLEDS 				  ; the calculations require
	ACALL SOUND
  SJMP main

MATHS: 								; divides button pushes by 16
  MOV A, 60H 						; store remainder in 65H
  MOV B, #16
  DIV AB
  MOV 64H,A 						; Quotient
  MOV 65H,B 						; Remainder
RET

BCDLEDS:
  MOV A, 65H 						; converts the remainder to
  JZ noLed 							; BCD for LED output.
  MOV R7, A
  MOV R6, #4

  Leds:
    ANL A,#1 						; And's the Accum with one
	PUSH 0E0H 						; pushes the AND'd value onto the stack
	MOV A,R7  						; restore the accum
	RR A 							; rotate right to repeat process
	MOV R7,A
	DJNZ R6,Leds
	
    POP 0E0H 						; we pushed, now we must pop.
    JZ lightBit3 				    
    CLR P2.4
 lightBit3:
    POP 0E0H
    JZ lightBit2
    CLR P0.5
  lightBit2:
    POP 0E0H
    JZ lightBit1
    CLR P2.7
  lightBit1:
    POP 0E0H
    JZ noLed
    CLR P0.4	
  noLed:
RET

buttonHandle:
  CLR P1.6                        ; turns on led saying you pressed button
  JNB P2.0,buttonHandle          ; Loops until you let go of the button
  SETB P1.6                       ; turns off the led
  ACALL DEBOUNCE                  ; timeout to prevent bouncing of switch
  INC R7                          ; increment our button presses counter
  MOV 60H, R7
  ACALL DECIMALCONVERT
  SJMP project                    ; jump to project section to wait for another press||timeout

resetHandle:
  JNB P2.2, resetHandle  		  ; handler for reset switch fun times.
  ACALL DEBOUNCE
  LJMP init

DEBOUNCE:                         ; Used for debouncing switches
    MOV R5,#50
  debounceLoop: 				  ; Prevent's 'thumbing it'
    MOV R6,#200
  debounceLoop_1:
    DJNZ R6,debounceLoop_1
    DJNZ R5,debounceLoop
  RET
  
DECIMALCONVERT: 					; Uses division by 10 to seperate out
  MOV A, R7 						; the hex from more normal numbers
  MOV B, #10 						; wouldn't have need this, but our 
  DIV AB 							; converters were only decimal
  MOV 61H, B
  MOV B, #10
  DIV AB
  MOV 62H, B
  MOV 63H, A 
RET

UPDATEDISPLAY: 						; function that multiplexes our 7segment cluster
  SETB P0.7 						; 3 IO pins are tied to grounding transistors
  MOV P1, 61H 
  ACALL DEBOUNCE
  CLR P0.7
  SETB P2.5
  MOV P1, 62H
  ACALL DEBOUNCE
  CLR P2.5
  SETB P2.6
  MOV P1, 63H
  ACALL DEBOUNCE
  CLR P2.6
  SETB P1.6
RET

sound:
  MOV A, 64H
  JZ noSound
sndRepeat:	
  MOV R5,#0FFH
Toggle:	
  LCALL DELAY
  CPL P1.7
  DJNZ R5, Toggle
  MOV R7,#55H
sndRepeat_1:	
  LCALL DELAY
  DJNZ R7, sndRepeat_1
  DJNZ 64H, SndRepeat
noSound:
  RET	
DELAY:
  MOV R0, #15
  AGAIN11:
    MOV R1,#0FFH
  AGAIN12:
    NOP
    DJNZ R1,AGAIN12
    DJNZ R0,AGAIN11
RET

DelayTone:
  MOV R0, #05
delayTone_1:
  MOV R1,#0FFH
delayTone_2:
  NOP
  DJNZ R1,delayTone_2
  DJNZ R0,delayTone_1
  RET

song:
	mov TH0, #0				; presets a 16-bit value into TIMER 0 
	mov TL0, #0				; upper byte first and then lower byte
	mov R5, #0				; sets this same 16-bit value into R3 and R4
	mov R6, #0				; used to reload TIMER 0 in the ISR
	SETB ET0					; enable TIMER 0 overflow interrupt
	SETB EA						; set global interrupt enable bit
	SETB TR0					; start TIMER 0 counting

start: 							;Beginning of the song
	mov R0, #8
	acall playDX6	
	acall Spacing
	mov R0, #8
	acall playE6	
	acall Spacing
	mov R0, #16
	acall playFX6	
	acall Spacing		
	mov R0, #16
	acall playB6	
	acall Spacing
	mov R0, #8
	acall playDX6	
	acall Spacing
	mov R0, #8
	acall playE6	
	acall Spacing
	mov R0, #8
	acall playFX6	
	acall Spacing
	mov R0, #8
	acall playB6	
	acall Spacing		
	mov R0, #8
	acall playCX16	
	acall Spacing
	mov R0, #8
	acall playDX16	
	acall Spacing
	mov R0, #8
	acall playCX16	
	acall Spacing	
	mov R0, #8
	acall playAX6	
	acall Spacing	
	mov R0, #16
	acall playB6	
	acall Spacing
	mov R0, #16
	acall playFX6	
	acall Spacing
	mov R0, #8
	acall playDX6	
	acall Spacing
	mov R0, #8
	acall playE6	
	acall Spacing
	mov R0, #16
	acall playFX6	
	acall Spacing
	mov R0, #16
	acall playB6	
	acall Spacing
	mov R0, #8
	acall playCX16	
	acall Spacing
	mov R0, #8
	acall playAX6	
	acall Spacing	
	mov R0, #8
	acall playB6	
	acall Spacing		
	mov R0, #8
	acall playCX16	
	acall Spacing		
	mov R0, #8
	acall playE16	
	acall Spacing		
	mov R0, #8
	acall playDX16	
	acall Spacing
	mov R0, #8
	acall playAX6	
	acall Spacing		
	mov R0, #8
	acall playE16	
	acall Spacing	
	mov R0, #8
	acall playCX16	
	acall Spacing   			;end of first line
loophereforfun:
	mov R0, #16
	acall playFX6	
	acall Spacing
	mov R0, #18
	acall playGX6	
	acall Spacing
	mov R0, #16
	acall playDX6	
	acall Spacing
	mov R0, #8
	acall playDX6	
	acall Spacing
	mov R0, #8
	acall playDX6	
	acall Spacing
	mov R0, #8
	acall Spacing
	mov R0, #8
	acall playD6	
	acall Spacing
	mov R0, #8
	acall playCX6	
	acall Spacing
	mov R0, #8
	acall playB6	
	acall Spacing
	mov R0, #8
	acall Spacing
	mov R0, #16
	acall playB6	
	acall Spacing	
	mov R0, #8
	acall playCX6	
	acall Spacing	
	mov R0, #16
	acall playD6	
	acall Spacing	
	mov R0, #8
	acall playD6	
	acall Spacing	
	mov R0, #8
	acall playCX6	
	acall Spacing	
	mov R0, #8
	acall playB6	
	acall Spacing		
	mov R0, #8
	acall playCX6	
	acall Spacing
	mov R0, #8
	acall playDX6	
	acall Spacing
	mov R0, #8
	acall playFX6	
	acall Spacing
	mov R0, #8
	acall playGX6	
	acall Spacing
;5
	mov R0, #8
	acall playDX6	
	acall Spacing
	mov R0, #8
	acall playFX6	
	acall Spacing
	mov R0, #8
	acall playCX6	
	acall Spacing
	mov R0, #8
	acall playDX6	
	acall Spacing
	mov R0, #8
	acall playB6	
	acall Spacing	
	mov R0, #8
	acall playCX6	
	acall Spacing	
	mov R0, #8
	acall playB6	
	acall Spacing
	mov R0, #16
	acall playDX6	
	acall Spacing
	mov R0, #16
	acall playFX6	
	acall Spacing
;5
	mov R0, #8
	acall playGX6	
	acall Spacing
	mov R0, #8
	acall playDX6	
	acall Spacing
	mov R0, #8
	acall playFX6	
	acall Spacing
	mov R0, #8
	acall playCX6	
	acall Spacing
	mov R0, #8
	acall playDX6	
	acall Spacing
	mov R0, #8
	acall playB6	
	acall Spacing
	mov R0, #8
	acall playD6	
	acall Spacing
	mov R0, #8
	acall playDX6	
	acall Spacing
	mov R0, #8
	acall playD6	
	acall Spacing
	mov R0, #8
	acall playCX6	
	acall Spacing
	mov R0, #8
	acall playB6	
	acall Spacing
	mov R0, #8
	acall playCX6	
	acall Spacing
	mov R0, #16
	acall playD6	
	acall Spacing
	mov R0, #8
	acall playB6	
	acall Spacing
	mov R0, #8
	acall playCX6	
	acall Spacing
	mov R0, #8
	acall playDX6	
	acall Spacing
	mov R0, #8
	acall playFX6	
	acall Spacing	
	mov R0, #8
	acall playCX6	
	acall Spacing
	mov R0, #8
	acall playDX6	
	acall Spacing	
	mov R0, #8
	acall playCX6	
	acall Spacing	
	mov R0, #8
	acall playB6	
	acall Spacing	
	mov R0, #16
	acall playCX6	
	acall Spacing	
	mov R0, #16
	acall playB6	
	acall Spacing	
	mov R0, #16
	acall playCX6	
	acall Spacing
	JNB P2.3,bail 
	Ljmp loophereforfun	
	bail:
	LJMP main
; Repeat the song
playC6:				
				clr p2.4       
		mov R5, #0xFC
		mov R6, #0x8F
		acall stall	
                setb p2.4     
	ret	
playCx6:				
				clr p0.5       
		mov R5, #0xFC
		mov R6, #0xC1
		acall stall	
                setb p0.5     
	ret		
				
playD6:
				clr p2.7
		mov R5, #0xFC
		mov R6, #0xEF
		acall stall
                setb p2.7
	ret
playDX6:
                clr p0.6
		mov R5, #0xFD
		mov R6, #0x1B
		acall stall
                setb p0.6
	ret
playE6:
                clr p1.6
		mov R5, #0xFD
		mov R6, #0x45
		acall stall
                setb p1.6
	ret
playF6:
                clr p0.4
		mov R5, #0xFD
		mov R6, #0x6C
		acall stall
                setb p0.4
	ret
playFX6:
                clr p2.5
		mov R5, #0xFD
		mov R6, #0x91
		acall stall
                setb p2.5
	ret
playG6:
                clr p0.7
		mov R5, #0xFD
		mov R6, #0xB4
		acall stall
                setb p0.7
	ret
playGX6:
                clr p2.6
		mov R5, #0xFD
		mov R6, #0xD5
		acall stall
                setb p2.6
	ret
playA6:
                clr p2.4
		mov R5, #0xFD
		mov R6, #0xF4
		acall stall
                setb p2.4
	ret
playAX6:
                clr p0.5
		mov R5, #0xFE
		mov R6, #0x12
		acall stall
                setb p0.5
	ret
playB6:
                clr p2.7
		mov R5, #0xFE
		mov R6, #0x2D
		acall stall
                setb p2.7
	ret
playC16:				
				clr p0.6       
		mov R5, #0xFE
		mov R6, #0x48
		acall stall	
                setb p0.6      
	ret	
playCX16:				
				 clr p1.6       
		mov R5, #0xFE
		mov R6, #0x60
		acall stall	
                setb p1.6       
	ret			
				
playD16:
                clr p0.4
		mov R5, #0xFE
		mov R6, #0x78
		acall stall
                setb p0.4
	ret
playDX16:
                clr p2.5
		mov R5, #0xFE
		mov R6, #0x8E
		acall stall
                setb p2.5
	ret
playE16:
                clr p0.7
		mov R5, #0xFE
		mov R6, #0xA2
		acall stall
        setb p0.7
	ret

	
	
Spacing:
		mov R0, #1
		mov R5, #0x00	; TIMER 0 re-load value is set to minimum
		mov R6, #0x00	; possible value.
		acall stall
	ret


playREST:
		mov R5, #0x00	; TIMER 0 re-load value is set to minimum
		mov R6, #0x00	; possible value.
		clr TR0		; stops TIMER 0 to stop sound
		acall stall
		setb TR0	; restarts TIMER 0 for next note
	ret
; **********************************************************************************
; *  This loop does nothing but loop to allow the note to play for the duration
; *  set by R0.  Set R0 to the proper value before calling this subroutine.
; **********************************************************************************
stall:
	loop0:
		mov R1, #65		; The values entered into R1
	loop1:				; and R2 control the tempo of the
		mov R2, #255		; song.  Smaller values make the 
	loop2:				; song play faster.
		nop
		djnz R2, loop2
		djnz R1, loop1
		djnz R0, loop0
		ret

END