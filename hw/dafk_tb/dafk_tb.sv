//////////////////////////////////////////////////////////////////////
////                                                              ////
////  DAFK Top Testbench                                          ////
////                                                              ////
////  This file is part of the DAFK Lab Course                    ////
////  http://www.da.isy.liu.se/courses/tsea02                     ////
////                                                              ////
////  Description                                                 ////
////  DAFK Top SystemVerilog Version                              ////
////                                                              ////
////  To Do:                                                      ////
////   - include assertions!                                      ////
////                                                              ////
////  Authors:                                                    ////
////      - Olle Seger, olles@isy.liu.se                          ////
////      - Andreas Ehliar, ehliar@isy.liu.se                     ////
////      - Per Karlström, perk@isy.liu.se                        ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2000 Authors and OPENCORES.ORG                 ////
////                                                              ////
//// This source file may be used and distributed without         ////
//// restriction provided that this copyright statement is not    ////
//// removed from the file and that any derivative work contains  ////
//// the original copyright notice and the associated disclaimer. ////
////                                                              ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 2.1 of the License, or (at your option) any   ////
//// later version.                                               ////
////                                                              ////
//// This source is distributed in the hope that it will be       ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ////
//// PURPOSE.  See the GNU Lesser General Public License for more ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, download it   ////
//// from http://www.opencores.org/lgpl.shtml                     ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
`include "include/dafk_defines.v"
`include "include/timescale.v"

`define VGA_MODULE
`define ETH_MODULE
`define PKMC_MODULE

// ************************************************************************
// The top module                                                         *
// ************************************************************************
module dafk_tb() ;
   logic clk,rst;
   logic rx,tx;
   
   initial begin
      clk = 1'b0;
      rst = 1'b1;
      #1000 rst = 1'b0; 
   end

   always #12.5 clk = ~clk;

   computer computer0(clk,rst);
   
   testcomputer tester1(clk,rst);
endmodule // dafk_tb

// ************************************************************************
// The test program                                                       *
// ************************************************************************
program testcomputer(input clk,rst);
   initial begin
      forever
	computer0.uart1.getch();
   end

   initial begin
      // send a packet to Ethernet Rx
      // #10000 computer0.phy0.send_rx_packet(64'h0055_5555_5555_5555, 4'h7, 8'hD5, 0, 46, 1'b0);
     
      // test monitor with "h\r"
      #6000000 computer0.uart1.putstr("h"); 

   end
   
endprogram // tester

// ************************************************************************
// The computer under test                                                *
// ************************************************************************
module computer(input clk, rst);
   wire uart_tx, uart_rx;
   wire [7:0] 	out_pad_o;
   wire 	flashCE, kboomFlashCE, pmcBuffOE, gbe_rst;   
   
   // Memory Bus
   wire [31:0] 	mc_dio;
   wire [23:0] 	mc_addr;
   wire [2:0] 	mc_cs;
   wire 	mc_we, mc_oe;
   wire 	mc_ras, mc_cas;
   wire 	mc_cke;
   wire 	mc_rp;
   wire [3:0] 	mc_sel;
   wire 	sdram_clk;
   wire [23:0] 	baddr; 
   wire [31:0] 	bdata;
   wire 	mdbuf_oe;
   wire 	mabuf_oe;
   wire 	mdbuf_dir;
`ifdef VGA_MODULE
   // Video memory port
   wire [17:0] 	vgamem_adr;
   wire [31:0] 	vgamem_dat;
   wire 	vgamem_oe;
   wire 	vgamem_we;
   wire 	vgamem_ce;
   wire [3:0] 	vgamem_be;
`endif
`ifdef ETH_MODULE
   // Ether
   wire 	mrx_clk;
   wire [3:0] 	mrxd;
   wire 	mrxdv;
   wire 	mrxerr;
   wire 	mcoll;
   wire 	mcrs;
   wire 	mtx_clk;
   wire [3:0] 	mtxd;
   wire 	mtxen;
   wire 	mtxerr;
   wire 	mdc;
   wire 	mdio; 
   integer 	phy_log_file_desc;
`endif //  `ifdef ETH_MODULE
   
   // Instantiate test UART
   uart_tasks uart1(.*);


   // Instantiate Ethernet PHY
`ifdef ETH_MODULE
   eth_phy	phy0
     (
      .m_rst_n_i(!rst),
      // MAC Tx
      .mtx_clk_o(mtx_clk), .mtxd_i(mtxd),
      .mtxen_i(mtxen), .mtxerr_i(mtxerr),
      // MAC Rx
      .mrx_clk_o(mrx_clk), .mrxd_o(mrxd),
      .mrxdv_o(mrxdv), .mrxerr_o(mrxerr),
      // common
      .mcoll_o(mcoll), .mcrs_o(mcrs),
      // MIIM
      .mdc_i(mdc), .md_io(mdio),
      // SYSTEM
      .phy_log(phy_log_file_desc)
      );
`endif //  `ifdef ETH_MODULE

   // Instantiate Video Memory
`ifdef VGA_MODULE
   // SRAM for video
   sram_1MB videomem
     (
      .address(vgamem_adr),
      .dio(vgamem_dat),
      .oe(vgamem_oe), .ce(vgamem_ce),
      .we(vgamem_we), .sel(vgamem_be)
      );
`endif

   
   // Instantiate Memory on the MC bus
`ifdef PKMC_MODULE
   // buffers on avnet board
   assign 		baddr = !mabuf_oe ? mc_addr : 32'bz;
   assign 		bdata = (!mdbuf_oe &  mdbuf_dir) ? mc_dio : 32'bz;	// write
   assign 		mc_dio = (!mdbuf_oe &  !mdbuf_dir) ? bdata : 32'bz;	// read
   // buffered addr & data

   // SRAM
   sram_1MB mysram
     (
      .address(baddr[17:0]),
      .dio(bdata),
      .oe(mc_oe), .ce(mc_cs[0]),
      .we(mc_we), .sel(mc_sel));

   // Flash
/*
   flash flash0
     (
      .dq(bdata),
      .addr(baddr[19:0]),
      .ceb(mc_cs[1]),
      .oeb(mc_oe),
      .web(mc_we),
      .rpb(mc_rp),
      .wpb(1'b1),
      .vpp(32'd3300),
      .vcc(32'd3300)
      );
*/
   // SDRAM
   sdram sdram0
     (
      .Dq(mc_dio),
      .Addr(mc_addr[12:0]),
      .Ba(mc_addr[14:13]),
      .Clk(sdram_clk),
      .Cke(mc_cke),
      .Cs_n(mc_cs[2]),
      .Ras_n(mc_ras),
      .Cas_n(mc_cas),
      .We_n(mc_we),
      .Dqm(mc_sel)
      );
`endif

   // ************************************************************************
   // Instantiate the computer                                               *
   // ************************************************************************
   dafk dafk_top
     (
      .clk_i(clk), .rst_i(rst),
      // UART
      .stx_pad_o(uart_tx), .srx_pad_i(uart_rx), 
      // PIA
      .in_pad_i(8'h80), .out_pad_o(out_pad_o)
      // MC BUS
      `ifdef PKMC_MODULE
      , .mc_addr_pad_o(mc_addr), // 24 address bus
      .mc_dio(mc_dio), 	 // 32 data bus
      .mc_dqm_pad_o(mc_sel), 	 // 4 byte enables
      .mc_oe_pad_o_(mc_oe), .mc_we_pad_o_(mc_we), // OE, WE
      .mc_cas_pad_o_(mc_cas), .mc_ras_pad_o_(mc_ras),
      .mc_cke_pad_o_(mc_cke),
      .mc_cs_pad_o_(mc_cs),	 // 8 chip selects
      .mc_rp_pad_o_	(mc_rp),
      .sdram_clk(sdram_clk),
      .mdbuf_oe(mdbuf_oe), 
      .mdbuf_dir(mdbuf_dir), 
      .mabuf_oe(mabuf_oe),
      .flashCE(flashCE), .kboomFlashCE(kboomFlashCE), .pmcBuffOE(pmcBuffOE)
      `endif
      //Ether Tx
      `ifdef ETH_MODULE
      , .mtx_clk_pad_i(mtx_clk), .mtxd_pad_o(mtxd),
      .mtxen_pad_o(mtxen), .mtxerr_pad_o(mtxerr),
      //Ether Rx
      .mrx_clk_pad_i(mrx_clk), .mrxd_pad_i(mrxd), 
      .mrxdv_pad_i(mrxdv), .mrxerr_pad_i(mrxerr), 
      .mcoll_pad_i(mcoll), .mcrs_pad_i(mcrs), 
      .mdc_pad_o(mdc), .md_pad_io(mdio), .gbe_rst(gbe_rst)
      `endif
      // Video memory
      `ifdef VGA_MODULE
      , .vgamem_adr_o(vgamem_adr), .vgamem_dat_io(vgamem_dat), 
      .vgamem_cs_o(vgamem_ce), .vgamem_oe_o(vgamem_oe), 
      .vgamem_we_o(vgamem_we), .vgamem_be_o(vgamem_be),
      .clk_p_o(), .hsync_pad_o(), .vsync_pad_o(), .csync_pad_o(), .blank_pad_o(), 
      .r_pad_o(), .g_pad_o(), .b_pad_o(), .ref_white_pad_o(),
      .ca_mclk_o(), .ca_vclk_i(1'b0), .ca_resetb_o(), .ca_enb_o(), .ca_sck_o(), 
      .ca_sda_io(), .ca_y_i(8'h0), .ca_hsync_i(1'b0), .ca_vsync_i(1'b0)
      `endif
      );
   
endmodule


// Local Variables:
// verilog-library-directories:("." ".." "../or1200" "../jpeg" "../pkmc" "../dvga" "../uart" "../monitor" "../lab1" "../dafk_tb" "../eth" "../wb" "../leela")
// End:
