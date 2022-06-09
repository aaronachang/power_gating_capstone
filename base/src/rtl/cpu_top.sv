`timescale 1ns/10ps

module cpu_top (
    input  logic clk,
    input  logic rst,
    input  logic activate, // power gating
    input  logic isolate,
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
   
    // output isolation control
    // logic isolate;
    // assign isolate = ~activate;

    // control signals
    logic [18:0] packed_ctrl;
    logic Reg1Loc, Reg2Loc, UncondBr, BX, BrTaken, SP;     // RD control
    logic [ 1:0] ImmSel;                                   // RD control
    logic [ 1:0][ 2:0] ALUOp;                              // EX control
    logic [ 1:0][ 1:0] ShiftOp;                            // EX control
    logic [ 1:0]       Shift;                              // EX control
    logic [ 1:0]       ALUSrc;                             // EX control
    logic [ 2:0]       MemWrite, MemToReg, BL;             // MEM control
    logic [ 3:0]       RegWrite;                           // WB control
    // control signal pipelining registers
    always_ff @(posedge clk) begin
        ALUOp[1] <= rst ? '0 : ALUOp[0];
        ShiftOp[1] <= rst ? '0 : ShiftOp[0];
        Shift[1] <= rst ? '0 : Shift[0];
        ALUSrc[1] <= rst ? '0 : ALUSrc[0];
        
        MemWrite[2] <= rst ? '0 : MemWrite[1];
        MemWrite[1] <= rst ? '0 : MemWrite[0];
        MemToReg[2] <= rst ? '0 : MemToReg[1];
        MemToReg[1] <= rst ? '0 : MemToReg[0];
        BL[2] <= rst ? '0 : BL[1];
        BL[1] <= rst ? '0 : BL[0];
        
        RegWrite[3] <= rst ? '0 : RegWrite[2];
        RegWrite[2] <= rst ? '0 : RegWrite[1];
        RegWrite[1] <= rst ? '0 : RegWrite[0];
    end
      
    // packed control signal assignment
    assign Reg1Loc     = packed_ctrl[18];
    assign Reg2Loc     = packed_ctrl[17];
    assign RegWrite[0] = packed_ctrl[16];
    assign ImmSel      = packed_ctrl[15:14];
    assign ALUSrc[0]   = packed_ctrl[13];
    assign ALUOp[0]    = packed_ctrl[12:10];
    assign Shift[0]    = packed_ctrl[9];
    assign ShiftOp[0]  = packed_ctrl[8:7];
    assign MemWrite[0] = packed_ctrl[6];
    assign MemToReg[0] = packed_ctrl[5];
    assign UncondBr    = packed_ctrl[4];
    assign BX          = packed_ctrl[3];
    assign BrTaken     = packed_ctrl[2];
    assign BL[0]       = packed_ctrl[1];
    assign SP          = packed_ctrl[0];

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
    
    
    //----------------------------------------------------------------------
    // IF stage
    //----------------------------------------------------------------------
    // Instruction Fetch, branching logic
    logic [31:0] Imm_br, PC_nextval, reg_D1, PC_val, PC_prevval;
    always_ff @(posedge clk) 
        PC_prevval <= PC_val;                                   // keep previous value of PC to calculate branch destination
    logic [2:0][31:0] PCplusone;                                // Pipelined all the way to mem stage for BL instruction
    always_ff @(posedge clk) begin
        PCplusone[1] <= rst ? '0 : PCplusone[0];
        PCplusone[2] <= rst ? '0 : PCplusone[1];
    end
    assign PCplusone[0] = PC_val + 1;
    assign Imm_br = (~BL[0]) ? UncondBr ? Imm11_extended : Imm8_extendeds : Imm6_extended;
    logic [31:0] reg_D1_RD;                                    // forwarded value of rdData1
    assign PC_nextval = (~BX) ? BrTaken ? (PC_prevval + Imm_br) : (PC_val + 1) : reg_D1_RD;
    
    // imem interface
    assign imem_addr  = PC_val;
    logic [15:0] instr_IF;
    assign instr_IF = imem_data;
    
    // flag registers
    logic alu_negative, alu_zero, alu_overflow, alu_cout;
    logic negative_reg, zero_reg, overflow_reg, cout_reg;
    logic [1:0][3:0] ctrl_flags;
    always_ff @(posedge clk)
        ctrl_flags[1] <= rst ? '0 : ctrl_flags[0];
    always_ff @(posedge clk) begin
        negative_reg <= (~rst) ? ctrl_flags[1][3] ? alu_negative : negative_reg : '0 ;
        zero_reg     <= (~rst) ? ctrl_flags[1][2] ? alu_zero : zero_reg : '0 ;
        cout_reg     <= (~rst) ? ctrl_flags[1][1] ? alu_cout : cout_reg : '0 ;
        overflow_reg <= (~rst) ? ctrl_flags[1][0] ? alu_overflow : overflow_reg : '0 ;
    end
    
    // IF to RD stage registers 
    logic [15:0] instr_RD;
    always_ff @(posedge clk)
        instr_RD <= rst ? '0 : instr_IF;
    
    //----------------------------------------------------------------------
    // RD stage
    //----------------------------------------------------------------------
    // Instruction decoding
    assign instr = instr_RD;
    instr_dec instr_dec1 (
        .instr,
        .ctrl       (packed_ctrl),
        .cmp        (dec_cmp),
        .addsub     (dec_addsub),
        .movbx      (dec_movbx),
        .zero       (ctrl_flags[1] == 4'b0000 ? zero_reg : alu_zero),
        .negative   (ctrl_flags[1] == 4'b0000 ? negative_reg : alu_negative),
        .overflow   (ctrl_flags[1] == 4'b0000 ? overflow_reg : alu_overflow),
        .carry      (ctrl_flags[1] == 4'b0000 ? cout_reg : alu_cout),           // use ALU flags to resolve branches if prev. instruction update flags
        .ctrl_flags (ctrl_flags[0])
    );

    // Regfile
    logic [ 3:0] rdAddr1, rdAddr2;
    logic [ 3:0][ 3:0] wrAddr;
    logic [31:0] reg_D2, reg_wrData; 
    
    assign rdAddr1 = Reg1Loc ? SP ? 4'd13 : Rn : Rm;
    assign rdAddr2 = Reg2Loc ? Rm : Rd;
    assign wrAddr[0]  = (~BL[0]) ? SP ? 4'd13 : Rd : 4'd14;
    // pipelining wrAddr
    always_ff @(posedge clk) begin
        wrAddr[1] <= rst ? '0 : wrAddr[0];
        wrAddr[2] <= rst ? '0 : wrAddr[1];
        wrAddr[3] <= rst ? '0 : wrAddr[2];
    end

    regfile regfile1(
        .rdAddr1,
        .rdAddr2,
        .rdData1(reg_D1),
        .rdData2(reg_D2),
        .rdPC   (PC_val),         // dedicated read port for program counter
        .wrAddr (wrAddr[3]),
        .wrData (reg_wrData),
        .wrPC   (PC_nextval),     // dedicated write port for program counter        
        .wrEn   (RegWrite[3]),
        .clk,
        .rst
    );
    // Immediates
    logic [31:0] Imm_RD, Imm_EX;
    always_comb begin
        case (ImmSel)
            2'b00: Imm_RD = Imm3_extended;
            2'b01: Imm_RD = Imm5_extended;
            2'b10: Imm_RD = Imm7_extended;
            2'b11: Imm_RD = Imm8_extendedz;
        endcase
    end
    
    // RD to EX registers
    logic [31:0] reg_D1_EX, reg_D2_RD, reg_D2_EX, reg_D2_MEM;
    // forwarding control units for the two ALU operands
    logic [1:0] fwSel1, fwSel2;
    fw_unit fw_unit1 (
        .SourceReg(rdAddr1),
        .DestReg1(wrAddr[1]),
        .DestReg2(wrAddr[2]),
        .WrEn1(RegWrite[1]),
        .WrEn2(RegWrite[2]), 
        .Fw_SourceReg(fwSel1)
    );
    fw_unit fw_unit2 (
        .SourceReg(rdAddr2),
        .DestReg1(wrAddr[1]),
        .DestReg2(wrAddr[2]),
        .WrEn1(RegWrite[1]),
        .WrEn2(RegWrite[2]), 
        .Fw_SourceReg(fwSel2)
    );
	
    //forwarding muxes
    logic [31:0] ex_out_EX, mem_out_MEM;
    always_comb begin
        case (fwSel1)
            2'b00: reg_D1_RD = reg_D1;
            2'b01: reg_D1_RD = ex_out_EX;
            2'b10: reg_D1_RD = mem_out_MEM;
            2'b11: reg_D1_RD = ex_out_EX;
        endcase
        case (fwSel2)
            2'b00: reg_D2_RD = reg_D2;
            2'b01: reg_D2_RD = ex_out_EX;
            2'b10: reg_D2_RD = mem_out_MEM;
            2'b11: reg_D2_RD = ex_out_EX;
        endcase
    end
    always_ff @(posedge clk) begin
        reg_D1_EX <= rst ? '0 : reg_D1_RD;
        reg_D2_EX <= rst ? '0 : reg_D2_RD;
        Imm_EX    <= rst ? '0 : Imm_RD;
    end
    
     //----------------------------------------------------------------------
    // EX stage
    //----------------------------------------------------------------------
    // ALU and shifter
    logic [31:0] op1, op2;
    assign op1 = reg_D1_EX;
    assign op2 = ALUSrc[1] ? Imm_EX : reg_D2_EX;
    logic [31:0] alu_out;
    alu alu1(
        .A       (op1),
        .B       (op2),
        .ctrl    (ALUOp[1]),
        .result  (alu_out),
        .negative(alu_negative),                 // TODO: add flag registers
        .zero    (alu_zero),
        .overflow(alu_overflow),
        .cout    (alu_cout)
    );
    
    logic [31:0] shifter_out;
    shifter shifter1(
        .in   (reg_D2_EX),
        .op   (ShiftOp[1]),
        .shAmt(reg_D1_EX),
        .out  (shifter_out)
    );
    
    logic [31:0] ex_out_MEM;
    assign ex_out_EX = Shift[1] ? shifter_out : alu_out;  // output of the execute alu 
    
    // EX to MEM registers 
    always_ff @(posedge clk) begin
        ex_out_MEM <= rst ? '0 : ex_out_EX;
        reg_D2_MEM <= rst ? '0 : reg_D2_EX;
    end
    
    //----------------------------------------------------------------------
    // MEM stage
    //----------------------------------------------------------------------
    // forwarding unit to obtain data from WB stage 
    assign dmem_wrdata = ((wrAddr[3] == wrAddr[2]) && (RegWrite[3] == 1'b1)) ? reg_wrData : reg_D2_MEM;
    
    // Dmem interface
    logic [31:0] mem_Data, mem_out_WB;
    assign dmem_addr  = ex_out_MEM;
    assign dmem_wren = MemWrite[2];
    assign dmem_rden = MemToReg[2];
    assign mem_Data = dmem_rddata; 
    assign mem_out_MEM = (~BL[2]) ? MemToReg[2] ? mem_Data : ex_out_MEM : PCplusone[2];
    
    always_ff @(posedge clk)
        mem_out_WB <= rst ? '0 : mem_out_MEM;
    //----------------------------------------------------------------------
    // WB stage
    //----------------------------------------------------------------------
    assign reg_wrData = mem_out_WB;
endmodule
