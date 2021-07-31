`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 31.07.2021 03:26:48
// Design Name: 
// Module Name: img_memory
// Project Name: 
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
 
parameter HEIGHT = 256,
          WIDTH = 256;
 
module img_memory(
input [7:0] pixel_in1,
input [7:0] pixel_in2,
output reg [7:0] pixel_out1,
output reg [7:0] pixel_out2,
input enable1,
input wr_enable1,
input enable2,
input wr_enable2,
input [HEIGHT*WIDTH-1:0] addr1,
input [HEIGHT*WIDTH-1:0] addr2,
input clk
    );
   
    
    reg [7:0] mem [HEIGHT*WIDTH-1:0];
    
    initial begin
       $readmemh("D:/Downloads/lena.hex",mem);      
    end 
    always @ (posedge clk) begin
        if (enable1)begin
            pixel_out1 <= mem[addr1];
                if (wr_enable1)
                    mem[addr1] <= pixel_in1;
        end
    end                
    
    always @ (posedge clk) begin    
        if (enable2) begin
            pixel_out2 <= mem[addr2];
                if (wr_enable2)
                    mem[addr2] <= pixel_in2;
        end            
                        
    end                 
endmodule
