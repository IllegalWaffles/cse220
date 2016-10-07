##############################################################
# Homework #2
# name: Kuba Gasiorowski
# sbuid: 109776237
##############################################################

.macro push(%reg)
	sw %reg,($sp)	
	addi $sp, $sp, 4
.end_macro

.macro pop(%reg)
	addi $sp, $sp, -4
	lw %reg,($sp)
.end_macro

.text

##############################
# PART 1 FUNCTIONS 
##############################

atoui:
	
	move $t0, $a0		# Move it into $t0
	li $t2, 0		# $t2 will be our sum variable
	
	li $t7, '0'		# $t7 holds the value for '0'
	li $t8, '9'		# $t8 holds the value for '9'
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
	move $v0, $t2	# Return the number calculated
	move $v1, $t0	# Return a pointer the the place in the string we are at
	jr $ra


##############################
uitoa:

	# $a0 has value
	# $a1 has the starting address
	# $a2 has the output size
	
	move $t5, $a1
	
	li $t7, 0
	li $t8, '0'
	li $t9, 10
	li $t0, 1 # Sum var
	
	move $t1, $a2 		# Set counter = output size
uitoa0:				# Begin loop 0
	beqz $t1, uitoa0exit 	# If counter = 0, exit
	multu $t0, $t9 		# Multiply 1 by 10
	mflo $t0
	addi $t1, $t1, -1	# Decrement counter

	j uitoa0 		# Loop
uitoa0exit:
	addiu $t0, $t0, -1 	# Subtract 1
        
    bgt $a0, $t0, uitoafail # If our value is greater than 10^size - 1
	bltz $a0, uitoafail
	bltz $a2, uitoafail
	# Initialize counter 1 to 0
    
uitoa1:	# Begin loop 1
	beqz $a0, uitoa1exit 	# If the number is zero, break
	div $a0, $t9 		# Divide by 10
	mflo $a0 		# Overwrite the original with the result
	mfhi $t1		# Push the remainder onto the stack
	push($t1)
	addi $t7, $t7, 1	# Increment counter
	j uitoa1		# Loop
uitoa1exit:
   
uitoa2:	# Begin loop 2
	beqz $t7, uitoa2exit	# If counter is zero, break
	pop($t1)		# Pop the first integer off the stack
	addi $t1, $t1, '0'	
	sb $t1,($a1)		# Write it to the address given
	addi $a1, $a1, 1	# Increment the address
	addi $t7, $t7, -1	# Decrement the counter
	j uitoa2		# Loop
uitoa2exit:
        
	move $v0, $a1
	li $v1, 1
    	
	jr $ra

uitoafail:

	li $v1, 0
	move $v0, $a1
	jr $ra

##############################
# PART 2 FUNCTIONS 
##############################    
            
decodeRun:
    #Define your code here
    li $v0, 0
    li $v1, 0
    
    # $a0 is the char
	# $a1 is the run length
	# $a2 is the output address

	push($s0)

	move $s0, $a0	# Save the originial address

	lb $t0, ($a0)

	#print_string(charToWrite)
	#print_char_reg($t0)
	#print_newline()

	move $t1, $a1
	move $t2, $a2
	
	move $a0, $t0
	push($ra)
	jal isAlphabetic
	pop($ra)

	beqz $v0, DRfail
	ble $t1, 0, DRfail

DR0:
	beqz, $t1, DRexit

	#print_string(overwrittenChar)
	#print_char_addr($t2)
	#print_newline()

	sb $t0, ($t2)
	addi $t2, $t2, 1
	addi $t1, $t1, -1	
	j DR0
DRexit:
	
	#addi $v0, $t2, 1
	move $v0, $t2
	li $v1, 1

	pop($s0)

    jr $ra

DRfail:

	li $v1, 0
	move $v0, $s0	

	pop($s0)
	
	jr $ra

########################################
decodedLength:
    #Define your code here
    li $v0, 0
    li $v1, 0
    
	# Save what we need to save here
	push($ra)
	push($s0)
	push($s1)
	push($s2)
	push($s3)

	move $s0, $a0	# $s0 holds the string pointer
	lb $s1, ($a1)	# $s1 holds the symbol
	li $s2, 0	# $s2 reserved for our current char
	li $s3, 0	# $s3 is our counter

	move $a0, $s1

	jal isAlphanumeric

	beq $v0, 1, decodedLengthFail
	
