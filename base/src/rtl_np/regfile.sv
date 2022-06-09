`timescale 1ns/10ps
module regfile (rdAddr1, rdAddr2, rdData1, rdData2, rdPC, wrAddr, wrData, wrPC, wrEn, clk, rst);
    input  logic [ 3:0] rdAddr1, rdAddr2, wrAddr;
    input  logic        clk, rst, wrEn;
    input  logic [31:0] wrData, wrPC;
    output logic [31:0] rdData1, rdData2, rdPC;

    // memory array
    logic [15:0][31:0] mem;
    
    // combinational reads on other registers
    assign rdData1 = mem[rdAddr1];
    assign rdData2 = mem[rdAddr2];
    assign rdPC = mem[15];
    
    // writing on negative edge TBD
    always_ff @(posedge clk) begin
        if (rst) mem <= '0;
        else begin
            mem[15] <= wrPC;
            if (wrEn && wrAddr < 15) mem[wrAddr] <= wrData;
        end
    end

endmodule
