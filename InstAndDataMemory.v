`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Class: Fundamentals of Digital Logic and Processor
// Designer: Shulin Zeng
// 
// Create Date: 2021/04/30
// Design Name: MultiCycleCPU
// Module Name: InstAndDataMemory
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


module InstAndDataMemory(reset, clk, Address, Write_data, MemRead, MemWrite, Mem_data);
	//Input Clock Signals
	input reset;
	input clk;
	//Input Data Signals
	input [31:0] Address;
	input [31:0] Write_data;
	//Input Control Signals
	input MemRead;
	input MemWrite;
	//Output Data
	output [31:0] Mem_data;
	
	parameter RAM_SIZE = 256;
	parameter RAM_SIZE_BIT = 8;
	parameter RAM_INST_SIZE = 32;
	
	reg [31:0] RAM_data[RAM_SIZE - 1: 0];

	//read data
	assign Mem_data = MemRead? RAM_data[Address[RAM_SIZE_BIT + 1:2]]: 32'h00000000;
	
	initial begin
	   // // addi $a0, $zero, 5
                     RAM_data[8'd0] <= {6'h08, 5'd0, 5'd4, 16'h0005};
                // // xor $v0, $zero, $zero
                     RAM_data[8'd1] <= {6'h00, 5'd0, 5'd0, 5'd2, 5'd0, 6'h26};
                // // jal sum
                     RAM_data[8'd2] <= {6'h03, 26'd4};
                // // Loop:
                // // beq $zero, $zero, Loop
                     RAM_data[8'd3] <= {6'h04, 5'd00, 5'd00, 16'hffff};
                // // sum:
                // // addi $sp, $sp, -8
                     RAM_data[8'd4] <= {6'h08, 5'd29, 5'd29, 16'hfff8};
                // // sw $ra, 4($sp)
                     RAM_data[8'd5] <= {6'h2b, 5'd29, 5'd31, 16'h0004};
                // // sw $a0, 0($sp)
                     RAM_data[8'd6] <= {6'h2b, 5'd29, 5'd04, 16'h0000};
                // // slti $t0, $a0, 1
                     RAM_data[8'd7] <= {6'h0a, 5'd04, 5'd08, 16'h0001};
                // // beq $t0, $zero, L1
                     RAM_data[8'd8] <= {6'h04, 5'd08, 5'd00, 16'h0002};
                // // addi $sp, $sp, 8
                     RAM_data[8'd9] <= {6'h08, 5'd29, 5'd29, 16'h0008};
                // // jr $ra
                     RAM_data[8'd10] <= {6'h00, 5'd31, 15'h0000, 6'h08};
                // // L1:
                // // add $v0, $a0, $v0
                     RAM_data[8'd11] <= {6'h00, 5'd04, 5'd02, 5'd02, 5'd00, 6'h20};
                // // addi $a0, $a0, -1
                     RAM_data[8'd12] <= {6'h08, 5'd04, 5'd04, 16'hffff};
                // // jal sum
                     RAM_data[8'd13] <= {6'h03, 26'd4};
                // // lw $a0, 0($sp)
                     RAM_data[8'd14] <= {6'h23, 5'd29, 5'd04, 16'h0000};
                // // lw $ra, 4($sp)
                     RAM_data[8'd15] <= {6'h23, 5'd29, 5'd31, 16'h0004};
                // // addi $sp, $sp, 8
                     RAM_data[8'd16] <= {6'h08, 5'd29, 5'd29, 16'h0008};
                // // add $v0, $a0, $v0
                     RAM_data[8'd17] <= {6'h00, 5'd04, 5'd02, 5'd02, 5'd00, 6'h20};
                // // jr $ra
                     RAM_data[8'd18] <= {6'h00, 5'd31, 15'h0000, 6'h08};
             
	end
//initial begin
//    // init instruction memory
//            // addi $a0, $zero, 12123 #(0x2f5b)
//              RAM_data[8'd0] <= {6'h08, 5'd0 , 5'd4 , 16'h2f5b};
//            // addiu $a1, $zero, -12345 #(0xcfc7)
//              RAM_data[8'd1] <= {6'h09, 5'd0 , 5'd5 , 16'hcfc7};
//            // sll $a2, $a1, 16
//              RAM_data[8'd2] <= {6'h00, 5'd0 , 5'd5 , 5'd6 , 5'd16 , 6'h00};
//            // sra $a3, $a2, 16
//              RAM_data[8'd3] <= {6'h00, 5'd0 , 5'd6 , 5'd7 , 5'd16 , 6'h03};
//            // beq $a3, $a1, L1
//              RAM_data[8'd4] <= {6'h04, 5'd7 , 5'd5 , 16'h0001};
//            // lui $a0, 22222 #(0x56ce)
//              RAM_data[8'd5] <= {6'h0f, 5'd0 , 5'd4 , 16'h56ce};
//            // L1:
//            // add $t0, $a2, $a0
//              RAM_data[8'd6] <= {6'h00, 5'd6 , 5'd4 , 5'd8 , 5'd0 , 6'h20};
//            // sra $t1, $t0, 8
//              RAM_data[8'd7] <= {6'h00, 5'd0 , 5'd8 , 5'd9 , 5'd8 , 6'h03};
//            // addi $t2, $zero, -12123 #(0xd0a5)
//              RAM_data[8'd8] <= {6'h08, 5'd0 , 5'd10, 16'hd0a5};
//            // slt $v0, $a0, $t2
//              RAM_data[8'd9] <= {6'h00, 5'd4 , 5'd10 , 5'd2 , 5'd0 , 6'h2a};
//            // sltu $v1, $a0, $t2
//              RAM_data[8'd10] <= {6'h00, 5'd4 , 5'd10 , 5'd3 , 5'd0 , 6'h2b};
//            // Loop:
//            // j Loop
//              RAM_data[8'd11] <= {6'h02, 26'd11};
//end
	
	//write data
	integer i;
	always @(posedge reset or posedge clk) begin
		if (reset) begin
//		    // init instruction memory
//            // addi $a0, $zero, 12123 #(0x2f5b)
//              RAM_data[8'd0] <= {6'h08, 5'd0 , 5'd4 , 16'h2f5b};
//            // addiu $a1, $zero, -12345 #(0xcfc7)
//              RAM_data[8'd1] <= {6'h09, 5'd0 , 5'd5 , 16'hcfc7};
//            // sll $a2, $a1, 16
//              RAM_data[8'd2] <= {6'h00, 5'd0 , 5'd5 , 5'd6 , 5'd16 , 6'h00};
//            // sra $a3, $a2, 16
//              RAM_data[8'd3] <= {6'h00, 5'd0 , 5'd6 , 5'd7 , 5'd16 , 6'h03};
//            // beq $a3, $a1, L1
//              RAM_data[8'd4] <= {6'h04, 5'd7 , 5'd5 , 16'h0001};
//            // lui $a0, 22222 #(0x56ce)
//              RAM_data[8'd5] <= {6'h0f, 5'd0 , 5'd4 , 16'h56ce};
//            // L1:
//            // add $t0, $a2, $a0
//              RAM_data[8'd6] <= {6'h00, 5'd6 , 5'd4 , 5'd8 , 5'd0 , 6'h20};
//            // sra $t1, $t0, 8
//              RAM_data[8'd7] <= {6'h00, 5'd0 , 5'd8 , 5'd9 , 5'd8 , 6'h03};
//            // addi $t2, $zero, -12123 #(0xd0a5)
//              RAM_data[8'd8] <= {6'h08, 5'd0 , 5'd10, 16'hd0a5};
//            // slt $v0, $a0, $t2
//              RAM_data[8'd9] <= {6'h00, 5'd4 , 5'd10 , 5'd2 , 5'd0 , 6'h2a};
//            // sltu $v1, $a0, $t2
//              RAM_data[8'd10] <= {6'h00, 5'd4 , 5'd10 , 5'd3 , 5'd0 , 6'h2b};
//            // Loop:
//            // j Loop
//              RAM_data[8'd11] <= {6'h02, 26'd11};

			// lui $s1, 0xABCD
		    //  RAM_data[8'd0] <= {6'h0f, 5'd0, 5'd17, 16'habcd};
			// addi $s1, $s1, 0x1234
			//  RAM_data[8'd1] <= {6'h08, 5'd17, 5'd17, 16'h1234};
			// lui $s2, 0xCDEF
			//  RAM_data[8'd2] <= {6'h0f, 5'd0, 5'd18, 16'hcdef};
			// addi $s2, $s2, 0x3456
			//  RAM_data[8'd3] <= {6'h08, 5'd18, 5'd18, 16'h3456};
			// setsub $s3, $s1, $s2
			//  RAM_data[8'd4] <= {6'h00, 5'd17, 5'd18, 5'd19, 5'd0, 6'h28};
			// Loop:
			// j Loop
			//  RAM_data[8'd5] <= {6'h02, 26'd5};
			

			// // addi $a0, $zero, 5
			 	RAM_data[8'd0] <= {6'h08, 5'd0, 5'd4, 16'h0005};
			// // xor $v0, $zero, $zero
			 	RAM_data[8'd1] <= {6'h00, 5'd0, 5'd0, 5'd2, 5'd0, 6'h26};
			// // jal sum
			 	RAM_data[8'd2] <= {6'h03, 26'd4};
			// // Loop:
			// // beq $zero, $zero, Loop
			 	RAM_data[8'd3] <= {6'h04, 5'd00, 5'd00, 16'hffff};
			// // sum:
			// // addi $sp, $sp, -8
			 	RAM_data[8'd4] <= {6'h08, 5'd29, 5'd29, 16'hfff8};
			// // sw $ra, 4($sp)
			 	RAM_data[8'd5] <= {6'h2b, 5'd29, 5'd31, 16'h0004};
			// // sw $a0, 0($sp)
			 	RAM_data[8'd6] <= {6'h2b, 5'd29, 5'd04, 16'h0000};
			// // slti $t0, $a0, 1
			 	RAM_data[8'd7] <= {6'h0a, 5'd04, 5'd08, 16'h0001};
			// // beq $t0, $zero, L1
			 	RAM_data[8'd8] <= {6'h04, 5'd08, 5'd00, 16'h0002};
			// // addi $sp, $sp, 8
			 	RAM_data[8'd9] <= {6'h08, 5'd29, 5'd29, 16'h0008};
			// // jr $ra
			 	RAM_data[8'd10] <= {6'h00, 5'd31, 15'h0000, 6'h08};
			// // L1:
			// // add $v0, $a0, $v0
			 	RAM_data[8'd11] <= {6'h00, 5'd04, 5'd02, 5'd02, 5'd00, 6'h20};
			// // addi $a0, $a0, -1
			 	RAM_data[8'd12] <= {6'h08, 5'd04, 5'd04, 16'hffff};
			// // jal sum
			 	RAM_data[8'd13] <= {6'h03, 26'd4};
			// // lw $a0, 0($sp)
			 	RAM_data[8'd14] <= {6'h23, 5'd29, 5'd04, 16'h0000};
			// // lw $ra, 4($sp)
			 	RAM_data[8'd15] <= {6'h23, 5'd29, 5'd31, 16'h0004};
			// // addi $sp, $sp, 8
			 	RAM_data[8'd16] <= {6'h08, 5'd29, 5'd29, 16'h0008};
			// // add $v0, $a0, $v0
			 	RAM_data[8'd17] <= {6'h00, 5'd04, 5'd02, 5'd02, 5'd00, 6'h20};
			// // jr $ra
			 	RAM_data[8'd18] <= {6'h00, 5'd31, 15'h0000, 6'h08};
			
			// Error Test
			// addi $a0, $zero, 16'h7fff
			//	RAM_data[8'd0] <= {6'h08, 5'd00, 5'd04, 16'h7fff};
			// sll $a0, $a0, 16
			//	RAM_data[8'd1] <= {6'h00, 5'd00, 5'd04, 5'd04, 5'd16, 6'h00};
			// addi $a0, $a0, 16'h7fff;
			//	RAM_data[8'd2] <= {6'h08, 5'd04, 5'd04, 16'h7fff};
			// addi $a1, $zero, 16'h7fff;
			//	RAM_data[8'd3] <= {6'h08, 5'd00, 5'd05, 16'h7fff};
			// sll $a1, $a1, 16
			//	RAM_data[8'd4] <= {6'h00, 5'd00, 5'd05, 5'd05, 5'd16, 6'h00};
			// addi $a1, $a1, 16'h7fff
			//	RAM_data[8'd5] <= {6'h08, 5'd05, 5'd05, 16'h7fff};
			// addu $a2, $a0, $a1
			//	RAM_data[8'd6] <= {6'h00, 5'd04, 5'd5, 5'd06, 5'd00, 6'h20};
			// loop:
			// j loop
			//	RAM_data[8'd7] <= {6'h02, 26'd7};
			// error
			//	RAM_data[8'd31] <= {6'h0d, 5'd00, 5'd00, 16'hffff};
            //init instruction memory
            //reset data memory		  
			for (i = 19; i < RAM_SIZE; i = i + 1) // before i = RAM_INST_SIZE - 1
				RAM_data[i] <= 32'h00000000;
		end else if (MemWrite) begin
			RAM_data[Address[RAM_SIZE_BIT + 1:2]] <= Write_data;
		end
	end

endmodule
