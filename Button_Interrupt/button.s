;============================================================================

;Assembly Program to toggle on board LED of NUCLEO-F401RE 

;when on board button is pressed using interrupt

;============================================================================

RCC_AHB1ENR		EQU		0x40023830	
RCC_APB2ENR		EQU		0x40023844	
GPIOA_MODER		EQU		0x40020000	
GPIOC_MODER		EQU		0x40020800	
GPIOA_ODR		EQU		0x40020014	
GPIOC_IDR 		EQU  	0x40020810	
SYSCFG_EXTICR4  EQU     0x40013814	
EXTI_IMR		EQU     0x40013C00	
EXTI_FTSR		EQU     0x40013C0C	
EXTI_PR			EQU     0x40013C14	
NVIC_ISER1		EQU     0xE000E104

				AREA	|.text|, CODE, READONLY, ALIGN = 2
				THUMB
				EXPORT __main
				EXPORT EXTI15_10_IRQHandler

__main						; entry point of program
		BL	LED_Init		; configure PA5	
		BL  BUTTON_Init		; configure PC13
		BL  IRQ_Enable		; enable interrupt
LOOP
		B   LOOP			

; interrupt service routine
EXTI15_10_IRQHandler		
		PUSH {LR}			; store address of next instruction 
		BL  CLEAR_PR
		BL LED_TOGGLE		; turn on led when button is pressed
		BL DELAY			; wait for switch debounce
		POP {LR}			; retrive address of next instruction
		BX LR				; return to main program

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

IRQ_Enable
		; Enable system configuration controller clock 
		LDR R1, =RCC_APB2ENR
		LDR R0,[R1]
		ORR R0, R0,#0x4000
		STR R0,[R1]	

		; Select external interrupt port
		LDR R1, =SYSCFG_EXTICR4
		LDR R0,[R1]
		ORR R0, R0,#0x0020
		STR R0,[R1]	

		;enable interrupt at NVIC
		LDR R1, =NVIC_ISER1
		LDR R0,[R1]
		ORR R0, R0,#0x0100
		STR R0,[R1]	
		
		; Enable interrupt by unmasking IMR
		LDR R1, =EXTI_IMR
		LDR R0,[R1]
		ORR R0, R0,#0x2000
		STR R0,[R1]	

		; Select type of interrupt
		LDR R1, =EXTI_FTSR
		LDR R0,[R1]
		ORR R0, R0,#0x2000
		STR R0,[R1]	
		BX LR

;clear interrupt pending register			
CLEAR_PR
		MOV R0, #0x2000
		LDR R1, =EXTI_PR
		STR R0,[R1]	
		BX LR

; subroutine to toggle led
LED_TOGGLE
		LDR R1, =GPIOA_ODR
		LDR R0,[R1]
		EOR R0, #0x20
		STR R0,[R1]	
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