//////////////////////////////////////////////////////////////////////
////                                                              ////
////  DAFK JPEG Accelerator top                                   ////
////                                                              ////
////  This file is part of the DAFK Lab Course                    ////
////  http://www.da.isy.liu.se/courses/tsea02                     ////
////                                                              ////
////  Description                                                 ////
////  DAFK JPEG Top Level SystemVerilog Version                   ////
////                                                              ////
////  To Do:                                                      ////
////   - make it smaller and faster                               ////
////                                                              ////
////  Author:                                                     ////
////      - Olle Seger, olles@isy.liu.se                          ////
////      - Andreas Ehliar, ehliar@isy.liu.se                     ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2005-2007 Authors                              ////
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
`include "include/dafk_defines.v"

  typedef     enum {TST, CNT, RST} op_t;
  typedef struct packed
	  {op_t op;
	   logic rden;
	   logic reg1en;
	   logic mux1;
	   logic dcten;
	   logic twr;
	   logic trd;
	   logic [1:0] mux2;
	   logic wren;
	   } mmem_t;

  module jpeg_top(wishbone.slave wb, wishbone.master wbm);

   logic 		 state;
   logic [6:0] 		 mpc;
   logic [31:0] 	 dout_res;
   logic 		 ce_in, ce_ut;
   logic [5:0] 		 rdc;
   logic [4:0] 		 wrc;

   logic [31:0] 	 dob, ut_doa;
   
   logic [0:7][11:0] 	 x, in, ut;

   logic [0:7][15:0] 	 y;   

   logic [31:0] 	 reg1;
   
   logic [31:0] 	 q, dia;
   logic [31:0] 	 doa;
   logic 		 csren;
   logic [7:0] 		 csr;
   logic 		 clr;
   mmem_t 	mmem;

   logic 		 dmaen;

   logic 		 dct_busy;
   logic 		 dma_start_dct;

   // ********************************************
   // *          Wishbone interface              *
   // ********************************************

   assign 	 ce_in = wb.stb && (wb.adr[12:11]==2'b00); // Input mem
   assign 	 ce_ut = wb.stb && (wb.adr[12:11]==2'b01); // Output mem
   assign 	 csren = wb.stb && (wb.adr[12:11]==2'b10); // Control reg
   assign        dmaen = wb.stb && (wb.adr[12:11]==2'b11); // DMA control
   
   
   // ack FSM
   // You must create the wb.ack signal somewhere...
   
   // You must change the error signal when you
   // have implemented your design
   assign wb.err = wb.stb;

   assign wb.rty = 1'b0;
   
   // Signals to the blockrams...
   logic [31:0] dma_bram_data;
   logic [8:0]  dma_bram_addr;
   logic        dma_bram_we;

   logic [31:0] bram_data;
   logic [8:0]  bram_addr;
   logic        bram_we;
   logic        bram_ce;

   logic [31:0] wb_dma_dat;

   // You must create the signals to the block ram somewhere...

   
   jpeg_dma dma
     (
      .clk_i(wb.clk), .rst_i(wb.rst),

      .wb_adr_i	(wb.adr),
      .wb_dat_i	(wb.dat_o),
      .wb_we_i	(wb.we),
      .dmaen_i	(dmaen),
      .wb_dat_o	(wb_dma_dat),

      .wbm(wbm),
      
      .dma_bram_data		(dma_bram_data[31:0]),
      .dma_bram_addr		(dma_bram_addr[8:0]),
      .dma_bram_we		(dma_bram_we),

      .start_dct (dma_start_dct),
      .dct_busy (dct_busy)
      );
   
   RAMB16_S36_S36 #(.SIM_COLLISION_CHECK("NONE")) inmem
     (// WB read & write
      .CLKA(wb.clk), .SSRA(wb.rst),
      .ADDRA(bram_addr),
      .DIA(bram_data), .DIPA(4'h0), 
      .ENA(bram_ce), .WEA(bram_we), 
      .DOA(doa), .DOPA(),
      // DCT read
      .CLKB(wb.clk), .SSRB(wb.rst),
      .ADDRB({3'h0,rdc}),
      .DIB(32'h0), .DIPB(4'h0), 
      .ENB(1'b1),.WEB(1'b0), 
      .DOB(dob), .DOPB());
   
   RAMB16_S36_S36 #(.SIM_COLLISION_CHECK("NONE")) utmem
     (// DCT write
      .CLKA(wb.clk), .SSRA(wb.rst),
      .ADDRA({4'h0,wrc}),
      .DIA(q), .DIPA(4'h0), .ENA(1'b1),
      .WEA(mmem.wren), .DOA(ut_doa), .DOPA(),
      // WB read & write
      .CLKB(wb.clk), .SSRB(wb.rst),
      .ADDRB(wb.adr[10:2]),
      .DIB(wb.dat_o), .DIPB(4'h0), .ENB(ce_ut),
      .WEB(wb.we), .DOB(dout_res), .DOPB());

   // You must create the wb.dat_i signal somewhere...

   // You must also create the control logic...
   				      
   // 8 point DCT
   // control: dcten
   dct dct0
     (.y(y), .x(x), 
      .clk_i(wb.clk), .en(mmem.dcten)
   );

   
   // transpose memory
   // control: trd, twr

   transpose tmem
     (.clk(wb.clk), .rst(wb.rst), 
      .wr(mmem.twr) , .rd(mmem.trd), 
      .in({y[7][11:0],y[6][11:0],y[5][11:0],y[4][11:0],y[3][11:0],y[2][11:0],y[1][11:0],y[0][11:0]}), 
      .ut(ut));

   
   
endmodule

// Local Variables:
// verilog-library-directories:("." ".." "../or1200" "../jpeg" "../pkmc" "../dvga" "../uart" "../monitor" "../lab1" "../dafk_tb" "../eth" "../wb" "../leela")
// End:
