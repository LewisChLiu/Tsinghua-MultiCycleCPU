`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Class: Fundamentals of Digital Logic and Processor
// Designer: Shulin Zeng
// 
// Create Date: 2021/04/30
// Design Name: MultiCycleCPU
// Module Name: ALU
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


module ALU(ALUConf, Sign, In1, In2, Zero, Result, Overflow);
    // Control Signals
    input [4:0] ALUConf;
    input Sign;
    // Input Data Signals
    input [31:0] In1;
    input [31:0] In2;
    // Output 
    output Zero;
    output reg [31:0] Result;
	output Overflow;

    //Zero logic
    assign Zero = (Result == 0);

	//Overflow Logic
	assign Overflow = (~(In1[31] ^ In2[31])) & (Result[31] ^ In1[31]) & (ALUConf == 5'b00000);
    //ALU logic
    wire ss;
	assign ss = {In1[31], In2[31]};
	
	wire lt_31;
	assign lt_31 = (In1[30:0] < In2[30:0]);
	
	wire lt_signed;
	assign lt_signed = (In1[31] ^ In2[31])? 
		((ss == 2'b01)? 0: 1): lt_31;

    always @(*) begin
		case (ALUConf)
			5'b00000: Result <= In1 + In2;
			5'b11011: Result <= In1 + In2; // for addiu and addu, overflow will not be detected.
			5'b00001: Result <= In1 | In2;
			5'b00010: Result <= In1 & In2;
			5'b00110: Result <= In1 - In2;
			5'b00111: Result <= {31'h00000000, Sign? lt_signed: (In1 < In2)};
			5'b01100: Result <= ~(In1 | In2);
			5'b01101: Result <= In1 ^ In2;
			5'b10000: Result <= (In2 >> In1[4:0]);
			5'b11000: Result <= ({{32{In2[31]}}, In2} >> In1[4:0]);
            5'b11001: Result <= (In2 << In1[4:0]);
			// my code below
			5'b11010: Result <= In1 & (~In2);
			// my code above
			default: Result <= 32'h00000000;
		endcase
    end

endmodule
