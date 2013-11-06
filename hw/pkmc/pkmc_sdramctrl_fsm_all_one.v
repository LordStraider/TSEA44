`include "include/pkmc_memctrl_defines.v"
`include "include/pkmc_sdram_defines.v"


module pkmc_all_one_logic(fsmInVec,
			  initCount,
			  state,
			  all_one,
			  irqAck
			  );

   input [4:0] fsmInVec;
   input       initCount;
   input [`STATE_LEN-1:0] state;
   input 		  irqAck;

   output 		 all_one;
   reg 			 all_one;

`include "include/pkmc_sdramctrl_fsm_parameters.v"

   always@(fsmInVec or initCount or state or irqAck) begin
      casex(state)
	init0 : begin
	   if(~initCount) begin 
	      all_one <= PCH_ONE;
	   end
	   else begin
	      all_one <= PCH_ALL;
	   end
	end
	ackWait : begin
	   if(irqAck) begin
	      all_one <= PCH_ALL;
	   end
	   else begin
	      all_one <= PCH_ONE;
	   end
	end
	default: all_one <= PCH_ONE;
      endcase // casex(state)
   end // always@ (fsmInVec or initCount)
endmodule// Local Variables:
// verilog-library-directories:("." ".." "../or1200" "../jpeg" "../pkmc" "../dvga" "../uart" "../monitor" "../lab1" "../dafk_tb" "../eth" "../wb" "../leela")
// End:
