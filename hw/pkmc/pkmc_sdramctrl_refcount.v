`include "include/pkmc_memctrl_defines.v"
`include "include/pkmc_sdram_defines.v"

module pkmc_sdram_refcount(clk,rst,out);
   input clk;
   input rst;
   output out;

   reg [`REF_COUNT_LEN-1:0] refCounter;

   reg 		    keeper;
   wire 		    refresh;

   reg 			    syncRst;

   always@(posedge clk) begin
      syncRst <= rst;
   end
   
   
   always@(posedge clk or posedge syncRst) begin
      if(syncRst) begin
	 		refCounter <= 0;
      end
      else begin
			refCounter <= refCounter + 1;
      end
   end

	always@(posedge clk or posedge syncRst) begin
		if(syncRst) begin
			keeper <= 0;
		end
		else begin
			keeper <= out;
		end
	end


   assign #1 refresh = (refCounter[`REF_COUNT_LEN-1] & refCounter[`REF_COUNT_BIT_1]) 
     & refCounter[`REF_COUNT_BIT_2];
   assign    out = keeper|refresh;

   specify
      $hold(posedge clk, negedge clk, `MIN_CLK_HP);
      $hold(negedge clk, posedge clk, `MIN_CLK_LP);
   endspecify
	
	


endmodule
// Local Variables:
// verilog-library-directories:("." ".." "../or1200" "../jpeg" "../pkmc" "../dvga" "../uart" "../monitor" "../lab1" "../dafk_tb" "../eth" "../wb" "../leela")
// End:
