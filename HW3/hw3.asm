##############################################################
# Homework #3
# name: Kuba Gasiorowski
# sbuid: 109776237
##############################################################
.text

.macro push(%reg)
	sw %reg,($sp)	
	addi $sp, $sp, 4
.end_macro

.macro pop(%reg)
	addi $sp, $sp, -4
	lw %reg,($sp)
.end_macro

.macro read_char(%reg)
	move $a0, %reg
	la $a1, buffer
	li $a2, 1
	li $v0, 14
	syscall
	lb $v1, buffer
.end_macro

.macro inc(%reg)
	addi %reg, %reg, 1
.end_macro

.macro pstring(%str)
	li $v0, 4
	la $a0, %str
	syscall
.end_macro

.macro pbin(%reg)
	li $v0, 35
	move $a0, %reg
	syscall
.end_macro

.macro pint(%reg)
	li $v0, 1
	move $a0, %reg
	syscall
.end_macro

.macro pchar(%reg)
	li $v0, 11
	move $a0, %reg
	syscall
.end_macro

.macro phex(%reg)
	li $v0, 34
	move $a0, %reg
	syscall
.end_macro

.macro newline()
	li $v0, 4
	la $a0, newline
	syscall
.end_macro

##############################
# PART 1 FUNCTIONS
##############################

smiley:
    li $t9, 0xFFFF0000	# Starting position of the grid. Not to be overwritten
    addiu $t8, $t9, 198 # Establish upper bound
    
    move $t0, $t9
    
    # Build black tile
    li $t1, 0x0F		# 1st byte
    sll $t1, $t1, 8
    ori	$t1, $t1, '\0'	# 2nd byte
    
    # Build eye tile
    li $t2, 0xB7
	sll $t2, $t2, 8
	ori $t2, $t2, 'b'
        
    # Build mouth tile
    li $t3, 0x1F
    sll $t3, $t3, 8
    ori $t3, $t3, 'e'
    
    # Loop to fully populate grid with black tiles
    
smiley1:
	sh $t1, 0($t0)		# Do the thing
	addiu $t0, $t0, 2
    bgt $t0, $t8, smiley1exit
   	j smiley1

smiley1exit:

	# Eyes
	sh $t2, 46($t9)
	sh $t2, 66($t9)

	sh $t2, 52($t9)
	sh $t2, 72($t9)

	# Mouth
	sh $t3, 124($t9)
	sh $t3, 146($t9)
	sh $t3, 168($t9)
	sh $t3, 170($t9)
	sh $t3, 152($t9)
	sh $t3, 134($t9)
	
	jr $ra

##############################
# PART 2 FUNCTIONS
##############################

open_file:
    #Define your code here
	# $a0 already contains the address of the string
	li $a1, 0
	li $a2, 0
	
	li $v0, 13
	syscall

    jr $ra

close_file:
    #Define your code here
	li $v0, 16
	syscall

    jr $ra

load_map:
    #Define your code here
    
    # $s0 - starting array location passed in
    # $s1 - file descriptor
    # $s2 - number of coordinates read
    # $s3 - unused
    # $s4 - last char
    # $s5 - current char
    
    push($ra)
    push($s0)
    push($s1)
    push($s2)
    push($s3)
    push($s4)
    push($s5)

    move $s1, $a0		
    move $s0, $a1
    li $s2, 0
    li $s3, 0
    li $s4, 0
    li $s5, 0
    li $t0, 0			# Counter
    
label0:
	add $t1, $s0, $t0
	sb $zero, ($t1)
	addi $t0, $t0, 1
	bgt $t0, 99, label1
	j label0
    
label1:					#Byte array should be cleared now
    
	li $s4, 0
	li $s5, 0

	read_char($s1)
    beqz $v0, endfileparse	# EOF read. Stop parsing the file
    move $s4, $v1
    
    #pstring(charRead)
    #pint($s4)
    #pstring(space)
    #pchar($s4)
    #pstring(space)
    #pbin($s4)
    #pstring(newline)
    
    move $a0, $s4
    jal isWhitespace	# Check if the character read was a whitespace
    beq $v0, 1, label1	# If it is, read the next value (jump up)
    
    move $a0, $s4
    jal isNumerical			# Check if it is numerical
    beqz $v0, loadmapfail	# It was neither whitespace nor numerical. Error!

	beq $s4, '0', zeroread	# If it was a zero, do something else
	
	read_char($s1)			# A number was read - check the next character
	move $s3, $s4
	beqz $v0, writeoutbeforefinishparse
	move $s5, $v1
	
	#pstring(charRead)
    #pint($s5)
    #pstring(space)
    #pchar($s5)
    #pstring(space)
    #pbin($s5)
    #pstring(newline)

	move $a0, $s5
	jal isNumerical			# Check if its numerical
	beq $v0, 1, loadmapfail # If it was, that's an error - number must be too big in this case
	
	move $a0, $s5			
	jal isWhitespace		# Check if its a whitespace
	beqz $v0, loadmapfail	# If it's not, must be an error. 
	
	li $t0, '0'
	sub $t0, $s4, $t0
	la $t1, coordinates
	addu $t1, $t1, $s2
	sb $t0, ($t1)
	addi $s2, $s2, 1
	j label1

zeroread:

	read_char($s1)	# A zero was read - check the next char.
	li $s3, '0'		# Write a zero to output
	beqz $v0, writeoutbeforefinishparse

	move $s5, $v1	

	#pstring(charRead)
    #pint($s5)
    #pstring(space)
    #pchar($s5)
    #pstring(space)
    #pbin($s5)
    #pstring(newline)

	beq $s5, '0', zeroread	# Another zero - go up to the top
	
	move $a0, $s5
	jal isWhitespace
	beqz $v0, label5		# If it is whitespace, we write a zero
	li $s4, '0'
	j label3
	label5:					# If it is not, skip
	move $a0, $s5
	jal isNumerical			# If it's a number, do something else.
	bnez $v0, label6
	j loadmapfail			# If it was none of the above, an error occurred.
	label6:
	move $s4, $s5
	j label4
	

label3:						# Whitespace was read after a zero. Write a zero to coordinates
	li $t0, '0'
	sub $t0, $s4, $t0
	la $t1, coordinates
	addu $t1, $t1, $s2
	sb $t0, ($t1)
	inc($s2)

	#pstring(valueStored)
	#pint($t0)
	#newline()

	j label1
	
label4:						# A number was read AFTER a zero. Handle all possible cases now

	#li $s4, '0'		# This label is reachable ONLY after a zero. Assume last number was a zero	

	read_char($s1)
	move $s3, $s4			# Make sure to write out the final char
	beqz $v0, writeoutbeforefinishparse
	
	move $s5, $v1

	#pstring(charRead)
    #pint($s5)
    #pstring(space)
    #pchar($s5)
    #pstring(space)
    #pbin($s5)
    #pstring(newline)

	move $a0, $s5
	jal isNumerical		
	beq $v0, 1, loadmapfail	# Two numbers in a row means failure

	move $a0, $s5
	jal isWhitespace
	beqz $v0, loadmapfail	# If it's not WS, then it must be an invalid char

	#move $s4, $s5

	j label3
	
writeoutbeforefinishparse:
	li $t0, '0'
	sub $t0, $s3, $t0
	la $t1, coordinates
	addu $t1, $t1, $s2
	sb $t0, ($t1)
	inc($s2)
	
	#pstring(valueStored)
    #pint($t0)
    #pstring(space)
    #pchar($t0)
    #pstring(space)
    #pbin($t0)
    #pstring(newline)

endfileparse:
	andi $t0, $s2, 1			# Check for odd # of values
	beq $t0, 1, loadmapfail	
	
	blt $s2, 2, loadmapfail

	li $t0, 0				# Counter
	la $t1, coordinates
	
loop2:
	lb $t3, ($t1)			# Load y
	inc($t1)				# Increment coordinates pointer
	inc($t0)				# Increment counter
	
	#pstring(loadedXVal)
	#pint($t3)
	#pstring(newline)

	lb $t2, ($t1)			# Load x
	inc($t1)				# Increment coordinates pointer
	inc($t0)				# Increment counter

	#pstring(loadedYVal)
	#pint($t2)
	#pstring(newline)

	li $t9, 10
	mult $t9, $t3			# (y * 10)
	mflo $t4				
	add $t5, $t4, $t2		# x + (y * 10) = offset
	addu $t6, $s0, $t5		# addr + offset
	
	#pstring(offset)
	#pint($t5)
	#pstring(newline)

	li $t8, 0
	ori $t8, $t8, 32
	sb $t8, ($t6)
	
	blt $t0, $s2, loop2

	li $t0, 0
	li $t1, 0
	li $t9, 10

###################
loopa:

	li $t1, 0
loopb:

	mult $t0, $t9
	mflo $t2
	add $t2, $t2, $t1
	addu $t2, $s0, $t2 
	lb $t2, ($t2)

	

	pint($t2)
	pstring(space)

	inc($t1)
	blt $t1, 10, loopb

	newline()

	inc($t0)
	blt $t0, 10, loopa
###################

    pop($s5)
	pop($s4)
	pop($s3)
	pop($s2)
	pop($s1)
	pop($s0)
	pop($ra)
    
    li $v0, 1
    jr $ra
    
loadmapfail:

	pop($s5)
	pop($s4)
	pop($s3)
	pop($s2)
	pop($s1)
	pop($s0)
	pop($ra)
    
    li $v0, -1
    jr $ra

#############################
isWhitespace:

	beq $a0, '\r', whtrue
	beq $a0, '\t', whtrue
	beq $a0, '\n', whtrue
	beq $a0, ' ', whtrue

whfail:
	li $v0, 0
	jr $ra	

whtrue:
	li $v0, 1
	jr $ra	

#############################
isNumerical:

	blt $a0, '0', numfail
	bgt $a0, '9', numfail
	
numtrue:
	li $v0, 1
	jr $ra

numfail:
	li $v0, 0
	jr $ra

##############################
# PART 3 FUNCTIONS
##############################

init_display:
    #Define your code here
    jr $ra

set_cell:
    #Define your code here
    ############################################
    # DELETE THIS CODE. Only here to allow main program to run without fully implementing the function
    li $v0, -200
    ###########################################
    jr $ra

reveal_map:
    #Define your code here
    jr $ra


##############################
# PART 4 FUNCTIONS
##############################

perform_action:
    #Define your code here
    ############################################
    # DELETE THIS CODE. Only here to allow main program to run without fully implementing the function
    li $v0, -200
    ##########################################
    jr $ra

game_status:
    #Define your code here
    ############################################
    # DELETE THIS CODE. Only here to allow main program to run without fully implementing the function
    li $v0, -200
    ##########################################
    jr $ra

##############################
# PART 5 FUNCTIONS
##############################

search_cells:
    #Define your code here
    jr $ra


#################################################################
# Student defined data section
#################################################################
.data
.align 2  # Align next items to word boundary
cursor_row: .word -1
cursor_col: .word -1

coordinates: .space 300

charRead: .asciiz "Character read:"
newline: .asciiz "\n"
space: .asciiz " "
zeroReadS: .asciiz "A zero was read"
loadedXVal: .asciiz "Loaded X Value:"
loadedYVal: .asciiz "Loaded Y Value:"
offset: .asciiz "Calculated offset:"
coordsRead: .asciiz "Coordinates read:"
valueStored: .asciiz "Value stored:"

buffer: .ascii ""

#place any additional data declarations here

