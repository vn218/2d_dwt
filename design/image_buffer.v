`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 30.07.2021 18:19:59
// Design Name: 
// Module Name: image_buffer
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
parameter WIDTH = 512,
          HEIGHT = 512;  

module image_buffer(
input clk,rst,
input [15:0] i_mac,
input i_mac_valid,
output reg [15:0] o_mac,
output reg o_mac_valid,
output reg o_mac_mode,
output reg [$clog2(WIDTH)-1:0] o_mac_row_column,
input i_mac_mode,
input [$clog2(WIDTH)-1:0] i_mac_row_column
    );
reg [7:0] img_buffer [HEIGHT*WIDTH - 1:0];
reg [7:0] mac_input_buffer [WIDTH-1:0];
reg [$clog2(WIDTH)-1:0] row_column_pointer;
reg [$clog2(WIDTH)-1:0] pixel_pointer;
reg [$clog2(WIDTH-1)-1:0] mac_buffer_pixel_pointer;
reg [$clog2(WIDTH)-1:0] mac_buffer_row_column_pointer;
reg mac_buffer_full;
reg mode; //row wise = 0 , column wise = 1
wire read;
integer i;
   
   assign read = !rst;
   initial begin
       $readmemh("D:/Downloads/lena.hex",img_buffer);
       for (i=0; i<HEIGHT*WIDTH;i = i+1)img_buffer[i] = img_buffer[i]/2;
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
                    if ((mode == 0 && row_column_pointer == HEIGHT-1)||( mode == 1 && row_column_pointer == WIDTH-1))
                        row_column_pointer <= 0;    
                    else 
                    row_column_pointer <= row_column_pointer + 1;        
                end
           end
    end
    
    always @ (posedge clk) begin
        if (mode == 0 && read)
            o_mac <= {img_buffer[row_column_pointer*WIDTH + pixel_pointer],img_buffer[row_column_pointer*WIDTH + pixel_pointer+1]};
        else if (mode == 1 && read)
            o_mac <= {img_buffer[pixel_pointer*WIDTH + row_column_pointer],img_buffer[(pixel_pointer+1)*WIDTH + row_column_pointer]}; 
        o_mac_valid <= read;
        o_mac_mode <= mode;
        o_mac_row_column <= row_column_pointer;          
    end
    
    always @ (posedge clk) begin
        if (rst)
            mode <= 0;
        else if(read) begin
            case (mode)
                0: if (pixel_pointer == WIDTH - 2 && row_column_pointer == HEIGHT-1) mode <= 1;
                1: if (pixel_pointer == HEIGHT - 2 && row_column_pointer == WIDTH-1) mode <= 0;
            endcase
        end        
    end 
    
    always @ (posedge clk) begin
        if (rst) begin
            mac_buffer_pixel_pointer <= 0;
            mac_buffer_full <= 0;
        end    
        else if (i_mac_valid) begin
            if ((i_mac_mode == 0 && mac_buffer_pixel_pointer == WIDTH/2 - 1)||(i_mac_mode == 1 && mac_buffer_pixel_pointer == HEIGHT/2 - 1))
                begin
                    mac_buffer_pixel_pointer <= 0;
                    mac_buffer_full <= 1;
                end
            else
                mac_buffer_pixel_pointer <= mac_buffer_pixel_pointer + 1;     
        end    
    end
    
    always @ (posedge clk) begin
        if (i_mac_valid) begin
            mac_input_buffer[mac_buffer_pixel_pointer] <= i_mac[15:8];
            if ( i_mac_mode == 0 )
                mac_input_buffer[mac_buffer_pixel_pointer + WIDTH/2] <= i_mac[7:0];    
            else if (i_mac_mode == 1)
                mac_input_buffer[mac_buffer_pixel_pointer + HEIGHT/2] <= i_mac[7:0];
        end
         
        if (mac_buffer_full) begin
            if ( i_mac_mode == 0 ) 
                for (i = 0; i <= WIDTH; i = i + 1) img_buffer[mac_buffer_row_column_pointer*WIDTH + i] <= mac_input_buffer[i];     
            else if ( i_mac_mode == 1)
                for (i = 0; i <= HEIGHT; i = i + 1) img_buffer[i*WIDTH + mac_buffer_row_column_pointer] <= mac_input_buffer[i];         
            mac_buffer_full <= 0;    
        end    
    end                          
                
endmodule
