.data
    title_one:     .asciiz "Movie Ticketing System\n"
    line_break:    .asciiz "\n"
    title_prompt:  .asciiz "Enter the ages for each movie goer!\n"
    prompt_age:    .asciiz "Enter the age of the person attending (or -1 to close ticketing): "
    prompt_total:  .asciiz "Total price: $"
    exit_prompt:   .asciiz "Enjoy the show!\n-- program has ended --\n"
    decimal:       .asciiz "."
    ticket_prices: .word 900            # child price
                   .word 1000           # adult price
                   .word 850            # senior price
    total_price:   .word 0              # will store the total price while in the loop
    adult_present: .word 0              # 'adult_present' is acting as a boolean to check if an adult is attending.

.text
.globl main
main:
    
    li $v0, 4
    la $a0, title_one                    # display 'title_one' prompt to user
    syscall

    li $v0, 4
    la $a0, title_prompt
    syscall
	
    li $t3, 0  # initialize $t3 to 0 (no adult present) acting as a boolean, and if adult is added in the loop, then the flag will be updated to avoid overcharging.

    # start of while loop to collect ages of people attending
    loop:
        li $v0, 4
        la $a0, prompt_age                # prompt the user for the age of an individual.
        syscall

        li $v0, 5                         # read the age from user input
        syscall
        move $t0, $v0                     # move integer into #t0.

        li $t1, -1                        # load immediate '-1' into $t1
        beq $t0, $t1, finish_output       # check if user has entered '-1' to exit the loop, and if true branch to 'finish_output'

        # calulation of ticket price
        li $v0, 0
        blt $t0, 18, child_age            # if age is less than 18, branch to child
        blt $t0, 66, adult_age            # if age is less than 66, branch to adult
        j senior_age                      # if user age is above 65, then jump to 'senior_age'

    child_age:
        la $t1, ticket_prices             # load address of 'ticket_prices' array
        lw $t2, 0($t1)                    # load the 'child' price 
        j calculate_total                 # jump to calculation

   adult_age:
        la $t1, ticket_prices            # load address of 'ticket_prices' array
        lw $t2, 4($t1)                   # load adult ticket price
        la $t3, adult_present            # load address of 'adult_present' to update bool flag.
        li $t4, 1                        # make adult_present == true to avoid overcharge.
        sw $t4, 0($t3)                   # store update flag
        j calculate_total                # jump to calculation

  senior_age:
        la $t1, ticket_prices            # load address of 'ticket_prices' array
		    lw $t2, 8($t1)                   # load senior ticket price
		    la $t3, adult_present            # add the adult flag here, since a senior is technically an adult. This is to avoid an extra adult ticket being added, if 2 children and a senior attended.
		    li $t4, 1                        # make adult_present == true to avoid overcharge.
		    sw $t4, 0($t3)                   # store update flag
		    j calculate_total                # jump to calculation

  calculate_total:
        lw $t3, total_price             # load 'total_price' 
        addu $t3, $t3, $t2              # add on new attendee to total price
        sw $t3, total_price             # store new attendee in 'total_price'
        j loop                          # end of loop and jumps back to the top to check for age input or (-1) to exit.

finish_output:
    la $t3, adult_present               # load address of bool 'adult_present' variable.
    lw $t2, 0($t3)                      # load the value
    beqz $t2, add_adult_price           # check if an adult price is equal to 0, if so indicates minors are solo and need an extra adult ticket added and branches to 'add_adult_price'

# print and format the total price
print_price:
	  li $v0, 4
    la $a0, line_break
    syscall

    li $v0, 4
    la $a0, prompt_total
    syscall

    # dollar amount
    li $v0, 1
    lw $a0, total_price               # load total price
    div $a0, $a0, 100                 # divide value by 100, to get dollar amount.
    mflo $a0                          # move result to $lo
    syscall

    
    li $v0, 4
    la $a0, decimal                   # print out decimal point from allocated space in '.data'
    syscall

    # cents amount
    li $v0, 1
    lw $a0, total_price                # load total price
    div $a0, $a0, 100                  # divide by 100, to get cents
    mfhi $a0                           # move remaineder to $hi
    syscall

    li $v0, 4
    la $a0, line_break                 # adds a line break, from allocated space.
    syscall

    # Print exit prompt
    li $v0, 4
    la $a0, exit_prompt                # load exit prompt
    syscall

    # Exit the program
    li $v0, 10                         # syscall to exit program
    syscall

# add adult price function
add_adult_price:
    lw $t3, total_price                # load total price
    li $t2, 1000                       # load immediate ticket price of $10.00 (1000 cents)
    addu $t3, $t3, $t2                 # add $10.00 to total if no adult present
    sw $t3, total_price                # store new total in total price
    j print_price                      # jump to print_price after adding adult ticket price

