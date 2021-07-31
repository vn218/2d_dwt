`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 30.07.2021 02:51:22
// Design Name: 
// Module Name: control_logic
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

parameter DECOMPOSITION_LEVEL = 1;


module control_logic(
input clk,rst,
input [15:0] i_mac,
input i_mac_valid,
output [15:0] o_mac,
output reg o_mac_valid,
output reg o_mac_mode,
output reg [$clog2(WIDTH)-1:0] o_mac_row_column_pointer,
output reg [$clog2(WIDTH)-1:0] o_mac_pixel_pointer,
output reg [7:0] axi_out,
input i_mac_mode,
input [$clog2(WIDTH)-1:0] i_mac_row_column_pointer,
input [$clog2(WIDTH)-1:0] i_mac_pixel_pointer    
    );
wire memory_select;
wire [$clog2(HEIGHT*WIDTH)-1:0] rd_addr1;
wire [$clog2(HEIGHT*WIDTH)-1:0] rd_addr2;
wire [$clog2(HEIGHT*WIDTH)-1:0] w_addr1;
wire [$clog2(HEIGHT*WIDTH)-1:0] w_addr2;
reg [7:0] mem1_in1;
reg [7:0] mem1_in2;
wire [7:0] mem1_out1;
wire [7:0] mem1_out2;
reg [7:0] mem2_in1;
reg [7:0] mem2_in2;
wire [7:0] mem2_out1;
wire [7:0] mem2_out2;
wire [15:0] mem_out;
reg [15:0] mem_in;
reg mode;  // 0 = row wise, 1 = column wise
reg [$clog2(WIDTH)-1:0] pixel_pointer;
reg [$clog2(WIDTH)-1:0] row_column_pointer;
reg read;
reg [2:0] level;

assign memory_select = mode;
assign mem_out = memory_select?{mem2_out1,mem2_out2}:{mem1_out1,mem1_out2};
assign o_mac = mem_out;

always @ (*) begin
    if (memory_select) begin
        mem1_in1 <= mem_in[15:8];
        mem1_in2 <= mem_in[7:0];
    end
    else if (!memory_select) begin
        mem2_in1 <= mem_in[15:8];
        mem2_in2 <= mem_in[7:0];
    end    
end

always @ (posedge clk) begin
    if (rst)
        pixel_pointer <= 0;
    else if(read) begin
        if ((mode == 0 && pixel_pointer == WIDTH - 2)||(mode == 1 && pixel_pointer == HEIGHT - 2))
            pixel_pointer <= 0;    
        else
            pixel_pointer <= pixel_pointer + 2;         
    end
end

always @ (posedge clk) begin
    if (rst)
        row_column_pointer <= 0;
    else if(read) begin
        if ((mode == 0 && pixel_pointer == WIDTH - 2)||(mode == 1 && pixel_pointer == HEIGHT - 2))
        begin    
            if ((mode == 0 && row_column_pointer == HEIGHT-1)||( mode == 1 && row_column_pointer == WIDTH-1)) begin
                row_column_pointer <= 0;
                read <= 0;    
            end
            else 
                row_column_pointer <= row_column_pointer + 1;        
        end
    end
end

assign rd_addr1 = mode? pixel_pointer*WIDTH + row_column_pointer : row_column_pointer*WIDTH + pixel_pointer;    
assign rd_addr2 = mode? (pixel_pointer+1)*WIDTH + row_column_pointer : row_column_pointer*WIDTH + pixel_pointer+1;

always @ (posedge clk) begin
    if (rst) begin
        o_mac_valid <= 0;
        o_mac_mode <= 0;
        o_mac_row_column_pointer <= 0;
        o_mac_pixel_pointer <= 0;          
    end
    else begin
        o_mac_valid <= read;
        if (read) begin        
            o_mac_mode <= mode;
            o_mac_row_column_pointer <= row_column_pointer;
            o_mac_pixel_pointer <= pixel_pointer;
        end
    end
end

assign rd_addr1 = i_mac_mode? (i_mac_pixel_pointer/2)*WIDTH + i_mac_row_column_pointer : i_mac_row_column_pointer*WIDTH + i_mac_pixel_pointer/2;
assign rd_addr2 = i_mac_mode? (i_mac_pixel_pointer/2 + HEIGHT/2)*WIDTH + i_mac_row_column_pointer : i_mac_row_column_pointer*WIDTH + i_mac_pixel_pointer/2 + WIDTH/2;

always @ (posedge clk) begin
    if (rst) begin
        mode <= 0;
        level <= 0;
        read <= 1;
    end     
    else if(i_mac_valid) begin
        case (i_mac_mode)
            0: begin 
                if (i_mac_pixel_pointer == WIDTH - 2 && i_mac_row_column_pointer == HEIGHT-1) begin 
                    mode <= 1;
                    read <= 1;
                end
                end    
                1: begin 
                if (i_mac_pixel_pointer == HEIGHT - 2 && i_mac_row_column_pointer == WIDTH-1) begin 
                    mode <= 0;
                    level <= level + 1;
                    if ( level < DECOMPOSITION_LEVEL ) read <= 1;                    
                end
                end    
        endcase
    end        
end

always @ (posedge clk) begin
    if ( level == DECOMPOSITION_LEVEL ) begin
        axi_out <= mem1_out1;
        if (pixel_pointer == WIDTH - 2) begin
            pixel_pointer <= 0;
            row_column_pointer <= row_column_pointer + 1;
        end        
        else
            pixel_pointer <= pixel_pointer + 1;
    end
end        
        
       
img_memory mem1(
.pixel_in1(mem1_in1),
.pixel_in2(mem1_in2),
.pixel_out1(mem1_out1),
.pixel_out2(mem1_out2),
.enable1(1),
.wr_enable1(memory_select&o_mac_valid),
.enable2(1),
.wr_enable2(memory_select&o_mac_valid),
.addr1(memory_select?w_addr1:rd_addr1),
.addr2(memory_select?w_addr2:rd_addr2),
.clk(clk)
    );
img_memory mem2(
.pixel_in1(mem2_in1),
.pixel_in2(mem2_in2),
.pixel_out1(mem2_out1),
.pixel_out2(mem2_out2),
.enable1(1),
.wr_enable1(!memory_select&o_mac_valid),
.enable2(1),
.wr_enable2(!memory_select&o_mac_valid),
.addr1(memory_select?rd_addr1:w_addr1),
.addr2(memory_select?rd_addr2:w_addr2),
.clk(clk)
    );          
          
endmodule
