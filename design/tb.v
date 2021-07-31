`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 31.07.2021 17:25:36
// Design Name: 
// Module Name: tb
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



`define total_image_size 256*256

module ip_tb(
    );

reg clk;
reg rst;
wire [7:0] out_data;
wire out_data_valid;
integer received_data = 0;
integer f_output;

initial
begin
    clk = 1'b0;
    forever
    begin
        #5 clk = ~clk;
    end
end

initial
begin
    rst = 0;
    #100;
    rst = 1;
    #100;
    f_output = $fopen("dwt.bin", "wb");
end
always @ (posedge clk)
begin
    if (out_data_valid)
    begin
        $fwrite(f_output, "%c", out_data);
        received_data = received_data + 1;
    end
    if (received_data == `total_image_size)
    begin
        $fclose(f_output);
        $stop;
    end
    
end
top_module #(
.HEIGHT(256),
.WIDTH(256),
.DECOMPOSITION_LEVEL(2))  
DUT(
.clk(clk), 
.rst(!rst),
.axi_out(out_data),
.axi_valid(out_data_valid)
    );
endmodule
