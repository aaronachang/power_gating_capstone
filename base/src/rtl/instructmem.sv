// Instruction ROM.  Supports reads only, but is initialized based upon the file specified.
// All accesses are 32-bit.  Addresses are byte-addresses, and must be word-aligned (bottom
// two words of the address must be 0).

`timescale 1ns/10ps

`include "cpu_global_define.vh"

// How many bytes are in our memory?  Must be a power of two.
// `define BENCHMARK "test_instr.txt"
`define INSTRUCT_MEM_SIZE		1024
module instructmem (
	input		logic		[31:0]	address,
	output	logic		[15:0]	instruction,
	input		logic					clk	// Memory is combinational, but used for error-checking
	);

	// Force %t's to print in a nice format.
	initial $timeformat(-9, 2, " ns", 10);

	// Make sure size is a power of two and reasonable.
	initial assert((`INSTRUCT_MEM_SIZE & (`INSTRUCT_MEM_SIZE-1)) == 0 && `INSTRUCT_MEM_SIZE > 4);

	// The data storage itself.
	logic [15:0] mem [`INSTRUCT_MEM_SIZE/2-1:0];

	// Load the program - change the filename to pick a different program.
	initial begin
		$readmemb(`BENCHMARK, mem);
		$display("Running benchmark: ", `BENCHMARK);
	end

	// Handle the reads.
	integer i;
	always_comb begin
		if (address >= `INSTRUCT_MEM_SIZE)
			instruction = 'x;
		else
			instruction = mem[address];
	end

endmodule

module instructmem_testbench ();

	parameter ClockDelay = 100;

	logic		[31:0]	address;
	logic					clk;
	logic		[15:0]	instruction;

	instructmem dut (.address, .instruction, .clk);

	initial begin // Set up the clock
		clk <= 0;
		forever #(ClockDelay/2) clk <= ~clk;
	end

	integer i;
	initial begin
		// Read every location, including just past the end of the memory.
		for (i=0; i <= `INSTRUCT_MEM_SIZE; i = i + 1) begin
			address <= i;
			@(posedge clk);
		end
		$stop;

	end
endmodule
