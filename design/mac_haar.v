`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 31.07.2021 16:37:17
// Design Name: 
// Module Name: mac
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



module mac
#(parameter HEIGHT = 256,
            WIDTH = 256)
(
input clk, rst,
input [15:0] pixel_input,
output reg [15:0] pixel_output,
input i_valid,
output reg o_valid,
input [$clog2(WIDTH)-1:0] i_row_column_pointer,
input [$clog2(WIDTH)-1:0] i_pixel_pointer,
output reg [$clog2(WIDTH)-1:0] o_row_column_pointer,
output reg [$clog2(WIDTH)-1:0] o_pixel_pointer
    );
always @ (posedge clk) begin
    if (i_valid) begin
        pixel_output[15:8] <= (pixel_input[15:8] + pixel_input[7:0])/2;
        if ( pixel_input[15:8] < pixel_input[7:0])
            pixel_output[7:0] <= 0;
        else
            pixel_output[7:0] <= (pixel_input[15:8] - pixel_input[7:0])/2;
        o_pixel_pointer <= i_pixel_pointer;
        o_row_column_pointer <= i_row_column_pointer;
    end
    o_valid <= i_valid;
                   
end    
endmodule
