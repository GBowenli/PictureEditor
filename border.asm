#name: Bowen Li
#studentID: 260787692

.data

#Must use accurate file path.
#file paths in MARS are relative to the mars.jar file.
# if you put mars.jar in the same folder as test2.txt and your.asm, input: should work.
input:	.asciiz "test1.txt"
output:	.asciiz "borded.pgm"	#used as output

borderwidth: .word 2    #specifies border width
buffer:  .space 2048		# buffer for upto 2048 bytes
newbuff: .space 2048
headerbuff: .space 2048  #stores header

#any extra data you specify MUST be after this line 

errorStatement: .asciiz "ERROR. Program is discontinued."
tempbuff: .space 2048	# temporary buffer for integer versions of array
tempbordbuff: .space 2048


	.text
	.globl main

main:	la $a0,input		#readfile takes $a0 as input
	jal readfile


	la $a0,tempbuff		#$a1 will specify the "2D array" we will be flipping
	la $a1,tempbordbuff		#$a2 will specify the buffer that will hold the flipped array.
	la $a2,borderwidth
	jal bord


	la $a0, output		#writefile will take $a0 as file location
	la $a1, tempbordbuff	#$a1 takes location of what we wish to write.
	la $a2, newbuff
	la $a3, borderwidth
	jal writefile

	li $v0,10		# exit
	syscall

readfile:li $v0, 13	# system call for open file
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


bord:	lw $t0, 0($a2)	# load the word from borderwidth
	
	add $t1, $t0, $t0	# calculate length of border (24 + 2 * bordwidth)
	addi $t1, $t1, 24
	mult $t1, $t0		# calculate area of top region of border
	mflo $t1		# store in t1 register
	
	li $t2, 0		# use as counter
	li $t3, 15		# used to store the border (white)
	
drawborder1:	sb $t3, 0($a1)		# store 15 (white) in tempborderbuffer
		addi $a1, $a1, 1	# advance to next character
		
		addi $t2, $t2, 1	# increment pointer
		bne $t2, $t1, drawborder1 	# keep drawing until all characters are drawn
		
		li $t6, 7	# total number of loops
		li $t2, 0	# reset counter
		li $t4, 0	# second counter
		
drawborder2:	sb $t3, 0($a1)	# store 15 (white) in tempborderbuffer
		addi $a1, $a1, 1# advance pointer to next character
		
		addi $t4, $t4, 1
		bne $t4, $t0, drawborder2
		
		li $t4, 0	# reset counter
		li $t8, 24	# total number of loops for loadstorebyte
		
loadstorebyte:	lb $t7, 0($a0)	# load byte from tempbuff and store in tempborderbuff
		sb $t7, 0($a1)
		addi $a0, $a0, 1
		addi $a1, $a1, 1
		
		addi $t4, $t4, 1
		bne $t4, $t8, loadstorebyte
		
		li $t4, 0	# reset counter
		
drawborder3:	sb $t3, 0($a1) # store 15 (white) in tempborderbuffer
		addi $a1, $a1, 1
		
		addi $t4, $t4, 1
		bne $t4, $t0, drawborder3
		
		li $t4, 0	# reset counter
		
		addi $t2, $t2, 1
		bne $t2, $t6, drawborder2
		
		li $t2, 0	# reset counter
		
drawborder4:	sb $t3, 0($a1)		# store 15 (white) in tempborderbuffer
		addi $a1, $a1, 1	# advance to next character
		
		addi $t2, $t2, 1	# increment pointer
		bne $t2, $t1, drawborder4 	# keep drawing until all characters are drawn

		jr $ra
#a0=buffer
#a1=newbuff
#a2=borderwidth
#Can assume 24 by 7 as input
#Try to understand the math before coding!
#EXAMPLE: if borderwidth=2, 24 by 7 becomes 28 by 11.

writefile:	move $t0, $a0	# save arguments
		move $t1, $a1
		move $t2, $a2
		
		lw $s1, 0($a3)
		
		li $v0, 13	# system call for open file
		li $a1, 1	# flag for writting
		li $a2, 0	# mode is disabled
		syscall
		
		li $t4, -1
		beq $v0, $t4, error # error check
		move $t3, $v0 	# save file descriptor
		
		li $t4, 0	# counter
		add $t7, $s1, $s1
		addi $t7, $t7, 24
		add $t5, $s1, $s1
		addi $t5, $t5, 7
		mult $t5, $t7
		mflo $t5	# total number of bytes to read

formatByte:	div $t4, $t7	# divide by 24 + 2 * bordwidth to check if need to print new line character
		mfhi $s0
		bne $s0, $0, skipNL
		
		li $s0, 10	# store new line character in s0 
		sb $s0, 0($t2)		# store new line character in newbuff
		addi $t2, $t2, 1	# advance newbuff to next

skipNL:		lb $t6, 0($t1)		# load a byte from tempflippedbuff
		addi $t1, $t1, 1	# advance tempflippedbuff to next
		blt $t6, 10, storeOneInt# if integer is less than 10 skip process of storing 2 integers seperately
		
storeTwoInt:	li $s0, 49	# store 1 (ascii) in s0 register
		sb $s0, 0($t2)
		addi $t2, $t2, 1
		
		subi $t6, $t6, 10	# subtract by 10 to find the "ones digit"
		ori $t6, $t6, 0x30	# convert to ascii
		
		sb $t6, 0($t2)		# store "ones digit" in newbuff 
		addi $t2, $t2, 1

		j loopend
		
storeOneInt:	ori $t6, $t6, 0x30	# convert integer to ascii
		sb $t6, 0($t2)		# store converted integer to newbuff
		addi $t2, $t2, 1	# advance newbuff to next
				
loopend:	li $s0, 32	# store space (ascii) in s0 register
		sb $s0, 0($t2)		# store space in newbuff
		addi $t2, $t2, 1	# advance newbuff to next
		
		addi, $t4, $t4, 1	# add one to counter
		bne $t4, $t5, formatByte# check if all bytes are read
		
		la $s2, headerbuff
		li $s3, 80	# ascii for P
		sb $s3, 0($s2)
		li $s3, 50	# ascii for 2
		sb $s3, 1($s2)
		li $s3, 10	# ascii for new line
		sb $s3, 2($s2)
		
		div $t7, $s3	# divide by 10
		mfhi $s3	# store remainder as "tens digit"
		mflo $s4	# store quotient as "ones digit"
		
		ori $s3, $s3, 0x30
		ori $s4, $s4, 0x30
		sb $s4, 3($s2)
		sb $s3, 4($s2)
		
		li $s3, 32	# ascii for space
		sb $s3, 5($s2)
		
		addi $s2, $s2, 6	# increase pointer
		
		add $s3, $s1, $s1
		addi $s3, $s3, 7	# calculate total number of rows
		
		li $s4, 10		# check if 1 digit or 2 digit
		blt $s3, $s4, onedigit
		
		div $s3, $s4	# divide by 10
		mfhi $s5	# store remainder as "tens digit"
		mflo $s6	# store quotient as "ones digit"
		
		ori $s5, $s5, 0x30
		ori $s6, $s6, 0x30
		sb $s6, 0($s2)
		sb $s5, 1($s2)
		
		addi $s2, $s2, 2
		
		j continue
		
onedigit:	ori $s3, 0x30
		sb $s3, 0($s2)
		addi $s3, $s3, 1
		
continue:	li $s3, 10	# ascii for new line
		sb $s3, 0($s2)	
		li $s3, 49	# ascii for 1
		sb $s3, 1($s2)
		li $s3, 53	# ascii for 5
		sb $s3, 2($s2)
		
		li $v0, 15 	# write the hard coded header
		move $a0, $t3
		la $a1, headerbuff 
		li $a2, 100
		syscall
		
		li $v0, 15	# write contents of newbuff to output file
		la $a1, newbuff
		li $a2, 1000
		syscall
		
		li $v0, 16	# close file
		move $a0, $t3
		syscall
		
		jr $ra
#slightly different from Q1.
#use as many arguments as you would like to get this to work.
#make sure the header matches the new dimensions!

error:  li $v0, 4	# system call for print string
	la $a0, errorStatement
	syscall
	
	li $v0,10		# exit
