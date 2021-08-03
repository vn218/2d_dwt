`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03.08.2021 16:17:38
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
input i_valid,
input last_pixel,
output reg o_valid,
input [$clog2(WIDTH)-1:0] i_row_column_pointer,
input [$clog2(WIDTH)-1:0] i_pixel_pointer,
output reg [$clog2(WIDTH)-1:0] o_row_column_pointer,
output reg [$clog2(WIDTH)-1:0] o_pixel_pointer
    );

reg [$clog2(WIDTH)-1:0] pixel_pointer_buffer [2:0];
reg [$clog2(WIDTH)-1:0] row_column_pointer_buffer [2:0];
reg [2:0] valid_buffer;
reg [1:0] last_pixel_buffer;
reg [31:0] sum_data [1:0];
reg [20:0] h0, h1, h2, h3;

reg [7:0] pixel [3:0];
reg [7:0] first_pixels [1:0];

initial begin
     h0 <= 21'b001111011101000110111;    //20 decimal places
     h1 <= 21'b011010110001001011111;
     h2 <= 21'b000111001011000011000;
     h3 <= 21'b000100001001000010000;
end

always @ (posedge clk) begin
    if (rst) begin
        valid_buffer <= 0;
    end
    else begin
        valid_buffer[0] <= i_valid;
        valid_buffer[1] <= valid_buffer[0];
        valid_buffer[2] <= valid_buffer[1];
        o_valid <= valid_buffer[2];
        if (i_valid) begin
            pixel[0] <= pixel_input[15:8];
            pixel[1] <= pixel_input[7:0];
            pixel_pointer_buffer[0] <= i_pixel_pointer;
            row_column_pointer_buffer[0] <= i_row_column_pointer;
            last_pixel_buffer[0] <= last_pixel;
        end
        if (valid_buffer[0]) begin
            pixel[2] <= pixel[0];
            pixel[3] <= pixel[1];
            pixel_pointer_buffer[1] <= pixel_pointer_buffer[0];
            row_column_pointer_buffer[1] <= row_column_pointer_buffer[0];
            last_pixel_buffer[1]<= last_pixel_buffer[0];
              
        end
        if (valid_buffer[1]) begin
            if (pixel_pointer_buffer[1] == 0) begin
                first_pixels[0] <= pixel[2];
                first_pixels[1] <= pixel[3];
            end
            case (last_pixel_buffer[1])
            0:  begin       
                  sum_data[0] <= h0*pixel[2] + h1*pixel[3] + h2*pixel[0] - h3*pixel[1];        
                  sum_data[1] <= h1*pixel[0] - h3*pixel[2] - h2*pixel[3] - h0*pixel[1];
                end
            1:  begin
                  sum_data[0] <= h0*pixel[2] + h1*pixel[3] + h2*first_pixels[0] - h3*first_pixels[1];
                  sum_data[1] <= h1*first_pixels[0] - h3*pixel[2] - h2*pixel[3] - h0*first_pixels[1];
                end
            endcase            
            pixel_pointer_buffer[2] <= pixel_pointer_buffer[1];
            row_column_pointer_buffer[2] <= row_column_pointer_buffer[1];
        end      
        if (valid_buffer[2]) begin
            //shift logic and final output            
            if (sum_data[0][31] == 1)
                pixel_output[15:8] <= 0;    
            else
                pixel_output[15:8] <= (sum_data[0]*5) >> 23;
            if (sum_data[1][31] == 1)
                pixel_output[7:0] <= 0;
            else
                pixel_output[7:0] <= (sum_data[1]*5) >> 23;    
            o_pixel_pointer <= pixel_pointer_buffer[2];
            o_row_column_pointer <= row_column_pointer_buffer[2];
        end    
    end            
end    
endmodule
