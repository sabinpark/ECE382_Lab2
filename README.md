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
I changed the memory browser view to *character* in order to see the following message:
![alt test](https://github.com/sabinpark/ECE382_Lab2/blob/master/images/R_funct_message.PNG "R functionality result")

As expected, the message was properly decrypted starting at the RAM memory address of 0x0200.

### B Functionality
Adding the B functionality was not too difficult. I accomplished this next task by adding two registers:
* R10 = register to store and hold an arbitrary terminate address
* R11 = register to store and hold the permanent value of the key_address
In the initializations for the ROM pointers, I added a line of code that stored my arbitrary value (0x00) that added a byte in ROM. This addition into the ROM was placed immediately following the end of the key. Using this detail, I was ultimately able to calculate the length of the key and determine when to reset the key pointer index.
```
terminate_address:
	.byte	0x00		; arbitrarily chosen value
```
As you may notice, I used R11 to reset the key index.
```
resetKeyIndex:
	mov.w	R11, R5
	jmp		continueDecrypt
```
Aside from those changes, I added in a *jz* call that would reset the key index if the index incremented to the address value of the terminating address. And thus, I also added in a label that would be used to return to the message decryption if/when I needed to reset the key index. 
```
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
```

I used the B functionality test case to test the program:
```
encrypt_address:
	.byte	0xf8,0xb7,0x46,0x8c,0xb2,0x46,0xdf,0xac,0x42,0xcb,0xba,0x03,0xc7,0xba,0x5a,0x8c,0xb3,0x46,0xc2,0xb8,0x57,0xc4,0xff,0x4a,0xdf,0xff,0x12,0x9a,0xff,0x41,0xc5,0xab,0x50,0x82,0xff,0x03,0xe5,0xab,0x03,0xc3,0xb1,0x4f,0xd5,0xff,0x40,0xc3,0xb1,0x57,0xcd,0xb6,0x4d,0xdf,0xff,0x4f,0xc9,0xab,0x57,0xc9,0xad,0x50,0x80,0xff,0x53,0xc9,0xad,0x4a,0xc3,0xbb,0x50,0x80,0xff,0x42,0xc2,0xbb,0x03,0xdf,0xaf,0x42,0xcf,0xba,0x50,0x8f
key_address:
	.byte	0xac,0xdf,0x23
```
*NOTE:* I had to separate the provided value of *0xacdf23* into *0xac,0xdf,0x23* in order for the program to properly take in the key.

##### Result
As expected, I obtained another easily-comprehendable message:
![alt test](https://github.com/sabinpark/ECE382_Lab2/blob/master/images/B_funct_message.PNG "B functionality result")

Luckily, this message proved to contain hints for obtaining A functionality.

### A Functionality

### Debugging
#### Required Functionality
I had some trouble initially due to the differences in bytes and words. I admit, I got lazy and simply set everything to .byte because I knew I was going to be reading through the message byte by byte. However, after I was confident that the logic of the code was correct, I went back and made sure that the code had .byte where it needed, and .word in its own appropriate places. Not rocket science.
#### B Functionality
I first attempted to create another subroutine that would calculate the length of the key...but I soon realized that was useless. Instead, I just made a small loop that would compare the terminate index and the current key index. When the two were equal, I would reset the key index back to the start.
#### A Functionality

## Documentation
No help received.
