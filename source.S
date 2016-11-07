.data
input_chr: .space 2
user_prompt_1: .asciiz "Please enter an integer: \n"
user_prompt_2: .asciiz "\nPlease enter an operator (+, -, *, /): "
user_prompt_3: .asciiz "\nPlease enter an integer: "
error_message: .asciiz "\nError: invalid arithmetic operation "

.text
	main:
		# this is for the first input
		li $v0, 4 
		la $a0, user_prompt_1 # prompt the user for first integer input
		syscall
		li $v0, 5 # takes in input
		syscall
		add $t0, $v0, $0  # $t0 stores the first user input

		# this is for the second input(characters) 
		li $v0, 4
		la $a0, user_prompt_2 # prompt the user for a character input(+, -, *, /)
		syscall
		
		li $v0, 12  # takes in input
		syscall
		move $t1, $v0  # save string to t1

		# this is for the third input 
		li $v0, 4
		la $a0, user_prompt_3 # prompt the user for second integer input
		syscall
		li $v0, 5  # takes in input
		syscall
		add $t2, $v0, $0 # $t2 stores the secont user input

		ori $a0, $t0, 0  # resigning the values to $a registers
		ori $a1, $t1, 0
		ori $a2, $t2, 0

		
		jal do_math  # making a function call(procedur call)


		# ori $v0, $0, 10
		# syscall

	do_math:  # procedure decleration
		addi $sp, $sp, -16
		li $t0, '+'
		li $t1, '-'	
		li $t2, '*'
		li $t3, '/'

		beq $a1, $t0, print_add
		beq $a1, $t1, print_sub
		beq $a1, $t2, multiply

		ori $v0, $zero, 10
		syscall


	print_add:
		jal do_add

		addi $a0, $v0, 0  # move the return value v0 to a0
		li $v0, 1  		#   for printint the value in a0
		syscall			

		ori $v0, $zero, 10
		syscall


	do_add:   # procedure decleration for addition
		sw $ra, 0($sp)  # saving the return address
		loop:
			xor $t0, $a0, $a2  # sum
			and $t1, $a0, $a2 	# carry
			sll $a0, $t1, 1	
			move $a2, $t0
			bne $t1, $zero, loop
		move $v0, $a2
		lw $ra, 0($sp)
		jal $ra	

	
	print_sub:
		jal do_subtract
		addi $a0, $v0, 0  # move the return value v0 to a0
		li $v0, 1  		#   for printint the value in a0
		syscall			

		ori $v0, $zero, 10   # to exit
		syscall

	do_subtract:   # procedure decleration for addition
		# addi $sp, $sp, -8
		sw $ra, 4($sp)  # savig the return address
		not $t0, $a2	  # switch every bit for 2's compliment
		ori $a2, $t0, 0 	# move t0 to a1 (parameter)
		sw $a0, 8($sp)	# move a0 to stack to free a0
		ori $a0, $zero, 1	# move 1 to a0 to add later (a0 parameter)
		jal do_add     # add call to calculat the 2's complement

		lw $a0, 8($sp)     # load the 1st user input back from stack
		ori $a2, $v0, 0		# move the return value(do_add) to a2(parameter)
		jal do_add

		lw $ra, 4($sp)

		jr $ra

	print_mult:
	  # addi $s4, $0, 0 
	  sw $ra, 12($sp)
	  li $v0, 1
	  move $a0, $s4
	  # ori $a0, $v0, 0
	  # ori $v0, $0, 1
	  syscall
	  ori $v0, $0, 10
	  syscall

	multiply:
		ori $t0, $a0, 0 #x
		ori $t1, $a2, 0 #y
		ori $s4, $zero, 0

	while_loop_check:
		bne $t1, $0, do_multiply
		j print_mult

	do_multiply:
	  andi $t2, $t1, 1 #t2 = n & 01
	  beq $t2, $0, shift
	  ori $a0, $s4, 0
	  ori $a2, $t0, 0
	  jal do_add
	  ori $s4, $v0, 0

	shift:
	  sll $t0, $t0, 1
	  srl $t1, $t1, 1
	  j while_loop_check 
