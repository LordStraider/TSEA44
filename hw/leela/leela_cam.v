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
//`default net_type none
module leela_cam (
       // Syscon interface
       clk, rst, int_o,

       // Camera interface
       ca_mclk_o, ca_vclk_i, ca_enb_o, ca_hsync_i, ca_vsync_i, ca_sda_io, 
       ca_sck_o, ca_resetb_o, ca_y_i,

       // Control registers
       reg0_i, reg1_i, reg2_i, reg3_i, status_o,

       // Control feedback
       reg0_reset_o,

       // Camera to MC interface
       mc_adr_o, mc_dat_o, mc_we_o, mc_stb_o, mc_cyc_o, 
       mc_ack_i, mc_cti_o, mc_bte_o,

       // Wishbone master interface
       wbm_adr_o, wbm_dat_o, wbm_dat_i, wbm_sel_o, wbm_we_o, wbm_stb_o, 
       wbm_cyc_o, wbm_ack_i, wbm_err_i, wbm_cti_o, wbm_bte_o
);

// Syscon interface
input			clk;
input			rst;
output			int_o;

// Camera interface
output			ca_mclk_o;
input			ca_vclk_i;
output			ca_enb_o;
input			ca_hsync_i;
input			ca_vsync_i;
inout			ca_sda_io;
output			ca_sck_o;
output			ca_resetb_o;
input	[7:0]		ca_y_i;

// Wishbone master interface
output	[31:0]		wbm_adr_o;
output	[31:0]		wbm_dat_o;
input	[31:0]		wbm_dat_i;
output	[3:0]		wbm_sel_o;
output			wbm_we_o;
output			wbm_stb_o;
output			wbm_cyc_o;
input			wbm_ack_i;
input			wbm_err_i;
output	[2:0]		wbm_cti_o;
output	[1:0]		wbm_bte_o;

// Control registers
input   [31:0]		reg0_i;
input   [31:0]		reg1_i;
input   [31:0]		reg2_i;
input   [31:0]		reg3_i;
output  [31:0]		status_o;

// Control feedback
output  [31:0]		reg0_reset_o;

// Camera to MC interface
output	[31:0]		mc_adr_o;
output  [31:0]		mc_dat_o;
output			mc_we_o;
output			mc_stb_o;
output			mc_cyc_o;
input			mc_ack_i;
output	[2:0]		mc_cti_o;
output	[1:0]		mc_bte_o;

// 
// Internal wires
//

wire	[31:0]		control;
wire			c_mc_source_sel;

wire	[31:0]		cam_status;
wire	[31:0]		sim_status;

// Camera to memory wires

wire	[31:0]		cam_mc_adr;
wire	[31:0]		cam_mc_dat;
wire			cam_mc_we;
wire			cam_mc_stb;
wire			cam_mc_ack;
wire			cam_mc_cyc;
wire	[2:0]		cam_mc_cti;
wire	[1:0]		cam_mc_bte;

// Simulator to memory wires

wire	[31:0]		sim_mc_adr;
wire	[31:0]		sim_mc_dat;
wire			sim_mc_we;
wire			sim_mc_stb;
wire			sim_mc_ack;
wire			sim_mc_cyc;
wire	[2:0]		sim_mc_cti;
wire	[1:0]		sim_mc_bte;

// Camera to master wires

wire			cam_wb_inta;
wire	[31:0]		cam_wbm_adr;
wire	[31:0]		cam_wbm_dat;
wire			cam_wbm_we;
wire			cam_wbm_stb;
wire			cam_wbm_ack;
wire			cam_wbm_cyc;
wire			cam_wbm_err;
wire	[2:0]		cam_wbm_cti;
wire	[1:0]		cam_wbm_bte;

// Simulator to master wires

wire			sim_wb_inta;
wire	[31:0]		sim_wbm_adr;
wire	[31:0]		sim_wbm_dat;
wire			sim_wbm_we;
wire			sim_wbm_stb;
wire			sim_wbm_ack;
wire			sim_wbm_cyc;
wire			sim_wbm_err;
wire	[2:0]		sim_wbm_cti;
wire	[1:0]		sim_wbm_bte;

// Control register definition
//
// 31:8       Reserved (Used by leela_cam_cam)
// 7          Reserved (Used by leela_top)
// 6:1        Reserved
// 0          Source select (0=cam, 1=sim)

assign control = reg0_i;
assign c_mc_source_sel = control[0];

leela_cam_sim sim0 (
	  .clk(clk),               .rst(rst),
	  .reg_ctrl_i(reg1_i),     .reg_update_i(32'b0),
	  .mc_adr_o(sim_mc_adr),   .mc_dat_o(sim_mc_dat),
	  .mc_we_o(sim_mc_we),     .mc_stb_o(sim_stb_o),    
	  .mc_cyc_o(sim_mc_cyc),   .mc_ack_i(sim_mc_ack), 
	  .mc_cti_o(sim_mc_cti),   .mc_bte_o(sim_mc_bte)
	  );

leela_cam_cam camcam0 (
	  .clk(clk),                       .rst(rst),
	  .int_o(cam_wb_inta),
	  .ca_mclk_o(ca_mclk_o),           .ca_vclk_i(ca_vclk_i),
	  .ca_enb_o(ca_enb_o),             .ca_hsync_i(ca_hsync_i),
	  .ca_vsync_i(ca_vsync_i),         .ca_sda_io(ca_sda_io),
	  .ca_sck_o(ca_sck_o),             .ca_resetb_o(ca_resetb_o),
	  .ca_y_i(ca_y_i),                 .reg_ctrl_i(reg0_i),
	  .reg_fbase0_i(reg1_i),           .reg_fbase1_i(reg2_i),
	  .reg_vbase_i(reg3_i),		   .status_o(cam_status),
	  .reg_ctrl_reset_o(reg0_reset_o), .mc_adr_o(cam_mc_adr),
	  .mc_dat_o(cam_mc_dat),           .mc_we_o(cam_mc_we), 
	  .mc_stb_o(cam_mc_stb),           .mc_cyc_o(cam_mc_cyc),
	  .mc_ack_i(cam_mc_ack),           .mc_cti_o(cam_mc_cti),     
	  .mc_bte_o(cam_mc_bte),           .wbm_adr_o(cam_wbm_adr), 
	  .wbm_dat_o(cam_wbm_dat),         .wbm_we_o(cam_wbm_we),   
	  .wbm_stb_o(cam_wbm_stb),         .wbm_cyc_o(cam_wbm_cyc), 
	  .wbm_ack_i(cam_wbm_ack),         .wbm_cti_o(cam_wbm_cti), 
	  .wbm_bte_o(cam_wbm_bte)
	  );

assign sim_wb_inta = 1'b0;
assign int_o = c_mc_source_sel?sim_wb_inta:cam_wb_inta;

assign mc_adr_o = c_mc_source_sel?sim_mc_adr:cam_mc_adr;
assign mc_dat_o = c_mc_source_sel?sim_mc_dat:cam_mc_dat;
assign mc_we_o  = c_mc_source_sel?sim_mc_we :cam_mc_we;
assign mc_stb_o = c_mc_source_sel?sim_mc_stb:cam_mc_stb;
assign mc_cyc_o = c_mc_source_sel?sim_mc_cyc:cam_mc_cyc;
assign mc_cti_o = c_mc_source_sel?sim_mc_cti:cam_mc_cti;
assign mc_bte_o = c_mc_source_sel?sim_mc_bte:cam_mc_bte;

assign wbm_adr_o = c_mc_source_sel?sim_wbm_adr:cam_wbm_adr;
assign wbm_dat_o = c_mc_source_sel?sim_wbm_dat:cam_wbm_dat;
assign wbm_we_o  = c_mc_source_sel?sim_wbm_we :cam_wbm_we;
assign wbm_stb_o = c_mc_source_sel?sim_wbm_stb:cam_wbm_stb;
assign wbm_cyc_o = c_mc_source_sel?sim_wbm_cyc:cam_wbm_cyc;
assign wbm_sel_o = 4'hF;
assign wbm_cti_o = c_mc_source_sel?sim_wbm_cti:cam_wbm_cti;
assign wbm_bte_o = c_mc_source_sel?sim_wbm_bte:cam_wbm_bte;

assign sim_status = 32'b0;
assign status_o  = c_mc_source_sel?sim_status:cam_status;

assign sim_mc_ack = c_mc_source_sel & mc_ack_i;
assign cam_mc_ack = !c_mc_source_sel & mc_ack_i;

assign sim_wbm_ack = c_mc_source_sel & wbm_ack_i;
assign cam_wbm_ack = !c_mc_source_sel & wbm_ack_i;

assign sim_wbm_err = c_mc_source_sel & wbm_err_i;
assign cam_wbm_err = !c_mc_source_sel & wbm_err_i;


endmodule // leela_cam
// Local Variables:
// verilog-library-directories:("." ".." "../or1200" "../jpeg" "../pkmc" "../dvga" "../uart" "../monitor" "../lab1" "../dafk_tb" "../eth" "../wb" "../leela")
// End:
