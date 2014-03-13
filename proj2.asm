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

  CSEG at 0x0000                  ; start our program here. at 0
  SJMP init                       ; jump over interrupt and go to init
  
  CSEG AT 0x000B		            	; Interrupt Vector Address for TIMER 0
  CPL P1.7				              	; compliments P1.4 to produce sound from speaker
  CLR C
  MOV A, R5				              	; Reads upper byte of 16-bit timer re-load value
  MOV TH0, A			              	; into A and puts it into the upper byte of TIMER 0
  MOV A, R6				              	; Reads lower byte of 16-bit timer re-load value
  MOV TL0, A			              	; into A and puts it into the lower byte of TIMER 0
  RETI						              	; Returns from the interrupt

init:
  MOV P0M1,#0				              ; Set ports to bi-directional
  MOV P1M1,#0
  MOV P2M1,#0
  MOV TMOD,#0x01		              ; Set TIMER 0 into mode 1

clear:
  SETB P2.4                       ; Turns off ALL leds
  SETB P0.5
  SETB P2.7
  SETB P0.6
  SETB P1.6
  SETB P0.4
  SETB P2.5
  SETB P0.7
  SETB P2.6
  MOV R7,#0                       ; Makes sure counter is clear

main:
  JNB P2.0,cntr                   ; Stay in loop until button is pressed
  JNB P2.1,debugSet               ; Enters debug mode with hard set value of button presses
  SJMP main
  
cntr:
  MOV R0,#20                      ; timeout function here
  tout_0:                         ; waits for X secods then starts to run MATHS on button presses
    MOV R1,#255                   ; 
  tout_1:
    MOV R2,#255
  tout_2:
    JNB P2.0,pressedButton        ; if button 1 is pressed,
    DJNZ R2, tout_2
    DJNZ R1, tout_1
    DJNZ R0, tout_0

debugMode:
  ACALL MATHS                     ; do maths and return values: R3=quotient  & R4=remainder
  ACALL LEDS                      ; turns on leds based on R4 -> goes first so lights are on before speaker
  ACALL THROB                     ; Beeps based on R3
  
  wait:
    JNB P2.2, clear               ; after speaker and lights, loop until reset button is pressed
    SJMP wait                     ; if reset-> jump to clear and start over

pressedButton:                   
  CLR P1.6                        ; turns on led saying you pressed button
  JNB P2.0,pressedButton          ; Loops until you let go of the button
  SETB P1.6                       ; turns off the led
  ACALL DEBOUNCE                  ; timeout to prevent bouncing of switch
  INC R7                          ; increment our button presses counter
  SJMP cntr                       ; jump to cntr section to wait for another press||timeout
	
debugSet:                         ; Debug so we can test without having to push 100x
  JNB P2.1,debugSet               ; stay here until you let go of the button
  CLR P2.5                        ; turn on light so we know we're debugging
  MOV R7,#19                      ; fill the counter with 19
  SJMP debugMode                  ; jump back to main program loop with new debug counter

; ==========================================================
;	Subroutines Go Below This Line. Also CAPS for all Subs.
; ==========================================================	

MATHS:
  MOV A,R7                        ; Num of Presses into Accum
  MOV B,#16                       ; Divide by 16
  DIV AB                          ; 
  MOV 20H,R7                      ; store total button pushes
  MOV R3,A                        ; Store quotient for beeps
  MOV R4,B                        ; Store remainder for binary output of leds
  RET

LEDS:
  MOV A,R4
  JZ noLed                        ; jump if no leds are needed
  MOV R0,#4                       ; setup our loop var (4 leds)
  MOV R1,#21H                     ; base memory loaction for led values
  MOV R6,#1                       ; our ANDing value to mask out bits
  MOV R7,A                        ; next step destroys data, so we need a backup to restore

  ledsInside:
    ANL A,R6                      ; 0001 && A to get first bit
    MOV @R1,A                     ; shift bits right and and again until nible is done
    INC R1                        ; store AND'd bits into 21H-24H using pointer to access
    MOV A,R7
    RR A
    MOV R7,A
    DJNZ R0, ledsInside

  ;lightBit4
    MOV A, 24H                    ; Move 24H into ACC to do if operation 
    JZ lightBit3                  ; if bit is set, turn on led, else jump to next LED
    CLR P2.4
  lightBit3:
    MOV A, 23H
    JZ lightBit2
    CLR P0.5
  lightBit2:
    MOV A, 22H
    JZ lightBit1
    CLR P2.3
  lightBit1:
    MOV A, 21H
    JZ noLed
    CLR P0.4

  noLed:                          ; don't turn on an led
    nop
  RET

THROB:                            ; makes the speaker 'drop a mad beat'
  MOV A,R3                        ; Restore our quotient into the acc
  JZ noThrob                      ; if ACC is 0, don't make a sound
  throbInside:
    MOV R5,#0xF7                  ; R3: number of beeps 
    MOV R6,#0xD1                  ; R4: remainder for leds
    SETB ET0                      ; R5: upperbit of timer for A6 note
    SETB EA                       ; R6: lowerbit of timer A6 note
    SETB TR0                      ; Turn on timer here

    MOV R0,#32                    ; Set delay loop timeout
    ACALL DELAY
    CLR TR0                       ; turn off timere
    MOV R0,#20                    ; set shorter delay for no beep
    MOV R5,#0
    MOV R6,#0
    ACALL DELAY 
    DJNZ R3, throbInside          ; loop if more beeps
  noThrob:
    nop
  RET

DEBOUNCE:                         ; Used for debouncing switches
    MOV R1,#50
  debounceLoop:
    MOV R2,#200
  debounceLoop_1:
    DJNZ R2,debounceLoop_1
    DJNZ R1,debounceLoop
  RET

DELAY:                            ; R0 is set before call to lengthen loop
  delayLoop:
    MOV R1,#85
  delayLoop_1:
    MOV R2,#255
  delayLoop_2:
    DJNZ R2,delayLoop_2
    DJNZ R1,delayLoop_1
    DJNZ R0,delayLoop
  RET

END
