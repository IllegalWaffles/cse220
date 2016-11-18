##############################################################
# Homework #4
# name: MY_NAME
# sbuid: MY_SBU_ID
##############################################################
.text

.macro push(%reg)
	addi $sp, $sp, -4
	sw %reg,($sp)	
.end_macro

.macro pop(%reg)
	lw %reg,($sp)
	addi $sp, $sp, 4
.end_macro

.macro inc(%reg)
	addi %reg, %reg, 1
.end_macro

.macro dec(%reg)
	addi %reg, %reg, -1
.end_macro

.macro print_int(%reg)
	push($v0)
	push($a0)
	move $a0, %reg
	li $v0, 1
	syscall
	pop($a0)
	pop($v0)
.end_macro

.macro newline()
	push($v0)
	push($a0)
	li $a0, '\n'
	li $v0, 11
	syscall
	pop($a0)
	pop($v0)
.end_macro

##############################
# PART 1 FUNCTIONS
##############################

preorder:
    # $a0 - address of the current node
    # $a1 - base address of the array of nodes
    # $a2 - file descriptor
    # do not change base array or FD
    
    # $s0 - left index
    # Ss1 - right index
    # $s2 - node value
    push($ra)
    push($s0)
    push($s1)
    push($s2)
    
    lw $t0, ($a0)
    andi $s2, $t0, 0xFFFF 	# Get the node value
    andi $s0, $t0, 0xFF000000
    srl $s0, $s0, 24		# Get left index
    andi $s1, $t0, 0xFF0000
    srl $s1, $s1, 16		# Get right index
    
    # Code to write it to file here
    # Write a newline here
    
    print_int($s2)
    newline()
    
leftpreorder:
    beq $s0, 255, rightpreorder
    
    sll $t1, $s0, 2				# Mult by 4, since each word is 4 bytes
    addu $a0, $t1, $a1			# Add it to the base memory address
    
    jal preorder
    
rightpreorder:
	beq $s1, 255, preorderexit

	sll $t1, $s1, 2				# Mult by 4, since each word is 4 bytes
	addu $a0, $t1, $a1			# Add it to the base memory address
	
	jal preorder

preorderexit:

	pop($s2)
	pop($s1)
	pop($s0)
    pop($ra)
	jr $ra

itof:
	# $a0 - integer to write to file
	# $a1 - file descriptor
	
	# While the quotient is not zero,
	# 	Get a digit, calc ascii value (char + '0'), push it to the stack
	# 	Count++
	# For every count, 
	#	pop a digit off the stack,
	# 	write it to the output buffer,
	#	syscall write to file with 1 char
	# Write a newline at the end
	
	# $t0 - count
	# $t1 - quotient
	# $t2 - remainder
	# $t3 - 10
	
	li $t3, 10
	li $t0, 0
	li $a2, 1
	
itof0:
	
	div $a0, $t3	# Divide by 10
	mflo $a0		# Get the quotient
	mfhi $t2		# Get the remainder
	
	addi $t2, $t2, '0'	# Calculate the ascii value of this digit
	push($t2)			# Push it on to the stack
	inc($t0)			# Increment our counter
	
	bnez $a0, itof0		# If the quotient is zero, no more digits!
	
itof1:

	pop($t1)			# Pop a digit off the stack
	sb $t1, buffer		# Write it to the output buffer
	
	move $a0, $a1		# Write the digit to the file
	la $a1, buffer
	li $v0, 15
	syscall
	
	dec($t0)			# Decrement count
	bnez $t0, itof1		# Loop
	
	li $t0, '\n'
	sw $t0, buffer
	
	move $a0, $a1
	la $a1, buffer
	li $a2, 1
	li $v0, 15
	syscall
	
	jr $ra

##############################
# PART 2 FUNCTIONS
##############################

linear_search:
    #Define your code here
    ############################################
    # DELETE THIS CODE. Only here to allow main program to run without fully implementing the function
    li $v0, -10
    ###########################################
    jr $ra

set_flag:
    #Define your code here
    ############################################
    # DELETE THIS CODE. Only here to allow main program to run without fully implementing the function
    li $v0, -20
    ###########################################
    jr $ra

find_position:
    #Define your code here
    ############################################
    # DELETE THIS CODE. Only here to allow main program to run without fully implementing the function
    li $v0, -30
    li $v1, -40
    ###########################################
    jr $ra

add_node:
    #Define your code here
    ############################################
    # DELETE THIS CODE. Only here to allow main program to run without fully implementing the function
    li $v0, -50
    ###########################################
	jr $ra

##############################
# PART 3 FUNCTIONS
##############################

get_parent:
    #Define your code here
    ############################################
    # DELETE THIS CODE. Only here to allow main program to run without fully implementing the function
    li $v0, -60
    li $v1, -70
    ###########################################
    jr $ra

find_min:
    #Define your code here
    ############################################
    # DELETE THIS CODE. Only here to allow main program to run without fully implementing the function
    li $v0, -80
    li $v1, -90
    ###########################################
    jr $ra

delete_node:
    #Define your code here
    ############################################
    # DELETE THIS CODE. Only here to allow main program to run without fully implementing the function
    li $v0, -100
    ###########################################
    jr $ra

##############################
# EXTRA CREDIT FUNCTION
##############################

add_random_nodes:
    #Define your code here
    jr $ra



#################################################################
# Student defined data section
#################################################################
.data
.align 2  # Align next items to word boundary

buffer: .ascii ""

#place any additional data declarations here

