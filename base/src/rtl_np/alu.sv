`timescale 1ns/10ps
// opcode:
//     000: BYPASSA
//     001: BYPASSB
//     010: ADD
//     011: SUB
//     100: NOT
//     101: AND
//     110: ORR
//     111: XOR

module alu (A, B, ctrl, result, negative, zero, overflow, cout);
    input  logic [31:0] A, B;
    input  logic [ 2:0] ctrl;
    output logic [31:0] result;
    output logic        negative, zero, overflow, cout;
    
    logic [32:0] result_w_cout;

    always_comb begin
        case (ctrl)
            3'd0:    result_w_cout = {1'b0, A};
            3'd1:    result_w_cout = {1'b0, B};
            3'd2:    result_w_cout = A + B;
            3'd3:    result_w_cout = A - B;
            3'd4:    result_w_cout = ~A;
            3'd5:    result_w_cout = A & B;
            3'd6:    result_w_cout = A | B;
            3'd7:    result_w_cout = A ^ B;
            default: result_w_cout = 'x;
        endcase
    end

    logic overflow_add, overflow_sub;
    assign overflow_add = (A[31] == B[31]) && (A[31] != result[31]); 
    assign overflow_sub = (A[31] != B[31]) && (A[31] != result[31]);

    assign result = result_w_cout[31:0];
    assign negative = result[31];
    assign zero     = (result == 0);
    always_comb begin
        case (ctrl)
            3'd2: overflow = overflow_add;
            3'd3: overflow = overflow_sub;
            default: overflow = 1'bx;
        endcase
    end
    assign cout = result_w_cout[32];

endmodule

module alu_testbench();
    logic [31:0] A, B;
    logic [ 2:0] ctrl;
    logic [31:0] result;
    logic        negative, zero, overflow, cout;
    
    alu dut (.*);
    
    initial begin
        A = 32'd1; B = 32'd0; ctrl = 3'b000; #50;
        A = 32'd1; B = 32'd0; ctrl = 3'b001; #50;
        A = 32'd1; B = 32'd0; ctrl = 3'b010; #50;
        A = 32'd1; B = 32'd0; ctrl = 3'b011; #50;
        A = 32'd1; B = 32'd0; ctrl = 3'b100; #50;
        A = 32'd1; B = 32'd0; ctrl = 3'b101; #50;
        A = 32'd1; B = 32'd0; ctrl = 3'b110; #50;
        A = 32'd1; B = 32'd0; ctrl = 3'b111; #50;
    end
endmodule
