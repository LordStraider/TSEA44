`resetall
`timescale 1ns/10ps
module leela_reg (
       clk, rst, 

       adr, dat_i, dat_o, we_i,
       ce_i, stb_i, ack_o,

       status_i,

       reg0_o, reg1_o, reg2_o, reg3_o,
       reg4_o, reg5_o, reg6_o, reg7_o,

       reg0_reset_i
);

input		clk;
input		rst;
input	[6:0]	adr;
input	[31:0]	dat_i;
output	[31:0]	dat_o;
reg	[31:0]  dat_o;
input		we_i;
input		ce_i;
input		stb_i;
output		ack_o;
input   [31:0]  status_i;
output  [31:0]  reg0_o;
output  [31:0]  reg1_o;
output  [31:0]  reg2_o;
output  [31:0]  reg3_o;
output  [31:0]  reg4_o;
output  [31:0]  reg5_o;
output  [31:0]  reg6_o;
output  [31:0]  reg7_o;

input   [31:0]  reg0_reset_i;

reg	[31:0]	reg0;
reg	[31:0]	reg1;
reg	[31:0]	reg2;
reg	[31:0]	reg3;
reg	[31:0]	reg4;
reg	[31:0]	reg5;
reg	[31:0]	reg6;
reg	[31:0]	reg7;
reg	[31:0]	status_reg;

reg	[31:0]	reg0_reset_r;

assign ack_o = ce_i & stb_i & (~(|reg0_reset_r));

always @ (posedge clk)
  reg0_reset_r <= reg0_reset_i;

always @ (posedge clk)
  if (rst == 1'b1)
    reg0 <= 32'b0;
  else if (|reg0_reset_r)
    reg0 <= reg0 & ~reg0_reset_r;
  else if (we_i & stb_i & (adr[4:2] == 3'h0))
    reg0 <= dat_i;

always @ (posedge clk)
  if (rst == 1'b1)
    reg1 <= 32'b0;
  else if (we_i & stb_i & (adr[4:2] == 3'h1))
    reg1 <= dat_i;

always @ (posedge clk)
  if (rst == 1'b1)
    reg2 <= 32'b0;
  else if (we_i & stb_i & (adr[4:2] == 3'h2))
    reg2 <= dat_i;

always @ (posedge clk)
  if (rst == 1'b1)
    reg3 <= 32'b0;
  else if (we_i & stb_i & (adr[4:2] == 3'h3))
    reg3 <= dat_i;

always @ (posedge clk)
  if (rst == 1'b1)
    reg4 <= 32'b0;
  else if (we_i & stb_i & (adr[4:2] == 3'h4))
    reg4 <= dat_i;

always @ (posedge clk)
  if (rst == 1'b1)
    reg5 <= 32'b0;
  else if (we_i & stb_i & (adr[4:2] == 3'h5))
    reg5 <= dat_i;

always @ (posedge clk)
  if (rst == 1'b1)
    reg6 <= 32'b0;
  else if (we_i & stb_i & (adr[4:2] == 3'h6))
    reg6 <= dat_i;

always @ (posedge clk)
  if (rst == 1'b1)
    reg7 <= 32'b0;
  else if (we_i & stb_i & (adr[4:2] == 3'h7))
    reg7 <= dat_i;

always @ (posedge clk)
  if (rst == 1'b1)
    status_reg <= 32'b0;
  else
    status_reg <= status_i;

always @ (*)
  case (adr[4:2])
     3'h0:    dat_o = reg0;
     3'h1:    dat_o = reg1;
     3'h2:    dat_o = reg2;
     3'h3:    dat_o = reg3;
     3'h4:    dat_o = reg4;
     3'h5:    dat_o = reg5;
     3'h6:    dat_o = reg6;
     default: dat_o = status_reg;
  endcase

assign reg0_o = reg0;
assign reg1_o = reg1;
assign reg2_o = reg2;
assign reg3_o = reg3;
assign reg4_o = reg4;
assign reg5_o = reg5;
assign reg6_o = reg6;
assign reg7_o = reg7;

endmodule // leela_reg

// Local Variables:
// verilog-library-directories:("." ".." "../or1200" "../jpeg" "../pkmc" "../dvga" "../uart" "../monitor" "../lab1" "../dafk_tb" "../eth" "../wb" "../leela")
// End:
