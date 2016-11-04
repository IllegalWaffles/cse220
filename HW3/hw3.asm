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
	inc($t0)
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

	lb $t8, ($t6)
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
			ori $t3, $t3, 0xF8
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
	inc($t6)			# Then increment the bomb counter for this cell
	
	j loop3
loop3exit:	
	
	# $t6 now has the number of bombs adjacent to the thing
	lb $t3, ($t2)
	or $t3, $t3, $t6
	
	#pint($t3)
	#pstring(space)

	sb $t3, ($t2)

	inc($t1)
	blt $t1, 10, loopb	# Close inner loop

	#newline()

	inc($t0)
	blt $t0, 10, loopa	# Close outer loop

	li $t0, 0
	li $t1, 0
	
	sw $t0, cursor_row	
	sw $t1, cursor_col

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
	push($s4)
	move $s3, $a0
	li $s0, 0
	li $s2, 10

pa1:
	add $s4, $s0, $s3
	inc($s0)
	lb $s1, ($s4)
	
	pint($s1)
	pstring(space)
	
	div $s0, $s2
	mfhi $s1
	bnez $s1, pa2
	newline()
pa2:	
	
	blt $s0, 100, pa1

	pop($s4)
	pop($s3)
	pop($s2)
	pop($s1)
	pop($s0)
	jr $ra

##############################
# PART 3 FUNCTIONS
##############################

init_display:
    
    li $t0, 0xFFFF0000	# Base MMIO addr
    li $t1, 0			# Counter
    
    # Build gray square
    li $t2, 0x77
    sll $t2, $t2, 8
    ori $t2, $t2, '\0'
    
initloop:
	add $t3, $t0, $t1
	sh $t2, ($t3)
	addi $t1, $t1, 2
	ble $t1, 198, initloop
    
    lw $t3, cursor_row
    lw $t4, cursor_col
    
    li $t2, 20
    
    mult $t3, $t2
    mflo $t2			# (row * 20)
    sll $t4, $t4, 1		# (col * 2)
    add $t2, $t2, $t4	# (row * 20) + (col * 2)
    addu $t0, $t0, $t2	# addr + above offset
    
    li $t3, 0xB0		# Set yellow background
    sll $t3, $t3, 8		# Shift it over
    lh $t1, ($t0)		# Load the current configuration
    andi $t1, $t1, 0xFF
    or $t1, $t1, $t3	# Set the yellow background
    sh $t1, ($t0)		# Store the tile back
    
    jr $ra
############################################
set_cell:
    
    # $t0 - row
    # $t1 - col
    # $t2 - ch (char)
    # $t3 - foreground half-byte
    # $t4 - background half-byte
    
    move $t1, $a0
    move $t0, $a1
    move $t2, $a2
    move $t3, $a3
    lw $t4, -4($sp)
    
    bltz  $t0, setcellfail
    bgt $t0, 9, setcellfail
    
    bltz $t1, setcellfail
    bgt $t1, 9, setcellfail
    
    bltz $t3, setcellfail
    bgt $t3, 15, setcellfail
    
    bltz $t4, setcellfail
    bgt $t4, 15, setcellfail
    
    # Make sure our fg and bg are exactly 4 bits each, and the char is 1 byte
    andi $t3, $t3, 0xF
    andi $t4, $t4, 0xF
    andi $t2, $t2, 0xFF
    
    sll $t4, $t4, 4		# Shift the bg over 4 bits
    or $t4, $t4, $t3	# Place fg in the 4 bit space
    sll $t4, $t4, 8		# Shift everything over by a byte to make room for the char
    or $t4, $t4, $t2	# Add the char byte to our value above
    
    li $t5, 0xFFFF0000	# Base MMIO address
    li $t6, 20
    
    # Calculate address here, store in $t5
    mult $t0, $t6
    mflo $t0			# (row * 20)
    sll $t1, $t1, 1		# (col * 2)
    add $t0, $t0, $t1	# (row * 20) + (col * 2)
    addu $t5, $t5, $t0	# addr + above offset
    
    sh $t4, ($t5)
    
    li $v0, 0
    jr $ra

setcellfail:

	li $v0, -1
	jr $ra
############################
reveal_map:
    
    push($ra)
    push($s0)
    push($s1)
    push($s2)
    push($s3)
    push($s4)
    push($s5)
    push($s6)
    push($s7)
    
    move $s0, $a1	# pointer to byte array
    move $a0, $a0	# Game state
    
	# s1 - col
	# s2 - row
    # s3 - counter
    # s4 - byte data
    # s5 - flagged
    # s6 - bomb
    # s7 - number of adjacent bombs
    
    beq $a0, 1, revealwon
    beq $a0, -1, reveallost
    
    beqz $a0, exitrevealmap
    
revealwon:
	jal smiley
	j exitrevealmap
    
reveallost:
	
	li $s3, 0			# Counter (offset)
	li $t9, 10

	revealloop1:
	addu $s4, $s3, $s0		# Calculate the address
	lb $s4, ($s4)			# $s4 contains that tile's data
	
	# Calculate column and row
	div $s3, $t9
	mfhi $s2				# Row
	mflo $s1				# Col

	# Code to test flags
	
	#bne $s2, 6, skipflag
	#ori $s4, $s4, 0x10
#skipflag:
	
	andi $s5, $s4, 16		# $s5 contains if it is flagged
	srl $s5, $s5, 4
	andi $s6, $s4, 32		# $s6 contains if it is a bomb
	srl $s6, $s6, 5			
	andi $s7, $s4, 0xF 		# $s7 contains the number of surrounding bombs
							# First check if it is flagged
	beqz $s5, revealmapbomb
		and $t0, $s6, $s5	# If its a correct flag
		beqz $t0, incorrectflag	# Write correct flag
			#sh $s5, ($t6)
			move $a0, $s2
			move $a1, $s1
			li $a2, 'f'
			li $a3, 0xC
			li $t8, 0xA
			push($t8)
			jal set_cell
			pop($t8)
			j finishtile
		incorrectflag:		# If its an incorrect flag
			#sh $s4, ($t6)	# Write incorrect flag
			move $a0, $s2
			move $a1, $s1
			li $a2, 'f'
			li $a3, 0xC
			li $t8, 0x9
			push($t8)
			jal set_cell
			pop($t8)
			j finishtile	
	revealmapbomb:			# Else, check if it is a bomb
	beqz $s6, revealmapnumber
		#sh $s1, ($t6)
		move $a0, $s2
		move $a1, $s1
		li $a2, 'b'
		li $a3, 0x7
		li $t8, 0x0
		push($t8)
		jal set_cell
		pop($t8)
		j finishtile
	revealmapnumber:		# Else, check how many bombs are nearby
		blez $s7, revealmapempty	# If > 0, write that number to the cell
		# sh $s3, ($t6)
		move $a0, $s2
		move $a1, $s1
		addi $a2, $s7, '0'
		li $a3, 0xD
		li $t8, 0x0
		push($t8)
		jal set_cell
		pop($t8)
		j finishtile
	revealmapempty:			# If == 0, it must be an empty cell
		#sh $s6, ($t6)
		move $a0, $s2
		move $a1, $s1
		li $a2, '\0'
		li $a3, 0xF
		li $t8, 0x0
		push($t8)
		jal set_cell
		pop($t8)
	finishtile:
	
	inc($s3)
	blt $s3, 100, revealloop1
	
	lw $a0, cursor_col				# Overwrite cursor to red explodey thing
	lw $a1, cursor_row
	li $a2, 'e'
	li $a3, 0xF
	li $t0, 0x9
	push($t0)
	jal set_cell
	pop($t0)
	
	#li $s3, 0x9F
    #ori $s3, $s3, 'e'
	
	j exitrevealmap

exitrevealmap:
    pop($s7)
    pop($s6)
    pop($s5)
    pop($s4)
    pop($s3)
    pop($s2)
    pop($s1)
    pop($s0)
    pop($ra)
    
    jr $ra

##############################
# PART 4 FUNCTIONS
##############################

