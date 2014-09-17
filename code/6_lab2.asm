;-------------------------------------------------------------------------------
; Title:		Lab 2 - Cryptography
; Name:			C2C Sabin Park, USAF
; Date:			15 September 2014
; Instructor:	Dr. Coulston
;
; This program uses subroutines to decrypt encrypted messages
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

; currently using the encrypted message provided from the A Functionality section
encrypt_address:
	.byte	0x35,0xdf,0x00,0xca,0x5d,0x9e,0x3d,0xdb,0x12,0xca,0x5d,0x9e,0x32,0xc8,0x16,0xcc,0x12,0xd9,0x16,0x90,0x53,0xf8,0x01,0xd7,0x16,0xd0,0x17,0xd2,0x0a,0x90,0x53,0xf9,0x1c,0xd1,0x17,0x90,0x53,0xf9,0x1c,0xd1,0x17,0x90
key_address:
	.byte	0x73, 0xbe
terminate_address:
	.byte	0x00		; arbitrarily chosen value, does not matter what value is stored

;-------------------------------------------------------------------------------
;           Main
;-------------------------------------------------------------------------------
main:
	mov.w   #__STACK_END,SP			; BOILERPLATE	Initialize stackpointer
	mov.w   #WDTPW|WDTHOLD,&WDTCTL 	; BOILERPLATE	Stop watchdog timer

; load registers with necessary info for decryptMessage here

	mov.w	#encrypt_address, R4	; R4 is the pointer to the encrypted message
	mov.w	#key_address, R5		; R5 is the pointer to the key
	mov.w	#RAM, R6				; R6 is the pointer to RAM
	mov.w	#terminate_address, R10	; R10 is the pointer to the terminate address
	mov.w	#key_address, R11		; permanent holder for the key start index

	call	#getMessageLength		; gets the message length

decrypt:
	call    #decryptMessage			; begins to decrypt the message

forever:
	jmp     forever					; infinite loop

;-------------------------------------------------------------------------------
;           Subroutines
;-------------------------------------------------------------------------------
;Subroutine Name: getMessageLength
;Author: C2C Sabin Park
;Function: obtains the length of the message by subtracting the address of
;		the key (which follows immediately after the message) from where the
;		the message begins.
;		length = initial address of key - initial address of message
;Inputs: key_address, encrypt_address, R8, R9
;Outputs: R8
;Registers destroyed: R8, R9
;-------------------------------------------------------------------------------

getMessageLength:
	mov.w	#key_address, R8		; store the initial address of the key into R8
	mov.w	#encrypt_address, R9	; same as above, buth with R9 and the encrypted message
	sub.w	R9, R8					; R8 = R8-R9,  thus R8 is the length of the message
	ret

;-------------------------------------------------------------------------------
;Subroutine Name: decryptMessage
;Author: C2C Sabin Park
;Function: Decrypts a string of bytes and stores the result in memory.  Accepts
;           the address of the encrypted message, address of the key, and address
;           of the decrypted message (pass-by-reference).  Accepts the length of
;           the message by a previously stored value in a register.
;			Uses the decryptCharacter subroutine to decrypt each byte of the message.
;			Stores theresults to the decrypted message location.
;Inputs: R8, R4, R5, R6, R7
;Outputs: decrypted message
;Registers destroyed: R4, R6, R8
;-------------------------------------------------------------------------------

decryptMessage:
	tst			R8						; test the value of R8
	jz			forever					; if 0, then infinite loop
	cmp.w		#terminate_address, R5	; if the key is at the end, then reset it
	jz			resetKeyIndex
continueDecrypt:
	mov.b		@R4+, R7				; put value at R4 into R7, increment R4
	call		#decryptCharacter
	mov.b		R7, 0(R6)				; put decrypted value into the address R6 points to
	inc.w		R6
	dec.b		R8
	jmp			decryptMessage			; go back to the top until message is fully decrypted
	ret

;-------------------------------------------------------------------------------
;Subroutine Name: decryptCharacter
;Author: C2C Sabin Park
;Function: Decrypts a byte of data by XORing it with a key byte.  Returns the
;           decrypted byte in the same register the encrypted byte was passed in.
;           Expects both the encrypted data and key to be passed by value.
;Inputs: value of R7 (encrypted), value at R5 (key)
;Outputs: updated R7 (decrypted)
;Registers destroyed: R7
;-------------------------------------------------------------------------------

decryptCharacter:
	xor.b		@R5+, R7
	ret

;-------------------------------------------------------------------------------

; resets the key index
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

