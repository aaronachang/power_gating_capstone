`timescale 1ns/10ps
// Shifter for LSL, LSR, ASR, ROR
module shifter (in, op, shAmt, out);
    input  logic [31:0] in, shAmt;
    input  logic [ 1:0] op;     // 00: LSL; 01: LSR; 10: ASR; 11: ROR;
    output logic [31:0] out;
    
    logic [127:0] temp;

    always_comb begin
        case(op)
            2'b00: out = in << shAmt;            // LSL
            2'b01: out = in >> shAmt;            // LSR
            2'b10: out = $signed(in) >>> shAmt;  // ASR, should be synthesizable
            2'b11: begin
                temp = {in, in} >> shAmt;
                out = temp[31:0];                // ROR under the assumption that shAmt <= 64
            end
        endcase
    end
endmodule