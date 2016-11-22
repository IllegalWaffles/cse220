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
	# shift mask to the left by 1
	# if masking byte is 256, j label1
	# j label2
	
	# $t1 - masking byte
	# $t2 - byte array pointer
	# $t3 - current (loaded) byte
	# $t4 - mask result
	# $t5 - count
	# $t6 - maxsize

	addi $t2, $a0, -1
	move $t6, $a1
	li $t5, 0
	
LS1:
	inc($t2)		# Increment byte array pointer
	lb $t3, ($t2)	# Load the newest byte
	li $t1, 1		# Reset the mask

LS2:
	and $t4, $t1, $t3		# Mask the byte
	beqz $t4, LSreturn		# If its zero, return with the current index
	inc($t5)				# Otherwise increment the index
	bgt $t5, $t6, LSfail		# If the index is > maxsize, return failure
	sll $t1, $t1, 1			# Shift the mask over one
	beq $t1, 256, LS1		# if the mask is zero, load the next byte and reset the max
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
	
	li $t4, 1			# Set it to the rightmost bit
	sllv $t4, $t4, $t0	# Shift it over how ever many times needed
	not $t4, $t4		# Flip it, since we want all the bits except this one
	
	and $t5, $t3, $t4	# Mask for all the bits except the one we want

	andi $t6, $a2, 1	# Mask for only the first bit
	sllv $t6, $t6, $t0	# Offset it to match the thing
	
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

	# $a0 - nodes array
	# $a1 - index
	# $a2 - newvalue
	
	push($ra)
	push($s0)
	push($s1)
	push($s2)
	push($s3)
	push($s4)
	
	move $s4, $a1
	sll $s0, $a2, 16	# Erase upper 16 bits
	sra $s0, $s0, 16	# Sign extend lower 16 bits

						# $s0 has newvalue
						# $s1 has node value
						# $s2 has left index
						# $s3 has right index
						# $s4 has the current index
	
	sll $t0, $a1, 2
	add $t1, $a0, $t0	# Calculate correct address
	
	lw $t0, ($t1)
    andi $s1, $t0, 0xFFFF 	# Get the node value
    andi $s2, $t0, 0xFF000000
    srl $s2, $s2, 24		# Get left index
    andi $s3, $t0, 0xFF0000
    srl $s3, $s3, 16		# Get right index

FPleftindex:
	
	bge $s0, $s1, FPrightindex	# if(newvalue < nodes[currIndex].value)
	bne $s2, 255, FPleftelse	# if(leftindex == 255)
	
	move $v0, $a1				# 
	li $v1, 0					# return currIndex, 0
	
	j FPreturn
FPleftelse:
	
	move $a1, $s2				# Set the argument to left node		
	
	jal find_position			
	j FPreturn					# Return find_position
	
FPrightindex:
	
	bne $s3, 255, FPrightelse	# if(rightIndex == 255)
	
	move $v0, $a1
	li $v1, 1
	
	j FPreturn					# Return currIndex, 1
FPrightelse:

	move $a1, $s3				# Set the argument to right node

	jal find_position			
	j FPreturn					# Return find_position

FPreturn:
	# pop everything before returning
	pop($s4)
	pop($s3)
	pop($s2)
	pop($s1)
	pop($s0)
	pop($ra)
	jr $ra
###################################################
add_node:
    
    lw $t0, 0($sp)
    lw $t1, 4($sp)
    
    push($ra)
    push($s0)
    push($s1)
    push($s2)
    push($s3)
    push($s4)
    push($s5)
    
    # $a0 - nodes array - $s0
    # $a1 - rootIndex - $s1
    # $a2 - newValue - $s2
    # $a3 - newIndex - $s3
    # top stack - maxsize - $s4
    # next on stack - flags array - $s5
    move $s0, $a0
    move $s1, $a1
    move $s2, $a2
    move $s3, $a3
    move $s4, $t0
    move $s5, $t1
    
    andi $s1, $s1, 0xFF
    andi $s3, $s3, 0xFF
    
    bge $s1, $s4, ANreturn0
    bge $s3, $s4, ANreturn0
    
    sll $s2, $s2, 16
    sra $s2, $s2, 16
    
    # boolean validRoot = nodeExists(rootIndex);
    
    move $a0, $s5
    move $a1, $s1
	jal linear_search
	
	beqz $v0, rootNotExists
	
	move $a0, $s0
	move $a1, $s1
	move $a2, $s2
	jal find_position
	
	# $v0 parent index
	# $v1 left or right, 1 = right 0 = left
	
	sll $t1, $v0, 2
	addu $t0, $s0, $t1
	lw $t2, ($t0)
	
	beq $v1, 1, ANifright
		
		andi $t2, $t2, 0xFFFFFF	# Set the left or something
		sll $t3, $s3, 24
		or $t2, $t2, $t3
		sw $t2, ($t0)
	
	j ANexitIF
ANifright:
	
		andi $t2, $t2, 0xFF00FFFF	# Set the right or something
		sll $t3, $s3, 16
		or $t2, $t2, $t3
		sw $t2, ($t0)
	
	j ANexitIF
rootNotExists:

	move $s3, $s1	# There's no node, so set it or something

ANexitIF:

	# Executed regardless of which statements in the if is executed
	sll $t1, $s3, 2
	addu $t0, $s0, $t1
	li $t2, 0xFFFF0000
	or $t2, $t2, $s2
	
	move $a0, $s5
	move $a1, $s3
	li $a2, 1
	move $a3, $s4
	
	jal set_flag
	j ANreturn
	
ANreturn0:
	li $v0, 0
ANreturn:
    pop($s5)
    pop($s4)
    pop($s3)
    pop($s2)
    pop($s1)
    pop($s0)
    pop($ra)
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
	push($ra)
	
	sll $t0, $a1, 2				# Multiply offset by 4
	addu $t0, $t0, $a0			# Add the offset to base address
	lw $t0, ($t0)				# Load the byte
	move $t2, $t0				# Save loaded byte for now
	andi $t0, $t0, 0xFF000000	# Mask for the left index
	srl $t0, $t0, 24				# Shift it over

	bne $t0, 0xFF, FMrecursive	# If there is a node there, do a recursive call
							# Otherwise this is the furthest left node
		move $v0, $a1			# Return current index

		andi $t0, $t2, 0xFF0000	# Mask for right index
		srl $t0, $t0, 16			# Shift it over

		bne $t0, 0xFF, FM1		# Branch if it is not a leaf
		li $v1, 1				# Otherwise it's a leaf
		j FM2
FM1:		li $v1, 0				# It's not a leaf
FM2:
							# Return
		pop($ra)
		jr $ra
	
FMrecursive:
		move $a1, $t0			# Load the left index as an arg
		jal find_min			# Recursive call
		pop($ra)				# Return from recursive call
		jr $ra				
#############################################
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

