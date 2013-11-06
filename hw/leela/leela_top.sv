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
  
module leela_top (
  // Wishbone slave interface
  wishbone.slave wbs,
  // Wishbone master interface
  wishbone.master wbm,
  // VGA memory Wishbone slave
  wishbone.slave vga,

  // Camera interface
    output logic  ca_mclk_o, 
    input  logic ca_vclk_i, 
    output logic ca_enb_o, 
    input  logic ca_hsync_i, ca_vsync_i, 
    inout  wire ca_sda_io, 
    output logic   ca_sck_o, ca_resetb_o, 
    input  logic [7:0] ca_y_i,

		  // Video memory port
    output logic [17:0]  mem_adr_o, 
    inout  wire [31:0] mem_dat_io, 
    output logic mem_cs_o, mem_oe_o, mem_we_o, 
    output logic [3:0] mem_be_o,

		  // VGA DAC control
    output logic ref_white_o,
    output logic int_o
);

// Syscon interface
   logic   clk, rst;
   assign  clk = wbs.clk;
   assign  rst = wbs.rst;
   
// Wishbone slave interface
   logic [31:0]        wbs_adr_i;
   logic [31:0]        wbs_dat_i;
   logic [31:0]        wbs_dat_o;
   logic [3:0] 	       wbs_sel_i;
   logic 	       wbs_we_i, wbs_stb_i, wbs_cyc_i;
   logic 	       wbs_ack_o, wbs_err_o;
   logic [2:0] 	       wbs_cti_i;
   logic [1:0] 	       wbs_bte_i;

   assign 	       wbs_adr_i = wbs.adr;
   assign 	       wbs_dat_i = wbs.dat_o;
   assign 	       wbs_sel_i = wbs.sel;
   assign 	       wbs_we_i = wbs.we;
   assign 	       wbs_stb_i = wbs.stb;
   assign 	       wbs_cyc_i = wbs.cyc;
   assign 	       wbs_cti_i = wbs.cti;
   assign 	       wbs_bte_i = wbs.bte;
   
   assign 	       wbs.dat_i = wbs_dat_o;
   assign 	       wbs.ack = wbs_ack_o;
   assign 	       wbs.err = wbs_err_o;
   assign 	       wbs.rty = 1'b0;
   
// Wishbone master interface
   logic [31:0]        wbm_adr_o;
   logic [31:0]        wbm_dat_o;
   logic [31:0]        wbm_dat_i;
   logic [3:0] 	       wbm_sel_o;
   logic 	       wbm_we_o, wbm_stb_o, wbm_cyc_o;
   logic 	       wbm_ack_i, wbm_err_i;
   logic [2:0] 	       wbm_cti_o;
   logic [1:0] 	       wbm_bte_o;

   assign wbm.adr = wbm_adr_o;
   assign wbm.dat_o = wbm_dat_o;
   assign wbm.sel = wbm_sel_o;
   assign wbm.we = wbm_we_o;
   assign wbm.stb = wbm_stb_o;
   assign wbm.cyc =  wbm_cyc_o;
   assign wbm.cti = wbm_cti_o;
   assign wbm.bte = wbm_bte_o;
   
   assign wbm_dat_i = wbm.dat_i;
   assign wbm_ack_i = wbm.ack;
   assign wbm_err_i = wbm.err;
   
// Wishbone slave interface
   logic [31:0]        vga_adr_i;
   logic [31:0]        vga_dat_i;
   logic [31:0]        vga_dat_o;
   logic [3:0] 	       vga_sel_i;
   logic 	       vga_we_i, vga_stb_i, vga_cyc_i;
   logic 	       vga_ack_o, vga_err_o;
   logic [2:0] 	       vga_cti_i;
   logic [1:0] 	       vga_bte_i;

   assign 	       vga_adr_i = vga.adr;
   assign 	       vga_dat_i = vga.dat_o;
   assign 	       vga_sel_i = vga.sel;
   assign 	       vga_we_i = vga.we;
   assign 	       vga_stb_i = vga.stb;
   assign 	       vga_cyc_i = vga.cyc;
   assign 	       vga_cti_i = vga.cti;
   assign 	       vga_bte_i = vga.bte;
   
   assign 	       vga.dat_i = vga_dat_o;
   assign 	       vga.ack = vga_ack_o;
   assign 	       vga.err = vga_err_o;
   
// -------------------------------------------------------
//
// Internal wires and registers
//

// Control register wires
wire	[31:0]		reg0;
wire	[31:0]		reg1;
wire	[31:0]		reg2;
wire	[31:0]		reg3;
wire	[31:0]		reg4;
wire	[31:0]		reg5;
wire	[31:0]		reg6;
wire	[31:0]		reg7;
wire	[31:0]		status;

// Control register reset wires
wire	[31:0]		reg0_reset;

// Register block wires
wire			reg_ce;
wire			reg_we;
wire			reg_stb;
wire			reg_ack;
wire	[31:0]		reg_dat;

// VGA MC block wires
wire			mc_ce;
wire			mc_we;
wire			mc_err;
wire			mc_stb;
wire			mc_ack;
wire	[31:0]		mc_dat;

// Camera to MC wires
wire	[31:0]		cam_mc_adr;
wire    [31:0]		cam_mc_dat;
wire    [31:0]		cam_mc_dato;
wire			cam_mc_we;
wire			cam_mc_stb;
wire			cam_mc_cyc;
wire			cam_mc_ack;
wire			cam_mc_err;
wire	[2:0]		cam_mc_cti;
wire	[1:0]		cam_mc_bte;

// Wire assignments
assign reg_we = wbs_stb_i & wbs_we_i & reg_ce;
assign mc_we = wbs_stb_i & wbs_we_i & mc_ce;
assign wbs_ack_o = reg_ack | mc_ack;
assign wbs_err_o = mc_err;

// Control register definition
//
// 31:8       Reserved (Used by leela_cam_cam)
// 7          Reference white (1=enabled)
// 6:0        Reserved (Used by leela_cam)

assign ref_white_o = reg0[7];

// Decode Wishbone address
assign reg_ce = !wbs_adr_i[21];
assign mc_ce = wbs_adr_i[21];
assign reg_stb = reg_ce & wbs_stb_i;
assign mc_stb = mc_ce & wbs_stb_i;

always_comb
       if (reg_ce)
          wbs_dat_o = reg_dat;
       else
	  wbs_dat_o = mc_dat;

leela_reg regs0(
	  .clk(clk), .rst(rst), .adr(wbs_adr_i[6:0]), .dat_i(wbs_dat_i),
	  .dat_o(reg_dat), .we_i(reg_we), .ce_i(reg_ce), 
	  .stb_i(reg_stb), .ack_o(reg_ack),
	  .status_i(status),
	  .reg0_o(reg0), .reg1_o(reg1), .reg2_o(reg2), .reg3_o(reg3), 
	  .reg4_o(reg4), .reg5_o(reg5), .reg6_o(reg6), .reg7_o(reg7),
	  .reg0_reset_i(reg0_reset)
	  );

leela_mc mc0(
	  .clk(clk), .rst(rst),

	  // Wishbone to memory interface
	  .s0_adr_i(wbs_adr_i),  .s0_dat_i(wbs_dat_i),
	  .s0_dat_o(mc_dat),     .s0_sel_i(wbs_sel_i),
	  .s0_we_i(wbs_we_i),    .s0_stb_i(mc_stb),
	  .s0_cyc_i(wbs_cyc_i),  .s0_ack_o(mc_ack),
	  .s0_cti_i(wbs_cti_i),  .s0_bte_i(wbs_bte_i),
	  .s0_err_o(mc_err),  

	  // Camera to memory interface
	  .s1_adr_i(cam_mc_adr), .s1_dat_i(cam_mc_dat), 
	  .s1_dat_o(cam_mc_dato),.s1_sel_i(4'hF),
	  .s1_we_i(cam_mc_we),   .s1_stb_i(cam_mc_stb), 
	  .s1_cyc_i(cam_mc_cyc), .s1_ack_o(cam_mc_ack), 
	  .s1_cti_i(cam_mc_cti), .s1_bte_i(cam_mc_bte), 
	  .s1_err_o(cam_mc_err),	  

	  // VGA to memory interface
	  .s2_adr_i(vga_adr_i),  .s2_dat_i(32'b0),
	  .s2_dat_o(vga_dat_o),  .s2_sel_i(vga_sel_i), 
	  .s2_we_i(vga_we_i),    .s2_stb_i(vga_stb_i), 
	  .s2_cyc_i(vga_cyc_i),  .s2_ack_o(vga_ack_o), 
	  .s2_cti_i(vga_cti_i),  .s2_bte_i(vga_bte_i), 
	  .s2_err_o(vga_err_o),

	  // Video memory port
	  .mem_adr_o(mem_adr_o), .mem_dat_io(mem_dat_io),
	  .mem_cs_o(mem_cs_o), .mem_oe_o(mem_oe_o),
	  .mem_we_o(mem_we_o), .mem_be_o(mem_be_o)
	  );
leela_cam cam0 (
	  .clk(clk),                 .rst(rst),
	  .int_o(int_o),
	  .ca_mclk_o(ca_mclk_o),     .ca_vclk_i(ca_vclk_i),
	  .ca_enb_o(ca_enb_o),       .ca_hsync_i(ca_hsync_i),
	  .ca_vsync_i(ca_vsync_i),   .ca_sda_io(ca_sda_io),
	  .ca_sck_o(ca_sck_o),       .ca_resetb_o(ca_resetb_o),
	  .ca_y_i(ca_y_i),           .reg0_i(reg0),
          .reg1_i(reg1),             .reg2_i(reg2),
	  .reg3_i(reg3),	     .status_o(status),
	  .reg0_reset_o(reg0_reset), .mc_adr_o(cam_mc_adr),   
	  .mc_dat_o(cam_mc_dat),     .mc_we_o(cam_mc_we),
	  .mc_stb_o(cam_mc_stb),     .mc_cyc_o(cam_mc_cyc),
	  .mc_ack_i(cam_mc_ack),     .mc_cti_o(cam_mc_cti),
	  .mc_bte_o(cam_mc_bte),     .wbm_adr_o(wbm_adr_o),
	  .wbm_dat_o(wbm_dat_o),     .wbm_dat_i(wbm_dat_i),
	  .wbm_sel_o(wbm_sel_o),     .wbm_we_o(wbm_we_o),
	  .wbm_stb_o(wbm_stb_o),     .wbm_cyc_o(wbm_cyc_o),
	  .wbm_ack_i(wbm_ack_i),     .wbm_err_i(wbm_err_i),
	  .wbm_cti_o(wbm_cti_o),     .wbm_bte_o(wbm_bte_o)
	  );

endmodule // leela_top
// Local Variables:
// verilog-library-directories:("." ".." "../or1200" "../jpeg" "../pkmc" "../dvga" "../uart" "../monitor" "../lab1" "../dafk_tb" "../eth" "../wb" "../leela")
// End:
