.data

#Must use accurate file path.
#file paths in MARS are relative to the mars.jar file.
# if you put mars.jar in the same folder as test2.txt and your.asm, input: should work.
input:	.asciiz "test1.txt" #used as input
output:	.asciiz "copy.pgm"	#used as output

errorStatement: .asciiz "ERROR. Program is discontinued."
header: .asciiz "P2\n24 7\n15\n"

buffer:  .space 2048		# buffer for upto 2048 bytes

	.text
	.globl main

main:	la $a0,input		#readfile takes $a0 as input
	jal readfile

	la $a0, output		#writefile will take $a0 as file location
	la $a1,buffer		#$a1 takes location of what we wish to write.
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
		
		la $v1, buffer # save address of buffer in v1
		
		li $v0, 4	# output content of buffer
		la $a0, buffer
		syscall
		
		li $v0, 16	# close file
		move $a0, $t0
		syscall
		
		jr $ra
		
#Open the file to be read,using $a0
#Conduct error check, to see if file exists

# read from file
# use correct file descriptor, and point to buffer
# hardcode maximum number of chars to read
# read from file

# address of the ascii string you just read is returned in $v1.
# the text of the string is in buffer
# close the file (make sure to check for errors)


writefile:	li $v0, 13	# system call for open file
		li $a1, 1	# flag for writting
		li $a2, 0	# mode is disabled
		syscall
		
		li $t1, -1
		beq $v0, $t1, error # error check
		move $t0, $v0 	# save file descriptor
		
		li $v0, 15 	# write the hard coded header
		move $a0, $t0
		la $a1, header 
		li $a2, 11
		syscall
		
		li $v0, 15	# write contents of buffer to output file
		la $a1, buffer
		li $a2, 1000
		syscall
		
		li $v0, 16	# close file
		move $a0, $t0
		syscall
		
		jr $ra
#open file to be written to, using $a0.
#write the specified characters:
#P2
#24 7
#15
#write the content stored at the address in $a1.
#close the file (make sure to check for errors)


error:  li $v0, 4	# system call for print string
	la $a0, errorStatement
	syscall
	
	li $v0,10		# exit
	syscall
