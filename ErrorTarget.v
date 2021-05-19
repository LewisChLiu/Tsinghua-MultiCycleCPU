`timescale 1ns / 1ps

module ErrorTarget(reset, clk, ErWrite, Er_i, Er_o);
    //Input Clock Signals
    input reset;             
    input clk;
    //Input Control Signals             
    input ErWrite;
    //Input PC             
    input [4:0] Er_i;
    //Output PC  
    output reg [4:0] Er_o; 


always@(posedge reset or posedge clk)
    begin
        if(reset) begin
            Er_o <= 0;
        end else if (ErWrite) begin
            Er_o <= Er_i;
        end else begin
            Er_o <= Er_o;
        end
    end
endmodule