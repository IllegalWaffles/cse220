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
	move $v0, $t2
	move $v1, $t0
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
    
    jr $ra

########################################
decodedLength:
    #Define your code here
    li $v0, 0
    li $v1, 0
    
	# Save what we need to save here
	push($s0)
	push($s1)
	push($s2)

	move $s0, $a0	# $s0 holds the address
	lb $s1, ($a1)	# $s1 holds the symbol
	li $s2, 0		# $t1 is our counter

	move $a0, $s1

	push($ra)
	jal isAlphanumeric
	pop($ra)

	beq $v0, 1, decodedLengthFail

dl0:
	lb $a0, ($s0)		# Load a char
	beqz $a0, dl0exit

	push($ra)			
	jal isAlphanumeric	# Find if its alphanumerical
	pop($ra)
	
	beqz $v0, dlExpansion		# If it is, go back up to the top
	addi $t1, $t1, 1
	addi $s0, $s0, 1
	j dl0
dlExpansion:					# If not, follow procedures for expansion
	addi $s0, $s0, 2			# Skip the next char
	move $a0, $s0

	push($ra)
	jal atoui
	pop($ra)

	add $t0, $t0, $v0
	move $s0, $a0
	j dl0
dl0exit:

	# Return what we saved - reverse order!!!
	pop($s2)
	pop($s1)
	pop($s0)
	
	move $v0, $t0
    jr $ra

decodedLengthFail:
	
	# Return what we saved - reverse order!!!
	pop($s1)
	pop($s0)
	
	li $v0, 0
	jr $ra

#####################################
runLengthDecode:
    #Define your code here
    li $v0, 0
    
    jr $ra

#Expects the char to be inside $a0
#$v0 contains 1 if it is alphanumeric and 0 if not
isAlphanumeric:

	move $t0, $a0

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
# PART 3 FUNCTIONS 
##############################
                
encodeRun:
    #Define your code here
    li $v0, 0
    li $v1, 0
    
    jr $ra

encodedLength:
    #Define your code here
    li $v0, 0
    
    jr $ra        

runLengthEncode:
    #Define your code here
    li $v0, 0
    
    jr $ra
    


.data 
.align 2
