`include "include/pkmc_memctrl_defines.v"
`include "include/pkmc_sdram_defines.v"

module pkmc_sdram_ackgen(rst, read, write, clk, ack);
   input read;
   input write;
   input clk;
   input rst;
   
   output ack;

`ifdef CAS_LATENCY_3
   localparam readWaitLen = 4;
`else
   localparam readWaitLen = 3;
`endif

   localparam writeWaitLen = 2;
   
   reg [readWaitLen-1:0] readAck;
   reg [writeWaitLen-1:0] writeAck;	  

   
   always@(posedge clk or posedge rst) begin
      if(rst) begin
	 readAck <= 0;
      end
      else begin
	 readAck <= {readAck[readWaitLen-2:0], read};
      end // else: !if(rst)
   end // always@ (posedge clk or posedge rst)

   always@(posedge clk or posedge rst) begin
      if(rst) begin
	 writeAck <= 2'b10;
      end
      
      else if(write | writeAck[0]) begin
	 writeAck <= {writeAck[0], writeAck[1]};
      end
   end
      
   
   assign #1 ack = writeAck[0] | readAck[readWaitLen-1];

endmodule // sdram_ackgen

      // Local Variables:
// verilog-library-directories:("." ".." "../or1200" "../jpeg" "../pkmc" "../dvga" "../uart" "../monitor" "../lab1" "../dafk_tb" "../eth" "../wb" "../leela")
// End:
