; ***************************************************************************
; * 	MUSIC.ASM
; *   
; *	This program uses TIMER 0 to contol the sound from the speaker.
; *	Using a timer allows more precise control of the pitch than a delay loop.
; *	TIMER 0 is set up as a 16-bit timer (input clock frequency is (7.373 MHz/2).
; *	The timer increments once for each cycle of the input clock.  When the 
; *	timer rolls over from all '1's to all '0's, it is set to cause an interrupt.
; *	This requires the program to have an interrupt service routine(ISR), which
; *	executes when the interrupt occurs.  The ISR in this program complements
; *	P0.2, which will produce the sound in the speaker.  It also loads a value into
; *	TIMER 0.  By loading different values into TIMER 0, the programmer can control 
; *	how long it takes until the timer increments to all '1's.  If you put a small
; *	value into the timer it will take longer to increment up to all '1's than if
; *	put a larger value into the timer.
; *	This code was written by a student in one of the summer camps and I placed
; *	it on the website as an example of how to use one of the P89LPC925 peripherals
; *	and how to use interrupts (See "How interrupts work" at the end of this code).
; *	For more information on all of the peripherals in this microprocessor please
; *	see the User Manual and Data sheet for the P89LPC925.  Links are given
; *	on the website.
; *	This program also shows how subroutines can be used to simplfy the code.
; *
; **************************************************************************************
#include <reg932.inc>


cseg at 0x0000			; Start of program set to address 0
	ljmp main					; jumps over the interrupt vector table
										; located from 0x0003 to 0x0073


cseg at 0x000B			; Interrupt Vector Address for TIMER 0
	cpl p1.7					; compliments P1.4 to produce sound from speaker
	clr c
	mov A, R3					; Reads upper byte of 16-bit timer re-load value
	mov TH0, A				; into A and puts it into the upper byte of TIMER 0
	mov A, R4					; Reads lower byte of 16-bit timer re-load value
	mov TL0, A				; into A and puts it into the lower byte of TIMER 0
	reti							; Returns from the interrupt
main:
	mov p0m1,#0				; set port 0 to bi-directional
	mov p1m1,#0				; set port 1 to bi-directional
	mov p2m1,#0				; set port 2 to bi-directional
	MOV TMOD,#0x01		; sets TIMER 0 into mode 1 operation 
	mov TH0, #0				; presets a 16-bit value into TIMER 0 
	mov TL0, #0				; upper byte first and then lower byte
	mov R3, #0				; sets this same 16-bit value into R3 and R4
	mov R4, #0				; used to reload TIMER 0 in the ISR
	SETB ET0					; enable TIMER 0 overflow interrupt
	SETB EA						; set global interrupt enable bit
	SETB TR0					; start TIMER 0 counting
; Beginning of the song
start:
	mov R0, #32		; The value in R0 sets the duration of a note,
	acall playC6		; 32 is a quarter note, 16 would be a eigth note
	acall playBreath	; and 64 would be a half note.  The values that
	mov R0, #32		; are placed in R1 and R2 in the "stall"
	acall playC6		; subroutine control the tempo.  
	acall playBreath	
	mov R0, #32		; The instruction ACALL calls a subroutine.
	acall playG6		; In this program, each note is 
	acall playBreath	; a subroutine.  The subroutine sets the values
	mov R0, #32		; in R3 and R4, which set the pitch of the note.
	acall playG6		; Each note subroutine calls the "stall" subroutine
	acall playBreath	; which uses the values in R0, R1 and R2 to set the
	mov R0, #32		; duration of the note.
	acall playA6		
	acall playBreath	; The subroutine "playBreath" places a short pause 
	mov R0, #32		; between each note.  It uses the smallest possible
	acall playA6		; value for R0 so that the duration is short.
	acall playBreath
	mov R0, #64		; A rest could be placed in the song by setting
	acall playG6		; the duration of the rest in R0 and calling the
	acall playBreath	; "playREST" subroutine.  It works the same as  
	mov R0, #32		; a note subroutine, but no sound is played.
	acall playF6
	acall playBreath	; This song is the first phrse of "Ode to Joy", 	
	mov R0, #32		; but other songs could be entered by following the 
	acall playF6		; pattern of move note duration into R0 and call note pitch.
	acall playBreath
	mov R0, #32		; If the note subroutine that you need does not
	acall playE6		; exist, then write a new subroutine.  The values for
	acall playBreath	; R3 and R4 are found using the following equation:
	mov R0, #32		; R3:R4 = 65,536 - (3,686,400/note frequency)
	acall playE6		; Convert the value found for R3:R4 into hexadecimal
	acall playBreath	; and put the upper byte in R3 and the lower byte in R4.
	mov R0, #32
	acall playD6
	acall playBreath
	mov R0, #32
	acall playD6
	acall playBreath
	mov R0, #64
	acall playC6
	acall playBreath
	mov R0, #32
	acall playG6
	acall playBreath
	mov R0, #32
	acall playG6
	acall playBreath
	mov R0, #32
	acall playF6
	acall playBreath
	mov R0, #32
	acall playF6
	acall playBreath
	mov R0, #32
	acall playE6
	acall playBreath
	mov R0, #32
	acall playE6
	acall playBreath
	mov R0, #64
	acall playD6
	acall playBreath
	mov R0, #32
	acall playG6
	acall playBreath
	mov R0, #32
	acall playG6
	acall playBreath
	mov R0, #32
	acall playF6
	acall playBreath
	mov R0, #32
	acall playF6
	acall playBreath
	mov R0, #32
	acall playE6
	acall playBreath
	mov R0, #32
	acall playE6
	acall playBreath
	mov R0, #64
	acall playD6
	acall playBreath
	mov R0, #32
	acall playC6
	acall playBreath
	mov R0, #32
	acall playC6
	acall playBreath
	mov R0, #32
	acall playG6
	acall playBreath
	mov R0, #32
	acall playG6
	acall playBreath
	mov R0, #32
	acall playA6
	acall playBreath
	mov R0, #32
	acall playA6
	acall playBreath
	mov R0, #64
	acall playG6
	acall playBreath
	mov R0, #32
	acall playF6
	acall playBreath
	mov R0, #32
	acall playF6
	acall playBreath
	mov R0, #32
	acall playE6
	acall playBreath
	mov R0, #32
	acall playE6
	acall playBreath
	mov R0, #32
	acall playD6
	acall playBreath
	mov R0, #32
	acall playD6
	acall playBreath
	mov R0, #64
	acall playC6
	acall playBreath
	mov R0, #255
	acall playREST
	Ljmp start		; Repeat the song
; *****************************************************************************
; * Note Subroutines
; *
; * The value in R0 sets the duration the note is played.  It determines
; * the number of times the processor loops in the stall subroutine
; *
; * The values in R3 and R4 are the upper and lower bytes of the 16-bit
; * re-load value for TIMER 0.  They set the pitch of the note.  The smaller the
; * number, the lower the pitch and the larger the number, the higher the pitch.
; *
; ******************************************************************************
playC6:				; label used to call the subroutine
		clr p2.4       ; turn on LED1
		mov R3, #0xF2
		mov R4, #0x3D
		acall stall	; this calls a second (nested) subroutine
                setb p2.4       ; turn off LED1
	ret			; return to previous program location
				; to execute the next instruction.
playD6:
                clr p0.5
		mov R3, #0xF3
		mov R4, #0xBE
		acall stall
                setb p0.5
	ret
playE6:
                clr p2.7
		mov R3, #0xF5
		mov R4, #0x14
		acall stall
                setb p2.7
	ret
playF6:
                clr p0.4
		mov R3, #0xF5
		mov R4, #0xB1
		acall stall
                setb p0.4
	ret
playG6:
                clr p2.6
		mov R3, #0xF6
		mov R4, #0xD1
		acall stall
                setb p2.6
	ret
playA6:
                clr p0.7
		mov R3, #0xF7
		mov R4, #0xD1
		acall stall
                setb p0.7
	ret
playBreath:
		mov R0, #1
		mov R3, #0x00	; TIMER 0 re-load value is set to minimum
		mov R4, #0x00	; possible value.
		acall stall
	ret


playREST:
		mov R3, #0x00	; TIMER 0 re-load value is set to minimum
		mov R4, #0x00	; possible value.
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
		mov R1, #85		; The values entered into R1
	loop1:				; and R2 control the tempo of the
		mov R2, #255		; song.  Smaller values make the 
	loop2:				; song play faster.
		nop
		djnz R2, loop2
		djnz R1, loop1
		djnz R0, loop0
		ret
end

; **************************************************************************************
; * 	How interrupts work:
; *	
; *	For an interrupt to occur from a peripheral, the interrupt must be enabled
; *	in the peripheral control registers and the global interrupt enable bit must
; *	be set.  When the peripheral reaches a condition that causes an interrupt, it
; *	sets a flag (a bit in a control register).  Since interrupts are enabled, this
; *	this flag is sent to the processor core where it requests an interrupt.
; *	When the processor completes the current instruction, it saves its current
; *	program location and jumps to appropriate location in the interrupt vector
; *	table (0x000B for TIMER 0 overflow)to begin executing the interrupt service
; *	routine.  The main item the ISR must do is clear the condition that is causing
; *	the interrupt to occur.  For the TIMER 0 overflow, just responding to the
; *	interrupt clears the overflow flag.  Other actions can be performed in the ISR,
; *	but they should not take a long time.  A properly written ISR will also save and 
; *	restore any registers that are used, so they are not changed from what was being
; *	used by the main program.  The last instruction in the ISR is the return from
; *	interrupt instruction (reti).  This tells the processor to return to its 
; *	previously saved location to exectute the next instruction.
; *************************************************************************************** 
