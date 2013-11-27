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
    logic [8:0] 		 rdc;
    logic [4:0] 		 wrc;

    logic [31:0] 	 dob, dob2, ut_doa;

    logic [0:7][11:0] 	 x, in, ut;

    logic [0:7][15:0] 	 y;

    logic [31:0] 	 reg1;

    logic [31:0] 	 q, dia;
    logic [31:0] 	 doa;
    logic 		 csren;
    logic [7:0] 		 csr;
    logic 		 clr;
    mmem_t 	mmem;

    logic 		 dmaen, ctrl_control;
    logic [15:0] rec_o2;
    logic [15:0] rec_o1;
    logic 		 dct_busy;
    logic 		 dma_start_dct;
    logic [31:0]  reciprocal_counter;
    logic         dff1;
    logic         dff2;
    logic         dff1rst;
    logic         dff2rst;
    reg 	ack;
    // ********************************************
    // *          Wishbone interface              *
    // ********************************************

    assign ce_in = wb.stb && (wb.adr[12:11]==2'b00); // Input mem
    assign ce_ut = wb.stb && (wb.adr[12:11]==2'b01); // Output mem
    assign csren = wb.stb && (wb.adr[12:11]==2'b10); // Control reg
    assign dmaen = wb.stb && (wb.adr[12:11]==2'b11); // DMA control

    /*
    81  82  83  84
    10000001    10000010    10000011    10000100
    10000101    10000110    10000111    10001000
    10001001    10001010    10001011    10001100
    */
    // ack FSM
    // You must create the wb.ack signal somewhere...
    //set ack
    always @(posedge wb.clk)
    begin
        if (wb.rst)
            ack <= 1'b0;
        else if (~dff1rst && dff2rst)
            ack <= 1'b0;
        else if (wb.stb)
            ack <= 1'b1;
        else
            ack <= 1'b0;
    end

    always @(posedge wb.clk)
    begin
        if (wb.rst)
            dff1 <= 1'b0;
        else 
            dff1 <= wb.we;
        dff2 <= dff1;
    end

    always @(posedge wb.clk)
    begin
        dff1rst <= wb.rst;
        dff2rst <= dff1rst;
    end    

    assign wb.ack = ack;

    assign int_o = 1'b0;  // Interrupt, not used in this lab
    assign wb.err = 1'b0; // Error, not used in this lab
    assign wb.rty = 1'b0; // Retry, not used in this course

    // Signals to the blockrams...
    logic [31:0] dma_bram_data;
    logic [8:0]  dma_bram_addr;
    logic        dma_bram_we;

    logic [31:0] bram_data;
    logic [8:0]  bram_addr;
    logic        bram_we;
    logic        bram_ce;

    logic [31:0] wb_dma_dat;
    logic [8:0] clock_counter;

    reg [5:0] in_counter;
    reg [31:0] dflipflop;
    reg read_enable;
    reg [7:0] DC2_ctrl_counter;
    reg clk_div2;
    reg clk_div4;
    reg [2:0] divcounter;
    reg mux2_enable;
    reg [1:0] mux2_counter;
    reg [31:0] mux2_out;


    int reciprocals [] = {2048,	1820,	3277,	819,	512,	819,	585,	290,
        2979,	1489,	2048,	1489,	405,	643,	377,	356,
        2731,	1365,	1365,	1130,	420,	537,	410,	271,
        2731,	936,	2341,	643,	377,	565,	529,	273,
        2341,	669,	1725,	886,	318,	546,	301,	324,
        2521,	512,	1260,	585,	345,	596,	318,	328,
        2341,	455,	2048,	482,	334,	575,	426,	318,
        1928,	356,	1365,	596,	293,	475,	315,	331};

    /*2048,	2979,	2731,	2731,	2341,	2521,	2341,	1928,
    1820,	1489,	1365,	936,	669,	512,	455,	356,
    3277,	2048,	1365,	2341,	1725,	1260,	2048,	1365,
    819,	1489,	1130,	643,	886,	585,	482,	596,
    512,	405,	420,	377,	318,	345,	334,	293,
    819,	643,	537,	565,	546,	596,	575,	475,
    585,	377,	410,	529,	301,	318,	426,	315,
    290,	356,	271,	273,	324,	328,	318,	331};*/


    // You must create the signals to the block ram somewhere...

    always @(posedge wb.clk) begin
      if (wb.rst) begin
         read_enable <= 1'b0;
         bram_data <= 32'b0;
         bram_addr <= 32'b0;
         bram_ce <= 1'b0;  
         bram_we <= 1'b0;
         rdc <= 9'b0;
         in_counter <= 5'h0;
         dflipflop <= 32'b0;

      // if write is finished and we are reading from the memory
      end else if (read_enable) begin
         // count up address memory on every second clock cycle
         if (clk_div2) begin
            rdc <= rdc + 4;
            dflipflop <= dob;
            if (rdc == 9'h40) begin
               rdc <= 9'd0;
               read_enable <= 1'b0;
            end
         end
      // if we want to write to the in block memory
      end else if (dff1 && ~dff2 && ce_in) begin
         bram_we <= wb.we;
         bram_ce <= 1'b1;
         in_counter <= in_counter + 1;

         bram_data <= wb.dat_o;
         bram_addr <= wb.adr;
      end else if (in_counter == 5'd16) begin
         // when the write is finished
         in_counter <= 5'd0;
         read_enable <= 1'b1;
         bram_we <= 1'b0;
         bram_ce <= 1'b0;
      end
    end

    //Mux till dct
    always_comb begin
        if (~mmem.mux1 && divcounter == 3'h3)
            x = {32'd0,dflipflop,dob};
        else if (mmem.mux1)
            x = ut;
    end

    always @(posedge wb.clk) begin
      if (wb.rst) begin
         bram_data <= 32'b0;
         bram_addr <= 32'b0;
      end else if (ce_ut) begin
         bram_data <= wb.dat_o;
         bram_addr <= wb.adr;
      end
    end

    //setting clk_div2...
    always @(posedge wb.clk) begin
        if (wb.rst) begin
            clk_div2 <= 1'b0;
            clk_div4 <= 1'b0;
            divcounter <= 3'b0;
        end else begin
            divcounter <= divcounter + 1;
            clk_div2 <= ~clk_div2;
            if (divcounter == 3'h3) begin
                clk_div4 <= 1'b1;
                divcounter <= 3'b0;
            end else begin
                clk_div4 <= 1'b0;
            end
        end
    end

    always @(posedge wb.clk) begin
        if(clock_counter == 2'h3) 
            clock_counter <= 2'h0;
        else
            clock_counter <= clock_counter + 1;
    end
    
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
      .ADDRB(rdc),
      .DIB(32'h0), .DIPB(4'h0),
      .ENB(1'b1),.WEB(1'b0),
      .DOB(dob2), .DOPB());
      
    assign dob = dob2;
    
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
    assign wb.dat_i = dout_res;

    always @(posedge wb.clk) begin
        if (wb.rst)
            ctrl_control <= 1'b0;
        else if (read_enable)
            ctrl_control <= 1'b1;
        else if (DC2_ctrl_counter == 8'd29) 
            ctrl_control <= 1'b0;
    end

    // the control logic
    always @(posedge wb.clk) begin
      if(wb.rst) begin
         mmem.rden <= 1'b0;
         mmem.reg1en <= 1'b0;
         mmem.mux1 <= 1'b0;
         mmem.dcten <= 1'b0;
         mmem.twr <= 1'b0;
         mmem.trd <= 1'b0;
         mmem.wren <= 1'b0;
         mux2_enable <= 1'b0;
         DC2_ctrl_counter <= 8'b0;
      end else if (ctrl_control) begin
         if (clk_div4) 
            DC2_ctrl_counter <= DC2_ctrl_counter + 1;
         if(divcounter == 3'h3) begin
            // Enable DCT and get its input from block RAM
            mmem.dcten <= 1'b1;
            //mmem.mux1 <= 1'b0;

         // DCT takes 4 cs, so when ready...
         end else if (DC2_ctrl_counter == 8'd5) begin
            // ...begin write to transpose memory
            mmem.twr <= 1'b1;

         // transpose write takes 8 cs
         end else if (DC2_ctrl_counter == 8'd13) begin
            // stop write, begin read
            mmem.twr <= 1'b0;
            mmem.trd <= 1'b1;
            // send transpose memory output to DCT
            mmem.mux1 <= 1'b1;

         // the first row transpose arrives out from DCT
         end else if (DC2_ctrl_counter == 8'd17) begin
            // begin writing result
            mux2_enable <= 1'b1;
            mmem.wren <= 1'b1;

         // 8 cc later, all rows are out of transpose memory
         end else if (DC2_ctrl_counter == 8'd25) begin
            // stop reading from transpose
            mmem.trd <= 1'b0;
            mmem.wren <= 1'b0;
            

         end else if (DC2_ctrl_counter == 8'd29) begin
            // turn off DCT
            mmem.dcten <= 1'b0;
            
         end
      end else begin
         mmem.rden <= 1'b0;
         mmem.reg1en <= 1'b0;
         mmem.mux1 <= 1'b0;
         mmem.dcten <= 1'b0;
         mmem.twr <= 1'b0;
         mmem.trd <= 1'b0;
         mmem.wren <= 1'b0;
         mux2_enable <= 1'b0;
         DC2_ctrl_counter <= 8'b0;
      end
    end
    //reciprocal_counter!!!
    always @(posedge wb.clk) begin
      if (wb.rst) 
        reciprocal_counter <= 0;
      else if(mux2_enable)
        reciprocal_counter <= reciprocal_counter + 2;
      else if(reciprocal_counter == 32'h40)
        reciprocal_counter <= 0;
        
    end 

    //mux2
    always_comb begin
      case(mmem.mux2)
         2'h1:    mux2_out = y[2:3];
         2'h2:    mux2_out = y[4:5];
         2'h3:    mux2_out = y[6:7];
         default: mux2_out = y[0:1];
      endcase
    end


    //count mux2 counter and output memory.
    always @(posedge wb.clk) begin
      if(wb.rst) begin

         mux2_counter <= 2'd0;
         wrc <= 1'b0;
      end else if(mux2_enable) begin
         mux2_counter <= mux2_counter + 1;
         wrc <= wrc + 1;
      end else begin
         mux2_counter <= 2'd0;
         wrc <= 1'b0;
      end
    end

    //mux2 styrsignal
    always_comb begin
        case(mux2_counter)
        2'd1:    mmem.mux2 = 2'd1;
        2'd2:    mmem.mux2 = 2'd2;
        2'd3:    mmem.mux2 = 2'd3;
        default: mmem.mux2 = 2'd0;
     endcase

    end

    //set reciprocals
    always_comb begin
        rec_o1 = reciprocals[reciprocal_counter];
        rec_o2 = reciprocals[reciprocal_counter+1];
    end

    // 8 point DCT
    // control: dcten //ändrat ny långsammare klocka.
    dct dct0
     (.y(y), .x(x),
      .clk_i(clk_div4), .en(mmem.dcten)
    );
    //Paul: Jag gillar inte eclipse.
    q2 Q2 (
      .x_i(mux2_out), .x_o(q),
      .rec_i1(rec_o1),
      .rec_i2(rec_o2) // !! TODO, rec_i shoud be something better
    );

    // transpose memory
    // control: trd, twr

    transpose tmem
     (.clk(wb.clk), .rst(wb.rst),
      .t_wr(mmem.twr) , .t_rd(mmem.trd),
      .data_in({y[7][11:0],y[6][11:0],y[5][11:0],y[4][11:0],y[3][11:0],y[2][11:0],y[1][11:0],y[0][11:0]}),
      .data_out(ut));

endmodule

// Local Variables:
// verilog-library-directories:("." ".." "../or1200" "../jpeg" "../pkmc" "../dvga" "../uart" "../monitor" "../lab1" "../dafk_tb" "../eth" "../wb" "../leela")
// End:
