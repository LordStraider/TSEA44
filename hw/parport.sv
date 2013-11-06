//////////////////////////////////////////////////////////////////////
////                                                              ////
////  DAFK parport                                                ////
////                                                              ////
////  This file is part of the DAFK Lab Course                    ////
////  http://www.da.isy.liu.se/courses/tsea02                     ////
////                                                              ////
////  Description                                                 ////
////  A simple parallel port, SystemVerilog Version               ////
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

// synopsys translate_off
`include "include/timescale.v"
// synopsys translate_on
  
module parport	(wishbone.slave wb,
		 input logic[31:0] in_pad_i,
		 output logic [31:0] out_pad_o);

   //
   // Local signals
   logic [31:0] out_reg, in_reg;
   
   assign     wb.err = 1'b0;
   assign     wb.rty = 1'b0;
   assign     wb.ack = wb.stb && wb.cyc;
   assign     wb.dat_i = in_reg;

   assign     out_pad_o = out_reg;
   
   always_ff @(posedge wb.clk) begin
	if (wb.rst)
	  out_reg <= 32'h0;
	else if (wb.cyc && wb.stb && wb.we)
	  out_reg <= wb.dat_o;
   end

   always_ff @(posedge wb.clk) begin
      if (wb.rst)
	in_reg <= 32'h0;
      else
	in_reg <= in_pad_i;
   end
   
endmodule
// Local Variables:
// verilog-library-directories:("." "or1200" "jpeg" "pkmc" "dvga" "uart" "monitor" "lab1" "dafk_tb" "eth" "wb" "leela")
// End:
