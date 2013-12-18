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

`define HEIGHT 2
`define WIDTH 3
`define PITCH (`WIDTH*8)

module jpeg_top_tb();
   logic       clk = 1'b0;
   logic       rst = 1'b1;
   wishbone wb(clk,rst);
   wishbone wbm(clk,rst);

   initial begin
      #200 rst = 1'b0;
   end

   always #20 clk = ~clk;

   // Instantiate the DUT
   jpeg_top dut(.*);
   mem mem0(.*);

   wishbone_tasks wb0(wb);

   // Instantiate the tester
   test_jpeg tester0();
endmodule // jpeg_top_tb

module mem(wishbone.slave wbm);
   logic [7:0] rom[0:2047];
   logic [1:0]  state;
   logic [8:0] adr;
   integer     blockx, blocky, x, y, i;

   initial begin
  // A test image, same as dma_dct_hw.c
  for (blocky=0; blocky<`HEIGHT; blocky++)
    for (blockx=0; blockx<`WIDTH; blockx++)
      for (i=1, y=0; y<8; y++)
    for (x=0; x<8; x++)
      rom[blockx*8+x+(blocky*8+y)*`PITCH] = i++ - 128;
   end

   assign wbm.err = 1'b0;
   assign wbm.rty = 1'b0;

   always_ff @(posedge wbm.clk)
     if (wbm.rst)
    state <= 2'h0;
     else
    case (state)
      2'h0: if (wbm.stb) state <= 2'h1;
      2'h1: state <= 2'h2;
      2'h2: state <= 2'h0;
    endcase

   assign wbm.ack = state[1];

   always_ff @(posedge wbm.clk)
     adr <= wbm.adr[8:0];

   assign wbm.dat_i = {rom[adr], rom[adr+1], rom[adr+2], rom[adr+3]};
endmodule // mem


program test_jpeg();
   int result = 0;
   // int d = 32'h807F807F;   // subtract 128 => d = {-127,-126,-125,-124}

    int d;
    int i = 0;
    int i1, i2, i3, csr;

   initial begin
        //SRCADDR
        jpeg_top_tb.wb0.m_write(32'h96001800, 0);
        //PITCH
        jpeg_top_tb.wb0.m_write(32'h96001804, `PITCH);
        //ENDBLOCK_X
        jpeg_top_tb.wb0.m_write(32'h96001808, `WIDTH-1);
        //ENDBLOCK_Y
        jpeg_top_tb.wb0.m_write(32'h9600180c, `HEIGHT-1);
        //CONTROL
        jpeg_top_tb.wb0.m_write(32'h96001810, 1);
        
    
    /*jpeg_top_tb.wb0.m_read(32'h96001800, result);
    $fwrite(1," %08X, ", result);
    jpeg_top_tb.wb0.m_read(32'h96001804, result);
    $fwrite(1," %08X, ", result);
    jpeg_top_tb.wb0.m_read(32'h96001808, result);
    $fwrite(1," %08X, ", result);
    jpeg_top_tb.wb0.m_read(32'h9600180c, result);
    $fwrite(1," %08X\n", result);*/
   
    for (int run=0; run<`HEIGHT; run++) begin
      for (int run2=0; run2<`WIDTH; run2++) begin
          
          
          result = 0;
          while ((csr & 32'h00000002 ) != 32'h00000002) begin
             // jpeg_top_tb.wb0.m_read(32'h96001000, result);
              
              jpeg_top_tb.wb0.m_read(32'h96001810, csr);
              /*jpeg_top_tb.wb0.m_read(32'h96001814, i1);
              jpeg_top_tb.wb0.m_read(32'h96001818, i2);
              jpeg_top_tb.wb0.m_read(32'h9600181c, i3);
              $fwrite(1,"csr: %08X, result: %08X, i1: %08X, i2: %08X, i3: %08X\n", csr, result, i1, i2, i3);*/
          end
         
          #2000
           
            for (int j=0; j<8; j++) begin
                for (int i=0; i<4; i++) begin
                    jpeg_top_tb.wb0.m_read(32'h96000800 + 4*i + j*16,result);
                    $fwrite(1,"%5d ", result >>> 16);
                    $fwrite(1,"%5d ", (result << 16) >>>16);
                end
                $fwrite(1,"\n");
            end
            
          //CONTROL
          if (run != `HEIGHT-1 && run2 != `WIDTH-1)
              jpeg_top_tb.wb0.m_write(32'h96001810, 2);
            
                       
          //d = 32'h81828384;

  /*      for (int run=0; run<10; run++) begin
          //d = 32'h807F807F;
          d = 32'h81828384;
           for (int i=0; i<16; i++) begin //16


             /*    if((i +1)% 4 < 2)
                    d = 32'h807F807F;
                 else
                    d = 32'h7F807F80;

                  if(i % 2)
                    d = 32'h80808080;

                  jpeg_top_tb.wb0.m_write(32'h96000000 + 4*i, d);
                d += 32'h04040404;
           end
           for (int i=0; i<16; i++) begin //16
              jpeg_top_tb.wb0.m_read(32'h96000000 + 4*i, result);
              $fwrite(1,"%08X\n ", result);
           end
           $fwrite(1,"-----\n");

            jpeg_top_tb.wb0.m_write(32'h96001000, 32'h1);

            while (result != 32'd128)
                jpeg_top_tb.wb0.m_read(32'h96001000,result);

            jpeg_top_tb.wb0.m_write(32'h96001000, 32'h0);

            for (int j=0; j<8; j++) begin
                for (int i=0; i<4; i++) begin
                    jpeg_top_tb.wb0.m_read(32'h96000800 + 4*i + j*16,result);
                    $fwrite(1,"%5d ", result >>> 16);
                    $fwrite(1,"%5d ", (result << 16) >>>16);
                end
            $fwrite(1,"\n");
            end

           $fwrite(1,"-----\n");
           $fwrite(1,"new run\n");
           $fwrite(1,"\n");
*/

          end
        end
        #20000000;
    end



//d = 32'h81828384;
//
//      for (int i=0; i<16; i++) begin
//       jpeg_top_tb.wb0.m_write(32'h96000000 + 4*i, d);
//       d += 32'h04040404;
//      end
//
//      jpeg_top_tb.wb0.m_write(32'h96001000, 32'h01000000);
//
//      while (result != 32'd128)
//  jpeg_top_tb.wb0.m_read(32'h96001000,result);
//
//    jpeg_top_tb.wb0.m_write(32'h96001000, 32'h0);
//
//      for (int j=0; j<8; j++) begin
//   for (int i=0; i<4; i++) begin
//      jpeg_top_tb.wb0.m_read(32'h96000800 + 4*i + j*16,result);
//      $fwrite(1,"%5d ", result >>> 16);
//      $fwrite(1,"%5d ", (result << 16) >>> 16);
//   end
//   $fwrite(1,"\n");
//      end
//
//   $fwrite(1,"-----\n");
//   $fwrite(1,"in inmem\n");
//
//      for (int i=0; i<16; i++) begin
//        jpeg_top_tb.wb0.m_read(32'h96000000 + 4*i, d);
//        $fwrite(1,"%d\n ", d);
//      end
//   end

endprogram // tester


// Local Variables:
// verilog-library-directories:("." ".." "../or1200" "../jpeg" "../pkmc" "../dvga" "../uart" "../monitor" "../lab1" "../dafk_tb" "../eth" "../wb" "../leela")
// End:
