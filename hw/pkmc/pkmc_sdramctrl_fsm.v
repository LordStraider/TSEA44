`include "include/pkmc_memctrl_defines.v"
`include "include/pkmc_sdram_defines.v"

module pkmc_sdramctrl_fsm(clk,
			  rst,
			  active,
			  bankActive,
			  newRow,
			  we_i,
			  autoRef,
			  initCount,
			  command,
			  apc,
			  all_one,
			  sdramIRQ,
			  irqAck
			  );
   
   input clk;
   input rst;
   input active;
   input bankActive;
   input newRow;
   input we_i;
   input autoRef;
   input initCount;
   input irqAck;

   output [`COMMAND_LEN-1:0] command;
   wire [`COMMAND_LEN-1:0]   command;

   output 	apc;
   output 	all_one;
   output 	sdramIRQ;
   
   localparam stateLen = `STATE_LEN;

   reg [stateLen-1:0] 	state;
   reg [stateLen-1:0] 	nextState;
   wire [4:0] 	fsmInVec;
   wire 	all_one;
   wire 	sdramIRQ;
   
   
   /*AUTOREG*/
   // Beginning of automatic regs (for this module's undeclared outputs)
   // End of automatics

   assign 		apc = 1'b0;

   `include "include/pkmc_sdramctrl_fsm_parameters.v"
   `include "include/pkmc_sdram_commands.v"

   
   assign #1 fsmInVec = {autoRef, active, bankActive, newRow, we_i};
   
   always@(posedge clk or posedge rst) begin
      if(rst) begin
	 state <= #1 init0;
      end
      else begin
	 state <= #1 nextState;
      end
   end

/* -----\/----- EXCLUDED -----\/-----
   nextState_logic nextState_logic
     (
      .fsmInVec(fsmInVec),
      .initCount(initCount),
      .state(state),
      .nextState(nextState)
      );
 -----/\----- EXCLUDED -----/\----- */

   always@(fsmInVec or initCount or state or irqAck) begin
      case(state)
	init0 : begin
	   if(~initCount) begin 
	      nextState <= init0;
	   end
	   else begin
	      nextState <= init1;
	   end
	end
	init1 : begin
	   nextState <= init2;
	end
	init2 : begin
	   nextState <= init3;
	end
	init3 : begin
	   nextState <= init4;
	end
	init4 : begin
	   nextState <= init5;
	end
	init5 : begin
	   nextState <= init6;
	end
	init6 : begin
	   nextState <= waitState;
	end
	waitState : begin
	   casex (fsmInVec)
	     5'b01101 : begin
		nextState <= nop5;
	     end
	     5'b01100 : begin
		nextState <= read;
	     end
	     5'b0111x : begin
		nextState <= prech;
	     end
	     5'b010x1 : begin
		nextState <= write;
	     end
	     5'b010x0 : begin
		nextState <= active2;
	     end
	     5'b00xxx : begin
		nextState <= waitState;
	     end
	     default : begin
		nextState <= ackWait;
	     end
	   endcase // casex(fsmInVec)
	end // case: waitState
	prech2 : begin
	   nextState <= nop3;
	end
	nop3 : begin
	   if (fsmInVec[3]) begin
	      nextState <= prech;
	   end
	   else begin
	      nextState <= waitState;
	   end
	end       
	write : begin
	   casex(fsmInVec)
	     5'b01101 : begin
		nextState <= nop5;
	     end
	     5'b01100 : begin
		nextState <= read;
	     end
	     5'b0111x : begin
		nextState <= prech;
	     end
	     5'b010x1 : begin
		nextState <= write;
	     end
	     5'b010x0 : begin
		nextState <= active2;
	     end
	     5'b00xxx : begin
		nextState <= waitState;
	     end
	     default : begin
		nextState <= ackWait;
	     end
	   endcase // casex(fsmInVec)
	end // case: write
	nop5 : begin
	   nextState <= write;
	end
	prech : begin
	   if (fsmInVec[0]) begin
	      nextState <= write;
	   end
	   else begin
	      nextState <= active1;
	   end
	end
	read : begin
	   nextState <= nop0;
	end
	nop0 : begin
	   nextState <= nop1;
	end
	nop1 : begin
	   if(fsmInVec[4]) begin
	      nextState <= ackWait;
	   end
	   else begin
	      nextState <= waitState;
	   end
	end // case: nop1
	active1, active2 : begin
	   nextState <= read;
	end
	ackWait : begin
	   if(irqAck) begin
	      nextState <= prech2;
	   end
	   else begin
	      nextState <= ackWait;
	   end
	end
	default : begin
	   nextState <= waitState;
	end
      endcase // casex(state)
   end // always@ (fsmInVec or initCount)

   

   pkmc_command_logic command_logic
     (
      .fsmInVec(fsmInVec),
      .initCount(initCount),
      .state(state),
      .command(command),
      .irqAck(irqAck)
      );
   
   
   pkmc_IRQ_logic IRQ_logic
     (
      .fsmInVec(fsmInVec),
      .initCount(initCount),
      .state(state),
      .sdramIRQ(sdramIRQ)
      );

   pkmc_all_one_logic all_one_logic
     (
      .fsmInVec(fsmInVec),
      .initCount(initCount),
      .state(state),
      .all_one(all_one),
      .irqAck(irqAck)
      );

   
   
endmodule
// Local Variables:
// verilog-library-directories:("." ".." "../or1200" "../jpeg" "../pkmc" "../dvga" "../uart" "../monitor" "../lab1" "../dafk_tb" "../eth" "../wb" "../leela")
// End:
