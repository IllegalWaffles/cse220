# Homework #1
# name: Kuba Gasiorowski
# sbuid: 109776237

.data
.align 2
numargs: .word 0
arg1: .word 0
arg2: .word 0
arg3: .word 0
Err_string: .asciiz "ARGUMENT ERROR"
Goodbye_string: .asciiz "Goodbye :)"
Numargs_string: .asciiz "Number of arguments: "
Part2_string: .asciiz "Part 2:"
Part3_string: .asciiz "Part 3:"
Newline: .asciiz "\n"

# Helper macro for grabbing command line arguments
.macro load_args
	sw $a0, numargs
	lw $t0, 0($a1)
	sw $t0, arg1
	lw $t0, 4($a1)
	sw $t0, arg2
	lw $t0, 8($a1)
	sw $t0, arg3
.end_macro

.macro exit_clean
	la $a0, Goodbye_string
	li $v0, 4
	syscall
	li $v0, 10
	syscall
.end_macro

.macro exit_argument_error
	la $a0, Err_string
	li $v0, 4
	syscall
	li $v0, 10
	syscall
.end_macro

.text
.globl main
main:

	load_args() # Only do this once
	
	move $t0, $a0 # Hold on to the number of arguments

Print_number_args:	
	li $v0, 4
	la $a0, Numargs_string
	syscall
	
	li $v0, 1
	move $a0, $t0
	syscall
	
	li $v0, 4
	la $a0, Newline
	syscall

	bgt $t0, 3, Illegal_arguments 
	blt $t0, 2, Illegal_arguments	

	j Exit

Illegal_arguments:
	exit_argument_error()

Exit:	
	exit_clean()
	

	