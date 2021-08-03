`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 31.07.2021 17:04:42
// Design Name: 
// Module Name: top_module
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


module top_module
#(parameter HEIGHT = 256,
            WIDTH =256,
            DECOMPOSITION_LEVEL = 1)
(
input clk, rst,
output [7:0] axi_out,
output axi_valid
    );

wire [15:0] pixel_to_mac;
wire [15:0] pixel_from_mac;
wire valid_to_mac;
wire valid_from_mac;
wire [$clog2(WIDTH)-1:0] row_column_pointer_to_mac;
wire [$clog2(WIDTH)-1:0] pixel_pointer_to_mac;    
wire [$clog2(WIDTH)-1:0] row_column_pointer_from_mac;
wire [$clog2(WIDTH)-1:0] pixel_pointer_from_mac;
wire last_pixel;    

control_logic #( 
.HEIGHT(HEIGHT),
.WIDTH(WIDTH),
.DECOMPOSITION_LEVEL(DECOMPOSITION_LEVEL))
control_logic(
.clk(clk),
.rst(rst),
.i_mac(pixel_from_mac),
.i_mac_valid(valid_from_mac),
.o_mac(pixel_to_mac),
.o_mac_valid(valid_to_mac),
.o_mac_row_column_pointer(row_column_pointer_to_mac),
.o_mac_pixel_pointer(pixel_pointer_to_mac),
.axi_out(axi_out),
.last_pixel(last_pixel),
.axi_valid(axi_valid),
.i_mac_row_column_pointer(row_column_pointer_from_mac),
.i_mac_pixel_pointer(pixel_pointer_from_mac)    
    );
mac_d4 #( 
.HEIGHT(HEIGHT),
.WIDTH(WIDTH))
mac(
.clk(clk), 
.rst(rst),
.pixel_input(pixel_to_mac),
.pixel_output(pixel_from_mac),
.i_valid(valid_to_mac),
.last_pixel(last_pixel),
.o_valid(valid_from_mac),
.i_row_column_pointer(row_column_pointer_to_mac),
.i_pixel_pointer(pixel_pointer_to_mac),
.o_row_column_pointer(row_column_pointer_from_mac),
.o_pixel_pointer(pixel_pointer_from_mac)
    );    


endmodule
