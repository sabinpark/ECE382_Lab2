ECE382_Lab2
===========

## Update

| Item | Status | Date |
|-------|-------|-------|
| Required Functionality | Complete | 16 September 14 |
| B Functionality | Complete | 16 September 14 |
| A Functionality | - | - |

## Prelab

#### Requirements

The prelab requires pseudo code and a flowchart for the two primary subroutines. The subroutines are described below:
* "The job of the first is to decrypt an individual piece of information. It should use the pass-by-value technique and take in the encrypted value and the key and pass out the decrypted value." (ECE 382 Lab 2)
* "The job of the second is to leverage the first subroutine to decrypt the entire message. It should use the pass-by-reference technique to take in the address of the beginning of the message, the address of the key, and the address in RAM where the decrypted message will be placed. It should use the pass-by-value technique to take in the length of the message. It will pass the encrypted message byte-by-byte to the first subroutine, then store the decrypted results in RAM." (ECE 382 Lab 2)

#### Flowchart
![alt test](https://github.com/sabinpark/ECE382_Lab2/blob/master/images/Lab2_flowchart.jpg "Lab 2 Flowchart")

#### Pseudocode

*NOTE:* the following is pseudocode and is not meant to compile

```
;  ROM A = message (encrypted)
;  ROM B = key
;  RAM = message (decrypted)

main:
  R4 points to ROM A
  R5 points to ROM B
  R6 points to RAM (starting at 0x0200)
  R7 is a temporary holder before storing the value in RAM
  R8 is set to message length
  
decryptByte (1st subroutine):
  ; provided that Z = encrypted, A = decrypted, K = key
  push    Z, K
  xor     Z, K
  mov     Z, A
  pop     A
  Ret
  
decryptMessage (2nd subroutine):
  mov     @R4+, R7    ; now R7 = R4
  call    #decryptByte
  mov     @R6+, R7
  
continue through the loop until R8 is 0
at this point, the message is fully decrypted

wait:
  jmp     wait
```

## Lab

### Required Functionality

I started this lab by creating a new *.asm* file using a pre-made boilerplate file. I copied and pasted the pertinent subroutine sections from the provided skeleton file. Using my pseudo code, I first set the ROM with the encrypted message and the key. *NOTE:* the values stored in ROM below are from the required functionality test cases 

```
encrypt_address:
	.byte	0xef,0xc3,0xc2,0xcb,0xde,0xcd,0xd8,0xd9,0xc0,0xcd,0xd8,0xc5,0xc3,0xc2,0xdf,0x8d,0x8c,0x8c,0xf5,0xc3,0xd9,0x8c,0xc8,0xc9,0xcf,0xde,0xd5,0xdc,0xd8,0xc9,0xc8,0x8c,0xd8,0xc4,0xc9,0x8c,0xe9,0xef,0xe9,0x9f,0x94,0x9e,0x8c,0xc4,0xc5,0xc8,0xc8,0xc9,0xc2,0x8c,0xc1,0xc9,0xdf,0xdf,0xcd,0xcb,0xc9,0x8c,0xcd,0xc2,0xc8,0x8c,0xcd,0xcf,0xc4,0xc5,0xc9,0xda,0xc9,0xc8,0x8c,0xde,0xc9,0xdd,0xd9,0xc5,0xde,0xc9,0xc8,0x8c,0xca,0xd9,0xc2,0xcf,0xd8,0xc5,0xc3,0xc2,0xcd,0xc0,0xc5,0xd8,0xd5,0x8f
key_address:
	.byte	0xac
```

As expected, the cipher text was stored in ROM starting at the address 0xC000. To my pleasant surprise, the next input into ROM (when I add in the key) was set immediately after the last byte of the cipher text. **[ADD USEFULNESS FOR COUNT]**

As for the rest of the code, I simply initialized the pointers and then called the appropriate subroutines. The moving of pointers was pretty self-explanatory as well.

```
main:
	mov.w   #__STACK_END,SP		; BOILERPLATE	Initialize stackpointer
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
```

#### Subroutines
##### decryptMessage
Translating my pseudo code into actual code was not very difficult. The only things I had to add in extra were the register for the message length and a jump call to continue to run through the message if it had not yet been fully decrypted.
```
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
```
##### decryptByte
This second subroutine was ridiculously simple:
```
decryptCharacter:
	xor.b		@R5, R7
	ret
```

##### Result
![alt test](https://github.com/sabinpark/ECE382_Lab2/blob/master/images/R_funct_message.PNG "R functionality result")

### B Functionality