DL0:
	lb $s2, ($s0)
	
	# The comments below are meant for debugging
	
	#li $v0, 4
	#la $a0, decodedLength_debug
	#syscall
	
	#li $v0, 11
	#move $a0, $s2
	#syscall
	
	#print_space
	
	#li $v0, 1
	#move $a0, $s3
	#syscall
	
	#li $v0, 11
	#li $a0, '\n'
	#syscall
	
	beqz $s2, DLexit
	move $a0, $s2
	jal isAlphanumeric
	beqz $v0, DL1
	addi $s3, $s3, 1
	addi $s0, $s0, 1
	j DL0
DL1:
	addi $s0, $s0, 2
	move $a0, $s0
	jal atoui
	add $s3, $s3, $v0
	move $s0, $v1
	j DL0
DLexit:
	
	addi $v0, $s3, 1
	
	pop($s3)
	pop($s2)
	pop($s1)
	pop($s0)
	pop($ra)
	
	jr $ra

decodedLengthFail:
	
	# Return what we saved - reverse order!!!
	pop($s3)
	pop($s2)
	pop($s1)
	pop($s0)
	pop($ra)
	
	li $v0, 0
	jr $ra



#####################################
runLengthDecode:
    #Define your code here
    li $v0, 0	
	
	# s0 - input pointer
	# s1 - output pointer
	# s2 - flag
	# s3 - current char
	# s4 - output size
	# s5 - pointer to flag
	# s6 - stored char

	push($ra)	# Incase we want to make some function calls (which we do)
	push($s0)
	push($s1)
	push($s2)
	push($s3)
	push($s4)
	push($s5)
	push($s6)
	
	move $s0, $a0
	move $s1, $a1
	move $s5, $a3
	move $s4, $a2
	lb $s2, ($s5)

	move $a0, $s0
	move $a1, $s5
	jal decodedLength

	blt $s4, $v0, RLDfail

	move $a0, $s2
	jal isAlphanumeric

	beq $v0, 1, RLDfail

RLD0:
	lb $s3, ($s0)		# Read char

	#print_string(charRead)
	#print_char_reg($s3)
	#print_newline()

	beqz $s3, RLDexit	# If it's the null terminator, exit
	beq $s3, $s2, RLD1	# If it's the flag, jump down
	sb $s3, ($s1)		# Otherwise copy the char
	addi $s0, $s0, 1	# Increment both pointers
	addi $s1, $s1, 1
	j RLD0				# Loop!
RLD1:
	addi $s0, $s0, 1	# Increment the input pointer and save the char there
	move $s6, $s0		# Copy a pointer to the char, since decodeRun needs a pointer

	#print_string(charStored)
	#print_char_addr($s6)
	#print_newline()

	addi $s0, $s0, 1	# Increment the input pointer. Should now point to a number
	move $a0, $s0		# Move the pointer to argument slot and call atoui
	jal atoui
	
	move $t1, $v0	# Hold on to number parsed
	move $s0, $v1	# Overwrite input pointer
					# Set args for decodeRun
	move $a0, $s6 	# Pointer to char
	move $a1, $t1	# Integer
	move $a2, $s1	# Output place

	jal decodeRun	# Write however many chars we need to output

	move $s1, $v0	# Overwrite output pointer
	j RLD0
RLDexit:

	li $t0, '\0'
	sb $t0, ($s1)

	pop($s6)
	pop($s5)	# Restore stuff
	pop($s4)	
	pop($s3)
	pop($s2)
	pop($s1)
	pop($s0)
	pop($ra)

	li $v0, 1
	jr $ra	
	
RLDfail:
	
	pop($s6)
	pop($s5)	# Restore stuff
	pop($s4)
	pop($s3)
	pop($s2)
	pop($s1)
	pop($s0)
	pop($ra)

	li $v0, 0
    jr $ra

#####################################
isAlphanumeric:

	bge $a0, 48, an0
	j anfalse
an0:
	ble $a0, 57, antrue

	bge $a0, 65, an1	
	j anfalse
an1:
	ble $a0, 90, antrue

	bge $a0, 97, an2
	j anfalse
an2:
	ble $a0, 122, antrue

anfalse:
	li $v0, 0
	jr $ra

antrue:
	li $v0, 1
	jr $ra
##############################
isAlphabetic:

	bge $a0, 65, ab1	
	j abfalse
ab1:
	ble $a0, 90, abtrue

	bge $a0, 97, ab2
	j abfalse
ab2:
	ble $a0, 122, abtrue

abfalse:
	li $v0, 0
	jr $ra

