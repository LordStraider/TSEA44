`include "include/pkmc_memctrl_defines.v"
`include "include/pkmc_sdram_defines.v"

module pkmc_sdramctrl_top(rst,
			  clk,
			  addr_i,
			  dat_i,
			  byte_sel,
			  we_i,
			  active_i,
			  dat_o,
			  ack_o,
			  shftClk,
			  sdramIRQ,
			  sdramAddr_o,
			  sdramBank_o,
			  sdramData_o,
			  sdramData_i,
			  sdramCommand_o,
			  sdramCke_o,
			  sdramByteSel_o,
			  sdramIRQack);

   input rst;
   input clk;
   input shftClk;
   input [`ADDR_I_WIDTH-1:0] addr_i;
   input [`DAT_I_WIDTH-1:0] dat_i;
   input [`SEL_I_WIDTH-1:0]   byte_sel;
   input 		    we_i;
   input 		    active_i;
   input 		    sdramIRQack;
   
   output [`DAT_I_WIDTH-1:0] dat_o;
   output 		     ack_o;
   output 		     sdramIRQ;
   output [`SDRAM_ADDRLEN-1:0] sdramAddr_o;
   output [`BANKLEN-1:0]       sdramBank_o;
   input [`DATALEN-1:0]        sdramData_i;
   output [`DATALEN-1:0]       sdramData_o;
   output [`COMMAND_LEN-1:0]   sdramCommand_o;
   output 		       sdramCke_o;
   output [`SEL_I_WIDTH-1:0]   sdramByteSel_o;

   wire [`BANKS-1:0] 	       currBank;
   wire [`BANKS-1:0] 	       newRowResVec;
   wire 		       all_one;
   wire 		       apc;
   wire [`COMMAND_LEN-1:0]     command;

   wire 		       prechCmd_o;
   wire 		       activeCmd_o;
   wire 		       readCmd_o;
   wire 		       writeCmd_o;
   
   
   genvar i;

   
   assign #1 		       sdramCommand_o = command;

   
   generate 
      for(i = 0; i<`BANKS; i = i+1) begin: newRowLogic
	 pkmc_rowcheck rowEval
	   (
	    .clk(clk),
	    .rst(rst),
	    .loadEn(currBank[i]),
	    .rowAddr(addr_i[23:11]),
	    .equal(newRowResVec[i])
	    );
      end
   endgenerate

`ifdef SIMULATE
   initial begin
      if(`BANKS != 4) begin
	 $display("### In %m: Number of banks must be four for current design to work");
      end
   end
`endif
   
   assign #1 currBank[0] = ~addr_i[25] & ~addr_i[24] & active_i;
   assign #1 currBank[1] = ~addr_i[25] & addr_i[24] & active_i;
   assign #1 currBank[2] = addr_i[25] & ~addr_i[24] & active_i;
   assign #1 currBank[3] = addr_i[25] & addr_i[24] & active_i;
   
   pkmc_sdramctrl_centralctrl central_controler
     (
      .clk(clk),
      .rst(rst),
      .active(active_i),
      .bankVector(currBank),
      .bankNum(addr_i[25:24]),
      .newRow(~newRowResVec[addr_i[25:24]]),
      .we_i(we_i),
      .ack_o(ack_o),
      .all_one(all_one),
      .autoPrecharge(apc),
      .command(command),
      .cke(sdramCke_o),
      .sdramIRQ(sdramIRQ),
      .prechCmd_o(prechCmd_o),
      .activeCmd_o(activeCmd_o),
      .readCmd_o(readCmd_o),
      .writeCmd_o(writeCmd_o),
      .sdramIRQack(sdramIRQack)
      );

   assign #1 sdramByteSel_o = ~byte_sel;
   assign    sdramData_o = dat_i;
   assign    dat_o = sdramData_i;


   pkmc_sdramctrl_addrgen addrgen
     (
      .addr_i(addr_i[`ADDRLEN-1:0]),
      .apc(apc),
      .all_one(all_one),
      .addrOut(sdramAddr_o),
      .bankOut(sdramBank_o),
      .prechCmd_i(prechCmd_o),
      .activeCmd_i(activeCmd_o),
      .readCmd_i(readCmd_o),
      .writeCmd_i(writeCmd_o)
      );
   

endmodule
// Local Variables:
// verilog-library-directories:("." ".." "../or1200" "../jpeg" "../pkmc" "../dvga" "../uart" "../monitor" "../lab1" "../dafk_tb" "../eth" "../wb" "../leela")
// End:
