//////////////////////////////////////////////////////////////////////
////                                                              ////
////  DAFK DCT                                                    ////
////                                                              ////
////  This file is part of the DAFK Lab Course                    ////
////  http://www.da.isy.liu.se/courses/tsea02                     ////
////                                                              ////
////  Description                                                 ////
////  1-D DCT, Loeffler's algorithm                               ////
////                                                              ////
////  To Do:                                                      ////
////   - make it smaller and faster                               ////
////                                                              ////
////  Author:                                                     ////
////      - Olle Seger, olles@isy.liu.se                          ////
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

module dct(/*AUTOARG*/
	   // Outputs
	   output logic [0:7][15:0] y, 
	   // Inputs
	   input logic [0:7][11:0] x, 
	   input logic clk_i, en
	   );
   // 16-bit Fixpoint representation on [-4,4[
   // Real numbers are multiplied by 8192
   logic signed [15:0] C6  =  16'd4433; // sqrt(2) * (c6)
   logic signed [15:0] S6  =  16'd10703; // sqrt(2) * (s6)
   logic signed [15:0] FIX_0_298631336  = 2446;  // sqrt(2) * (-c1+c3+c5-c7)
   logic signed [15:0] FIX_0_390180644  = 3196;  // sqrt(2) * (c5-c3)
   logic signed [15:0] FIX_0_541196100  = 4433;
   logic signed [15:0] FIX_0_765366865  = 6270;
   logic signed [15:0] FIX_0_899976223  = 7373;  // sqrt(2) * (c7-c3)
   logic signed [15:0] FIX_1_175875602  = 9633;  // sqrt(2) * c3
   logic signed [15:0] FIX_1_501321110  = 12299; // sqrt(2) * ( c1+c3-c5-c7)
   logic signed [15:0] FIX_1_847759065  = 15137;
   logic signed [15:0] FIX_1_961570560  = 16069; // sqrt(2) * (-c3-c5)
   logic signed [15:0] FIX_2_053119869  = 16819; // sqrt(2) * ( c1+c3-c5+c7)
   logic signed [15:0] FIX_2_562915447  = 20995; // sqrt(2) * (-c1-c3)
   logic signed [15:0] FIX_3_072711026  = 25172; // sqrt(2) * ( c1+c3+c5-c7)

   // First stage
   logic signed [11:0]  x0[0:7];
   logic signed [12:0]  x1[0:7]; 

   // Second stage
   logic signed [13:0]  x2[0:7]; 

   logic signed [13:0]  z1; 
   logic signed [13:0]  z2;
   logic signed [13:0]  z3;
   logic signed [13:0]  z4;
   logic signed [15:0] 	z5;

   // Third stage
   logic signed [14:0]  x3_0; 
   logic signed [14:0]  x3_1;
   logic signed [28:0]  x3_2;
   logic signed [28:0]  x3_3;
   
   logic signed [27:0]  x3_4;
   logic signed [27:0]  x3_5;
   logic signed [27:0]  x3_6;
   logic signed [27:0]  x3_7;
   logic signed [27:0]  x3_8;
   logic signed [27:0]  x3_9;

   // Fourth stage
   logic signed [14:0]  x4_0; 
   logic signed [14:0]  x4_4; 
   logic signed [27:0]  x4_2;
   logic signed [28:0]  x4_6;

   logic signed [27:0]  x4_1;
   logic signed [27:0]  x4_3;
   logic signed [27:0]  x4_5;
   logic signed [27:0]  x4_7;

   // ********* Input stage ************
   assign 		x0[0] = x[0];
   assign 		x0[1] = x[1];
   assign 		x0[2] = x[2];
   assign 		x0[3] = x[3];
   assign 		x0[4] = x[4];
   assign 		x0[5] = x[5];
   assign 		x0[6] = x[6];
   assign 		x0[7] = x[7];

   // ********* First stage ************
   always_ff @(posedge clk_i) begin
      if (en) begin
	 x1[0] <= x0[0] + x0[7];
	 x1[7] <= x0[0] - x0[7];

	 x1[1] <= x0[1] + x0[6];
	 x1[6] <= x0[1] - x0[6];

	 x1[2] <= x0[2] + x0[5];
	 x1[5] <= x0[2] - x0[5];

	 x1[3] <= x0[3] + x0[4];
	 x1[4] <= x0[3] - x0[4];
      end
   end // always @ (posedge clk_i)

   // ********* Second stage ************
   always_ff @(posedge clk_i) begin
      if (en) begin
	 x2[0] <= x1[0] + x1[3];
	 x2[3] <= x1[0] - x1[3];
	 x2[1] <= x1[1] + x1[2];
	 x2[2] <= x1[1] - x1[2];

	 x2[4] <= x1[4];
	 x2[5] <= x1[5];
	 x2[6] <= x1[6];
	 x2[7] <= x1[7];

	 z1 <= x1[4] + x1[7];
	 z2 <= x1[5] + x1[6];
	 z3 <= x1[4] + x1[6];
	 z4 <= x1[5] + x1[7];
      end
   end // always @ (posedge clk_i)
   assign z5 = z3 + z4;

   // Work around possible synthesis bug in XST
   logic signed [27:0] foo;
   logic signed [27:0] bar;

   assign 	      foo = x2[2] * S6;   
   assign 	      bar = x2[3] * C6;

   // ********* Third stage ************
   always_ff @(posedge clk_i) begin
      if (en) begin
	 x3_0 <= x2[0] + x2[1];
	 x3_1 <= x2[0] - x2[1];

	 x3_2 <= x2[2]*C6 + x2[3]*S6;
	 x3_3 <= bar - foo;

	 x3_4 <= x2[4] * FIX_0_298631336 - z1 * FIX_0_899976223;
	 x3_5 <= x2[5] * FIX_2_053119869 - z2 * FIX_2_562915447;
	 x3_6 <= x2[6] * FIX_3_072711026 - z2 * FIX_2_562915447;
	 x3_7 <= x2[7] * FIX_1_501321110 - z1 * FIX_0_899976223;
	 x3_8 <= z5 * FIX_1_175875602 - z3 * FIX_1_961570560;
	 x3_9 <= z5 * FIX_1_175875602 - z4 * FIX_0_390180644;
      end
   end // always @ (posedge clk_i)

   // ********* Fourth stage ************
   always_ff @(posedge clk_i) begin
      if (en) begin
	 x4_0 <= x3_0;
	 x4_4 <= x3_1;
	 x4_2 <= x3_2;
	 x4_6 <= x3_3;
	 
	 x4_7 <= x3_4 + x3_8;
	 x4_5 <= x3_5 + x3_9;
	 x4_3 <= x3_6 + x3_8;
	 x4_1 <= x3_7 + x3_9;
      end
   end

   // ********* Output stage ************
   assign y[0] = {x4_0[14],x4_0}; 
   assign y[1] = {x4_1[27],x4_1[27:13]}; 
   assign y[2] = {x4_2[27],x4_2[27:13]}; 
   assign y[3] = {x4_3[27],x4_3[27:13]}; 
   assign y[4] = {x4_4[14],x4_4};	 
   assign y[5] = {x4_5[27],x4_5[27:13]}; 
   assign y[6] = {x4_6[28:13]};
   assign y[7] = {x4_7[27],x4_7[27:13]}; 

endmodule //
// Local Variables:
// verilog-library-directories:("." ".." "../or1200" "../jpeg" "../pkmc" "../dvga" "../uart" "../monitor" "../lab1" "../dafk_tb" "../eth" "../wb" "../leela")
// End:
