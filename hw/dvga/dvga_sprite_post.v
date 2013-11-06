`include "include/dvga_defines.v"

module dvga_sprite_post(
  clk, rst,
  r_i, g_i, b_i, hsync_i, vsync_i, blank_i,
  r_o, g_o, b_o, hsync_o, vsync_o, blank_o
);

input			clk;
input			rst;

input  [7:0]            r_i;
input  [7:0]            g_i;
input  [7:0]            b_i;
input                   hsync_i;
input                   vsync_i;
input                   blank_i;

output [7:0]            r_o;
output [7:0]            g_o;
output [7:0]            b_o;
output                  hsync_o;
output                  vsync_o;
output                  blank_o;

// Pipeline step 0
reg                     blank0;

// Pipeline step 0
always @ (posedge clk)
  if (rst == 1'b1)
    blank0 <= 1'b0;
  else
    blank0 <= blank_i;

// Outputs
assign r_o     = r_i;
assign g_o     = g_i;
assign b_o     = b_i;
assign hsync_o = hsync_i;
assign vsync_o = vsync_i;
assign blank_o = blank0;

endmodule

// Local Variables:
// verilog-library-directories:("." ".." "../or1200" "../jpeg" "../pkmc" "../dvga" "../uart" "../monitor" "../lab1" "../dafk_tb" "../eth" "../wb" "../leela")
// End:
