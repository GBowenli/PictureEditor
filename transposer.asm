.data

#Must use accurate file path.
#file paths in MARS are relative to the mars.jar file.
# if you put mars.jar in the same folder as test2.txt and your.asm, input: should work.
input:	.asciiz "test1.txt"
output:	.asciiz "transposed.pgm"	#used as output
buffer:  .space 2048		# buffer for upto 2048 bytes
newbuff: .space 2048

tempbuff: .space 2048	# temporary buffer for integer versions of array
temptransposedbuff: .space 2048	# temporary buffer for transposed array
errorStatement: .asciiz "ERROR. Program is discontinued."
header: .asciiz "P2\n7 24\n15"

	.text
	.globl main

main:	la $a0,input 		#readfile takes $a0 as input
	jal readfile


	la $a0,tempbuff		#$a0 will specify the "2D array" we will be flipping
	la $a1,temptransposedbuff		#$a1 will specify the buffer that will hold the flipped array.
    	jal transpose


	la $a0, output		#writefile will take $a0 as file location
	la $a1, temptransposedbuff	#$a1 takes location of what we wish to write.
	la $a2, newbuff
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


transpose:	li $t0, 0	# counter
		li $t1, 24	# total number of columns 
		li $t2, 0	# use as temp storage for loaded byte
		
convert:	lb $t2, 0($a0)
		sb $t2, 0($a1)
		lb $t2, 24($a0)	
		sb $t2, 1($a1)
		lb $t2, 48($a0)
		sb $t2, 2($a1)
		lb $t2, 72($a0)
		sb $t2, 3($a1)
		lb $t2, 96($a0)
		sb $t2, 4($a1)
		lb $t2, 120($a0)
		sb $t2, 5($a1)
		lb $t2, 144($a0)
		sb $t2, 6($a1)
		
		addi $a0, $a0, 1
		addi $a1, $a1, 7
				
		addi $t0, $t0, 1
		bne $t0, $t1, convert
		
		jr $ra
#Can assume 24 by 7 again for the input.txt file
#Try to understand the math before coding!

writefile:	move $t0, $a0	# save arguments
		move $t1, $a1
		move $t2, $a2
		
		li $v0, 13	# system call for open file
		li $a1, 1	# flag for writting
		li $a2, 0	# mode is disabled
		syscall
		
		li $t4, -1
		beq $v0, $t4, error # error check
		move $t3, $v0 	# save file descriptor
		
		li $t4, 0	# counter
		li $t5, 168	# total number of bytes to read

formatByte:	li $t7, 7	# divide by 24 to check if need to print new line character
		div $t4, $t7
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
		
		li $v0, 15 	# write the hard coded header
		move $a0, $t3
		la $a1, header 
		li $a2, 10
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
#make sure the header matches the new dimensions

error:  li $v0, 4	# system call for print string
	la $a0, errorStatement
	syscall
	
	li $v0,10		# exit
