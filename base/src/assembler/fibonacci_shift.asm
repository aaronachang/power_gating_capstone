// filename: fibonacci.asm
//
// Description: Assembly program that computes the first 10 fibonacci numbers

// Start at the main function
    B main
    NOOP

// Compute a fibonacci number (F_n), given the previous two (F_{n-1} and F_{n-2})
// That is, F_n = F_{n-1} + F_{n-2}
// Inputs:
//      - Register 0: F_{n-1}
//      - Register 1: F_{n-2}
// Outputs:
//      - Register 2: F_n
fibonacci:
    ADDS 2, 0, 1     // F_n = F_{n-1} + F_{n-2}
    LSLS 5, 5, 6    // R5 = R5 << R6 (R6 is always equal to 1)
    BX 14           // return
    NOOP

// main function
main:
    MOVS 0, #1      // F_1 = 1
    MOVS 1, #1      // F_2 = 1
    MOVS 5, #1      // R5 = 1, for shifter operations
    MOVS 6, #1      // R6 = 1, for shifter operations
    // for loop to compute the next 8 fibonacci numbers:
    MOVS 3, #0      // i = 0
    MOVS 4, #30      // i_max = 30
    for_fibonacci:
        CMP 3, 4
        BGT end_for_fibonacci   // If i >= i_max, exit the for loop
        NOOP
        BL fibonacci    // Call the fibonacci function. F_{3+i} will be stored in register 2
        NOOP
        MOV 0, 1        // Move the two most recently computed fibonacci numbers to registers 0 and 1
        MOV 1, 2
        ADDS 3, 3, #1   // i = i + 1
        B for_fibonacci
        NOOP
    end_for_fibonacci:
    MOV 3, 2    // Copy the result to register 3
    
    MOVS 7, #7  // end of program indicator
