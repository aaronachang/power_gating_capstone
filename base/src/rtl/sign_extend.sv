`timescale 1ns/10ps

// parametrized sign extender for immediates
module extend_unit #(parameter WIDTH_I) (in, sign, out);
    input  logic [WIDTH_I-1 :0] in;
    input  logic                sign;
    output logic [31:0]         out;

    assign out[WIDTH_I-1:0] = in;
    assign out[31:WIDTH_I] = sign ? in[WIDTH_I-1] ? '1 : '0 : '0;

endmodule
