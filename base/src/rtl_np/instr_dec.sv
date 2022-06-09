`timescale 1ns/10ps

module instr_dec (instr, ctrl, cmp, addsub, movbx, zero, negative, overflow);
    input  logic [15:0] instr;
    output logic [18:0] ctrl;                      // packed control signals
    input  logic        zero, negative, overflow;  // flags for conditional branch
    output logic        cmp, addsub, movbx;               // control signal for decoding Rn and Rm
    
    parameter ALUOp = 16'b00xxxxxxxxxxxxxx, // Add, subtract, move, and compare
              DPOp  = 16'b010000xxxxxxxxxx, // Data processing
              SDIOp = 16'b010001xxxxxxxxxx, // Special data instructions and branch and exchange
              LDROp = 16'b01101xxxxxxxxxxx, // Load
              STROp = 16'b01100xxxxxxxxxxx, // Store
              SPOp  = 16'b101100xxxxxxxxxx, // Stack pointer
              CBOp  = 16'b1101xxxxxxxxxxxx, // Conditional branch
              BOp   = 16'b11100xxxxxxxxxxx, // Unconditional branch
              NOp   = 16'b1011111100000000; // Stall

    assign cmp    = (instr[15:10] == 6'b010000) && (instr[9:6] == 4'b1010);                          // set cmp when instruction is CMP
    assign addsub = (instr[15:14] == 2'b00) && (instr[13:9] == 5'b01100 || instr[13:9] == 5'b01101); // set addsub when instruction is ADD or SUB registers
    assign movbx  = (instr[15:10] == 6'b010001) && (instr[9:8] == 2'b10 || instr[9:7] == 3'b110);     // set movbx when instruction is MOV or BX

    always_comb begin
        casex (instr)
            ALUOp: begin
                casex (instr[13:9])
                    5'b01100: ctrl = 19'b111_xx_0_010_0_xx_00x0000; // ADD (reg)
                    5'b01101: ctrl = 19'b111_xx_0_011_0_xx_00x0000; // SUB
                    5'b01110: ctrl = 19'b1x1_00_1_010_0_xx_00x0000; // ADD 3-bit immediate
                    5'b01111: ctrl = 19'b1x1_00_1_011_0_xx_00x0000; // SUB 3-bit immediate
                    5'b100xx: ctrl = 19'bxx1_11_1_001_0_xx_00x0000; // MOV immediate
                    default:  ctrl = 19'bxx0_xx_x_xxx_x_xx_0xx00xx; // NOp
                endcase
            end
            DPOp: begin
                case (instr[9:6])
                    4'b0000: ctrl = 19'b001_xx_0_101_0_xx_00x0000; // Bitwise AND
                    4'b0001: ctrl = 19'b001_xx_0_111_0_xx_00x0000; // Bitwise XOR
                    4'b0010: ctrl = 19'b001_xx_0_xxx_1_00_00x0000; // LSL
                    4'b0011: ctrl = 19'b001_xx_0_xxx_1_01_00x0000; // LSR
                    4'b0100: ctrl = 19'b001_xx_0_xxx_1_10_00x0000; // ASR
                    4'b0111: ctrl = 19'b001_xx_0_xxx_1_11_00x0000; // ROR
                    4'b1010: ctrl = 19'b110_xx_0_011_x_xx_0xx00x0; // CMP
                    4'b1100: ctrl = 19'b001_xx_0_110_0_xx_00x0000; // Bitwise ORR
                    4'b1111: ctrl = 19'b001_xx_0_100_0_xx_00x0000; // Bitwise NOT
                    default: ctrl = 19'bxx0_xx_x_xxx_x_xx_0xx00xx; // NOp
                endcase
            end
            SDIOp: begin
                casex (instr[9:6])
                    4'b10xx: ctrl = 19'b0x1_xx_x_000_0_xx_00x0000; // MOV
                    4'b110x: ctrl = 19'b0x0_xx_x_xxx_x_xx_0xx1xxx; // BX
                    4'b0100: ctrl = 19'bxx1_xx_x_xxx_x_xx_0xx011x; // BL
                    default: ctrl = 19'bxx0_xx_x_xxx_x_xx_0xx00xx; // NOp
                endcase
            end
            LDROp: ctrl = 19'b1x1_01_1_010_0_xx_01x0000; // LDR
            STROp: ctrl = 19'b100_01_1_010_0_xx_1xx00x0; // STR
            SPOp: begin
                case (instr[9:7])
                    3'b000:  ctrl = 19'b1x1_10_1_010_0_xx_00x0001; // ADD SP
                    3'b001:  ctrl = 19'b1x1_10_1_011_0_xx_00x0001; // SUB SP
                    default: ctrl = 19'bxx0_xx_x_xxx_x_xx_0xx00xx; // NOp
                endcase
            end
            CBOp: begin
                ctrl[18:3] = 16'bxx0_xx_x_xxx_x_xx_0x00;
                ctrl[ 1:0] = 2'b00;
                case (instr[11:8]) // See reference manual page 99
                    4'b0000: ctrl[2] = zero;                              // B.EQ
                    4'b0001: ctrl[2] = ~zero;                             // B.NE
                    4'b1010: ctrl[2] = (negative == overflow);            // B.GE
                    4'b1011: ctrl[2] = (negative != overflow);            // B.LT
                    4'b1100: ctrl[2] = ~zero && (negative == overflow);   // B.GT
                    4'b1101: ctrl[2] = zero || (negative != overflow);    // B.LE
                    default: ctrl[2] = 1'b0;
                endcase
            end
            BOp:     ctrl = 19'bxx0_xx_x_xxx_x_xx_0x10100; // B
            NOp:     ctrl = 19'bxx0_xx_x_xxx_x_xx_0xx00xx; // NOp
            default: ctrl = 19'bxx0_xx_x_xxx_x_xx_0xx00xx; // NOp
        endcase
    end
 endmodule
