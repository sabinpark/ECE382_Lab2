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
	.byte	0xf8,0xb7,0x46,0x8c,0xb2,0x46,0xdf,0xac,0x42,0xcb,0xba,0x03,0xc7,0xba,0x5a,0x8c,0xb3,0x46,0xc2,0xb8,0x57,0xc4,0xff,0x4a,0xdf,0xff,0x12,0x9a,0xff,0x41,0xc5,0xab,0x50,0x82,0xff,0x03,0xe5,0xab,0x03,0xc3,0xb1,0x4f,0xd5,0xff,0x40,0xc3,0xb1,0x57,0xcd,0xb6,0x4d,0xdf,0xff,0x4f,0xc9,0xab,0x57,0xc9,0xad,0x50,0x80,0xff,0x53,0xc9,0xad,0x4a,0xc3,0xbb,0x50,0x80,0xff,0x42,0xc2,0xbb,0x03,0xdf,0xaf,0x42,0xcf,0xba,0x50,0x8f
key_address:
	.byte	0xac,0xdf,0x23
terminate_address:
	.byte	0x00		; arbitrarily chosen value
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
	mov.w	#terminate_address, R10
	mov.w	#key_address, R11		; permanent holder for the key start index

	call	#getMessageLength

decrypt:
	call    #decryptMessage

forever:
	jmp     forever


;-------------------------------------------------------------------------------
;           Subroutines
;-------------------------------------------------------------------------------
;Subroutine Name: getMessageLength
;Author: C2C Sabin Park
;Function: obtains the length of the message by subtracting the address of
;		the key (which follows immediately after the message) from where the
;		the message begins
;Inputs:
;Outputs:
;Registers destroyed:
;-------------------------------------------------------------------------------

getMessageLength:
	mov.w	#key_address, R8
	mov.w	#encrypt_address, R9
	sub.w	R9, R8		; R8 = R8-R9,  thus R8 is the length of the message
	ret

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
			cmp.w		#terminate_address, R5
			jz			resetKeyIndex
continueDecrypt:
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
;Inputs: value of R7 (encrypted), value at R5 (key)
;Outputs: updated R7 (decrypted)
;Registers destroyed:
;-------------------------------------------------------------------------------

decryptCharacter:
			xor.b		@R5+, R7

            ret
;-------------------------------------------------------------------------------
resetKeyIndex:
	mov.w	R11, R5
	jmp		continueDecrypt

;-------------------------------------------------------------------------------
;           System Initialization
;-------------------------------------------------------------------------------
	.global __STACK_END				; BOILERPLATE
	.sect 	.stack					; BOILERPLATE
	.sect   ".reset"				; BOILERPLATE		MSP430 RESET Vector
	.short  main					; BOILERPLATE

