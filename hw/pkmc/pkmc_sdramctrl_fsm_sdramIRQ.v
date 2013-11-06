`include "include/pkmc_memctrl_defines.v"
`include "include/pkmc_sdram_defines.v"


module pkmc_IRQ_logic(fsmInVec,
		      initCount,
		      state,
		      sdramIRQ
		      );

   input [4:0] fsmInVec;
   input       initCount;
   input [`STATE_LEN-1:0] state;

   output 		 sdramIRQ;
   reg 			 sdramIRQ;

`include "include/pkmc_sdramctrl_fsm_parameters.v"

   always@(fsmInVec or initCount or state) begin
      casex(state)
	init0, init1, init2, init3, init4, init5, 
	init6, prech2, nop3, ackWait : begin
	   sdramIRQ <= 1'b1;
	end
	waitState, write, nop1 : begin
	   if (fsmInVec[4]) begin
	      sdramIRQ <= 1'b1;
	   end
	   else begin
	      sdramIRQ <= 1'b0;
	   end
	end // case: waitState
	default : sdramIRQ <= 1'b0;
      endcase // casex(state)
   end // always@ (fsmInVec or initCount)
endmodule// Local Variables:
// verilog-library-directories:("." ".." "../or1200" "../jpeg" "../pkmc" "../dvga" "../uart" "../monitor" "../lab1" "../dafk_tb" "../eth" "../wb" "../leela")
// End:
