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
   
module control_logic
#(parameter HEIGHT = 256,
            WIDTH =256,
            DECOMPOSITION_LEVEL = 1)
(
input clk,rst,
input [15:0] i_mac,
input i_mac_valid,
output [15:0] o_mac,
output reg o_mac_valid,
output reg [$clog2(WIDTH)-1:0] o_mac_row_column_pointer,
output reg [$clog2(WIDTH)-1:0] o_mac_pixel_pointer,
output reg [7:0] axi_out,
output reg axi_valid,
output reg last_pixel,
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

reg mode; //0 rowwise  1 columnwise
reg [$clog2(WIDTH)-1:0] pixel_pointer;
reg [$clog2(WIDTH)-1:0] row_column_pointer;
reg read;
reg [2:0] level;
reg axi_valid_buffer;

assign memory_select = mode; 
assign mem_out = memory_select?{mem2_out1,mem2_out2}:{mem1_out1,mem1_out2};
assign o_mac = mem_out;

always @ (*) begin
    if (memory_select) begin
        mem1_in1 <= i_mac[15:8];
        mem1_in2 <= i_mac[7:0];
    end
    else if (!memory_select) begin
        mem2_in1 <= i_mac[15:8];
        mem2_in2 <= i_mac[7:0];
    end    
end

always @ (posedge clk) begin
    if (rst) begin
        pixel_pointer <= 0;
        last_pixel <= 0;
    end    
    else if(read) begin
        if ((mode == 0 && pixel_pointer == (WIDTH >> level) - 2)||(mode == 1 && pixel_pointer == (HEIGHT >> level) - 2)) begin
            pixel_pointer <= 0;
            last_pixel <= 1;
        end        
        else begin
            pixel_pointer <= pixel_pointer + 2;
            last_pixel <= 0;
        end             
    end
end

always @ (posedge clk) begin
    if (rst)
        row_column_pointer <= 0;
    else if(read) begin
        if ((mode == 0 && pixel_pointer == (WIDTH >> level) - 2)||(mode == 1 && pixel_pointer == (HEIGHT >> level) - 2))
        begin    
            if ((mode == 0 && row_column_pointer == (HEIGHT >> level) - 1)||( mode == 1 && row_column_pointer == (WIDTH >> level) -1)) begin
                row_column_pointer <= 0;
                read <= 0;    
            end
            else 
                row_column_pointer <= row_column_pointer + 1;        
        end
    end
end

assign rd_addr1 = mode? pixel_pointer*WIDTH + row_column_pointer : row_column_pointer*WIDTH + pixel_pointer;    
assign rd_addr2 = mode? rd_addr1 + WIDTH : rd_addr1 + 1;


always @ (posedge clk) begin
    o_mac_row_column_pointer <= row_column_pointer;
    o_mac_pixel_pointer <= pixel_pointer;
    o_mac_valid <= read;
end

assign w_addr1 = mode? (i_mac_pixel_pointer >> 1)*WIDTH + i_mac_row_column_pointer : i_mac_row_column_pointer*WIDTH + i_mac_pixel_pointer/2;
assign w_addr2 = mode? w_addr1 + (HEIGHT >> (level + 1))*WIDTH : w_addr1+ (WIDTH >> (level + 1));

always @ (posedge clk) begin
    if (rst) begin
        mode <= 0;
        level <= 0;
        read <= 1;
    end     
    else if(i_mac_valid) begin
        case (mode)
            0: begin 
                if (i_mac_pixel_pointer == (WIDTH >> level) - 2 && i_mac_row_column_pointer == (HEIGHT >> level) - 1) begin 
                    mode <= 1;
                    read <= 1;
                end
                end    
                1: begin 
                if (i_mac_pixel_pointer == (HEIGHT >> level) - 2 && i_mac_row_column_pointer == (WIDTH >> level) -1) begin 
                    mode <= 0;
                    level <= level + 1;
                    if ( level < DECOMPOSITION_LEVEL - 1 ) read <= 1;                    
                end
                end    
        endcase
    end        
end

always @ (posedge clk) begin
    if (rst) begin
        axi_valid <= 0;
        axi_valid_buffer <= 0;
    end    
    else if ( level == DECOMPOSITION_LEVEL ) begin
        axi_valid_buffer <= 1;
        axi_valid <= axi_valid_buffer;
        axi_out <= mem1_out1;
        if (pixel_pointer == WIDTH - 1) begin
            pixel_pointer <= 0;
            row_column_pointer <= row_column_pointer + 1;
        end        
        else
            pixel_pointer <= pixel_pointer + 1;
    end
end        
        
       
img_memory #(
.HEIGHT(HEIGHT),
.WIDTH(WIDTH))
mem1(
.pixel_in1(mem1_in1),
.pixel_in2(mem1_in2),
.pixel_out1(mem1_out1),
.pixel_out2(mem1_out2),
.enable1(1),
.wr_enable1(memory_select&i_mac_valid),
.enable2(1),
.wr_enable2(memory_select&i_mac_valid),
.addr1(memory_select?w_addr1:rd_addr1),
.addr2(memory_select?w_addr2:rd_addr2),
.clk(clk)
    );
img_memory #( 
.HEIGHT(HEIGHT),
.WIDTH(WIDTH))
mem2(
.pixel_in1(mem2_in1),
.pixel_in2(mem2_in2),
.pixel_out1(mem2_out1),
.pixel_out2(mem2_out2),
.enable1(1),
.wr_enable1(!memory_select&i_mac_valid),
.enable2(1),
.wr_enable2(!memory_select&i_mac_valid),
.addr1(memory_select?rd_addr1:w_addr1),
.addr2(memory_select?rd_addr2:w_addr2),
.clk(clk)
    );          
          
endmodule
