`include "include/dvga_defines.v"

module dvga_sprite_rend(
  clk, rst,

  xpos_i, ypos_i, xpos_o, ypos_o,
  r_i, g_i, b_i, hsync_i, vsync_i, blank_i,
  r_o, g_o, b_o, hsync_o, vsync_o, blank_o,

  swapcolor_i, 

  spren_i, sprx_i, spry_i, sproffsx_i, sproffsy_i,
  spradr_o, sprdat_i
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

input  [2:0]            swapcolor_i;
input                   spren_i;
input  [31:0]           sprx_i;
input  [31:0]           spry_i;
input  [4:0]            sproffsx_i;
input  [4:0]            sproffsy_i;

output [9:0]            spradr_o;
input  [15:0]           sprdat_i;


// Non-pipelined functions
wire   [9:0]            idxx_calc;
wire   [9:0]            idxy_calc;

// Pipeline stage 0
reg    [`XCNTW-1:0]     xpos0;
reg    [`YCNTW-1:0]     ypos0;
reg    [9:0]            idxx0;
reg    [9:0]            idxy0;

// Pipeline stage 1
reg    [`XCNTW-1:0]     xpos1;
reg    [`YCNTW-1:0]     ypos1;
wire   [15:0]           pixdat1; // Register at memory output
reg    [`XCNTW:0]       idxx1;
reg    [`YCNTW:0]       idxy1;

wire   [15:0]           pixdat_colorswap;

// Pipeline stage 2
reg                     opaque2;
reg    [15:0]           pixdat2;
reg                     blank2;

// Pipeline stage 3
reg    [7:0]		r3;
reg    [7:0]		g3;
reg    [7:0]		b3;
reg                     hsync3;
reg                     vsync3;


// Non-pipelined functions
assign idxx_calc = xpos_i - sprx_i[`XCNTW:0] + sproffsx_i;
assign idxy_calc = ypos_i - spry_i[`YCNTW:0] + sproffsy_i;

// Pipeline stage 0
always @ (posedge clk)
  if (rst == 1'b1) begin
    xpos0 <= `XCNTW'b0;
    ypos0 <= `YCNTW'b0;
    idxx0 <= `XCNTW'b0;
    idxy0 <= `YCNTW'b0;
  end else begin
    xpos0 <= xpos_i;
    ypos0 <= ypos_i;
    idxx0 <= idxx_calc;
    idxy0 <= idxy_calc;
  end
   
// Pipeline stage 1
assign pixdat1 = sprdat_i; // Register at memory output
always @ (posedge clk)
  if (rst == 1'b1) begin
    xpos1 <= `XCNTW'b0;
    ypos1 <= `YCNTW'b0;
    idxx1 <= `XCNTW'b0;
    idxy1 <= `YCNTW'b0;
  end else begin
    xpos1 <= xpos0;
    ypos1 <= ypos0;
    idxx1 <= idxx0;
    idxy1 <= idxy0;
  end

// Logic for pipeline stage 2
assign pixdat_colorswap = {pixdat1[15], 
                           (swapcolor_i[2]?(5'b11111^pixdat1[14:10]):pixdat1[14:10]),
                           (swapcolor_i[1]?(5'b11111^pixdat1[9:5])  :pixdat1[9:5]),
                           (swapcolor_i[0]?(5'b11111^pixdat1[4:0])  :pixdat1[4:0]) };

// Pipeline stage 2
always @ (posedge clk)
  if (rst == 1'b1) begin
    opaque2 <= 1'b0;
    pixdat2 <= 16'b0;
    blank2  <= 1'b0;
  end else begin
    opaque2 <= ((xpos1+sproffsx_i) >= sprx_i) && (idxx1 < `SPRW) &&
               ((ypos1+sproffsy_i) >= spry_i) && (idxy1 < `SPRH) && 
               pixdat1[15] && spren_i;
    pixdat2 <= pixdat_colorswap;
    blank2  <= blank_i;
  end

// Pipeline stage 3
always @ (posedge clk)
  if (rst == 1'b1) begin
    r3     <= 8'b0;
    g3     <= 8'b0;
    b3     <= 8'b0;
    hsync3 <= 1'b0;
    vsync3 <= 1'b0;
  end else begin
    r3     <= opaque2?{pixdat2[14:10], 1'b0, pixdat2[10], 1'b0}:r_i;
    g3     <= opaque2?{pixdat2[ 9: 4], 1'b0, pixdat2[ 5], 1'b0}:g_i;
    b3     <= opaque2?{pixdat2[ 5: 0], 1'b0, pixdat2[ 0], 1'b0}:b_i;
    hsync3 <= hsync_i;
    vsync3 <= vsync_i;
  end

// Outputs
assign spradr_o = {idxy_calc[4:0], idxx_calc[4:0]};
assign r_o      = r3;
assign g_o      = g3;
assign b_o      = b3;
assign hsync_o  = hsync3;
assign vsync_o  = vsync3;
assign blank_o  = blank2;
assign xpos_o   = xpos0;
assign ypos_o   = ypos0;

endmodule

// Local Variables:
// verilog-library-directories:("." ".." "../or1200" "../jpeg" "../pkmc" "../dvga" "../uart" "../monitor" "../lab1" "../dafk_tb" "../eth" "../wb" "../leela")
// End:
