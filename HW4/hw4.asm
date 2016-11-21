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
   	
    push($ra)	
    push($s0)	# $s0 - left index
    push($s1)	# Ss1 - right index
    push($s2)	# $s2 - node value
    
    move $s3, $a0
    move $s4, $a1
    move $s5, $a2
    
    lw $t0, ($a0)
    andi $s2, $t0, 0xFFFF 	# Get the node value
    andi $s0, $t0, 0xFF000000
    srl $s0, $s0, 24		# Get left index
    andi $s1, $t0, 0xFF0000
    srl $s1, $s1, 16		# Get right index
    
    push($a0)
    push($a1)
    push($a2)
    # Code to write it to file here
    move $a0, $s2
    move $a1, $a2
    jal itof
    
    pop($a2)
    pop($a1)
    pop($a0)
    
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
	
	move $t9, $a1 # Save file descriptor
	
	andi $t8, $a0, 0x8000
	
	beqz $t8, itof0		# If its positive, skip all this
	
	push($t0)
	push($t9)
	push($v0)
	push($a0)
	push($a1)
	push($a2)
	
	li $t0, '-'
	sb $t0, buffer
	
	move $a0, $t9
	la $a1, buffer
	li $a2, 1
	li $v0, 15
	syscall

	li $t0, 0
	sb $t0, buffer

	pop($a2)
	pop($a1)
	pop($a0)
	pop($v0)
	pop($t9)
	pop($t0)
	
	xori $a0, $a0, 0xFFFF
	addi $a0, $a0, 1	# Convert to positive
	
	
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
	
	move $a0, $t9		# Write the digit to the file
	la $a1, buffer
	li $v0, 15
	syscall
	
	dec($t0)			# Decrement count
	bnez $t0, itof1		# Loop
	
	li $t0, '\n'
	sb $t0, buffer
	
	move $a0, $t9
	la $a1, buffer
	li $a2, 1
	li $v0, 15
	syscall
	
	jr $ra

##############################
# PART 2 FUNCTIONS
##############################

linear_search:

	# Create static masking byte:0x80 ($t0) doesn't change

	# Decrement byte array pointer
	# label1
	# Increment byte array pointer
	# Load that byte
	# reset masking byte
	# label2
	# mask loaded byte with masking byte
	# if its nonzero, return count
	# increment count
	# if count > maxsize, return negative
	# shift mask to the right by 1
	# if masking byte is zero, j label1
	# j label2
	
	# $t0 - static masking byte
	# $t1 - masking byte
	# $t2 - byte array pointer
	# $t3 - current (loaded) byte
	# $t4 - mask result
	# $t5 - count
	# $t6 - maxsize

	li $t0, 0x80
	addi $t2, $a0, -1
	move $t6, $a1
	li $t5, 0
	
LS1:
	inc($t2)		# Increment byte array pointer
	lb $t3, ($t2)	# Load the newest byte
	move $t1, $t0	# Reset the mask
	
LS2:
	and $t4, $t1, $t3		# Mask the byte
	beqz $t4, LSreturn		# If its zero, return with the current index
	inc($t5)				# Otherwise increment the index
	bgt $t5, $t6, LSfail	# If the index is > maxsize, return failure
	srl $t1, $t1, 1			# Shift the mask over one
	beqz $t1, LS1			# if the mask is zero, load the next byte and reset the max
	j LS2					# otherwise read the next bit

LSreturn:
	move $v0, $t5
	jr $ra

LSfail:
    li $v0, -1
    jr $ra
    
###################################################
set_flag:
	addi $t0, $a3, -1
	bgt $a1, $t0, SFfail
	
	# $a0 array pointer
	# $a1 index to write [0 -> (maxsize-1)]
	# $a2 setValue
	# $a3 maxsize
	
	andi $t0, $a1, 7	# Remainder div/8
	srl $t1, $a1, 3		# Quotient div/8
	
	add $t2, $a0, $t1	# Offset it by the number of bytes
	lbu $t3, ($t2)		# Load the byte at this location
	# Don't change $t2 from here out
	
	li $t4, 0x80		# Set it to the leftmost bit
	srlv $t4, $t4, $t0	# Shift it over how ever many times needed
	not $t4, $t4		# Flip it, since we want all the bits except this one
	
	and $t5, $t3, $t4	# Mask for all the bits except the one we want
	
	sll $t6, $a2, 7		# Move the set bit to the left end
	srlv $t6, $t6, $t0	# Offset it to match the thing
	
	or $t5, $t6, $t5
	sb $t5, ($t2)
	
SFreturn:
	li $v0, 1
	jr $ra

SFfail:
    li $v0, 0
    jr $ra
###################################################
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

