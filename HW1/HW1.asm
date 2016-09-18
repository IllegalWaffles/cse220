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
Goodbye_string: .asciiz "Goodbye..."
Numargs_string: .asciiz "Number of arguments: "
Part2_string: .asciiz "Part 2:"
Part3_string: .asciiz "Part 3:"
newline: .asciiz "\n"
space: .asciiz " "

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

# Helps me push stuff onto the stack
.macro push (%reg)
	sw %reg($sp)
	addi $sp, $sp, -4
.end_macro

# Helps me pop stuff from the stack
.macro pop (%reg)
	addiu $sp, $sp, 4
	lw %reg($sp)
.end_macro

# Prints a string to console
.macro print_string (%string)
	la $a0, %string
	li $v0, 4
	syscall
.end_macro

# Prints an int to the console
.macro print_int (%reg)
	move $a0, %reg
	li $v0, 1
	syscall
.end_macro

# Exits the program with a specified string
.macro exit_with_string (%string)
	print_string(%string)
	li $v0, 10
	syscall
.end_macro

.text
.globl main
main:

	load_args() # Only do this once
	move $s0, $a0 # Hold on to the number of arguments

Print_number_args:	
	
	print_string(Numargs_string)
	print_int($s0)
	print_string(newline)

	bgt $s0, 3, Illegal_arguments 
	blt $s0, 2, Illegal_arguments	

	la $a0, arg1
	jal Find_length

	print_string(arg1)

	j Exit

Illegal_arguments:
	exit_with_string(Err_string)

Exit:	
	exit_with_string(Goodbye_string)
	
Find_length: # Expects the address of the word to be loaded into $a0
	li $v0, 0
loop:	
	lb $t0, ($a0)
	beqz $t0, exit
	
	
	exit:
	jr $ra
	
