`include "include/pkmc_memctrl_defines.v"
`include "include/pkmc_sdram_defines.v"


module pkmc_command_logic(fsmInVec,
			  initCount,
			  state,
			  command,
			  irqAck
			  );

   input [4:0] fsmInVec;
   input       initCount;
   input [`STATE_LEN-1:0] state;
   input 		  irqAck;

   output [`COMMAND_LEN-1:0] command;
   reg [`COMMAND_LEN-1:0] command;

`include "include/pkmc_sdramctrl_fsm_parameters.v"
`include "include/pkmc_sdram_commands.v"
   
   always@(fsmInVec or initCount or state or irqAck) begin
      casex(state)
	init0 : begin
	   if(~initCount) begin 
	      command <= NOP;
	   end
	   else begin
	      command <= PRECHARGE;
	   end
	end
	init1, init3 : begin
	   command <= AUTO_REFR;
	end
	init5 : begin
	   command <= LMR;
	end
	waitState, write : begin
	   casex (fsmInVec)
	     5'b01101 : begin
		command <= WRITE;
	     end
	     5'b01100 : begin
		command <= READ;
	     end
	     5'b0111x : begin
		command <= PRECHARGE;
	     end
	     5'b010xx : begin
		command <= ACTIVE;
	     end
	     5'b00xxx : begin
		command <= COMMAND_INHIBIT;
	     end
	     default : begin
		command <= NOP;
	     end
	   endcase // casex(fsmInVec)
	end // case: waitState
	prech2 : begin
	   command <= AUTO_REFR;
	end
	prech : begin
	   command <= ACTIVE;
	end
	active1 : begin
	   command <= READ;
	end
	nop1 : begin
	   if(fsmInVec[4]) begin
	      command <= NOP;
	   end
	   else begin
	      command <= COMMAND_INHIBIT;
	   end
	end // case: nop1
	active2 : begin
	   command <= READ;
	end
	ackWait : begin
	   if(irqAck) begin
	      command <= PRECHARGE;
	   end
	   else begin
	      command <= NOP;
	   end
	end
	default : begin
	   command <= NOP;
	end
      endcase // casex(state)
   end // always@ (fsmInVec or initCount)

endmodule// Local Variables:
// verilog-library-directories:("." ".." "../or1200" "../jpeg" "../pkmc" "../dvga" "../uart" "../monitor" "../lab1" "../dafk_tb" "../eth" "../wb" "../leela")
// End:
