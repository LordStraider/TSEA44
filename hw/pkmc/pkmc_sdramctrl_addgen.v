`include "include/pkmc_memctrl_defines.v"
`include "include/pkmc_sdram_defines.v"

module pkmc_sdramctrl_addrgen(addr_i,
			      apc,
			      all_one,
			      addrOut,
			      bankOut,
			      prechCmd_i,
			      activeCmd_i,
			      readCmd_i,
			      writeCmd_i
			      );
   
   input [`ADDRLEN-1:0] addr_i;
   input 	apc;
   input 	all_one;
   output [`SDRAM_ADDRLEN-1:0] addrOut;
   output [`BANKLEN-1:0]        bankOut;

   input 		       prechCmd_i;
   input 		       activeCmd_i;
   input 		       readCmd_i;
   input 		       writeCmd_i;

   /*AUTOREG*/
   // Beginning of automatic regs (for this module's undeclared outputs)
   // End of automatics

   wire [`SDRAM_ADDRLEN-1:0] 	   prechAddr;
   wire [`SDRAM_ADDRLEN-1:0] 	   LMR_Addr;
   wire [`SDRAM_ADDRLEN-1:0] 	   activeAddr;
   wire [`SDRAM_ADDRLEN-1:0] 	   readAddr;
   wire [`SDRAM_ADDRLEN-1:0] 	   writeAddr;

   wire [`SDRAM_ADDRLEN-1:0] 	   stage1;
   wire [`SDRAM_ADDRLEN-1:0] 	   stage2;
   wire [`SDRAM_ADDRLEN-1:0] 	   stage3;


`include "include/pkmc_sdram_commands.v"
   
   assign #1 		   prechAddr = {2'b0, all_one, 10'b0};
   assign #1 		   LMR_Addr = {`RESERVED, `WB, `OP_MODE, `CAS_LATENCY, `BT, `BURST_LEN};
   assign #1 		   activeAddr = addr_i[`ROW_START+`ROWLEN-1:`ROW_START];
   assign #1 		   readAddr = {`COL_FILL_LEN'b0,addr_i[`COL_START+`COLLEN-1:`COL_START]} | {2'b0, apc, 10'b0};
   assign #1 		   writeAddr = {`COL_FILL_LEN'b0,addr_i[`COL_START+`COLLEN-1:`COL_START]}; 
   
   


   localparam PRECH_ALL  = `SDRAM_ADDRLEN'bx_x1xx_xxxx_xxxx;
   localparam PRECH_ONE  = `SDRAM_ADDRLEN'bx_x0xx_xxxx_xxxx;

   
/* -----\/----- EXCLUDED -----\/-----
   always@(command or prechAddr or LMR_Addr or activeAddr or readAddr or writeAddr) begin
      casex(command)
	PRECHARGE : #1 addrOut <= prechAddr;
	LMR : #1 addrOut <= LMR_Addr;
	ACTIVE : #1 addrOut <= activeAddr;
	READ : #1 addrOut <= readAddr;
	WRITE : #1 addrOut <= writeAddr;
	`COMMAND_LEN'bx: #1 addrOut <= writeAddr;
      endcase // case(addrOutSel)
   end
 -----/\----- EXCLUDED -----/\----- */

   assign #1 		   stage1 = prechCmd_i ? prechAddr : LMR_Addr;
   assign #1 		   stage2 = activeCmd_i ? activeAddr : readAddr;
   assign #1 		   stage3 = writeCmd_i ? writeAddr : stage1;
   assign #1 		   addrOut = activeCmd_i | readCmd_i ? stage2 : stage3;

   //assign #1 bankOut = addr_i[`BANK_START+`BANKLEN-1:`BANK_START];
   assign #1 bankOut = addr_i[25:24];

endmodule
// Local Variables:
// verilog-library-directories:("." ".." "../or1200" "../jpeg" "../pkmc" "../dvga" "../uart" "../monitor" "../lab1" "../dafk_tb" "../eth" "../wb" "../leela")
// End:
