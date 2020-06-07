;===============================================================================

;Assembly Program to blink on board LED of NUCLEO-F401RE

;===============================================================================

RCC_AHB1ENR		EQU		0x40023830
GPIOA_MODER		EQU		0x40020000
GPIOA_ODR		EQU		0x40020014

				AREA	|.text|, CODE, READONLY, ALIGN = 2
				THUMB
				EXPORT __main

__main						; entry point of program
		BL	GPIOA_Init		; branch to GPIOA_Init subroutine
LOOP
		BL  BLINK			; branch to blink subroutine
		BL	DELAY			; branch to delay subroutine
		B   LOOP			; stay in infinite loop

;subroutine to configure PA5		
GPIOA_Init
		; Enable GPIOA Clock
		LDR R1, =RCC_AHB1ENR
		LDR R0,[R1]				; store current value of RCC_AHB1ENR into R0
		ORR R0, R0,#0x0001		; enable clock for GPIOA
		STR R0,[R1]				; sotore modified value back to RCC_AHB1ENR

		; Set PA5 mode as output
		LDR R1, =GPIOA_MODER
		LDR R0, [R1]
		ORR R0, R0, #0x0400
		STR R0, [R1]
		BX LR					; return from subroutine

;blink subroutine
BLINK
		LDR R1, =GPIOA_ODR
		LDR R0,[R1]				;store value of ODR into R0
		EOR R0, R0, #0x20		;XOR R0 with 0x20 inorder to blink
		STR R0, [R1]
		BX LR	

;delay subroutine
DELAY
		; MOVW followed by MOVT is used to load 32 bit immediate value to register
		MOVW R0, #0xFDE8	; MOVW loads lower 16 bits
		MOVT R0, #0x0010	; MOVT loads heigher 16 bits into R0
LOOP1 	SUB R0, R0, #1
		CMP R0, #0
		BNE LOOP1
        BX LR

		ALIGN
		END