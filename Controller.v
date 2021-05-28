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


module Controller(reset, clk, OpCode, Funct, Overflow,  
                PCWrite, PCWriteCond, IorD, MemWrite, MemRead,
                IRWrite, MemtoReg, RegDst, RegWrite, ExtOp, LuiOp,
                ALUSrcA, ALUSrcB, ALUOp, PCSource, PCorData, Err, ErWrite, isEIF, WrE);
    //Input Clock Signals
    input reset;
    input clk;
    //Input Signals
    input  [5:0] OpCode;
    input  [5:0] Funct;
	input Overflow;
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
	output reg Err;
	output reg ErWrite;
	output reg isEIF;
	output reg WrE;
  
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
	parameter ERR = 4'b1010;
	parameter EMP = 4'b1011;
	parameter EWB = 4'b1100;
	parameter TMP = 4'b1101;
	
	//reg [5:0] OpCode_delay;
	//reg [5:0] Funct_delay;
	
	//always @(posedge clk or posedge reset)begin
	//	OpCode_delay <= OpCode;
	//	Funct_delay <= Funct;
	//end

	always @(posedge clk or posedge reset) begin
		if (reset) begin
			SM_State <= IF;
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
							6'h0d:
								begin
									SM_State <= RW;
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
						if (Overflow) begin
							SM_State <= ERR;
						end
						else begin
							SM_State <= IF;
						end
					end
				ERR:
					begin
						SM_State <= IF;
					end
				// EMP:
				// 	begin
				// 		SM_State <= TMP;
				// 	end
				// TMP:
				// 	begin
				// 		SM_State <= ID_RF;
				// 	end
				JC:
					begin
						SM_State <= IF;
					end
				// EWB:
				// 	begin
				// 		SM_State <= IF;
				// 	end
				default:
				    begin
			            SM_State <= IF;
			        end
			endcase
		end
	end
	
	
	
	// Control Logics
	always @(*) begin
	    if (reset) begin
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
                ALUOp[3:0] <= 4'b0000;
                PCSource[1:0] <= 2'b00;
                PCorData <= 0;
                Err <= 0;
                ErWrite <= 0;
                isEIF <= 0;
                WrE <= 0;
       end
       else begin
       // ExtOp and LuiOp
       ExtOp <= (OpCode[5:0] == 6'h0c) ? 0 : 1; // andi
       LuiOp <= (OpCode[5:0] == 6'h0f) ? 1 : 0; // lui
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
					Err <= 0;
					isEIF <= 0;
					WrE <= 0;
					ErWrite <= 0;
					PCSource[1:0] <= 2'b00;
					ALUSrcA[1:0] <= 2'b00;
					ALUSrcB[1:0] <= 2'b01;
					MemtoReg <= 0;
					RegDst[1:0] <= 2'b00;
					PCorData <= 0;
				end
			ID_RF:
				begin
						isEIF <= 0;
						Err <= 0;
						ErWrite <= 0;
						MemRead <= 0;
						IRWrite <= 0;
						PCWrite <= 0;
						PCWriteCond <= 0;
						ALUSrcA[1:0] <= 2'b00;
						ALUSrcB[1:0] <= 2'b11;
						IorD <= 0;
						MemWrite <= 0;
						MemtoReg <= 0;
						RegDst[1:0] <= 2'b00;
						RegWrite <= 0;
						PCSource[1:0] <= 2'b00;
						PCorData <= 0;
						WrE <= 0;

				end
			EXE:
				begin
				    IorD <= 0;
				    MemWrite <= 0;
					MemRead <= 0;
					IRWrite <= 0;
					ErWrite <= 0;
					isEIF <= 0;
					WrE <= 0;
					case(OpCode)
							6'h0f: // lui
								begin
								    PCWriteCond <= 0;
								    PCWrite <= 0;
									ALUSrcA <= 2'b01;
									ALUSrcB <= 2'b10;
									MemtoReg <= 0;
									RegDst[1:0] <= 2'b00;
									RegWrite <= 0;
									PCSource[1:0] <= 2'b00;
									PCorData <= 0;
									Err <= 0;
								end
							6'h08: // addi
								begin
								    PCWrite <= 0;
								    PCWriteCond <= 0;
									ALUSrcA <= 2'b01;
									ALUSrcB <= 2'b10;
									MemtoReg <= 0;
									RegDst[1:0] <= 2'b00;
									RegWrite <= 0;
									PCSource[1:0] <= 2'b00;
									PCorData <= 0;
									Err <= 0;
								end
							6'h09: // addiu, prob exists
								begin
								    PCWrite <= 0;
								    PCWriteCond <= 0;
									ALUSrcA <= 2'b01;
									ALUSrcB <= 2'b10;
									MemtoReg <= 0;
									RegDst[1:0] <= 2'b00;
									RegWrite <= 0;
									PCSource[1:0] <= 2'b00;
									PCorData <= 0;
									Err <= 0;
								end
							6'h0c: // andi
								begin
								    PCWrite <= 0;
								    PCWriteCond <= 0;
									ALUSrcA <= 2'b01;
									ALUSrcB <= 2'b10;
									MemtoReg <= 0;
									RegDst[1:0] <= 2'b00;
									RegWrite <= 0;
									PCSource[1:0] <= 2'b00;
									PCorData <= 0;
									Err <= 0;
								end
							6'h0a: // slti
								begin
								    PCWrite <= 0;
								    PCWriteCond <= 0;
									ALUSrcA <= 2'b01;
									ALUSrcB <= 2'b10;
									MemtoReg <= 0;
									RegDst[1:0] <= 2'b00;
									RegWrite <= 0;
									PCSource[1:0] <= 2'b00;
									PCorData <= 0;
									Err <= 0;
								end
							6'h0b: // sltiu
								begin
								    PCWrite <= 0;
								    PCWriteCond <= 0;
									ALUSrcA <= 2'b01;
									ALUSrcB <= 2'b10;
									MemtoReg <= 0;
									RegDst[1:0] <= 2'b00;
									RegWrite <= 0;
									PCSource[1:0] <= 2'b00;
									PCorData <= 0;
									Err <= 0;
								end
							6'h23:
								begin
								    PCWrite <= 0;
								    PCWriteCond <= 0;
									ALUSrcA <= 2'b01;
									ALUSrcB <= 2'b10;
									MemtoReg <= 0;
									RegDst[1:0] <= 2'b00;
									RegWrite <= 0;
									PCSource[1:0] <= 2'b00;
									PCorData <= 0;
									Err <= 0;
								end
							6'h2b:
								begin
								    PCWrite <= 0;
								    PCWriteCond <= 0;
									ALUSrcA <= 2'b01;
									ALUSrcB <= 2'b10;
									MemtoReg <= 0;
									RegDst[1:0] <= 2'b00;
									RegWrite <= 0;
									PCSource[1:0] <= 2'b00;
									PCorData <= 0;
									Err <= 0;
								end
							6'h04:
								begin
								    PCWrite <= 0;
									PCWriteCond <= 1;
									ALUSrcA <= 2'b01;
									ALUSrcB <= 2'b00;
									PCSource <= 2'b01;
									MemtoReg <= 0;
									RegDst[1:0] <= 2'b00;
									RegWrite <= 0;
									PCorData <= 0;
									Err <= 0;
								end	
							6'h02:
								begin
									PCWrite <= 1;
									PCWriteCond <= 0;
									PCSource[1:0] <= 2'b11;
									MemtoReg <= 0;
									RegDst[1:0] <= 2'b00;
									RegWrite <= 0;
									ALUSrcA[1:0] <= 2'b00;
									ALUSrcB[1:0] <= 2'b00;
									PCorData <= 0;
									Err <= 0;
								end
							6'h03:
								begin
									PCWrite <= 1;
									PCWriteCond <= 0;
									PCSource <= 2'b11;
									RegWrite <= 1;
									RegDst <= 2'b10;
									PCorData <= 1;
									MemtoReg <= 0;
									ALUSrcA[1:0] <= 2'b00;
									ALUSrcB[1:0] <= 2'b00;
									Err <= 0;
								end
							6'h0d:
								begin
								    PCWrite <= 0;
								    PCWriteCond <= 0;
									Err <= 0;
									ALUSrcA <= 01;
									ALUSrcB <= 10;
									MemtoReg <= 0;
									RegDst[1:0] <= 2'b00;
									RegWrite <= 0;
									PCSource[1:0] <= 2'b00;
									PCorData <= 0;
								end
							6'h00:
								begin
								    PCWrite <= 0;
								    PCWriteCond <= 0;
									MemtoReg <= 0;
									RegDst[1:0] <= 2'b00;
									RegWrite <= 0;
									PCSource[1:0] <= 2'b00;
									PCorData <= 0;
									Err <= 0;
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
						  default:
						      begin
						          PCWrite <= 0;
						          PCWriteCond <= 0;
								  MemtoReg <= 0;
								  RegDst[1:0] <= 2'b00;
								  RegWrite <= 0;
								  ALUSrcA[1:0] <= 2'b00;
								  ALUSrcB[1:0] <= 2'b00;
								  PCSource[1:0] <= 2'b00;
								  PCorData <= 0;
								  Err <= 0;
						      end
					endcase
				end
			JC:
				begin
				    IorD <= 0;
				    MemWrite <= 0;
					IRWrite <= 0;
					ALUSrcA[1:0] <= 2'b00;
					ALUSrcB[1:0] <= 2'b00;
					Err <= 0;
					ErWrite <= 0;
					isEIF <= 0;
					WrE <= 0;
					MemRead <= 0;
					case(Funct)
							6'h08: // jr
								begin
									PCWrite <= 1;
									PCSource <= 2'b01;
									PCWriteCond <= 0;
									MemtoReg <= 0;
									RegDst[1:0] <= 2'b00;
									RegWrite <= 0;
									PCorData <= 0;
									//RegWrite <= 1;
									//RegDst <= 2'b10;
									//PCorData <= 1;
									//MemtoReg <= 0;
								end
							6'h09: // jalr
								begin
									PCWrite <= 1;
									PCSource <= 2'b01;
									RegWrite <= 1;
									RegDst <= 2'b01;
									PCorData <= 1;
									MemtoReg <= 0;
									PCWriteCond <= 0;
								end
							default:
							    begin
							         PCWrite <= 0;
							         PCWriteCond <= 0;
									 MemtoReg <= 0;
									 RegDst[1:0] <= 2'b00;
									 RegWrite <= 0;
									 PCSource[1:0] <= 2'b00;
									 PCorData <= 0;
							    end		
					endcase
				end
			RW:
				begin
					RegWrite <= 1;
					PCWriteCond <= 0;
					IorD <= 0;
					MemWrite <= 0;
					MemRead <= 0;
					IRWrite <= 0;
					ALUSrcA[1:0] <= 2'b00;
					ALUSrcB[1:0] <= 2'b00;
					PCSource[1:0] <= 2'b00;
					ErWrite <= 0;
						case(OpCode)
							6'h0f: // lui
								begin
								    PCWrite <= 0;
									RegDst <= 2'b00;
									PCorData <= 0;
									MemtoReg <= 0;
									Err <= 0;
									isEIF <= 0;
									WrE <= 0;
								end
							6'h08: // addi
								begin
								    PCWrite <= 0;
									RegDst <= 2'b00;
									PCorData <= 0;
									MemtoReg <= 0;
									Err <= 0;
									isEIF <= 0;
									WrE <= 0;
								end
							6'h09: // addiu, prob exists
								begin
								    PCWrite <= 0;
									RegDst <= 2'b00;
									PCorData <= 0;
									MemtoReg <= 0;
									Err <= 0;
									isEIF <= 0;
									WrE <= 0;
								end
							6'h0c: // andi
								begin
								    PCWrite <= 0;
									RegDst <= 2'b00;
									PCorData <= 0;
									MemtoReg <= 0;
									Err <= 0;
									isEIF <= 0;
									WrE <= 0;
								end
							6'h0a: // slti
								begin
								    PCWrite <= 0;
									RegDst <= 2'b00;
									PCorData <= 0;
									MemtoReg <= 0;
									Err <= 0;
									isEIF <= 0;
									WrE <= 0;
								end
							6'h0b: // sltiu
								begin
								    PCWrite <= 0;
									RegDst <= 2'b00;
									PCorData <= 0;
									MemtoReg <= 0;
									Err <= 0;
									isEIF <= 0;
									WrE <= 0;
								end
							6'h0d:
								begin
									WrE <= 1;
									PCorData <= 0;
									MemtoReg <= 0;
									Err <= 1;
									isEIF <= 1;
									PCWrite <= 1;
									RegDst[1:0] <= 2'b00;
								end
							default:
								begin
								    PCWrite <= 0;
									RegDst <= 2'b01;
									PCorData <= 0;
									MemtoReg <= 0;
									Err <= 0;
									isEIF <= 0;
									WrE <= 0;
								end
						endcase
				end
			MAR:
				begin
				        PCWrite <= 0;
						MemRead <= 1;
						IorD <= 1;
						PCWriteCond <= 0;
						MemWrite <= 0;
						IRWrite <= 0;
						MemtoReg <= 0;
						RegDst[1:0] <= 2'b00;
						RegWrite <= 0;
						ALUSrcA[1:0] <= 2'b00;
						ALUSrcB[1:0] <= 2'b00;
						PCSource[1:0] <= 2'b00;
						PCorData <= 0;
						Err <= 0;
						ErWrite <= 0;
						isEIF <= 0;
						WrE <= 0;
				end
			RWLW:
				begin
				        PCWrite <= 0;
						MemRead <= 0;
						RegWrite <= 1;
						RegDst <= 2'b00; // write in rt
						PCorData <= 0;
						MemtoReg <= 1;
						PCWriteCond <= 0;
						IorD <= 1;
						MemWrite <= 0;
						IRWrite <= 0;
						ALUSrcA[1:0] <= 2'b00;
						ALUSrcB[1:0] <= 2'b00;
						PCSource[1:0] <= 2'b00;
						Err <= 0;
						ErWrite <= 0;
						isEIF <= 0;
						WrE <= 0;
				end
			MAW:
				begin
				        PCWrite <= 0;
						MemWrite <= 1;
						IorD <= 1;
						PCWriteCond <= 0;
						MemRead <= 0;
						IRWrite <= 0;
						MemtoReg <= 0;
						RegDst[1:0] <= 2'b00;
						RegWrite <= 0;
						ALUSrcA[1:0] <= 2'b00;
						ALUSrcB[1:0] <= 2'b00;
						PCSource[1:0] <= 2'b00;
						PCorData <= 0;
						Err <= 0;
						ErWrite <= 0;
						isEIF <= 0;
						WrE <= 0;
				end
			ERR:
				begin
					Err <= 1;
					PCWrite <= 1;
					ErWrite <= 1;
					isEIF <= 0;
					PCWriteCond <= 0;
					IorD <= 0;
					MemWrite <= 0;
					MemRead <= 0;
					IRWrite <= 0;
					MemtoReg <= 0;
					RegDst[1:0] <= 2'b00;
					RegWrite <= 0;
					ALUSrcA[1:0] <= 2'b00;
					ALUSrcB[1:0] <= 2'b00;
					PCSource[1:0] <= 2'b00;
					PCorData <= 0;
					WrE <= 0;
				end
			default: begin
			     MemWrite <= 0;
                 RegWrite <= 0;
                 IorD <= 0;
                 MemRead <= 1;
                 IRWrite <= 1;
                 PCWrite <= 1;
                 PCWriteCond <= 0;
                 Err <= 0;
                 isEIF <= 0;
                 WrE <= 0;
                 ErWrite <= 0;
                 PCSource[1:0] <= 2'b00;
                 ALUSrcA[1:0] <= 2'b00;
                 ALUSrcB[1:0] <= 2'b01;
				 MemtoReg <= 0;
				 RegDst[1:0] <= 2'b00;
				 PCorData <= 0;
			end
		endcase
		// ALUOp
		ALUOp[3] <= OpCode[0];
                if (SM_State == IF || SM_State == ID_RF) begin
                    ALUOp[2:0] <= 3'b000;
                end else if (OpCode == 6'h00) begin 
                    ALUOp[2:0] <= 3'b010;
                end else if (OpCode == 6'h04) begin
                    ALUOp[2:0] <= 3'b001;
                end else if (OpCode == 6'h0c) begin
                    ALUOp[2:0] <= 3'b100;
                end else if (OpCode == 6'h0a || OpCode == 6'h0b) begin
                    ALUOp[2:0] <= 3'b101;
                end else if (OpCode == 6'h09) begin
                    ALUOp[2:0] <= 3'b011;
                end else begin
                    ALUOp[2:0] <= 3'b000;
	            end
	end

    //--------------Your code above-----------------------



    end

endmodule