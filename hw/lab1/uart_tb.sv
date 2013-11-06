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

module suart_tb();
   logic       clk = 1'b0;
   logic       rst = 1'b1;
   logic       int_o, rx_tx;
       
   wishbone wb(clk,rst);

   initial begin
      #75 rst = 1'b0;
   end
   
   always #20 clk = ~clk;

   // Instantiate the DUT
   lab1_uart_top dut(wb, int_o, rx_tx, rx_tx);
   
   wishbone_tasks wb0(wb);
   
   // Instantiate the tester
   test_uart test_uart0();
endmodule // jpeg_top_tb

program test_uart();
   int A = 32'h41000000;
   int result = 0;
   int i;
   
   initial begin
      for (i=0;i<25;i++) begin
	 suart_tb.wb0.m_write(32'h90000000, A);
	 #400;
	 while (result != 32'h00010000) begin
	    suart_tb.wb0.m_read(32'h90000004, result);
	    result = result & 32'h00010000;
	    #400;
	 end
	 suart_tb.wb0.m_read(32'h90000000, result);
	 #400;
	 result = 0;
	 A = A + 32'h01000000;
      end
   end

endprogram // test_uart
   
   
