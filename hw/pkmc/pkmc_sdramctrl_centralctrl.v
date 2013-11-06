`include "include/pkmc_memctrl_defines.v"
`include "include/pkmc_sdram_defines.v"

module pkmc_sdramctrl_centralctrl(clk,
				  rst,
				  active,
				  bankVector,
				  bankNum,
				  newRow,
				  we_i,
				  ack_o,
				  all_one,
				  autoPrecharge,
				  command,
				  cke,
				  sdramIRQ,
				  prechCmd_o,
				  activeCmd_o,
				  readCmd_o,
				  writeCmd_o,
				  sdramIRQack
				  );
   input clk;
   input rst;
   input active;
   input [`BANKS-1:0] bankVector;
   input [`BANKLEN-1:0] bankNum;
   input 		 newRow;   
   input 		 we_i;
   input 		 sdramIRQack;
   
   output 		 ack_o;
   output 		 all_one;
   output 		 autoPrecharge;
   output [`COMMAND_LEN-1:0] command;
   output 		     cke;
   output 		     sdramIRQ;
   output 		     prechCmd_o;
   output 		     activeCmd_o;
   output 		     readCmd_o;
   output 		     writeCmd_o;

   //Internal wires
   wire [`COMMAND_LEN-1:0]   commandBus;
   wire 		     writeCmd;
   wire 		     readCmd;
   wire 		     prechCmd;
   wire 		     activeCmd;
   wire 		     autoRefCmd;
   wire 		     init;
   wire 		     issAutoRef;
   wire 		     apc;
   wire 		     bankActive;
   wire 		     allOneWire;	

   `include "include/pkmc_sdram_commands.v"

   assign 		     prechCmd_o = prechCmd;
   assign 		     activeCmd_o = activeCmd;
   assign 		     readCmd_o = readCmd;
   assign 		     writeCmd_o = writeCmd;
   
   pkmc_sdramctrl_fsm sdramctrl_fsm
     (
      .clk(clk),
      .rst(rst),
      .active(active),
      .bankActive(bankActive),
      .newRow(newRow),
      .we_i(we_i),
      .autoRef(issAutoRef),
      .initCount(init),
      .command(commandBus),
      .apc(apc),
      .all_one(allOneWire),
      .sdramIRQ(sdramIRQ),
      .irqAck(sdramIRQack)
      );

   pkmc_sdram_initcount sdram_initcount
     (
      .clk(clk),
      .rst(rst),
      .out(init)
      );

   pkmc_sdram_refcount sdram_refcount
     (
      .clk(clk),
      .rst(autoRefCmd),
      .out(issAutoRef)
      );

   pkmc_commanddecoder cmd_dec_write
     (
      .command(commandBus),
      .refCommand(WRITE),
      .hit(writeCmd)
      );
   
   pkmc_commanddecoder cmd_dec_read
     (
      .command(commandBus),
      .refCommand(READ),
      .hit(readCmd)
      );

   pkmc_commanddecoder cmd_dec_autoref
     (
      .command(commandBus),
      .refCommand(AUTO_REFR),
      .hit(autoRefCmd)
      );

   pkmc_commanddecoder cmd_dec_active
     (
      .command(commandBus),
      .refCommand(ACTIVE),
      .hit(activeCmd)
      );

   pkmc_commanddecoder cmd_dec_prech
     (
      .command(commandBus),
      .refCommand(PRECHARGE),
      .hit(prechCmd)
      );


   pkmc_sdram_ackgen ackgen
     (
      .rst(rst),
      .read(readCmd),
      .write(writeCmd),
      .clk(clk),
      .ack(ack_o)
      );

   pkmc_sdramctrl_activebanks active_banks 
     (
      .clk(clk),
      .rst(rst),
      .bankVector(bankVector),
      .bankNum(bankNum),
      .all_one(allOneWire),
      .apc(apc),
      .prech(prechCmd),
      .activeCmd(activeCmd),
      .bankActive(bankActive)
      );

   assign 	all_one = allOneWire;
   assign 	autoPrecharge = apc;
   assign 	command = commandBus;
   assign 	cke = 1'b1;
endmodule
// Local Variables:
// verilog-library-directories:("." ".." "../or1200" "../jpeg" "../pkmc" "../dvga" "../uart" "../monitor" "../lab1" "../dafk_tb" "../eth" "../wb" "../leela")
// End:
