`timescale 1ns/10ps
module regfile (rdAddr1, rdAddr2, rdData1, rdData2, rdPC, wrAddr, wrData, wrPC, wrEn, clk, rst);
    input  logic [ 3:0] rdAddr1, rdAddr2, wrAddr;
    input  logic        clk, rst, wrEn;
    input  logic [31:0] wrData, wrPC;
    output logic [31:0] rdData1, rdData2, rdPC;

    // memory array
    logic [15:0][31:0] mem;
    
    // combinational reads
    assign rdData1 = mem[rdAddr1];
    assign rdData2 = mem[rdAddr2];
    always_ff @(posedge clk)
        rdPC <= mem[15];
    
    always_ff @(negedge clk) begin
        if (rst) mem <= '0;
        else begin
            if (wrEn && wrAddr < 15) mem[wrAddr] <= wrData;
            mem[15] <= wrPC;
        end
    end

endmodule
