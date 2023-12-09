# Caesar Cipher
# By Team Fireflies
# Names: Ian Chow, Demetrio Herrera, Andrew Lee, Samuel Nunez
#
# This program aims to encrypt and decrypt messages using the famous Caesar Cipher
#
# 1. Asks whether the user wishes to encrypt or decrypt a message
# 2. Takes in a input for the message and the shift amount
# 3. Shifts the message and prints it out to the user
# 4. Asks if they wish to go again

.macro printstr(%s)
	li $v0, 4
	.data
	tempStr: .asciiz %s
	.text
	la $a0, tempStr
	syscall
.end_macro

# int is stored in v0
.macro getint
	li $v0, 5
	syscall
.end_macro

# string is stored in buffer
.macro getstr
	li $v0, 8
	la $a0, buffer
	li $a1, 64
	syscall
.end_macro

.data
	buffer: .space 64
.text
main:
	# print intro
	printstr "Welcome to the Caesar Cipher!\n" # macro
	j choice_loop

choice_loop:
	printstr "Please select what you would like to do:\n1. Encrypt\n2. Decrypt\n3. Exit\nPlease enter a number: "
	# get choice
	getint
	
	# branch on choice
	beq $v0, 1, encrypt
	beq $v0, 2, decrypt
	beq $v0, 3, exit
	
	# invalid choice handler
	printstr "Not a valid choice"
	j choice_loop

print_result:
	# print result string
	printstr "The result of your shift is: "
	# print word
	li $v0, 4
	la $a0, buffer
	syscall
	j another_loop

another_loop:
	printstr "Would you like to go again?:\n1. Yes\n2. No (exit)\nPlease enter a number: "
	# get choice
	getint
	
	# branch on choice
	beq $v0, 1, choice_loop
	beq $v0, 2, exit
	
	# invalid choice handler
	printstr "Not a valid choice"
	j another_loop
	
encrypt:
	# print encrypt prompt
	printstr "Please enter the word you would like to encrypt: "
	# read string w/ 64 byte buffer
	getstr
	# print shift prompt
	printstr "Please enter the shift: "
	# read shift
	getint
	
	# init	
	la $s0, buffer # s0 holds message
	move $s1, $v0 # s1 holds shift
	li $t0, 0 # counter in t0
	j encrypt_loop

encrypt_loop:
	add $t1, $s0, $t0 # t1 holds char address
	lb $t2, ($t1) # t2 holds char
	beq $t2, $zero, print_result # if char 0 branch (null terminator)
	
	# encrypt based on upper char or lower char
	bge $t2, 97, encrypt_lower
	bge $t2, 65, encrypt_upper
	# else skip, ignore invalid char
	j encrypt_skip

encrypt_lower:
	bgt $t2, 122, encrypt_skip # if not between 'a' and 'z'
	subi $t2, $t2, 97 # between 0 and 25
	add $t2, $t2, $s1 # add shift
	rem $t2, $t2, 26 # wrap char if above 25
	addi $t2, $t2, 97 # move it back to between 'a' and 'z'
	sb $t2, ($t1) # store byte
	j encrypt_skip

encrypt_upper:
	bgt $t2, 90, encrypt_skip # if not between 'A' and 'Z'
	subi $t2, $t2, 65 # between 0 and 25
	add $t2, $t2, $s1 # add shift
	rem $t2, $t2, 26 # wrap char if above 25
	addi $t2, $t2, 65 # move it back to between 'A' and 'Z'
	sb $t2, ($t1) # store byte
	j encrypt_skip

encrypt_skip:
	addi $t0, $t0, 1 # inc counter
	j encrypt_loop

decrypt:
	# print encrypt prompt
	printstr "Please enter the ciphertext you would like to decrypt: "
	# read string w/ 64 byte buf and move to s0
	getstr
	# print shift prompt
	printstr "Please enter the shift: "
	# read shift
	getint

	# init	
	la $s0, buffer # s0 holds message
	move $s1, $v0 # s1 holds shift
	li $t0, 0 # counter in t0
	j decrypt_loop

decrypt_loop:
	add $t1, $s0, $t0 # t1 holds char address
	lb $t2, ($t1) # t2 holds char
	beq $t2, $zero, print_result # if char 0 branch (null terminator)
	
	# decrypt based on upper char or lower char
	bge $t2, 97, decrypt_lower
	bge $t2, 65, decrypt_upper
	# else skip, ignore invalid char
	j decrypt_skip

decrypt_lower:
	bgt $t2, 122, decrypt_skip # if not between 'a' and 'z'
	subi $t2, $t2, 71 # between 26 and 51 (to prevent negative numbers)
	sub $t2, $t2, $s1 # remove shift
	rem $t2, $t2, 26 # wrap char if below 26 and move between 0 and 25
	addi $t2, $t2, 97 # move it back to between 'a' and 'z'
	sb $t2, ($t1) # store byte
	j decrypt_skip

decrypt_upper:
	bgt $t2, 90, decrypt_skip # if not between 'A' and 'Z'
	subi $t2, $t2, 39 # between 26 and 51
	sub $t2, $t2, $s1 # remove shift
	rem $t2, $t2, 26 # wrap char if below 26 and move between 0 and 25
	addi $t2, $t2, 65 # move it back to between 'A' and 'Z'
	sb $t2, ($t1) # store byte
	j decrypt_skip

decrypt_skip:
	addi $t0, $t0, 1 # inc counter
	j decrypt_loop

exit:
	# exit
	li $v0, 10
	syscall