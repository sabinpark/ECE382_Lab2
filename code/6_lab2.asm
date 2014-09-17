;-------------------------------------------------------------------------------
; Title:		Lab 2 - Cryptography
; Name:			C2C Sabin Park, USAF
; Date:			15 September 2014
; Instructor:	Dr. Coulston
;
; This program uses subroutines to decrypt and encrypt messages
;-------------------------------------------------------------------------------

	.cdecls C,LIST,"msp430.h"	; BOILERPLATE	Include device header file
 	.text						; BOILERPLATE	Assemble into program memory
	.retain						; BOILERPLATE	Override ELF conditional linking and retain current section
	.retainrefs					; BOILERPLATE	Retain any sections that have references to current section
	.global main				; BOILERPLATE	Project -> Properties and select the following in the pop-up
								; Build -> Linker -> Advanced -> Symbol Management
								;    enter main into the Specify program entry point... text box

	.data
	.bss		RAM, 0x80
	.text

encrypt_address:
	.byte	0xef,0xc3,0xc2,0xcb,0xde,0xcd,0xd8,0xd9,0xc0,0xcd,0xd8,0xc5,0xc3,0xc2,0xdf,0x8d,0x8c,0x8c,0xf5,0xc3,0xd9,0x8c,0xc8,0xc9,0xcf,0xde,0xd5,0xdc,0xd8,0xc9,0xc8,0x8c,0xd8,0xc4,0xc9,0x8c,0xe9,0xef,0xe9,0x9f,0x94,0x9e,0x8c,0xc4,0xc5,0xc8,0xc8,0xc9,0xc2,0x8c,0xc1,0xc9,0xdf,0xdf,0xcd,0xcb,0xc9,0x8c,0xcd,0xc2,0xc8,0x8c,0xcd,0xcf,0xc4,0xc5,0xc9,0xda,0xc9,0xc8,0x8c,0xde,0xc9,0xdd,0xd9,0xc5,0xde,0xc9,0xc8,0x8c,0xca,0xd9,0xc2,0xcf,0xd8,0xc5,0xc3,0xc2,0xcd,0xc0,0xc5,0xd8,0xd5,0x8f
key_address:
	.byte	0xac
;-------------------------------------------------------------------------------
;           Main
;-------------------------------------------------------------------------------
main:
	mov.w   #__STACK_END,SP			; BOILERPLATE	Initialize stackpointer
	mov.w   #WDTPW|WDTHOLD,&WDTCTL 	; BOILERPLATE	Stop watchdog timer

; load registers with necessary info for decryptMessage here

	mov.w	#encrypt_address, R4
	mov.w	#key_address, R5
	mov.w	#RAM, R6

	call	#getLength

decrypt:
	call    #decryptMessage

forever:
	jmp     forever


;------------------------------------------
;			Subroutine for message length
;------------------------------------------
getLength:
	mov.w	#key_address, R8
	mov.w	#encrypt_address, R9
	sub.w	R9, R8		; R8 = R8-R9,  thus R8 is the length of the message
	ret



;-------------------------------------------------------------------------------
;           Subroutines
;-------------------------------------------------------------------------------
;Subroutine Name: decryptMessage
;Author: C2C Sabin Park
;Function: Decrypts a string of bytes and stores the result in memory.  Accepts
;           the address of the encrypted message, address of the key, and address
;           of the decrypted message (pass-by-reference).  Accepts the length of
;           the message by value.  Uses the decryptCharacter subroutine to decrypt
;           each byte of the message.  Stores theresults to the decrypted message
;           location.
;Inputs:
;Outputs:
;Registers destroyed:
;-------------------------------------------------------------------------------

decryptMessage:
			tst			R8
			jz			forever
			mov.b		@R4+, R7	; put value at R4 into R7, increment R4
			call		#decryptCharacter
			mov.b		R7, 0(R6)	; put decrypted value into the address R6 points to
			inc.w		R6
			dec.b		R8
			jmp			decryptMessage
            ret

;-------------------------------------------------------------------------------
;Subroutine Name: decryptCharacter
;Author: C2C Sabin Park
;Function: Decrypts a byte of data by XORing it with a key byte.  Returns the
;           decrypted byte in the same register the encrypted byte was passed in.
;           Expects both the encrypted data and key to be passed by value.
;Inputs: value at R4 (encrypted), value at R5 (key)
;Outputs: updated R4 (decrypted)
;Registers destroyed:
;-------------------------------------------------------------------------------

decryptCharacter:
			xor.b		@R5, R7
            ret

;-------------------------------------------------------------------------------
;           System Initialization
;-------------------------------------------------------------------------------
	.global __STACK_END				; BOILERPLATE
	.sect 	.stack					; BOILERPLATE
	.sect   ".reset"				; BOILERPLATE		MSP430 RESET Vector
	.short  main					; BOILERPLATE

