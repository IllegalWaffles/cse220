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
Goodbye_string: .asciiz "\n(clean exit)"
Part2_string: .asciiz "Part 2: "
Part3_string: .asciiz "Part 3: "
endl: .asciiz "\n"
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
.macro pstring (%string)
	la $a0, %string
	li $v0, 4
	syscall
.end_macro

# Prints an int to the console
.macro pint (%reg)
	move $a0, %reg
	li $v0, 1
	syscall
.end_macro

# Prints a number as a binary number
.macro pbin (%reg)
	move $a0, %reg
	li $v0, 35
	syscall
.end_macro

# Prints an int as a char
.macro pchar (%reg)
	move $a0, %reg
	li $v0, 11
	syscall
.end_macro

# Exits the program with a specified string
.macro exit_with_string (%string)
	pstring(%string)
	li $v0, 10
	syscall
.end_macro

.text
.globl main # MAIN
main:

	load_args() 	# Only do this once
	move $s0, $a0 	# Hold on to the number of arguments

	bgt $s0, 3, Exit_illegal_arguments 
	blt $s0, 2, Exit_illegal_arguments
	
	lw $a0, arg1
	jal Strlen	# Determine length of arg1
	
	move $s1, $v0	# $s1 now holds length of arg1
	
	bne $s1, 1, Exit_illegal_arguments
	
	# A = 65
	# a = 97
	# R = 82
	# r = 114
	
	lw $t0, arg1
	lb $s2, ($t0)	# $s2 holds arg1
	
	beq $s2, 65, Part2
	beq $s2, 97, Part2
	beq $s2, 82, Part3
	beq $s2, 114, Part3 
	
	j Exit_illegal_arguments
	
Part2:
	#pstring(Part2_string)
	#pchar($s2)
	blt $s0, 3, Exit_illegal_arguments
	
		

	
	
	j Exit_clean

Part3:
	pstring(Part3_string)
	pchar($s2)
	j Exit_clean

# Exit labels
Exit_illegal_arguments:
	exit_with_string(Err_string)

Exit_clean:	
	exit_with_string(Goodbye_string)
	
	
# Functions
Strlen:
		 		# $a0 holds the address of our word
	li $v0, 0 		# $v0 is our counter variable
	
loop:	lb $t0, ($a0)		# Loads the next byte into $t2
	beqz $t0, exit 		# if it's a null terminator, jump to the exit
	addi $a0, $a0, 1 	# increment our string pointer
	addi $v0, $v0, 1 	# increment our counter
	j loop			# LOOP!
exit:
	jr $ra
	
	