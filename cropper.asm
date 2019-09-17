.data

#Must use accurate file path.
#file paths in MARS are relative to the mars.jar file.
# if you put mars.jar in the same folder as test2.txt and your.asm, input: should work.
input:	.asciiz "test1.txt"
output:	.asciiz "cropped.pgm"	#used as output
buffer:  .space 2048		# buffer for upto 2048 bytes
newbuff: .space 2048
x1: .word 1
x2: .word 4
y1: .word 5
y2: .word 20
headerbuff: .space 2048  #stores header

errorStatement: .asciiz "ERROR. Program is discontinued."
tempbuff: .space 2048	# temporary buffer for integer versions of array
tempcroppedbuff: .space 2048
header: .asciiz "P2\n"

	.text
	.globl main

main:	la $a0,input		#readfile takes $a0 as input
	jal readfile


    #load the appropriate values into the appropriate registers/stack positions
    #appropriate stack positions outlined in function*
    	la $a0, x1
    	la $a1, x2
    	la $a2, y1
    	la $a3, y2
    	la $s0, tempbuff
    	la $s1, tempcroppedbuff
	jal crop

	la $a0, output		#writefile will take $a0 as file location
	la $a1,tempcroppedbuff		#$a1 takes location of what we wish to write.
	#add what ever else you may need to make this work.
	la $a2, newbuff
	la $a3, x1
	la $s0, x2
	la $s1, y1
	la $s2, y2
	jal writefile

	li $v0,10		# exit
	syscall

readfile:	li $v0, 13	# system call for open file
		li $a1, 0	# flag for reading
		li $a2, 0	# mode is disabled
		syscall
		
		li $t1, -1
		beq $v0, $t1, error # error check
		move $t0, $v0 	# save file descriptor
		
		li $v0, 14	# system call for read file
		move $a0, $t0	# file descriptor
		la $a1, buffer	# address of buffer from which to read
		li $a2, 1000	# harcoded buffer length
		syscall
		
		li $v0, 16	# close file
		move $a0, $t1
		syscall
		
		li $t1, 168	# total bytes to store
		add $t2, $0, $0	# counter for each byte read
		
		la $t3, buffer	# load address of buffer to t3
		la $t6, tempbuff # load address of newbuff to t6 
		
readByte:	lb $t4, 0($t3)	# load 1 byte to t4 register
		addi $t3, $t3, 1	# advance buffer to next 
		blt $t4, 48, readByte
		lb $t5, 0($t3)	# load 1 byte to t5 register to check if it is 2 digit number
		addi $t3, $t3, 1	# advance buffer to next
		
storeByte:	andi $t4, $t4, 0x0F	# convert t4 to integer
		blt $t5, 48, skipAddition	# if t5 does not hold an integer do not add them together
		andi $t5, $t5, 0x0F	# convert t5 to integer
		li $t7, 10
		mult $t4, $t7	# multiply t4 and t7
		mflo $t4	# set 32 least significant bits to t4
		add $t4, $t4, $t5 
skipAddition:	sb $t4, 0($t6)		# store t4 into newbuff
		addi $t6, $t6, 1	# advance newbuff to next
		
		addi $t2, $t2, 1	# update counter
		bne $t2, $t1, readByte	# exit if looped 168 times
		
		li $v0, 16	# close file
		move $a0, $t0
		syscall
		
		jr $ra
#done in Q1


crop:	lw $t0, 0($a0)
	lw $t1, 0($a1)
	lw $t2, 0($a2)
	lw $t3, 0($a3)

	addi $sp, $sp, -20	# space on stack
	sw $a0, 0($sp)		# save arguments and registers on stack
	sw $a1, 4($sp)
	sw $a2, 8($sp)
	sw $a3, 12($sp)
	sw $s0, 16($sp)
	sw $s1, 20($sp)
	
	li $t4, 0	# use as counter for initial position
	
	beq $t0, $0, skipAddRows
	
addRows:	addi $s0, $s0, 24
		addi $t4, $t4, 1
		bne $t4, $t0, addRows	# keep going to next row 
		
skipAddRows:	add $s0, $s0, $t2	# at starting position

		li $t4, 0		# reset counter for convert (number of elements in one row)
		li $t5, 0		# use this as counter for number of rows
		sub $t6, $t3, $t2	# total # of elements to store in one row
		addi $t6, $t6, 1
		
		sub $t7, $t1, $t0	# total # of rows to loop through 
		addi $t7, $t7, 1	

convert:	lb $t8, 0($s0)		# load a byte in tempbuff and store in t8 register
		sb $t8, 0($s1)		# save byte in tempcroppedbuff
		addi, $s0, $s0, 1	# move pointers to next
		addi, $s1, $s1, 1
		
		addi $t4, $t4, 1
		bne $t4, $t6, convert
		
		li $t4, 0		# reset counter
		
		addi $s0, $s0, 24
		sub $s0, $s0, $t6
		
		addi $t5, $t5, 1
		bne $t5, $t7, convert	# continue converting if not done looping through all requested rows
		
		lw $a0, 0($sp)	# restore registers
		lw $a1, 4($sp)
		lw $a2, 8($sp)
		lw $a3, 12($sp)
		lw $s0, 16($sp)
		lw $s1, 20($sp)
		
		addi $sp, $sp, 20	# restore space on stack
		
		jr $ra
#a0=x1
#a1=x2
#a2=y1
#a3=y2
#16($sp)=buffer
#20($sp)=newbuffer that will be made

writefile:	move $t0, $a0	# save arguments
		move $t1, $a1
		move $t2, $a2
		
		lw $t3, 0($a3)
		lw $t4, 0($s0)
		lw $t5, 0($s1)
		lw $t6, 0($s2)

		addi $sp, $sp, -24	# space on stack
		sw $a0, 0($sp)		# save arguments and registers on stack
		sw $a1, 4($sp)
		sw $a2, 8($sp)
		sw $a3, 12($sp)
		sw $s0, 16($sp)
		sw $s1, 20($sp)
		sw $s2, 24($sp)
		
		li $v0, 13	# system call for open file
		li $a1, 1	# flag for writting
		li $a2, 0	# mode is disabled
		syscall
		
		li $t7, -1
		beq $v0, $t7, error # error check
		move $s0, $v0 	# save file descriptor
		
		li $s1, 0	# counter
		sub $t8, $t6, $t5	# find total # of columns in cropped picture
		addi $t8, $t8, 1
		sub $t9, $t4, $t3	# find total # of rows in cropped picture
		addi $t9, $t9, 1
		mult $t8, $t9
		mflo $s2	# total number of bytes to read
		
formatByte:	div $s1, $t8	# divide by # of columns to check if need to print new line character
		mfhi $s3
		bne $s3, $0, skipNL
		
		li $s3, 10	# store new line character in s3
		sb $s3, 0($t2)		# store new line character in newbuff
		addi $t2, $t2, 1	# advance newbuff to next
		
skipNL:		lb $s4, 0($t1)		# load a byte from tempflippedbuff
		addi $t1, $t1, 1	# advance tempflippedbuff to next
		blt $s4, 10, storeOneInt# if integer is less than 10 skip process of storing 2 integers seperately

storeTwoInt:	li $s3, 49	# store 1 (ascii) in s3 register
		sb $s3, 0($t2)
		addi $t2, $t2, 1
		
		subi $s4, $s4, 10	# subtract by 10 to find the "ones digit"
		ori $s4, $s4, 0x30	# convert to ascii
		
		sb $s4, 0($t2)		# store "ones digit" in newbuff 
		addi $t2, $t2, 1

		j loopend

storeOneInt:	ori $s4, $s4, 0x30	# convert integer to ascii
		sb $s4, 0($t2)		# store converted integer to newbuff
		addi $t2, $t2, 1	# advance newbuff to next
		
loopend:	li $s4, 32	# store space (ascii) in s0 register
		sb $s4, 0($t2)		# store space in newbuff
		addi $t2, $t2, 1	# advance newbuff to next
		
		addi, $s1, $s1, 1	# add one to counter
		bne $s1, $s2, formatByte# check if all bytes are read
		
		la $s5, header		# load address of header
		addi $s5, $s5, 3	# point to next blank space
		li $s6, 20		
		bge $t8, $s6, above20columns	# check if total # of columns is greater than 20, 10, or is a single digit number
		li $s6, 10
		bge $t8, $s6, above10columns
		j onedigitcolumns
		
above20columns:	li $s4, 50		# store 2 in header
		sb $s4, 0($s5)
		addi $s5, $s5, 1	# pointer header to next space
		subi $s4, $t8, 20	# subtract # of columns by 20 to find "ones digit"
		ori $s4, $s4, 0x30	# convert to ascii
		sb $s4, 0($s5)		# store in header
		addi $s5, $s5, 1	
		j continue

above10columns:	li $s4, 49		# store 1 in header
		sb $s4, 0($s5)		
		addi $s5, $s5, 1	# point header to next space
		subi $s4, $t8, 10	# subtract # of columns by 10 to find "ones digit"
		ori $s4, $s4, 0x30	# convert to ascii
		sb $s4, 0($s5)		# store in header
		addi $s5, $s5, 1	
		j continue
		
onedigitcolumns:ori $s4, $t8, 0x30	# convert # of columns to ascii
		sb $s4, 0($s5)		# store in header
		addi $s4, $s4, 1
		
continue:	li $s4, 32		# store space (ascii) in s4 register
		sb $s4, 0($s5)		# store space in header
		ori $s4, $t9, 0x30	# convert # of rows to ascii
		sb $s4, 1($s5)		
		li $s4, 10		# store new line in s4 register
		sb $s4, 2($s5)
		li $s4, 49		# store 1 (ascii) in s4 register 
		sb $s4, 3($s5)
		li $s4, 53		# store 5 (ascii) in s4 register
		sb $s4, 4($s5)
		
		li $v0, 15 	# write the header
		move $a0, $s0
		la $a1, header 
		li $a2, 100
		syscall
		
		li $v0, 15	# write contents of newbuff to output file
		la $a1, newbuff
		li $a2, 1000
		syscall
		
		li $v0, 16	# close file
		move $a0, $s0
		syscall
		
		addi $sp, $sp, 24	# space on stack
		lw $a0, 0($sp)		# save arguments and registers on stack
		lw $a1, 4($sp)
		lw $a2, 8($sp)
		lw $a3, 12($sp)
		lw $s0, 16($sp)
		lw $s1, 20($sp)
		lw $s2, 24($sp)

		jr $ra

error:  li $v0, 4	# system call for print string
	la $a0, errorStatement
	syscall
	
	li $v0,10		# exit
