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
arg2s: .asciiz "ARG2: "
arg3s: .asciiz "ARG3: "
Part2_string: .asciiz "Part 2: "
Part3_string: .asciiz "Part 3: "
endl: .asciiz "\n"
space: .asciiz " "
hamming_distance: .asciiz "Hamming Distance: "
last_value: .asciiz "Last value drawn: "
total_values: .asciiz "Total values: "
evens: .asciiz "# of Even: "
odds: .asciiz "# of Odds: "
powers_of_2: .asciiz "Power of 2: "
mult2: .asciiz "Multiple of 2: "
mult4: .asciiz "Multiple of 4: "
mult8: .asciiz "Multiple of 8: "

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
	
	lw $t0, arg1
	lb $s2, ($t0)	# $s2 holds arg1
	
	beq $s2, 65, Part2
	beq $s2, 97, Part2
	beq $s2, 82, Part3
	beq $s2, 114, Part3 
	
	j Exit_illegal_arguments
	
Part2:
	
	blt $s0, 3, Exit_illegal_arguments
	
	# Build Arg2
	lw $a0, arg2
	jal BuildWord

	# Print Arg2
	move $t0, $v0	# Save our built word
	
	la $a0, arg2s
	li $v0, 4
	syscall
	
	move $a0, $t0	# Recall our built word
	jal PrintWord
	
	move $s2, $t0	# Save what we built for arg2
	pstring(endl)
	
	# Build Arg3
	lw $a0, arg3
	
	jal BuildWord
	
	# Print Arg3
	
	move $t0, $v0	# Save our built word
	
	la $a0, arg3s
	li $v0, 4
	syscall
	
	move $a0, $t0	# Recall our built word
	jal PrintWord
	
	move $s3, $t0 	# Save what we built for arg3
	
	move $a0, $s2
	move $a1, $s3
	
	jal HammingDistance
	
	move $t0, $v0
	
	pstring(endl)
	
	li $v0, 4
	la $a0, hamming_distance
	syscall
	
	move $a0, $t0
	li $v0, 1
	syscall
	
	j Exit_clean

Part3:

	bgt $s0, 2, Exit_illegal_arguments	

	lw $a0, arg2
	jal Hash
	
	li $a0, 0
	move $a1, $v0
	li $v0, 40
	syscall
	
loop:	# Generate random value
	# Check if it's a power of 2
	# Check if it's < 64
	# Is both are true, branch to exit
	# Otherwise, check if its even
	# Check if it's odd
	# Check if it's div by 2
	# Check if it's div by 4
	# Check if it's div by 8
	# (Incrememnt a separate counter for each of these conditions)
	# Back to loop
exit:	# Print the collected data 
	
	j Exit_clean

# Exit labels
Exit_illegal_arguments:
	exit_with_string(Err_string)

Exit_clean:	
	li $v0, 10
	syscall
	
	
# Functions
#############################################################################
Strlen:
		 		# $a0 holds the address of our word
	li $v0, 0 		# $v0 is our counter variable
	
loop_l:	lb $t0, ($a0)		# Loads the next byte into $t2
	beqz $t0, exit_l 		# if it's a null terminator, jump to the exit
	addi $a0, $a0, 1 	# increment our string pointer
	addi $v0, $v0, 1 	# increment our counter
	j loop_l			# LOOP!
exit_l:
	jr $ra
#############################################################################
BuildWord:
	move $t0, $a0	
	lb $t1, 0($t0)
	
	lb $t2, 1($t0)
	sll $t2, $t2, 8
	or $t1, $t1, $t2
	
	lb $t2, 2($t0)
	sll $t2, $t2, 16
	or $t1, $t1, $t2
	
	lb $t2, 3($t0)
	sll $t2, $t2, 24
	or $t1, $t1, $t2
	move $v0, $t1

	jr $ra
#############################################################################
PrintWord:
	
	move $t0, $a0

	pbin($t0)
	pstring(space)
	
	move $a0, $t0
	li $v0, 34
	syscall
	pstring(space)
	
	pint($t0)
	pstring(space)
	
	move $a0, $t0
	li $v0, 100
	syscall
	pstring(space)
	
	move $a0, $t0
	li $v0, 101
	syscall

	jr $ra
#############################################################################
HammingDistance:
	
	move $t6, $a0
	move $t7, $a1
	
	xor $t0, $t6, $t7	# XOR'd the numbers
	move $a0, $t0		# Put it in the function argument slot
	
	push($ra)		# Save our return address
	
	jal TrueBits
	
	pop($ra)		# Recall our return address
				# The return value of TrueBits is what we want.
	jr $ra			# Simply return now.
	
#############################################################################
Hash:
				# $a0 holds the word we wanna hash
	move $t0, $a0		# Move it into $t0
	li $t2, 0		# $t2 will be our sum variable
	
	li $t7, 48		# $t7 holds the value for '0'
	li $t8, 57		# $t8 holds the value for '9'
	li $t9, 10		# $t9 holds 10
	
loop_h:	
	lb $t1, ($t0)		# Get the next char
	beqz $t1, exit_h	# If it's a null terminator, that's the end of the string
	
	blt $t1, $t7, exit_h
	bgt $t1, $t8, exit_h	# Break
	
	sub $t3, $t1, $t7 	# char - '0'
	
	mult $t2, $t9		# sum * 10
	mflo $t4		
	
	add $t2, $t3, $t4	# (sum * 10) + (char - '0')
	
	addi $t0, $t0, 1	# Increment pointer
	j loop_h			# LOOP!
exit_h:
	move $v0, $t2
	jr $ra
#############################################################################
TrueBits:			# Returns the number of bits that are true in the byte loaded into #a0
				# If this returns exactly 1, then the number in $a0 is a power of 2
				
	li $t1, 0		# General counter
	li $t2, 0		# Counter for xor bits
	move $t0, $a0
	
loop_tb:
	bgt $t1, 31, exit_tb 	# Loop counts from 0-31, to get each bit

	srlv $t3, $t0, $t1 	# Shift some bits over
	andi $t4, $t3, 1	# Mask for only the first bit
	bne $t4, 1, zero
	addi $t2, $t2, 1
zero: 
	addi $t1, $t1, 1	# Increment counter
	j loop_tb 		# LOOP!
exit_tb:
	move $v0, $t2
	jr $ra