##############################################################
# Homework #3
# name: MY_NAME
# sbuid: MY_SBU_ID
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
buffer: .ascii ""

#place any additional data declarations here

