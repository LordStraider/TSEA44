`include "include/dvga_defines.v"

module dvga_sprite(
  clk, rst,

  xpos_i, ypos_i,
  r_i, g_i, b_i, hsync_i, vsync_i, blank_i,
  r_o, g_o, b_o, hsync_o, vsync_o, blank_o,

  swapcolor0_i, swapcolor1_i,

  spr0en_i, spr0x_i, spr0y_i, spr0offsx_i, spr0offsy_i,
  spr1en_i, spr1x_i, spr1y_i, spr1offsx_i, spr1offsy_i,
  spr0_adr_o, spr0_dat_i, 
  spr1_adr_o, spr1_dat_i
);

input			clk;
input			rst;

input  [`XCNTW-1:0]     xpos_i;
input  [`YCNTW-1:0]     ypos_i;

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

input  [2:0]            swapcolor0_i;
input  [2:0]            swapcolor1_i;

input                   spr0en_i;
input  [31:0]           spr0x_i;
input  [31:0]           spr0y_i;
input  [4:0]            spr0offsx_i;
input  [4:0]            spr0offsy_i;
input                   spr1en_i;
input  [31:0]           spr1x_i;
input  [31:0]           spr1y_i;
input  [4:0]            spr1offsx_i;
input  [4:0]            spr1offsy_i;

output [9:0]            spr0_adr_o;
input  [15:0]           spr0_dat_i;
output [9:0]            spr1_adr_o;
input  [15:0]           spr1_dat_i;

wire   [7:0]            r0;
wire   [7:0]            g0;
wire   [7:0]            b0;
wire                    hsync0;
wire                    vsync0;
wire                    blank0;
wire   [`XCNTW-1:0]     xpos0;
wire   [`YCNTW-1:0]     ypos0;

wire   [7:0]            r1;
wire   [7:0]            g1;
wire   [7:0]            b1;
wire                    hsync1;
wire                    vsync1;
wire                    blank1;
wire   [`XCNTW-1:0]     xpos1;
wire   [`YCNTW-1:0]     ypos1;

wire   [7:0]            r2;
wire   [7:0]            g2;
wire   [7:0]            b2;
wire                    hsync2;
wire                    vsync2;
wire                    blank2;
wire   [`XCNTW-1:0]     xpos2;
wire   [`YCNTW-1:0]     ypos2;

wire   [7:0]            r3;
wire   [7:0]            g3;
wire   [7:0]            b3;
wire                    hsync3;
wire                    vsync3;
wire                    blank3;

dvga_sprite_pre spre(
  .clk(clk),                .rst(rst),
  .xpos_i(xpos_i),          .ypos_i(ypos_i),
  .xpos_o(xpos0),           .ypos_o(ypos0),
  .r_i(r_i),                .g_i(g_i),
  .b_i(b_i),                .hsync_i(hsync_i),
  .vsync_i(vsync_i),        .blank_i(blank_i),
  .r_o(r0),                 .g_o(g0),
  .b_o(b0),                 .hsync_o(hsync0),
  .vsync_o(vsync0),         .blank_o(blank0)
);

dvga_sprite_rend sr0(
  .clk(clk),                .rst(rst),
  .xpos_i(xpos0),           .ypos_i(ypos0),
  .xpos_o(xpos1),           .ypos_o(ypos1),
  .r_i(r0),                 .g_i(g0),
  .b_i(b0),                 .hsync_i(hsync0),
  .vsync_i(vsync0),         .blank_i(blank0),
  .r_o(r1),                 .g_o(g1),
  .b_o(b1),                 .hsync_o(hsync1),
  .vsync_o(vsync1),         .blank_o(blank1),

  .swapcolor_i(swapcolor0_i),
  .spren_i(spr0en_i),       .sprx_i(spr0x_i),
  .spry_i(spr0y_i),      
  .sproffsx_i(spr0offsx_i), .sproffsy_i(spr0offsy_i),
  .spradr_o(spr0_adr_o),    .sprdat_i(spr0_dat_i)
);

dvga_sprite_rend sr1(
  .clk(clk),                .rst(rst),
  .xpos_i(xpos1),           .ypos_i(ypos1),
  .xpos_o(xpos2),           .ypos_o(ypos2),
  .r_i(r1),                 .g_i(g1),
  .b_i(b1),                 .hsync_i(hsync1),
  .vsync_i(vsync1),         .blank_i(blank1),
  .r_o(r2),                 .g_o(g2),
  .b_o(b2),                 .hsync_o(hsync2),
  .vsync_o(vsync2),         .blank_o(blank2),

  .swapcolor_i(swapcolor1_i),
  .spren_i(spr1en_i),       .sprx_i(spr1x_i),
  .spry_i(spr1y_i), 
  .sproffsx_i(spr1offsx_i), .sproffsy_i(spr1offsy_i),
  .spradr_o(spr1_adr_o),    .sprdat_i(spr1_dat_i)
);

dvga_sprite_post spost(
  .clk(clk),                .rst(rst),
  .r_i(r2),                 .g_i(g2),
  .b_i(b2),                 .hsync_i(hsync2),
  .vsync_i(vsync2),         .blank_i(blank2),
  .r_o(r3),                 .g_o(g3),
  .b_o(b3),                 .hsync_o(hsync3),
  .vsync_o(vsync3),         .blank_o(blank3)
);

assign r_o     = blank3?8'b0:r3;
assign g_o     = blank3?8'b0:g3;
assign b_o     = blank3?8'b0:b3;
assign hsync_o = hsync3;
assign vsync_o = vsync3;
assign blank_o = blank3;

endmodule

// Local Variables:
// verilog-library-directories:("." ".." "../or1200" "../jpeg" "../pkmc" "../dvga" "../uart" "../monitor" "../lab1" "../dafk_tb" "../eth" "../wb" "../leela")
// End:
