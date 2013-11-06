//////////////////////////////////////////////////////////////////////
////                                                              ////
////  DAFK Top Level                                              ////
////                                                              ////
////  This file is part of the DAFK Lab Course                    ////
////  http://www.da.isy.liu.se/courses/tsea02                     ////
////                                                              ////
////  Description                                                 ////
////  DAFK Top Level SystemVerilog Version                        ////
////                                                              ////
////  To Do:                                                      ////
////   - make it smaller and faster                               ////
////                                                              ////
////  Author:                                                     ////
////      - Olle Seger, olles@isy.liu.se                          ////
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
`include "include/timescale.v"
`include "include/or1200_defines.v"
`include "include/dafk_defines.v"
`include "include/buildnum.v"


module lab1
  (
   // System
   input clk_i, rst_i,
   // UART signals
   output stx_pad_o, 
   input srx_pad_i, 
   // PIA
   input [7:0] in_pad_i, 
   output [7:0] out_pad_o,   
   output sdram_clk,
   // MC BUS
   output [23:0] mc_addr_pad_o, // 24 address bus
   inout [31:0] mc_dio, // 32 data bus
   output [3:0] mc_dqm_pad_o, 	// 4 byte enables
   output mc_oe_pad_o_, mc_we_pad_o_, // OE, WE
   output mc_cas_pad_o_, mc_ras_pad_o_,	 // RAS,CAS
   output mc_cke_pad_o_,
   output [2:0] mc_cs_pad_o_, // 3 chip selects
   output mc_rp_pad_o_, mdbuf_oe, mdbuf_dir, mabuf_oe,
   output flashCE, kboomFlashCE, pmcBuffOE
   );
   
   // ************************************************************************
   // Internal wires and regs                                                *
   // ************************************************************************  
   wire 	 sys_clk, sys_rst;
   wire 	 sdram_clk_int;
   wire [3:0] 	 int_sdramCommand_o;
   wire [7:0] 	 dummy;
   wire [23:0] 	 unused24;
   reg 		 negrst;
   
   //
   // OR1200 interrupts
   //
   wire [19:0] pic_ints;
   wire        uart_int, eth_int, vga_int, leela_int;

   // ************************************************************************
   // Clock generator                                                        *
   // ************************************************************************
   sys_sig_gen sys_sig_gen
     (
      .masterClk(clk_i), .masterRst(rst_i),
      .sysclk(sys_clk), .sysRst(sys_rst), 
      .sdramclk(sdram_clk_int), .nsysclk(sdram_clk)
      );
   
   // ************************************************************************
   // WISHBONE interconnects                                                 *
   // ************************************************************************
   wishbone Mx[0:7](sys_clk,sys_rst), Sx[0:9](sys_clk,sys_rst), vga(sys_clk,sys_rst);

   wb_top  
     #(.s0_addr(`ADDR_MC),      // slave 0
       .s1_addr(`ADDR_BOOT),	// slave 1
       .s2_addr(`ADDR_UART),	// slave 2
       .s3_addr(`ADDR_ETH),	// slave 3
       .s4_addr(`ADDR_PS2),	// slave 4
       .s5_addr(`ADDR_VGA),	// slave 5
       .s6_addr(`ADDR_DCT),	// slave 6
       .s7_addr(`ADDR_PARP), 	// slave 7
       .s8_addr(`ADDR_LEELA)) 	// slave 8
       wb_conbus (sys_clk, sys_rst, Mx, Sx);

   
   // ************************************************************************
   // OR1200 CPU Master 0,1                                                  *
   // ************************************************************************
   assign 		pic_ints[1:0] = 2'b0;     //  0-1  Reserved
   assign 		pic_ints[2] = uart_int;   //  2	UART16550 Controller
   assign 		pic_ints[3] = 1'b0;       //  3	General-Purpose I/O
   assign 		pic_ints[4] = eth_int;    //  4	Ethernet Controller
   assign 		pic_ints[5] = 1'b0;       //  5	PS/2 Controller
   assign 		pic_ints[6] = 1'b0;	  //  6	Traffic COP 0, Real-Time Clock
   assign 		pic_ints[7] = 1'b0;	  // 7	PWM/Timer/Counter Controller
   assign 		pic_ints[8] = vga_int;	  // 8	Graphics Controller
   assign 		pic_ints[9] = leela_int;  // 9	IrDA Controller
   assign 		pic_ints[19:10] = 10'b0; // 10	PCI Controller

   or1200_top cpu
     (
      .clk_i(sys_clk), .rst_i(sys_rst), 
      .pic_ints_i(pic_ints), .clmode_i(2'b00),
      .iwb(Mx[0]),  // Instruction WISHBONE INTERFACE
      .dwb(Mx[1]),  // Data WISHBONE INTERFACE
      // External Debug Interface
      .dbg_stall_i(1'b0), .dbg_ewt_i(1'b0), .dbg_lss_o(), 
      .dbg_is_o(), .dbg_wp_o(), .dbg_bp_o(),
      .dbg_stb_i(1'b0), .dbg_we_i(1'b0), .dbg_adr_i(32'h0), 
      .dbg_dat_i(32'h0), .dbg_dat_o(), .dbg_ack_o(),
      // Power Management
      .pm_cpustall_i(1'b0), .pm_clksd_o(), .pm_dc_gate_o(), 
      .pm_ic_gate_o(), .pm_dmmu_gate_o(), .pm_immu_gate_o(), 
      .pm_tt_gate_o(), .pm_cpu_gate_o(), .pm_wakeup_o(), 
      .pm_lvolt_o()
      );

   // ************************************************************************
   //                Master 3                                                *
   // ************************************************************************
   dummy_master dm3(Mx[3]);
   
   // ************************************************************************
   // Memory Ctrl s0   sdram = 0x0  sram = 0x2000_0000 flash = 0xf000_0000   *
   // ************************************************************************
   pkmc_top pkmc_mc
     (
      .wb(Sx[0]), // WB i/f
      .wb_lock_i(1'b0), .shftClk(sdram_clk_int),
      //Board interface, bi := Board Interface
      //SRAM
      .sramCE_bi(mc_cs_pad_o_[0]),
      .sramOE_bi(mc_oe_pad_o_),
      .sramBuffDir_bi(mdbuf_dir),
      .sramBuffOE_bi(mdbuf_oe),
      //FLASH
      .flashCE_bi(mc_cs_pad_o_[1]),
      //SDRAM
      .sdramCke_o_bi(mc_cke_pad_o_),
      //Common interface
      .sdramCommand_o_bi(int_sdramCommand_o),
      .data_io_bi(mc_dio),
      .addr_o_bi({dummy, mc_addr_pad_o}),
      .byteSel_o_bi(mc_dqm_pad_o)
      );

   assign 		{mc_cs_pad_o_[2], mc_ras_pad_o_, mc_cas_pad_o_, mc_we_pad_o_} = int_sdramCommand_o;

   // control buffers
   assign 		mabuf_oe  =  1'b0;
   assign 		flashCE = 1'b1;
   assign 		kboomFlashCE = 1'b1;
   assign 		pmcBuffOE = 1'b1;
   assign 		mc_rp_pad_o_ = negrst;
   
   // FLASH reset
   always_ff @ (posedge sys_clk)
     if (sys_rst == 1'b1)
       negrst <= 1'b0;
     else
       negrst <= 1'b1;
   
   // ************************************************************************
   // Instantiate Boot Monitor Memory on slave1    base = 0x4000_0000        *
   // ************************************************************************ 
   romram rom0(Sx[1]);

   // ************************************************************************
   // Instantiate your own UART   slave2   base = 0x9000_0000                *
   // ************************************************************************
   lab1_uart_top uart
     (
      .wb(Sx[2]),
      .int_o(uart_int), // interrupt request
      // UART	signals serial input/output
      .stx_pad_o(stx_pad_o), 
      .srx_pad_i(srx_pad_i)
      );

   // ************************************************************************
   // Instantiate Ethernet Master 2 Slave 3  base = 0x9200_0000              *
   // ************************************************************************
   dummy_slave ds3(Sx[3]); 
   dummy_master dm2(Mx[2]);
   
   // ************************************************************************
   // Slave 4                                                                *
   // ************************************************************************
   dummy_slave ds4(Sx[4]); 

   // ************************************************************************
   // VGA Controller       Slave 5   base = 0x9700_0000                      *
   // ************************************************************************
   assign 		vga_int = 1'b0;
   dummy_slave ds5(Sx[5]);

   // ************************************************************************
   // Parallell port  slave 7  base = 0x9100_0000                            *
   // ************************************************************************
  parport	pia
     (// Wishbone signals
      .wb(Sx[7]),
      // PORT	signals
      .out_pad_o({unused24, out_pad_o}), .in_pad_i({8'h80,`BUILDREV, in_pad_i})
      );

   // ************************************************************************
   // Instantiate Leela  slave8 master4     base = 0x9800_0000               *
   // ************************************************************************
   assign 		leela_int = 1'b0;
   dummy_slave ds8(Sx[8]);
   dummy_master dm4(Mx[4]);

   // ************************************************************************
   // Slave 9 , Master 5                                                     *
   // ************************************************************************
   perf_top perf0(Sx[9], Mx[0], Mx[1]);
   
   //dummy_slave ds9(Sx[9]);
   dummy_master dm5(Mx[5]);

   // ************************************************************************
   // DCT accelerator  master6 slave6   base = 0x9600_0000                   *
   // ************************************************************************
   dummy_slave ds6(Sx[6]);
   dummy_master dm6(Mx[6]);

   // ************************************************************************
   // Master 7                                                               *
   // ************************************************************************
   dummy_master dm7(Mx[7]);
   
endmodule

// Local Variables:
// verilog-library-directories:("." "or1200" "jpeg" "pkmc" "dvga" "uart" "monitor" "lab1" "dafk_tb" "eth" "wb" "leela")
// End:
