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
    
    move $a0, $s0
    jal printArray
    
    newline()
    
label0:
	add $t1, $s0, $t0
	sb $zero, ($t1)
	inc($t0)
	bgt $t0, 99, labelabc
	j label0

labelabc:
  
    move $a0, $s0
    jal printArray
    newline()
    
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

loopa:

	li $t1, 0
loopb:

	mult $t0, $t9
	mflo $t2
	add $t2, $t2, $t1
	addu $t2, $s0, $t2 	# $t2 holds the address of the current cell
	#lb $t2, ($t2)
	
	li $t3, 0	# $t3 is our blank byte
	# row stored in $t0
	# col stored in $t1
	
	bnez $t0, rowcase1
		bnez $t1, colcase01
			ori $t3, $t3, 0xB
		j ifexit
	colcase01:
		bne $t1, 9, colcase02
			ori $t3, $t3, 0x16
		j ifexit
	colcase02:
			ori $t3, $t3, 0x1F
		j ifexit
rowcase1:
	bne $t0, 9, rowcase2
		bnez $t1, colcase11
			ori $t3, $t3, 0x68
		j ifexit
	colcase11:
		bne $t1, 9, colcase12
			ori $t3, $t3, 0xD0
		j ifexit
	colcase12:
			ori $t3, $t3, 0xF1
		j ifexit
rowcase2:
		bnez $t1, colcase21
			ori $t3, $t3, 0x6B
		j ifexit
	colcase21:
		bne $t1, 9, colcase22
			ori $t3, $t3, 0xD6
		j ifexit
	colcase22:
			ori $t3, $t3, 0xFF
		j ifexit

ifexit:

	# $t3 is our mask now
	
	li $t6, 0
	li $t4, 256
	
loop3:
	srl $t4, $t4, 1		# Shift our mask over by 1
	blez $t4, loop3exit
	and $t5, $t3, $t4	# See if this cell is included in the mask
	beqz $t5, loop3		# If this cell isn't in the mask, skip it
	
	move $a0, $t4		
	jal getNum			# Get the offset for this cell
	add $t5, $v0, $t2	# Add it to this cell's address
	lb $t5, ($t5)		# Load the data at that cell's address
	
	andi $t5, $t5, 32	# Is there a bomb there?
	beqz $t5, loop3		# If there is...
	inc($t6)			# Then 
	
	j loop3
loop3exit:	
	
	# $t6 now has the number of bombs adjacent to the thing
	pint($t6)
	pstring(space)
	#pint($t2)
	#pstring(space)

	inc($t1)
	blt $t1, 10, loopb

	newline()

	inc($t0)
	blt $t0, 10, loopa

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
############################
getNum:

	bne $a0, 128, gn0
	li $v0, -11
	jr $ra
gn0:bne $a0, 64, gn1
	li $v0, -10
	jr $ra
gn1:bne $a0, 32, gn2
	li $v0, -9
	jr $ra
gn2:bne $a0, 16, gn3
	li $v0, -1
	jr $ra
gn3:bne $a0, 8, gn4
	li $v0, 1
	jr $ra
gn4:bne $a0, 4, gn5
	li $v0, 9
	jr $ra
gn5:bne $a0, 2, gn6
	li $v0, 10
	jr $ra
gn6:bne $a0, 1, gn7
	li $v0, 11
	jr $ra
gn7:
	li $v0, -99999
	jr $ra
########################
printArray:

	push($s0)
	push($s1)
	push($s2)
	push($s3)
	move $s3, $a0
	li $s0, 0
	li $s2, 10

pa1:
	add $s3, $s0, $s3
	inc($s0)
	lb $s1, ($s3)
	
	pint($s1)
	pstring(space)
	
	div $s0, $s2
	mfhi $s1
	bnez $s1, pa2
	newline()
pa2:	
	
	blt $s0, 100, pa1

	pop($s3)
	pop($s2)
	pop($s1)
	pop($s0)
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

