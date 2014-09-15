ECE382_Lab2
===========

## Prelab

#### Requirements

The prelab requires pseudo code and a flowchart for the two primary subroutines. The subroutines are described below:
* "The job of the first is to decrypt an individual piece of information. It should use the pass-by-value technique and take in the encrypted value and the key and pass out the decrypted value." (ECE 382 Lab 2)
* "The job of the second is to leverage the first subroutine to decrypt the entire message. It should use the pass-by-reference technique to take in the address of the beginning of the message, the address of the key, and the address in RAM where the decrypted message will be placed. It should use the pass-by-value technique to take in the length of the message. It will pass the encrypted message byte-by-byte to the first subroutine, then store the decrypted results in RAM." (ECE 382 Lab 2)

#### Flowchart
![alt test](https://github.com/sabinpark/ECE382_Lab2/blob/master/Lab2_flowchart.jpg "Lab 2 Flowchart")

#### Pseudocode
```
; Given:
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
```