perform_action:

	# s0 = byte array
    # s1 = char
    # s2 = cursor row
    # s3 = cursor column
    # s4 = MMIO address at the cursor
    # s5 = 1-byte address at the cursor
    
    push($ra)
	push($s0)
	push($s1)
	push($s2)
	push($s3)
	push($s4)
	push($s5)
	
	move $s0, $a0
	move $s1, $a1
	ori $s1, $s1, 0x20		# Set all the chars to lowercase
	
	lb $s2, cursor_row
	lb $s3, cursor_col
	
	move $a0, $s2
	move $a1, $s3
	jal get1byteOffset
	addu $s5, $v0, $s0		# $s5 holds the 1-byte address
	
	move $a0, $s2
	move $a1, $s3
	jal get2byteOffset		
	addiu $s4, $v0, 0xFFFF0000# $s4 holds the 2-byte address	
	
	#lb $t0, ($s5)
	#pbin($t0)
	#newline()
	
	# Handle key presses:
	# w,a,s,d
	# f - flag
	# r - reveal
	
	bne $s1, 'w', actiona
		blez $s2, action_do_nothing	# Check if this move is possible
		
		addi $t9, $s4, -20
		lh $t0, ($t9)
		andi $t0, $t0, 0xFFF	# Mask for only the char and the fg color
		li $t1, 0xB000				# Load yellow
		or $t0, $t0, $t1		# Add the two values
		sh $t0, ($t9)			# Set the new cursor's background

		lb $t0, cursor_row
		addi $t0, $t0, -1
		sb $t0, cursor_row		# Dec the cursor row stored in mem

		# Now replace the old cursor spot
		lb $t0, ($s5)
		andi $t1, $t0, 64		# $t1 has if it is revealed
		beqz $t1, action_notrevealed
		j action_revealed
		
actiona:
	bne $s1, 'a', actions
		blez $s3, action_do_nothing # Check if this move is possible
		
		addi $t9, $s4, -2
		lh $t0, ($t9)
		andi $t0, $t0, 0xFFF	# Mask for only the char and the fg color
		li $t1, 0xB000				# Load yellow
		or $t0, $t0, $t1		# Add the two values
		sh $t0, ($t9)			# Set the new cursor's background

		lb $t0, cursor_col
		addi $t0, $t0, -1
		sb $t0, cursor_col		# Dec the cursor row stored in mem
	
		# Now replace the old cursor spot
		lb $t0, ($s5)
		andi $t1, $t0, 64		# $t1 has if it is revealed
		beqz $t1, action_notrevealed
		j action_revealed
		
actions:
	bne $s1, 's', actiond
		bge $s2, 9, action_do_nothing # Check if this move is possible
		
		# s0 = byte array
    	# s1 = char
    	# s2 = cursor row
    	# s3 = cursor column
    	# s4 = MMIO address at the cursor
    	# s5 = 1-byte address at the cursor
		
		addi $t9, $s4, 20
		lh $t0, ($t9)
		andi $t0, $t0, 0xFFF	# Mask for only the char and the fg color
		li $t1, 0xB000				# Load yellow
		or $t0, $t0, $t1		# Add the two values
		sh $t0, ($t9)			# Set the new cursor's background

		lb $t0, cursor_row
		addi $t0, $t0, 1
		sb $t0, cursor_row		# Inc the cursor row stored in mem

		# Now replace the old cursor spot
		lb $t0, ($s5)
		andi $t1, $t0, 64	# $t1 has if it is revealed
		beqz $t1, action_notrevealed
		j action_revealed
		
actiond:
	bne $s1, 'd', actionf
		bge $s3, 9, action_do_nothing # Check if this move is possible
		
		addi $t9, $s4, 2
		lh $t0, ($t9)
		andi $t0, $t0, 0xFFF	# Mask for only the char and the fg color
		li $t1, 0xB000				# Load yellow
		or $t0, $t0, $t1		# Add the two values
		sh $t0, ($t9)			# Set the new cursor's background

		# Update coordinates
		lb $t0, cursor_col
		addi $t0, $t0, 1
		sb $t0, cursor_col		# Inc the cursor row stored in mem	

		# Now replace the old cursor spot
		lb $t0, ($s5)
		andi $t1, $t0, 64		# $t1 has if it is revealed
		beqz $t1, action_notrevealed
		j action_revealed

action_revealed:
	
		lh $t0, ($s4)
		andi $t0, $t0, 0xFFF	# Mask for the first 12 bits
		sh $t0, ($s4)
	
	j action_return
	
action_notrevealed:	# If it is not revealed:
	
		lh $t0, ($s4)
		andi $t0, $t0, 0xFFF	# Mask for the first 12 bits
		li $t1, 0x7000
		or $t0, $t0, $t1
		sh $t0, ($s4)
		
	j action_return
	
	
actionf:
	bne $s1, 'f', actionr
	
	lb $t0, ($s5)

	andi $t1, $t0, 64				# do nothing if it is already revealed
	bnez $t1, action_do_nothing

	# Flip the bit we must flip
	xori $t0, $t0, 16	# Flip this bit
	sb $t0, ($s5)		# Save the new value
	
	lh $t3, ($s4)
	andi $t3, $t3, 0xF000

	andi $t2, $t0, 16	# Save the new flag value
	beqz $t2, actionf_writenull # If it is zero, write a null as the character

actionf_writeflag:				# Otherwise, put a flag there
	ori $t3, $t3, 'f'
	ori $t3, $t3, 0x400
	sh $t3, ($s4)
	j action_return

actionf_writenull:
	ori $t3, $t3, '\0'
	ori $t3, $t3, 0x700
	sh $t3, ($s4)
	j action_return
	
actionr:
	bne $s1, 'r', action_do_nothing
	
	jal search_cells
	
	lb $t0, ($s5)
	andi $t1, $t0, 64
	bnez $t1, action_do_nothing	# Branch if it is already revealed

	ori $t0, $t0, 64 	# Its not revealed. Set it to revealed
	andi $t0, $t0, 0x6f	# Remove the flag, if any
	sb $t0, ($s5)		# Save it into memory

	andi $t1, $t0, 32
	beqz $t1, actionr_notbomb
	# Its a bomb! Fuck!
	li $t1, 'b'
	ori $t1, $t1, 0xb500
	sh $t1, ($s4)
	j action_return
actionr_notbomb: # Its not a bomb

	# Check number of adjacent bombs
	andi $t1, $t0, 0xF
	bnez $t1, actionr_numtile
actionr_emptytile:

	li $t2, 0xb000
	ori $t2, $t2, '\0'
	sh $t2, ($s4)

	j action_return
actionr_numtile:
	li $t2, 0xb500
	addi $t1, $t1, '0'
	or $t2, $t2, $t1
	sh $t2, ($s4)

	j action_return
	
action_return:

	pop($s5)
	pop($s4)
	pop($s3)
	pop($s2)
	pop($s1)
	pop($s0)
	pop($ra)
	li $v0, 0
	jr $ra

action_do_nothing:
	
	pop($s5)
	pop($s4)
	pop($s3)
	pop($s2)
	pop($s1)
	pop($s0)
	pop($ra)
	li $v0, -1
    jr $ra
#############################3
game_status:

	move $t0, $a0	# $t0 stores the base address
	li $t1, 0		# $t1 is our counter
	li $t6, 0		# $t6 is our incorrect bonb counter

	statusloop:

	add $t2, $t0, $t1
	inc($t1)
	lb $t2, ($t2)	# $t2 contains the data for the current tile
	# $t3 contains if it is a bomb
	andi $t3, $t2, 32
	srl $t3, $t3, 5
	# $t4 contains if it is revealed
	andi $t4, $t2, 64
	srl $t4, $t4, 6
	# $t5 contains if it is flagged
	andi $t5, $t2, 16
	srl $t5, $t5, 4
	# if there is a revealed bomb, branch immediately to fail.
	# xor the bomb and flag bits, add to a counter
	# if the counter ends up being zero, each bomb was correctly flagged
	
	and $t7, $t3, $t4
	bnez $t7, game_status_lose

	xor $t7, $t5, $t3	# iff one value is true
	add $t6, $t6, $t7

	blt $t1, 100, statusloop
	
	bnez $t6, game_status_ongoing
	
game_status_win:

	li $v0, 1
    jr $ra

game_status_ongoing:

	li $v0, 0
	jr $ra

game_status_lose:
	
	li $v0, -1
	jr $ra



##############################
get2byteOffset:
	# $a0 has the row
	# $a1 has the col
	li $t0, 20		
	mult $t0, $a0		# Row * 20
	mflo $t0		
	
	sll $a1, $a1, 1		# Col * 2
	add $v0, $t0, $a1	# (Row * 20) + (col * 2)
	
	jr $ra
##############################
get1byteOffset:
	# $a0 has the row
	# $a1 has the col
	li $t0, 10
	mult $t0, $a0
	mflo $t0
	
	add $v0, $t0, $a1	
	
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
dash: .asciiz "_"

buffer: .ascii ""

#place any additional data declarations here

