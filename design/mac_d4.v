`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03.08.2021 00:24:39
// Design Name: 
// Module Name: mac_d4
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


module mac_d4
#(parameter HEIGHT = 256,
            WIDTH = 256)
(
input clk, rst,
input [15:0] pixel_input,
output reg [15:0] pixel_output,
input last_pixel,
input i_valid,
output reg o_valid,
input [$clog2(WIDTH)-1:0] i_row_column_pointer,
input [$clog2(WIDTH)-1:0] i_pixel_pointer,
output reg [$clog2(WIDTH)-1:0] o_row_column_pointer,
output reg [$clog2(WIDTH)-1:0] o_pixel_pointer
    );
    
reg [7:0] pixels[WIDTH-1:0];
reg valid_buffer;
integer i;
reg h0 = 0.4829629131445341;
reg h1 = 0.8365163037378077;
reg h2 = 0.2241438680420134;
reg h3 = 0.1294095225512603;
    
always @ (posedge clk) begin
    if (rst) begin
        for (i = 0; i < WIDTH; i = i + 1)
           pixels[i] <= 0;
    end
    else begin
        if (i_valid) begin
            if (i_pixel_pointer == 0) begin
                pixels[0] <= pixel_input[7:0];
                pixels[1] <= pixel_input[15:8];
                valid_buffer <= 0;
            end else if (last_pixel) begin
                if (h0*pixel_input[7:0] + h1*pixel_input[15:8] + h2*pixels[WIDTH-3] < h3*pixels[WIDTH-4])
                    pixel_output[15:8] = 0;
                else
                    pixel_output[15:8] = h0*pixel_input[7:0] + h1*pixel_input[15:8] + h2*pixels[WIDTH-3] - h3*pixels[WIDTH-4];
                if (h1*pixels[2] < h3*pixels[0] + h2*pixels[1] + h0*pixels[3])
                    pixel_output[7:0] = 0;
                else
                    pixel_output[7:0] = h1*pixels[WIDTH-3] - h3*pixel_input[7:0] - h2*pixel_input[15:8] - h0*pixels[WIDTH-4];
            end else begin
                pixels[0] <= pixel_input[7:0];
                pixels[1] <= pixel_input[15:8];
                for (i = 0; i < WIDTH-1; i = i + 1)
                    pixels[i+1] <= pixels[i];
                if (h0*pixels[0] + h1*pixels[1] + h2*pixels[2] < h3*pixels[3])
                    pixel_output[15:8] = 0;
                else
                    pixel_output[15:8] = h0*pixels[0] + h1*pixels[1] + h2*pixels[2] - h3*pixels[3];
                if (h1*pixels[2] < h3*pixels[0] + h2*pixels[1] + h0*pixels[3])
                    pixel_output[7:0] = 0;
                else
                    pixel_output[7:0] = h1*pixels[2] - h3*pixels[0] - h2*pixels[1] - h0*pixels[3];
                valid_buffer <= i_valid;
            end
            o_pixel_pointer <= i_pixel_pointer;
            o_row_column_pointer <= i_row_column_pointer;
        end
        o_valid <= i_valid;
     end
                   
end    
endmodule