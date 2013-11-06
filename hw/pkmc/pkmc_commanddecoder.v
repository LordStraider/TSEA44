`include "include/pkmc_memctrl_defines.v"
`include "include/pkmc_sdram_defines.v"

module pkmc_commanddecoder(command,
			   refCommand,
			   hit);
   
   input [`COMMAND_LEN-1:0] command;
   input [`COMMAND_LEN-1:0] refCommand;
   output 		    hit;
   
   assign #1 		    hit = (command == refCommand) ? 1'b1 : 1'b0;
   
endmodule // commanddecoder
// Local Variables:
// verilog-library-directories:("." ".." "../or1200" "../jpeg" "../pkmc" "../dvga" "../uart" "../monitor" "../lab1" "../dafk_tb" "../eth" "../wb" "../leela")
// End:
