`timescale 1ns/10ps

module tb_cpu_top();
    logic clk;
    logic rst;
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
        //$sdf_annotate("./cpu_top.syn.sdf", cpu_top);
        $vcdpluson;
		rst <= 1; repeat(2)   @(posedge clk);
		rst <= 0; repeat(200)  @(posedge clk);
        output_file = $fopen("cpu_output.txt", "a+");
        for (int i = 0; i < 16; i++)
            $fwrite(output_file, "%0d\n", dut.regfile1.mem[i]);
        
        $fclose(output_file);
        $finish;
        $stop;
	end
endmodule
