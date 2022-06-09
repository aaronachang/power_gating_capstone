`timescale 1ns/10ps

module fw_unit (SourceReg, DestReg1, DestReg2, WrEn1, WrEn2, Fw_SourceReg);
	input  logic [3:0] SourceReg, DestReg1, DestReg2;
	input  logic       WrEn1, WrEn2;
	output logic [1:0] Fw_SourceReg;                        // 00 if no forwarding, 01/11 if 1 cycle, 10 if 2 cycle. Used for mux selection
                                                            // if both DestReg are equal to the source reg, use the most recent result

	assign Fw_SourceReg[0] = (SourceReg == DestReg1) && WrEn1;
	assign Fw_SourceReg[1] = (SourceReg == DestReg2) && WrEn2;
endmodule