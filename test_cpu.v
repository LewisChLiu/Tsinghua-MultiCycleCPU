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


module test_cpu();
    
    reg reset;
    reg cpuclk_i;
    reg sys_clk;
    reg SW2;
    reg SW1;
    reg SW0;
    
    wire [7:0] led;
    wire [3:0] ano;
    wire [6:0] dout;
    
    
    top top1(sys_clk, cpuclk_i, SW0, SW1, SW2, reset, ano, dout, led);
    
    initial begin
        reset <= 0;
        sys_clk <= 1;
        SW0 <= 0;
        SW1 <= 0;
        SW2 <= 0;
        forever begin
        #5 sys_clk = ~sys_clk;
        end
    end
    
    
endmodule
