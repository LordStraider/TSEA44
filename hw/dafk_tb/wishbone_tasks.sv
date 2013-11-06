//////////////////////////////////////////////////////////////////////
////                                                              ////
////  DAFK JPEG Accelerator Testbench                             ////
////                                                              ////
////  This file is part of the DAFK Lab Course                    ////
////  http://www.da.isy.liu.se/courses/tsea02                     ////
////                                                              ////
////  Description                                                 ////
////  DAFK JPEG Testbench SystemVerilog Version                   ////
////                                                              ////
////  To Do:                                                      ////
////   - include assertions!                                      ////
////                                                              ////
////  Author:                                                     ////
////      - Olle Seger, olles@isy.liu.se                          ////
////      - Andreas Ehliar, ehliar@isy.liu.se                     ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2000 Authors                                   ////
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

module wishbone_tasks(wishbone.master wb);
   int result = 0;

   reg oldack;
   reg [31:0] olddat;

   // This could probably be done in a neater way with
   // clocking blocks but in this way it is obvious what is
   // going on.
   always @(posedge wb.clk) begin
      oldack <= wb.ack;
      olddat <= wb.dat_i;
   end
   

   // ******************************
   task m_read(input [31:0] adr, output logic [31:0] data);
      begin
	 @(posedge wb.clk);
	 wb.adr <= adr;
	 wb.stb <= 1'b1;
	 wb.we  <= 1'b0;
	 wb.cyc <= 1'b1;
	 wb.sel <= 4'hf;
	 
	 @(posedge wb.clk);
	 #1; // After this delay we are guaranteed that the always
	     // block above has executed

	 // If we got an ack in the previous cycle we are
	 // finished.
	 while (!oldack) begin
	   @(posedge wb.clk);
           #1;
	 end
	 
	 wb.stb <= 1'b0;
	 wb.we  <= 1'b0;
	 wb.cyc <= 1'b0;
	 wb.sel <= 4'h0;
	 
	 data = olddat;
      end
   endtask // m_read
   
   // ******************************
   task m_write(input [31:0] adr, input [31:0] dat);
      begin
	 @(posedge wb.clk);
	 wb.adr <= adr;
	 wb.dat_o <= dat;
	 wb.stb <= 1'b1;
	 wb.we <= 1'b1;
	 wb.cyc <= 1'b1;
	 wb.sel <= 4'hf;

	 @(posedge wb.clk);
	 #1;
	 
	 while (!oldack) begin
	   @(posedge wb.clk);
           #1;
	 end
	 
	 wb.stb <= 1'b0;
	 wb.we  <= 1'b0;
	 wb.cyc <= 1'b0;
	 wb.sel <= 4'h0;
      end
   endtask // m_write

endmodule // wishbone_tasks

   

// Local Variables:
// verilog-library-directories:("." ".." "../or1200" "../jpeg" "../pkmc" "../dvga" "../uart" "../monitor" "../lab1" "../dafk_tb" "../eth" "../wb" "../leela")
// End:
