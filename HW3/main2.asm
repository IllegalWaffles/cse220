.text

.globl main

main:

	jal smiley
	
	li $v0, 10
	syscall
	
.include "hw3.asm"