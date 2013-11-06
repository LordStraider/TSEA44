`include "include/pkmc_memctrl_defines.v"
`include "include/pkmc_sdram_defines.v"      

module pkmc_sdramctrl_activebanks(clk,
				  rst,
				  bankVector,
				  bankNum,
				  all_one,
				  apc,
				  prech,
				  activeCmd,
				  bankActive);

   localparam bankLen = 2**`BANKS;
   
   input clk;
   input rst;
   input [`BANKS-1:0] bankVector;
   input [`BANKLEN-1:0] bankNum;
   input 		all_one;
   input 		apc;
   input 		prech;
   input 		activeCmd;
   output 		bankActive;

   reg [`BANKS-1:0] 	 activeBanks;
//`include "./pkmc/pkmc_activebank_udp.v"
   //integer 		 i;
   
   always@(posedge clk or posedge rst) begin
      if(rst) begin
	 activeBanks <= `BANKS'b0;
      end
      else begin
/* -----\/----- EXCLUDED -----\/-----
	 for(i = 0; i<`BANKS;i = i+1) begin
	    activeBanks[i] <= new(activeBanks[i],bankVector[i],all_one,prech,apc,activeCmd);
	 end
	 activeBanks[0] <= new(activeBanks[0],bankVector[0],all_one,prech,apc,activeCmd);
	 activeBanks[1] <= new(activeBanks[1],bankVector[1],all_one,prech,apc,activeCmd);
	 activeBanks[2] <= new(activeBanks[2],bankVector[2],all_one,prech,apc,activeCmd);
	 activeBanks[3] <= new(activeBanks[3],bankVector[3],all_one,prech,apc,activeCmd);
   -----/\----- EXCLUDED -----/\----- */
   // Changed by Daniel 2004-09-28 to ensure compatibility with ModelSim<5.8
	 activeBanks[0] <= bankVector[0]  & activeCmd
	                 | activeBanks[0] & ~bankVector[0] & ~all_one 
			 | activeBanks[0] & ~bankVector[0] &  all_one & ~prech & ~apc
			 | activeBanks[0] &  bankVector[0] & ~all_one & ~prech & ~apc
			 | activeBanks[0] &  bankVector[0] &  all_one & ~prech & ~apc; 
	 activeBanks[1] <= bankVector[1]  & activeCmd
	                 | activeBanks[1] & ~bankVector[1] & ~all_one 
			 | activeBanks[1] & ~bankVector[1] &  all_one & ~prech & ~apc
			 | activeBanks[1] &  bankVector[1] & ~all_one & ~prech & ~apc
			 | activeBanks[1] &  bankVector[1] &  all_one & ~prech & ~apc; 
	 activeBanks[2] <= bankVector[2]  & activeCmd
	                 | activeBanks[2] & ~bankVector[2] & ~all_one 
			 | activeBanks[2] & ~bankVector[2] &  all_one & ~prech & ~apc
			 | activeBanks[2] &  bankVector[2] & ~all_one & ~prech & ~apc
			 | activeBanks[2] &  bankVector[2] &  all_one & ~prech & ~apc; 
	 activeBanks[3] <= bankVector[3]  & activeCmd
	                 | activeBanks[3] & ~bankVector[3] & ~all_one 
			 | activeBanks[3] & ~bankVector[3] &  all_one & ~prech & ~apc
			 | activeBanks[3] &  bankVector[3] & ~all_one & ~prech & ~apc
			 | activeBanks[3] &  bankVector[3] &  all_one & ~prech & ~apc; 
      end
   end

   assign bankActive = activeBanks[bankNum];
endmodule
// Local Variables:
// verilog-library-directories:("." ".." "../or1200" "../jpeg" "../pkmc" "../dvga" "../uart" "../monitor" "../lab1" "../dafk_tb" "../eth" "../wb" "../leela")
// End:
