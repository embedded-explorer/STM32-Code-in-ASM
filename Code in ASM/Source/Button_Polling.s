;=======================================================================================
;Assembly Program to turn on board LED of NUCLEO-F401RE when on board button is pressed
;=======================================================================================
RCC_AHB1ENR		EQU		0x40023830
GPIOA_MODER		EQU		0x40020000
GPIOC_MODER		EQU		0x40020800
GPIOA_ODR		EQU		0x40020014
GPIOC_IDR 		EQU  	0x40020810

				AREA	|.text|, CODE, READONLY, ALIGN = 2
				THUMB
				EXPORT __main
				
__main						; entry point of program
		BL	LED_Init		; branch to GPIOA_Init subroutine
		BL  BUTTON_Init
LOOP
		BL LED_OFF			; by default led is off
		BL INPUT			; jump to subroutine to check input
		CMP R0, #0x0000		; comapre input
		BEQ LED_ON			; turn on led when button is pressed
		BL DELAY			; wait for switch debounce
		B   LOOP			
		
;subroutine to configure PA5		
LED_Init
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

; subroutine to configure PC13
BUTTON_Init
		LDR R1, =RCC_AHB1ENR
		LDR R0,[R1]
		ORR R0, R0,#0x04
		STR R0,[R1]	
		BX LR

; subroutine to turn on led
LED_ON
		LDR R1, =GPIOA_ODR
		LDR R0,[R1]
		ORR R0, R0,#0x20
		STR R0,[R1]	
		BX LR

; subroutine to turn off led
LED_OFF
		MOV R0, #0x00
		LDR R1, =GPIOA_ODR
		STR R0, [R1]
		BX LR	

;subroutine to check button status
INPUT
		LDR R1, =GPIOC_IDR
		LDR R0, [R1]
		AND R0, R0, #0x2000
		BX LR

;delay subroutine
DELAY
		; MOVW followed by MOVT is used to load 32 bit immediate value to register
		MOVW R0, #0xFFFF	; MOVW loads lower 16 bits
LOOP1 	SUB R0, R0, #1
		CMP R0, #0
		BNE LOOP1
        BX LR

		ALIGN
		END
		