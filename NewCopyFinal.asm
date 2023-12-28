.data
    title_one:     .asciiz "Movie Ticketing System\n"
    line_break:    .asciiz "\n"
    title_prompt:  .asciiz "Enter the ages for each movie goer!\n"
    prompt_age:    .asciiz "Enter the age of the person attending (or -1 to close ticketing): "
    prompt_total:  .asciiz "Total price: $"
    exit_prompt:   .asciiz "Enjoy the show!\n"
    ticket_prices: .word 900  # Child price
                   .word 1000 # Adult price
                   .word 850  # Senior price
    decimal:       .asciiz "."
    total_price:   .word 0
    adult_present: .word 0

.text
.globl main
main:
    # Display title and information
    li $v0, 4
    la $a0, title_one
    syscall

    li $v0, 4
    la $a0, title_prompt
    syscall
	
    # Initialize loop variables
    li $t3, 0  # Initialize $t3 to 0 (no adult present)

    # Start while loop to collect ages for all attendees
    loop:
        # Prompt for the age of the person attending
        li $v0, 4
        la $a0, prompt_age
        syscall

        # Read the age of the person attending
        li $v0, 5
        syscall
        move $t0, $v0

        # Check if -1 has been entered to stop the loop
        li $t1, -1
        beq $t0, $t1, finish_output

        # Calculate the ticket price based on age
        li $v0, 0
        blt $t0, 18, child_age            # If age is less than 18, treat as child
        blt $t0, 66, adult_age            # If age is less than 66, treat as adult
        j senior_age                      # Otherwise, treat as senior

    child_age:
        la $t1, ticket_prices
        lw $t2, 0($t1)  # Load child ticket price
        j calculate_total

    adult_age:
        la $t1, ticket_prices
        lw $t2, 4($t1)  # Load adult ticket price

        # Indicate an adult ticket has been added to avoid over-adding adult tickets per child
        la $t3, adult_present
        li $t4, 1
        sw $t4, 0($t3)

        j calculate_total

    senior_age:
        la $t1, ticket_prices
	lw $t2, 8($t1)  # Load senior ticket price

	# Same as in adult_age, indicate an adult (or senior) presence
	la $t3, adult_present
	li $t4, 1
	sw $t4, 0($t3)
	j calculate_total

    calculate_total:
        lw $t3, total_price
        addu $t3, $t3, $t2   # Add on new attendee to total price
        sw $t3, total_price
        j loop

finish_output:
    # Check if an adult ticket needs to be added (only if children without adult)
    la $t3, adult_present
    lw $t2, 0($t3)
    beqz $t2, add_adult_price

    # Printing total price logic follows

print_price:

    li $v0, 4
    la $a0, line_break
    syscall

    li $v0, 4
    la $a0, prompt_total
    syscall

    # Print total price in dollars
    li $v0, 1
    lw $a0, total_price
    div $a0, $a0, 100  # Divide by 100 to get dollars
    mflo $a0
    syscall

    # Print decimal point
    li $v0, 4
    la $a0, decimal
    syscall

    # Print cents amount
    li $v0, 1
    lw $a0, total_price
    div $a0, $a0, 100  # Divide by 100 to get cents
    mfhi $a0
    syscall
	
    li $v0, 4
    la $a0, line_break
    syscall

    # Print exit prompt
    li $v0, 4
    la $a0, exit_prompt
    syscall

    # Exit the program
    li $v0, 10
    syscall

add_adult_price:
    # Add the price of an adult ticket
    lw $t3, total_price
    li $t2, 1000  # Adult ticket price is $10.00 (1000 cents)
    addu $t3, $t3, $t2
    sw $t3, total_price
    
    j print_price  # Jump to print_price after adding adult ticket price
