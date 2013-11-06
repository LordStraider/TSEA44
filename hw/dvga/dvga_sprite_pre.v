
`include "include/dvga_defines.v"

module dvga_sprite_pre(
  clk, rst,
  xpos_i, ypos_i, xpos_o, ypos_o,
  r_i, g_i, b_i, hsync_i, vsync_i, blank_i,
  r_o, g_o, b_o, hsync_o, vsync_o, blank_o
);

input			clk;
input			rst;

input  [`XCNTW-1:0]     xpos_i;
input  [`YCNTW-1:0]     ypos_i;

output [`XCNTW-1:0]     xpos_o;
output [`YCNTW-1:0]     ypos_o;

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

reg    [7:0]            r0;
reg    [7:0]            g0;
reg    [7:0]            b0;
reg                     hsync0;
reg                     vsync0;
reg                     blank0;

reg    [7:0]            r1;
reg    [7:0]            g1;
reg    [7:0]            b1;
reg                     hsync1;
reg                     vsync1;
reg                     blank1;

reg    [7:0]            r2;
reg    [7:0]            g2;
reg    [7:0]            b2;
reg                     hsync2;
reg                     vsync2;

// Pipeline step 0
always @ (posedge clk)
  if (rst == 1'b1) begin
    r0 <= 8'b0;
    g0 <= 8'b0;
    b0 <= 8'b0;
    hsync0 <= 1'b0;
    vsync0 <= 1'b0;
    blank0 <= 1'b0;
  end else begin
    r0 <= r_i;
    g0 <= g_i;
    b0 <= b_i;
    hsync0 <= hsync_i;
    vsync0 <= vsync_i;
    blank0 <= blank_i;
  end

// Pipeline step 1
always @ (posedge clk)
  if (rst == 1'b1) begin
    r1     <= 8'b0;
    g1     <= 8'b0;
    b1     <= 8'b0;
    hsync1 <= 1'b0;
    vsync1 <= 1'b0;
    blank1 <= 1'b0;
  end else begin
    r1     <= r0;
    g1     <= g0;
    b1     <= b0;
    hsync1 <= hsync0;
    vsync1 <= vsync0;
    blank1 <= blank0;
  end

// Pipeline step 2
always @ (posedge clk)
  if (rst == 1'b1) begin
    r2     <= 8'b0;
    g2     <= 8'b0;
    b2     <= 8'b0;
    hsync2 <= 1'b0;
    vsync2 <= 1'b0;
  end else begin
    r2     <= r1;
    g2     <= g1;
    b2     <= b1;
    hsync2 <= hsync1;
    vsync2 <= vsync1;
  end

// Outputs
assign r_o     = r2;
assign g_o     = g2;
assign b_o     = b2;
assign hsync_o = hsync2;
assign vsync_o = vsync2;
assign blank_o = blank1;
assign xpos_o  = xpos_i;
assign ypos_o  = ypos_i;

endmodule

// Local Variables:
// verilog-library-directories:("." ".." "../or1200" "../jpeg" "../pkmc" "../dvga" "../uart" "../monitor" "../lab1" "../dafk_tb" "../eth" "../wb" "../leela")
// End:
