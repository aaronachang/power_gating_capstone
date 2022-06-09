module cpu_top (
    input  logic clk,
    input  logic rst,
    // imem interface
    output logic [31:0] imem_addr,
    input  logic [15:0] imem_data,
    // dmem interface 
    output logic [31:0] dmem_addr,
    output logic        dmem_wren,
    output logic        dmem_rden,
    output logic [31:0] dmem_wrdata,
    input  logic [31:0] dmem_rddata
);
    
    // control signals
    logic [18:0] packed_ctrl;
    logic Reg1Loc,
          Reg2Loc,
          RegWrite,
          ALUSrc,
          Shift,
          MemWrite,
          MemToReg,
          UncondBr,
          BX,
          BrTaken,
          BL,
          SP;

    logic [ 1:0] ImmSel, ShiftOp;
    logic [ 2:0] ALUOp;
    
    // packed control signal assignment
    assign Reg1Loc  = packed_ctrl[18];
    assign Reg2Loc  = packed_ctrl[17];
    assign RegWrite = packed_ctrl[16];
    assign ImmSel   = packed_ctrl[15:14];
    assign ALUSrc   = packed_ctrl[13];
    assign ALUOp    = packed_ctrl[12:10];
    assign Shift    = packed_ctrl[9];
    assign ShiftOp  = packed_ctrl[8:7];
    assign MemWrite = packed_ctrl[6];
    assign MemToReg = packed_ctrl[5];
    assign UncondBr = packed_ctrl[4];
    assign BX       = packed_ctrl[3];
    assign BrTaken  = packed_ctrl[2];
    assign BL       = packed_ctrl[1];
    assign SP       = packed_ctrl[0];

    logic [15:0] instr;                                // current instruction 
    logic [ 3:0] Rd, Rn, Rm;
    logic        dec_cmp, dec_addsub, dec_movbx;       // extra control signals from instr_dec to select Rm and Rn locations
    assign Rd = (instr[15:11] == 5'b00100) ? {1'b0, instr[10:8]} : {1'b0, instr[2:0]};      // Rd = instr[10:8] for MOVS instruction
    assign Rn = dec_cmp ? {1'b0, instr[2:0]} : {1'b0, instr[5:3]};
    assign Rm = (~dec_movbx) ? dec_addsub ? {1'b0, instr[8:6]} : {1'b0, instr[5:3]} : instr[6:3];

    // immediates and extend units
    logic [ 2:0] Imm3;
    logic [ 4:0] Imm5;
    logic [ 5:0] Imm6;
    logic [ 6:0] Imm7;
    logic [ 7:0] Imm8;
    logic [10:0] Imm11;
    assign Imm3 = instr[8:6];
    assign Imm5 = instr[10:6];
    assign Imm6 = instr[5:0];
    assign Imm7 = instr[6:0];
    assign Imm8 = instr[7:0];
    assign Imm11 = instr[10:0];

    logic [31:0] Imm3_extended, Imm5_extended, Imm6_extended,
                 Imm7_extended, Imm8_extendedz, Imm8_extendeds, Imm11_extended; // Imm8 needs both signed and zero extension
    extend_unit #(3)  extend_imm3 (.in(Imm3), .sign(1'b0), .out(Imm3_extended));
    extend_unit #(5)  extend_imm5 (.in(Imm5), .sign(1'b0), .out(Imm5_extended));
    extend_unit #(6)  extend_imm6 (.in(Imm6), .sign(1'b1), .out(Imm6_extended));
    extend_unit #(7)  extend_imm7 (.in(Imm7), .sign(1'b0), .out(Imm7_extended));
    extend_unit #(8)  extend_imm8z (.in(Imm8), .sign(1'b0), .out(Imm8_extendedz));
    extend_unit #(8)  extend_imm8s (.in(Imm8), .sign(1'b1), .out(Imm8_extendeds));
    extend_unit #(11) extend_imm11 (.in(Imm11), .sign(1'b1), .out(Imm11_extended));
    

    // Instruction Fetch, branching logic
    logic [31:0] Imm_br, PC_nextval, reg_D1, PC_val;
    assign Imm_br = (~BL) ? UncondBr ? Imm11_extended : Imm8_extendeds : Imm6_extended;
    assign PC_nextval = (~BX) ? BrTaken ? (PC_val + Imm_br) : (PC_val + 1) : reg_D1;
    
    // imem interface
    assign imem_addr  = PC_val;
    assign instr = imem_data;
    
    // flag register, need to be improved for pipelined CPU
    logic alu_negative, alu_zero, alu_overflow, alu_cout;
    logic negative_reg, zero_reg, overflow_reg, cout_reg;
    always_ff @(posedge clk) begin
        negative_reg <= alu_negative;
        zero_reg     <= alu_zero;
        overflow_reg <= alu_overflow;
        cout_reg     <= alu_cout;
    end

    // Instruction decoding
    logic [20:0] packed_ctrl;
    instr_dec instr_dec1 (
        .instr,
        .ctrl     (packed_ctrl),
        .cmp      (dec_cmp),
        .addsub   (dec_addsub),
        .movbx    (dec_movbx),
        .zero     (zero_reg),
        .negative (negative_reg),
        .overflow (overflow_reg)
    );

    // Regfile
    logic [ 3:0] rdAddr1, rdAddr2, wrAddr;
    logic        wrEn;
    logic [31:0] reg_D2, reg_wrData; 
    
    assign rdAddr1 = Reg1Loc ? SP ? 4'd13 : Rn : Rm;
    assign rdAddr2 = Reg2Loc ? Rm : Rd;
    assign wrAddr  = (~BL) ? SP ? 4'd13 : Rd : 4'd14;

    regfile regfile1(
        .rdAddr1,
        .rdAddr2,
        .rdData1(reg_D1),
        .rdData2(reg_D2),
        .rdPC   (PC_val),         // dedicated read port for program counter
        .wrAddr,
        .wrData (reg_wrData),
        .wrPC   (PC_nextval),     // dedicated write port for program counter        
        .wrEn   (RegWrite),
        .clk,
        .rst
    );
    
    // ALU and shifter
    logic [31:0] Imm_ex;
    always_comb begin
        case (ImmSel)
            2'b00: Imm_ex = Imm3_extended;
            2'b01: Imm_ex = Imm5_extended;
            2'b10: Imm_ex = Imm7_extended;
            2'b11: Imm_ex = Imm8_extendedz;
        endcase
    end
    
    logic [31:0] alu_out;
    alu alu1(
        .A       (reg_D1),
        .B       (ALUSrc ? Imm_ex : reg_D2),
        .ctrl    (ALUOp),
        .result  (alu_out),
        .negative(alu_negative),                 // TODO: add flag registers
        .zero    (alu_zero),
        .overflow(alu_overflow),
        .cout    (alu_cout)
    );
    
    logic [31:0] shifter_out;

    shifter shifter1(
        .in   (reg_D2),
        .op   (ShiftOp),
        .shAmt(reg_D1),
        .out  (shifter_out)
    );
    
    logic [31:0] ex_out;
    assign ex_out = Shift ? shifter_out : alu_out;  // output of the execute stage

    // Dmem interface
    logic [31:0] mem_Data;
    assign dmem_addr  = ex_out;
    assign dmem_wren = MemWrite;
    assign dmem_rden = MemToReg ;
    assign dmem_wrdata = reg_D2;
    assign mem_Data = dmem_rddata; 

    // write back
    assign reg_wrData = (~BL) ? MemToReg ? mem_Data : ex_out : (PC_val + 1);
endmodule

module cpu_top_testbench();
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
        $vcdpluson;
		rst <= 1; repeat(2)   @(posedge clk);
		rst <= 0; repeat(200)  @(posedge clk);
        output_file = $fopen("cpu_output.txt", "a+");
        for (int i = 0; i < 16; i++)
            $fwrite(output_file, "%0d\n", dut.regfile1.mem[i]);
        $fclose(output_file);
        $finish;
	end
endmodule
