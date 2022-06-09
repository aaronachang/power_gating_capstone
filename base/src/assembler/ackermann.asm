// filename: ackermann.asm
//
// Description: Assembly program that computes the ackermann function

// Start at the main function
    B main

// Compute Ackermann's function recursively
// Constraints
//      - The value on register 0 will be permanently lost after calling this function
// Inputs:
//      - m (stored in memory, at SP-2)
//      - n (stored in memory, at SP-3)
// Outputs:
//      - A(m,n) (stored in SP-1)
ackermann:
    // This function will use registers 1, 2 and 3, so we store their current values on the stack
    SUB SP, SP, #3
    MOV 0, 13   // Copying the SP to register 0
    STR 1, [0, #3]
    STR 2, [0, #2]
    STR 3, [0, #1]
    // Now we load the function inputs to registers 1 and 2
    MOV 0, 13   // Copying the SP to register 0
    LDR 1, [0, #5]  // Storing m in register 1
    LDR 2, [0, #6]  // Storing n in register 2
    // We first check if we don't need to iterate:
    MOVS 3, #0
    CMP 3, 1
    BNE ackermann_m_ne_0    // if m == 0, return n+1
        ADDS 2, 2, #1   // n = n + 1
        STR 2, [0, #4]  // Saving n+1 in the stack, as required
        // Restoring the values in the registers
        LDR 1, [0, #3]  // Restoring register 1
        LDR 2, [0, #2]  // Restoring register 2
        LDR 3, [0, #1]  // Restoring register 3
        ADD SP, SP, #3  // Restoring the SP
        // Returning to the main function
        BX 14
    ackermann_m_ne_0:
    CMP 3, 2
    BNE ackermann_n_ne_0    // If n == 0, return A(m-1,1)
        SUB SP, SP, #4  // We're about to store four elements in the stack
        MOV 0, 13   // Copying the SP to register 0
        MOV 3, 14       // Storing the return address in the stack
        STR 3, [0, #4]
        SUBS 1, 1, #1   // m = m - 1, and we store it in the stack
        STR 1, [0, #2]
        MOVS 1, #1      // Storing 1 in the stack
        STR 1, [0, #3]
        BL ackermann    // Computing A(m-1,1)
        MOV 0, 13       // Restoring register 0 (Copying the SP to register 0)
        LDR 3, [0, #1]  // Store the result in register 3
        STR 3, [0, #8]  // And then, storing the result in its allocated position on the stack
        // Restoring the values in the registers
        LDR 1, [0, #7]  // Restoring register 1
        LDR 2, [0, #6]  // Restoring register 2
        LDR 3, [0, #5]  // Restoring register 3
        LDR 0, [0, #4]  // Restoring the return address in register 0
        ADD SP, SP, #7  // Restoring the SP
        // Returning to the main function
        BX 0
    ackermann_n_ne_0:   // If m != 0 and n != 0, return A( m-1, A(m,n-1) )
        SUB SP, SP, #4  // We're about to store four elements in the stack
        MOV 0, 13       // Copying the SP to register 0
        MOV 3, 14       // Storing the return address in the stack
        STR 3, [0, #4]
        SUBS 2, 2, #1   // n = n - 1, and we store it in the stack
        STR 2, [0, #3]
        STR 1, [0, #2]  // Storing m in the stack
        BL ackermann_aux_call   // Computing A(m,n-1)
        SUB SP, SP, #2  // We're about to store two elements in the stack
        MOV 0, 13       // Restoring register 0 (Copying the SP to register 0)
        SUBS 1, 1, #1   // m = m - 1, and we store it in the stack
        STR 1, [0, #2]
        BL ackermann_aux_call   // Computing A( m-1, A(m,n-1) )
        MOV 0, 13       // Restoring register 0 (Copying the SP to register 0)
        LDR 3, [0, #1]  // Store the result in register 3
        STR 3, [0, #10] // And then, storing the result in its allocated position on the stack
        // Restoring the values in the registers
        LDR 1, [0, #9]  // Restoring register 1
        LDR 2, [0, #8]  // Restoring register 2
        LDR 3, [0, #7]  // Restoring register 3
        LDR 0, [0, #6]  // Restoring the return address in register 0
        ADD SP, SP, #9  // Restoring the SP
        // Returning to the main function
        BX 0
    ackermann_aux_call: // The immediate for some branches exceeds its maximum allowed value, so we need two jumps
        B ackermann

// main function
main:
    SUB SP, SP, #3  // Increment the SP according to Ackermann's function expectations
    MOV 0, 13       // Copying the SP to register 0
    MOVS 1, #3      // m = 3, stored in the stack
    STR 1, [0, #2]
    MOVS 1, #2     // n = 2, stored in the stack
    STR 1, [0, #3]
    BL ackermann_aux_call   // Compute ackermann(m,n). Its value will be stored in [SP-1]
    MOV 0, 13       // Restoring register 0
    LDR 3, [0, #1]  // Store the result in register 3
    ADD SP, SP, #3  // Restoring the SP
    end:
        NOOP
        B end
