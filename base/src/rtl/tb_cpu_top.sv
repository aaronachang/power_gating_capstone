`timescale 1ns/10ps

module cpu_top_testbench();
    logic clk;
    logic rst;
    logic activate; //power gating
    // imem interface
    logic [31:0] imem_addr;
    logic [15:0] imem_data;
    // dmem interface 
    logic [31:0] dmem_addr;
    logic        dmem_wren;
    logic        dmem_rden;
    logic [31:0] dmem_wrdata;
    logic [31:0] dmem_rddata;
    
    cpu_top dut (.*);
    
    instructmem imem (
        .address    (imem_addr),
        .instruction(imem_data),
        .clk
    );
    
    datamem dmem (
        .address     (dmem_addr),
        .write_enable(dmem_wren),
        .read_enable (dmem_rden),
        .write_data  (dmem_wrdata),
        .clk,
        .xfer_size   (4'd4),
        .read_data   (dmem_rddata)   
    );
    
    initial begin // Set up the clock
		clk <= 0;
		forever #(50) clk <= ~clk;
	end
		
    int output_file;

	initial begin
        $vcdpluson;
		rst <= 1; repeat(2)   @(posedge clk);
        activate <= 1;
		rst <= 0;
        @(posedge clk);
        while (imem_data != 16'b0010011100000111)
            @(posedge clk);
        repeat(4) @(posedge clk);
        output_file = $fopen("cpu_output.txt", "a+");
        for (int i = 0; i < 16; i++)
            $fwrite(output_file, "%0d\n", dut.regfile1.mem[i]);
        
        $fclose(output_file);
        $finish;
        $stop;
	end
endmodule