abtrue:
	li $v0, 1
	jr $ra

##############################
# PART 3 FUNCTIONS 
##############################
                
encodeRun:
    #Define your code here
    li $v0, 0
    li $v1, 0
	
	push($ra)
	push($s0)
	push($s1)
	push($s2)
	push($s3)	
	push($s4)

	move $s0, $a2	# Output
	li $s1, 0		# Counter
	move $s2, $a1	# Run length
	lb $s3, ($a3)	# Flag
	lb $s4, ($a0)	# Char

	move $a0, $s4	# Check if char is alphabetical
	jal isAlphabetic
	beq $v0, 0, ERfail

	move $a0, $s3	# Check if the flag is alphanumerical
	jal isAlphanumeric
	beq $v0, 1, ERfail

	bltz $s2, ERfail	# Run cannot be non-positive

	bgt $s2, 3, ER1		# If run length > 3, do the other thing
ER0:
	sb $s4, ($s0)
	addi $s0, $s0, 1
	addi $s1, $s1, -1
	beqz $s1, ERexit
	j ER0
ER1:
	sb $s3, ($s0)		# Write flag
	addi $s0, $s0, 1
	sb $s4, ($s0)		# Write char
	addi $s0, $s0, 1
	
	move $a0, $s2		# Make some space for the int
	jal numDigits
	addi $t0, $v0, 1

	move $a0, $s2		# Write the int out
	move $a1, $s0
	move $a2, $t0
	jal uitoa

ERexit:
	pop($s4)
	pop($s3)
	pop($s2)
	pop($s1)
	pop($s0)	
	pop($ra)

	li $v1, 1
	jr $ra


ERfail:
	pop($s4)
	pop($s3)
	pop($s2)
	pop($s1)
	pop($s0)	
	pop($ra)

	move $v0, $s0
	li $v0, 0
	jr $ra

encodedLength:
    #Define your code here
    li $v0, 0
    
	# Save things
	push($ra)
	push($s0)
	push($s1)
	push($s2)
	push($s3)
	push($s4)
	push($s5)

	move $s0, $a0
	li $s1, 0
	li $s3, 0
	li $s4, 0
	li $s5, 0	# Indicates if the last strech of chars was a run or not

	lb $s1, ($s0)

	beqz $s1, RDfail

RD0:
	lb $s2, ($s0)

	#print_string(charRead)
	#print_char_reg($s2	)
	#print_newline()

	addi $s0, $s0, 1
	beqz $s2, RDexit
	bne $s1, $s2, RDdiff
	addi $s3, $s3, 1
	j RD0
RDdiff:
	move $s1, $s2
	bgt $s3, 3, RDenc
	add $s4, $s4, $s3
	addi $s4, $s4, 1	

	#print_string(countIncreased)
	#print_int($s4)
	#print_newline()

	li $s3, 0
	j RD0
RDenc:
	move $a0, $s3
	jal numDigits
	addi $v0, $v0, 2
	add $s4, $s4, $v0

	#print_string(countIncreased)
	#print_int($s4)
	#print_newline()

	li $s3, 0
	j RD0
RDexit: # Before we fully exit, we need to make sure all of the chars were accounted for.
		# Probably 	better to fix the loop but.... fuck it
	bgt $s3, 3, RDexit1
	add $s4, $s4, $s3
	j RDexit2
	
RDexit1:
	
	move $a0, $s3
	jal numDigits
	addi $v0, $v0, 2
	add $s4, $s4, $v0

RDexit2:

	#move $v0, $s4
	addi $v0, $s4, 1

	pop($s5)
	pop($s4)
	pop($s3)
	pop($s2)
	pop($s1)
	pop($s0)
	pop($ra)
    
    jr $ra       

RDfail:

	li $v0, 0
	jr $ra


runLengthEncode:
    #Define your code here
    li $v0, 0
    
    jr $ra
    
###############################
numDigits:

	# $a0 has the integer
	li $t0, 10
	li $v0, 0
ND0:
	div $a0, $t0
	mflo $a0
	mfhi $t1
	beqz $t1, NDexit
	addi $v0, $v0, 1
	j ND0
NDexit:
	jr $ra


.data 
.align 2

charStored: .asciiz "Char stored:"
charRead: .asciiz "Char read:"
newChar: .asciiz "New Char:"
overwrittenChar: .asciiz "Overwritten char:"
charToWrite: .asciiz "Char to write:"
countIncreased: .asciiz "Count Increased To:"
