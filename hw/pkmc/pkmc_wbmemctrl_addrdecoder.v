`include "include/pkmc_memctrl_defines.v"

module pkmc_wbmemctrl_addrdecoder
  (clk,
   stb_i,
   err_o,
   cyc_i,
   addr_i,
   active,
   muxSel,
   sdramIRQ_in, 
   sdramIRQack_o,
   wb_ack);
   
   input clk;
   input stb_i;
   input wb_ack;
   output err_o;
   input  cyc_i;
   input [`ADDR_I_WIDTH-1:0] addr_i;
   input 		     sdramIRQ_in;
   
   
   output 		     sdramIRQack_o;
   output [`NUM_MEMS-1:0]    active;
   output [`SEL_MUX_WIDTH-1:0] muxSel;

   wire [`NUM_MEMS-1:0]        int_active;

   wire 		       topComp;

   reg 			       sdramIRQ;
   reg 			       sdramIRQ_hold;
   reg 			       sdramIRQack_o;

   always@(posedge clk) begin
      if(~(int_active[0] | int_active[2]) || wb_ack) begin
	 sdramIRQ = sdramIRQ_in;
	 sdramIRQack_o = sdramIRQ_in;
      end
   end
   

   // SRAM 1MB [0x2000_0000, 0x2010_0000)
   assign #1 		       int_active[0] = ((addr_i[31:20] == 12'h200) || (addr_i[31:20] == 12'hc00)) ? ~sdramIRQ : 1'b0;

   // SDRAM 64MB [0x0000_0000, 0x0c00_0000)
   assign #1 		       int_active[1] = (addr_i[31:20] >= 12'h000) && (addr_i[31:20] < 12'h0c0) ? 1'b1 : 1'b0;
   
   // FLASH 16MB [0xf000_0000, 0xf100_0000)
   assign #1 		       int_active[2] = (addr_i[31:20] >= 12'hf00) && (addr_i[31:20] < 12'hf10) ? ~sdramIRQ : 1'b0;

   
   assign #1		    err_o = (stb_i & cyc_i) & ~(|int_active) & ~sdramIRQ;
//   assign 		       err_o = 1'b0;
   
   genvar i;

   generate
      for(i = 0; i<`NUM_MEMS;i = i+1) begin: activeOut
	 assign active[i] = int_active[i] & stb_i & cyc_i;
      end
   endgenerate
   
`ifdef SIMULATE
   initial begin
      if(`NUM_MEMS != 3) begin
	 $display("In %m: Number of memories must be three for datapath muxes to work in current design");
      end
      if (`SEL_MUX_WIDTH != 1) begin
	 $display("In %m: Width of muxSel bus must be roof(log2(`NUM_MEMS))");
      end
   end
`endif

   assign muxSel[0] = sdramIRQ | int_active[1];
   assign muxSel[1] = ~sdramIRQ & int_active[2];
   
endmodule
// Local Variables:
// verilog-library-directories:("." ".." "../or1200" "../jpeg" "../pkmc" "../dvga" "../uart" "../monitor" "../lab1" "../dafk_tb" "../eth" "../wb" "../leela")
// End:
