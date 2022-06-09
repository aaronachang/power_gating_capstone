00100_000_00000001      // MOVS R0, #1              R0 = 1
010001100_0000_001      // MOV R1, R0               R1 = 1

// --------- R0 = 1, R1 = 1, everything else  = 0 ----------
// Test branch
00100_010_00000110      // MOVS R2, #6              R2 = 6
// TODO: Fix BX to a valid address; fix PC to match testbench
//010001110_0010_000      // BX R2                    PC = R2 (skip next instruction)
//1011111100000000        // NOP
00100_000_00000000      // MOVS R0, #0              R0 = 0, should never happen
11100_00000000011       // B +3 (skip next instruction)
1011111100000000        // NOP
00100_000_00000000      // MOVS R0, #0              R0 = 0, should never happen
0100001010_000_001      // CMP R1, R0
1101_0000_00000011      // B.EQ +3 (skip next instruction)
1011111100000000        // NOP
00100_000_00000000      // MOVS R0, #0              R0 = 0, should never happen
0100010100_000011       // BL +3 (skip next instruction, update link register)
1011111100000000        // NOP
00100_000_00000000      // MOVS R0, #0              R0 = 0, should never happen
00100_011_00000111      // MOVS R3, #7              R3 = 7, success
1011111100000000        // NOP

00100_111_00000111      // MOVS R7, #7              R7 = 7

