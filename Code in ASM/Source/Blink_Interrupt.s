;===============================================================================
;Assembly Program to blink on board LED of NUCLEO-F401RE
;Using Systick timer interrupt 
;===============================================================================
RCC_AHB1ENR		EQU		0x40023830
GPIOA_MODER		EQU		0x40020000
GPIOA_ODR		EQU		0x40020014
	
SYST_CSR		EQU		0xE000E010	;Systick control and Status register
SYST_RVR		EQU		0xE000E014	;Systick Reload Value Register
SYST_CVR		EQU		0xE000E018	;Systick Current Value Register

				AREA	|.text|, CODE, READONLY, ALIGN = 4
				THUMB
				EXPORT __main
				EXPORT SysTick_Handler

				
__main						; entry point of program
		BL	GPIOA_Init		; branch to GPIOA_Init subroutine
		BL  SYSTICK_Init
LOOP
		B   LOOP			; stay in infinite loop
		
SysTick_Handler
		PUSH {LR}
		BL TOGGLE_LED
		POP {LR}
		BX LR

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
		
SYSTICK_Init
		; Load Reload value into SYST_RVR
		MOVW R3, #0x1200
		MOVT R3, #0x007A
		LDR R2, =SYST_RVR
		STR R3, [R2]

		; Clear Current Value Register
		BFC R3, #0, #32
		LDR R2, =SYST_CVR
		STR R3, [R2]
		
		; Configure control and Status register
		LDR R2, =SYST_CSR
		LDR R1,[R2]	
		ORR R1, #0x07
		STR R1, [R2]
		
		BX LR
		
; subroutine to toggle LED state
TOGGLE_LED
		LDR R1, =GPIOA_ODR
		LDR R0,[R1]				;store value of ODR into R0
		EOR R0, #0x20		;XOR R0 with 0x20 inorder to blink
		STR R0, [R1]
		BX LR	
		
		ALIGN
		END