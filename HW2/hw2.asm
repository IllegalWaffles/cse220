##############################################################
# Homework #2
# name: Kuba Gasiorowski
# sbuid: 109776237
##############################################################
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
	j loop_h		# LOOP!
exit_h:
	move $v0, $t2
	jr $ra


##############################
uitoa:

	# $a0 has value
	# $a1 has the starting address
	# $a2 has the output size
	
	li $t7, 0
	li $t8, '0'
	li $t9, 10
#	li $t0, 1 # Sum var
	
#	move $t1, $a2 		# Set counter = output size
#uitoa0:				# Begin loop 0
#	beqz $t1, uitoa0exit 	# If counter = 0, exit
#	mult $t0, $t9 		# Multiply 1 by 10
#	mflo $t0
#	addi $t1, $t1, -1	# Decrement counter

#	j uitoa0 		# Loop
#uitoa0exit:
#	addi $t0, $t0, -1 	# Subtract 1
        
#        ble $a0, $t0, uitoafits # If our value is greater than 10^size - 1,   
#        move $v0, $a1 		# return with 0 and the original address of the string
#        li $v1, 0
#        jr $ra

	bltz $a0, uitoafail
	bltz $a2, uitoafail
	# Initialize counter 1 to 0
    
uitoa1:	# Begin loop 1
	beqz $a0, uitoa1exit 	# If the number is zero, break
	div $a0, $t9 		# Divide by 10
	mflo $a0 		# Overwrite the original with the result
	mfhi $t1		# Push the remainder onto the stack
	addi $sp, $sp, 4
	sw $t1,($sp)
	addi $t7, $t7, 1	# Increment counter
	j uitoa1		# Loop

uitoa1exit:
   
uitoa2:	# Begin loop 2
	beqz $t7, uitoa2exit	# If counter is zero, break
	lw $t1,($sp)		# Pop the first integer off the stack
	addi $sp, $sp, -4
	addi $t1, $t1, '0'	
	sb $t1,($a1)		# Write it to the address given
	addi $a1, $a1, 1	# Increment the address
	addi $t7, $t7, -1	# Decrement the counter
	j uitoa2		# Loop
uitoa2exit:
        
	# Move address into $a0
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

decodedLength:
    #Define your code here
    li $v0, 0
    li $v1, 0
    
    jr $ra
         
runLengthDecode:
    #Define your code here
    li $v0, 0
    
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