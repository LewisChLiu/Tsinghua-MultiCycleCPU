`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Class: Fundamentals of Digital Logic and Processor
// Designer: Shulin Zeng
// 
// Create Date: 2021/04/30
// Design Name: MultiCycleCPU
// Module Name: Controller
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


module Controller(reset, clk, OpCode, Funct, 
                PCWrite, PCWriteCond, IorD, MemWrite, MemRead,
                IRWrite, MemtoReg, RegDst, RegWrite, ExtOp, LuiOp,
                ALUSrcA, ALUSrcB, ALUOp, PCSource, PCorData);
    //Input Clock Signals
    input reset;
    input clk;
    //Input Signals
    input  [5:0] OpCode;
    input  [5:0] Funct;
    //Output Control Signals
    output reg PCWrite;
    output reg PCWriteCond;
    output reg IorD;
    output reg MemWrite;
    output reg MemRead;
    output reg IRWrite;
    output reg MemtoReg;
    output reg [1:0] RegDst;
    output reg RegWrite;
    output reg ExtOp;
    output reg LuiOp;
    output reg [1:0] ALUSrcA;
    output reg [1:0] ALUSrcB;
    output reg [3:0] ALUOp;
    output reg [1:0] PCSource;
	output reg PCorData;
  
    //--------------Your code below-----------------------
    
	reg [3:0] SM_State;
    parameter IF = 4'b0000;
	parameter ID_RF = 4'b0001;
	parameter MADC = 4'b0010;
	parameter MAR = 4'b0011;
	parameter RWLW = 4'b0100;
	parameter MAW = 4'b0101;
	parameter EXE = 4'b0110;
	parameter RW = 4'b0111;
	parameter BC = 4'b1000;
	parameter JC = 4'b1001;
	
	//reg [5:0] OpCode_delay;
	//reg [5:0] Funct_delay;
	
	//always @(posedge clk or posedge reset)begin
	//	OpCode_delay <= OpCode;
	//	Funct_delay <= Funct;
	//end
	
	always @(posedge clk or posedge reset) begin
		if (reset) begin
			SM_State <= IF;
			PCWrite <= 0;
			PCWriteCond <= 0;
			IorD <= 0;
			MemWrite <= 0;
			MemRead <= 0;
			IRWrite <= 0;
			MemtoReg <= 0;
			RegDst[1:0] <= 2'b00;
			RegWrite <= 0;
			ExtOp <= 0;
			LuiOp <= 0;
			ALUSrcA[1:0] <= 2'b00;
			ALUSrcB[1:0] <= 2'b00;
			ALUOp[3:0] <= 2'b0000;
			PCSource[1:0] <= 2'b00;
			PCorData <= 0;
		end
		else begin
			case(SM_State)
				IF:
					begin
						SM_State <= ID_RF;
					end
				ID_RF:
					begin
						SM_State <= EXE;
					end
				MAR:
					begin
						SM_State <= RWLW;
					end
				RWLW:
					begin
						SM_State <= IF;
					end
				MAW:
					begin
						SM_State <= IF;
					end
				EXE:
					begin
						case (OpCode)
							6'h0f: // lui
								begin
									SM_State <= RW;
								end
							6'h08: // addi
								begin
									SM_State <= RW;
								end
							6'h09: // addiu, prob exists
								begin
									SM_State <= RW;
								end
							6'h0c: // andi
								begin
									SM_State <= RW;
								end
							6'h0a: // slti
								begin
									SM_State <= RW;
								end
							6'h0b: // sltiu
								begin
									SM_State <= RW;
								end
							6'h23:
								begin
									SM_State <= MAR;
								end
							6'h2b:
								begin
									SM_State <= MAW;
								end
							6'h04:
								begin
									SM_State <= IF;
								end
							6'h02:
								begin
									SM_State <= IF;
								end
							6'h03:
								begin
									SM_State <= IF;
								end
							6'h04:
								begin
									SM_State <= IF;
								end
							default: // those inst with zero Opcode
								begin
									case(Funct)
										6'h08:
											begin
												SM_State <= JC; // jr
											end
										6'h09:
											begin
												SM_State <= JC; // jalr
											end
										default:
											begin
												SM_State <= RW;
											end
									endcase
								end
						endcase
					end
				RW:
					begin
						SM_State <= IF;
					end
				JC:
					begin
						SM_State <= IF;
					end
			endcase
		end
	end
	
	// ExtOp and LuiOp
	always @(*) begin
		ExtOp = (OpCode == 6'h0b | OpCode == 6'h0c) ? 0 : 1; // andi, sltiu
		LuiOp = (OpCode == 6'h0f) ? 1 : 0; // lui
	end
	
	// Control Logics
	always @(*) begin
		case(SM_State)
			IF:
				begin
					MemWrite <= 0;
					RegWrite <= 0;
					IorD <= 0;
					MemRead <= 1;
					IRWrite <= 1;
					PCWrite <= 1;
					PCWriteCond <= 0;
					PCSource[1:0] <= 2'b00;
					ALUSrcA[1:0] <= 2'b00;
					ALUSrcB[1:0] <= 2'b01;
				end
			ID_RF:
				begin
						MemRead <= 0;
						IRWrite <= 0;
						PCWrite <= 0;
						ALUSrcA[1:0] <= 2'b00;
						ALUSrcB[1:0] <= 2'b11;
				end
			EXE:
				begin
					case(OpCode)
							6'h0f: // lui
								begin
									ALUSrcA <= 2'b01;
									ALUSrcB <= 2'b10;
								end
							6'h08: // addi
								begin
									ALUSrcA <= 2'b01;
									ALUSrcB <= 2'b10;
								end
							6'h09: // addiu, prob exists
								begin
									ALUSrcA <= 2'b01;
									ALUSrcB <= 2'b10;
								end
							6'h0c: // andi
								begin
									ALUSrcA <= 2'b01;
									ALUSrcB <= 2'b10;
								end
							6'h0a: // slti
								begin
									ALUSrcA <= 2'b01;
									ALUSrcB <= 2'b10;
								end
							6'h0b: // sltiu
								begin
									ALUSrcA <= 2'b01;
									ALUSrcB <= 2'b10;
								end
							6'h23:
								begin
									ALUSrcA <= 2'b01;
									ALUSrcB <= 2'b10;		
								end
							6'h2b:
								begin
									ALUSrcA <= 2'b01;
									ALUSrcB <= 2'b10;
								end
							6'h04:
								begin
									PCWriteCond <= 1;
									ALUSrcA <= 2'b01;
									ALUSrcB <= 2'b00;
									PCSource <= 2'b01;
								end	
							6'h02:
								begin
									PCWrite <= 1;
									PCSource[1:0] <= 2'b11;
								end
							6'h03:
								begin
									PCWrite <= 1;
									PCSource <= 2'b11;
									RegWrite <= 1;
									RegDst <= 2'b10;
									PCorData <= 1;
									MemtoReg <= 0;
								end
							6'h00:
								begin
									case(Funct)
										6'h00:
											begin
												ALUSrcA <= 2'b10;
												ALUSrcB <= 2'b00;
											end
										6'h02:
											begin
												ALUSrcA <= 2'b10;
												ALUSrcB <= 2'b00;
											end
										6'h03:
											begin
												ALUSrcA <= 2'b10;
												ALUSrcB <= 2'b00;
											end
										default:
											begin
												ALUSrcA <= 2'b01;
												ALUSrcB <= 2'b00;
											end
									endcase
								end
					endcase
				end
			JC:
				begin
					case(Funct)
							6'h08: // jr
								begin
									PCWrite <= 1;
									PCSource <= 2'b01;
									RegWrite <= 1;
									RegDst <= 2'b10;
									PCorData <= 1;
									MemtoReg <= 0;
								end
							6'h09: // jalr
								begin
									PCWrite <= 1;
									PCSource <= 2'b01;
									RegWrite <= 1;
									RegDst <= 2'b01;
									PCorData <= 1;
									MemtoReg <= 0;
								end
							default:begin
									end		
					endcase
				end
			RW:
				begin
					RegWrite <= 1;
						case(OpCode)
							6'h0f: // lui
								begin
									RegDst <= 2'b00;
									PCorData <= 0;
									MemtoReg <= 0;
								end
							6'h08: // addi
								begin
									RegDst <= 2'b00;
									PCorData <= 0;
									MemtoReg <= 0;
								end
							6'h09: // addiu, prob exists
								begin
									RegDst <= 2'b00;
									PCorData <= 0;
									MemtoReg <= 0;
								end
							6'h0c: // andi
								begin
									RegDst <= 2'b00;
									PCorData <= 0;
									MemtoReg <= 0;
								end
							6'h0a: // slti
								begin
									RegDst <= 2'b00;
									PCorData <= 0;
									MemtoReg <= 0;
								end
							6'h0b: // sltiu
								begin
									RegDst <= 2'b00;
									PCorData <= 0;
									MemtoReg <= 0;
								end
							default:
								begin
									RegDst <= 2'b01;
									PCorData <= 0;
									MemtoReg <= 0;
								end
						endcase
				end
			MAR:
				begin
						MemRead <= 1;
						IorD <= 1;
				end
			RWLW:
				begin
						MemRead <= 0;
						RegWrite <= 1;
						RegDst <= 2'b00; // write in rt
						MemtoReg <= 0;
				end
			MAW:
				begin
						MemWrite <= 1;
						IorD <= 1;
				end
		endcase
	end

    //--------------Your code above-----------------------


    //ALUOp
    always @(*) begin
        ALUOp[3] = OpCode[0];
        if (SM_State == IF || SM_State == ID_RF) begin
            ALUOp[2:0] = 3'b000;
        end else if (OpCode == 6'h00) begin 
            ALUOp[2:0] = 3'b010;
        end else if (OpCode == 6'h04) begin
            ALUOp[2:0] = 3'b001;
        end else if (OpCode == 6'h0c) begin
            ALUOp[2:0] = 3'b100;
        end else if (OpCode == 6'h0a || OpCode == 6'h0b) begin
            ALUOp[2:0] = 3'b101;
        end else begin
            ALUOp[2:0] = 3'b000;
        end
    end

endmodule