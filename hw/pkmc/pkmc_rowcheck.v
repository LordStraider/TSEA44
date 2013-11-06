`include "include/pkmc_sdram_defines.v"
`include "include/pkmc_memctrl_defines.v"

module pkmc_rowcheck(clk,loadEn,rowAddr,equal,rst);
   input clk;
   input loadEn;
   input [`ROWLEN-1:0] rowAddr;
   output 	equal;
   input 	rst;

   wire 	intEqual;
   wire 	loadNew;
   
   reg [`ROWLEN-1:0] 	oldAddr;
		
   always@(posedge clk or posedge rst) begin
      if(rst) begin
	 oldAddr <= `ROWLEN'b0;
      end
      else begin
	 if (loadNew) begin
	    oldAddr <= rowAddr;
	 end
      end // else: !if(rst)
   end // always@ (posedge clk or posedge rst)

   assign loadNew = loadEn & ~intEqual;
   assign equal = intEqual;
   assign intEqual = oldAddr == rowAddr;

endmodule
// Local Variables:
// verilog-library-directories:("." ".." "../or1200" "../jpeg" "../pkmc" "../dvga" "../uart" "../monitor" "../lab1" "../dafk_tb" "../eth" "../wb" "../leela")
// End:
