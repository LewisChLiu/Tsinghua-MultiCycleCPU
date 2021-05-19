`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Class: Fundamentals of Digital Logic and Processor
// Designer: Shulin Zeng
// 
// Create Date: 2021/04/30
// Design Name: MultiCycleCPU
// Module Name: MultiCycleCPU
// Project Name: Multi-cycle-cpu
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module MultiCycleCPU (reset, clk);
    //Input Clock Signals
    input reset;
    input clk;

    //--------------Your code below-----------------------
	
	// Controller
	wire [5:0] Opcode;
	wire [5:0] Funct;
	wire PCWrite;
	wire PCWriteCond;
	wire IorD;
	wire MemWrite;
	wire MemRead;
	wire IRWrite;
	wire MemtoReg;
	wire [1:0] RegDst;
	wire RegWrite;
	wire ExtOp;
	wire LuiOp;
	wire [1:0] ALUSrcA;
	wire [1:0] ALUSrcB;
	wire [3:0] ALUOp;
	wire [1:0] PCSource;
	wire PCorData;
	wire Err;
	wire ErWrite;
	wire isEIF;
	wire Overflow;
	wire WrE;
	

	
	
	Controller controller(reset, clk, Opcode, Funct, Overflow, PCWrite, PCWriteCond, IorD, MemWrite, MemRead, IRWrite, MemtoReg, RegDst, RegWrite, ExtOp, LuiOp, ALUSrcA, 
						  ALUSrcB, ALUOp, PCSource, PCorData, Err, ErWrite, isEIF, WrE);
	
	// PC
	wire PCWriteAC;
	wire Zero;
	assign PCWriteAC = (Zero & PCWriteCond) | PCWrite;
	wire [31:0] PC_i;
	wire [31:0] PC_o;
	//reg [31:0] jAddr;
	wire [31:0] jAddr;
	//wire [31:0] jAddrOut;
	wire [27:0] shift_2;
	wire [31:0] MDRout;
    wire [31:0] Aout;
    wire [31:0] ALUout;
    wire [31:0] Bout;
    wire [31:0] Result;
	assign PC_i = Err ? (isEIF ? EPC_o : 32'h7c) : (PCSource[1] ? (PCSource[0] ? jAddr : shift_2) : (PCSource[0] ? ALUout : Result)); // PCSource = 10 for shift_2, =01 for ALUout, =00 for Result, =11 for jAddr
	PC pc(reset, clk, PCWriteAC, PC_i, PC_o);
	
	// EPC Register
	wire [31:0] EPC_i;
	wire [31:0] EPC_o;
	wire EPCWriteAC;
	assign EPC_i = PC_o;
	//assign EPCWriteAC = (~Err & PCWriteAC);
	PC epc(reset, clk, Err, EPC_i, EPC_o);
	
	// ALU
	wire [31:0] In1;
	wire [31:0] In2;
	wire [4:0] Shamt;
	wire [31:0] ImmExtOut;
    wire [31:0] ImmExtShift;
    wire Sign;
    wire [4:0] ALUConf;
	assign In1 = ALUSrcA[1] ? {17'b0, Shamt[4:0]} : (ALUSrcA[0] ? Aout[31:0] : PC_o[31:0]); // ALUSrcA = 00 for PC, ALUSrcA = 01 for Aout, ALUSrcA = 10 for Shamt
	assign In2 = ALUSrcB[1] ? (ALUSrcB[0] ? ImmExtShift : ImmExtOut) : (ALUSrcB[0] ? 4 : Bout); // ALUSrcB = 00 for Bout, = 01 for 4, =10 for ImmExtOut, =11 for ImmExtShift 
	ALU alu(ALUConf, Sign, In1, In2, Zero, Result, Overflow);
	
	// ALUControl
	
	
	ALUControl alucontrol(ALUOp, Funct, ALUConf, Sign);
	
	// InstAndDataMemory
	wire [31:0] Address;
	wire [31:0] Write_dataMem;
	wire [31:0] Mem_data;
	assign Address = IorD ? ALUout : PC_o; // IorD = 1 for Data, IorD = 0 for Instruction
	assign Write_dataMem = Bout;
	InstAndDataMemory instanddatamemory(reset, clk, Address, Write_dataMem, MemRead, MemWrite, Mem_data);
	
	// Instruction Register
	wire [4:0] rs;
	wire [4:0] rt;
	wire [4:0] rd;
	
	InstReg instreg(reset, clk, IRWrite, Mem_data, Opcode, rs, rt, rd, Shamt, Funct);
	
	//RegisterFile
	wire [4:0] Write_register;
	wire [31:0] Write_dataReg;
	wire [31:0] Read_data1;
	wire [31:0] Read_data2;
	
	assign Write_register[4:0] = WrE ? Er_o : (RegDst[1] ? 5'b11111 : (RegDst[0] ? rd : rt)); // RegDst = 00 for rt, RegDst = 01 for rd, 10 for $ra, Err = 1 for Er_o
	assign Write_dataReg[31:0] = PCorData ? PC_o : (MemtoReg ? MDRout : ALUout); // MemtoReg = 1 for MDRout, MemtoReg = 0 for ALUout PCorData = 1 for PC, 0 for Data
	RegisterFile registerfile(reset, clk, RegWrite, rs, rt, Write_register, Write_dataReg, Read_data1, Read_data2);
	
	// RegTemps
	
	RegTemp regtempMDR(reset, clk, Mem_data, MDRout);
	
	
	RegTemp regtempA(reset, clk, Read_data1, Aout);
	
	
	RegTemp regtempB(reset, clk, Read_data2, Bout);
	
	
	RegTemp regtempALUout(reset, clk, Result, ALUout);

	// ErrorTarget Register
	wire [4:0] Er_i;
	wire [4:0] Er_o;
	assign Er_i[4:0] = RegDst[0] ? rd : rt;
	ErrorTarget errortarget(reset, clk, ErWrite, Er_i, Er_o);
	
	wire [3:0] PC_H4;
	assign PC_H4 = PC_o[31:28];
	assign jAddr = {PC_H4[3:0], shift_2[27:0]};
	//always @(posedge reset or posedge clk) begin
	//	jAddr <= {PC_H4[3:0], shift_2[27:0]};
	//end
	//RegTemp regtempJAddr(reset, clk, jAddr, jAddrOut);
	// ImmExt
	wire [15:0] Immediate;
	assign Immediate = {rd[4:0], Shamt[4:0], Funct[5:0]};
	ImmProcess immext1(ExtOp, LuiOp, Immediate, ImmExtOut, ImmExtShift);
	
	// Others
	
	assign shift_2 = {rs[4:0], rt[4:0], rd[4:0], Shamt[4:0], Funct[5:0]} << 2;
	
	
	
	
	
	
	
	
    //--------------Your code above-----------------------

endmodule