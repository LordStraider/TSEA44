//
// Verilog Module leela.leela_top.arch_name
//
// Created:
//          by - danwi.users (tinuviel.isy.liu.se)
//          at - 13:12:20 05/10/2004
//
// using Mentor Graphics HDL Designer(TM) 2003.2 (Build 28)
//
`resetall
`timescale 1ns/10ps
module leela_cam_sim (
       // Syscon interface
       clk, rst,

       // Control registers for simulator
       reg_ctrl_i, reg_update_i,

       // Camera to MC interface
       mc_adr_o, mc_dat_o, mc_we_o, mc_stb_o, 
       mc_cyc_o, mc_ack_i, mc_cti_o, mc_bte_o
);

// Syscon interface
input			clk;
input			rst;

// Control registers for simulator
input	[31:0]		reg_ctrl_i;
input	[31:0]		reg_update_i;

// Camera to MC interface
output	[31:0]		mc_adr_o;
output  [31:0]		mc_dat_o;
output			mc_we_o;
output			mc_stb_o;
output			mc_cyc_o;
input			mc_ack_i;
output	[2:0]		mc_cti_o;
output	[1:0]		mc_bte_o;

assign mc_adr_o = 32'b0;
assign mc_dat_o = 32'b0;
assign mc_we_o  = 1'b0;
assign mc_cyc_o = 1'b0;
assign mc_stb_o = 1'b0;
assign mc_cti_o = 3'b0;
assign mc_bte_o = 3'b0;

endmodule // leela_cam_sim
// Local Variables:
// verilog-library-directories:("." ".." "../or1200" "../jpeg" "../pkmc" "../dvga" "../uart" "../monitor" "../lab1" "../dafk_tb" "../eth" "../wb" "../leela")
// End:
