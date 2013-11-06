`include "include/pkmc_sram_defines.v"
`include "include/pkmc_flash_defines.v"
`include "include/pkmc_sdram_defines.v"
`include "include/pkmc_memctrl_defines.v"

module pkmc_wbmemctrl(//WB i/f
		      wb_rst_i,
		      wb_clk_i,
		      wb_ack_o,
		      wb_addr_i,
		      wb_cyc_i,
		      wb_err_o,
                      wb_lock_i,
		      wb_rty_o,
		      wb_sel_i,
		      wb_stb_i,
		      wb_we_i,
		      wb_dat_i,
                      wb_dat_o,
		      shftClk,
		      //SRAM i/f;
		      sramAddr,
		      sramData_i,
		      sramData_o,
		      sramByteSelect,
		      sramCE,
		      sramWE,
		      sramOE,
		      sramBuffDir,
		      sramBuffOE,

		      //FLASH i/f;
		      flashAddr,
		      flashData_o,
		      flashData_i,
		      flashCE,
		      flashWE,
		      flashOE,
		      flashBuffDir,
		      flashBuffOE,

		      //SDRAM i/f
		      sdramAddr_o,
		      sdramBank_o,
		      sdramData_i,
		      sdramData_o,
		      sdramCommand_o,
		      sdramCke_o,
		      sdramByteSel_o,
		      //Controll i/f
		      muxSel,
		      we_o);


   //WB i/f
   input wb_rst_i;
   input wb_clk_i;
   output wb_ack_o;
   input [`ADDR_I_WIDTH-1:0] wb_addr_i;
   input 		     wb_cyc_i;
   output 		     wb_err_o;
   input 		     wb_lock_i;
   output 		     wb_rty_o;
   input [`SEL_I_WIDTH-1:0]  wb_sel_i;
   input 		     wb_stb_i;
   input 		     wb_we_i;
   input [`DAT_I_WIDTH-1:0]  wb_dat_i;
   output [`DAT_O_WIDTH-1:0] wb_dat_o;

   //SRAM i/f
   output [`SRAM_ADDR_WIDTH-1:0] sramAddr;
   output [`SRAM_DATA_WIDTH-1:0] sramData_o;
   input [`SRAM_DATA_WIDTH-1:0]  sramData_i;
   output [`SRAM_BS_WIDTH-1:0] 	 sramByteSelect;
   output 			 sramCE;
   output 			 sramWE;
   output 			 sramOE;
   output 			 sramBuffDir;
   output 			 sramBuffOE;

   //FLASH i/f
   output [`FLASH_ADDR_WIDTH-1:0] flashAddr;
   output [`FLASH_DATA_WIDTH-1:0] flashData_o;
   input [`FLASH_DATA_WIDTH-1:0]  flashData_i;
   output 			 flashCE;
   output 			 flashWE;
   output 			 flashOE;
   output 			 flashBuffDir;
   output 			 flashBuffOE;

   //SDRAM i/f
   output [`SDRAM_ADDRLEN-1:0] 	 sdramAddr_o;
   output [`BANKLEN-1:0] 	 sdramBank_o;
   input [`DATALEN-1:0] 	 sdramData_i;
   output [`DATALEN-1:0] 	 sdramData_o;
   output [`COMMAND_LEN-1:0] 	 sdramCommand_o;
   output 			 sdramCke_o;
   output [`SEL_I_WIDTH-1:0] 	 sdramByteSel_o;

   //Controll output
   output [`SEL_MUX_WIDTH-1:0] 	 muxSel;
   input 			 shftClk;
   output 			 we_o;
   
   //internal wires and regs
   wire [`NUM_MEMS-1:0] 	 active;

   wire [`DAT_O_WIDTH-1:0] 	 dat_o_bus [`NUM_MEMS-1:0];
   wire [`NUM_MEMS-1:0] 	 ack_o_bus;
   wire 			 sdramIRQ;
   wire 			 sdramIRQack;

   /*AUTOREG*/
   // Beginning of automatic regs (for this module's undeclared outputs)
   reg			wb_ack_o;
   reg [`DAT_O_WIDTH-1:0]wb_dat_o;

   // End of automatics

   assign 		 wb_rty_o = 0;
//   assign #1 			 wb_dat_o = muxSel[0] ? dat_o_bus[1] : dat_o_bus[0];

   always @ (muxSel or dat_o_bus[0] or dat_o_bus[1] or dat_o_bus[2]) begin
      case (muxSel) 
	2'h0: begin
	   wb_dat_o = dat_o_bus[0];
	end
	2'h1: begin
	   wb_dat_o = dat_o_bus[1];
	end
	default: begin
	   wb_dat_o = dat_o_bus[2];
	end
      endcase
   end
   
//   assign #1 			 wb_ack_o = muxSel[0] ? ack_o_bus[1] : ack_o_bus[0];

   always @ (muxSel or ack_o_bus) begin
      case (muxSel) 
	2'h0: begin
	   wb_ack_o = ack_o_bus[0];
	end
	2'h1: begin
	   wb_ack_o = ack_o_bus[1];
	end
	default: begin
	   wb_ack_o = ack_o_bus[2];
	end
      endcase
   end
   

   
   assign 			 we_o = wb_we_i;
   
   pkmc_wbmemctrl_addrdecoder addrdecoder
     (
      .clk(wb_clk_i),
      .stb_i(wb_stb_i),
      .err_o(wb_err_o),
      .cyc_i(wb_cyc_i),
      .addr_i({wb_addr_i[31:2],2'b0}),
      .active(active),
      .muxSel(muxSel),
      .sdramIRQ_in(sdramIRQ),
      .sdramIRQack_o(sdramIRQack),
      .wb_ack(wb_ack_o)
      );

   pkmc_sramctrl sramcontroller
     (
      .clk(wb_clk_i),
      .rst(wb_rst_i),
      .ack_o(ack_o_bus[0]),
      .addr_i({12'b0, wb_addr_i[`SRAM_ADDR_WIDTH+1:2], 2'b0}),
      .dat_i(wb_dat_i),
      .dat_o(dat_o_bus[0]),
      .we_i(wb_we_i),
      .active(active[0]),
      .sel_i(wb_sel_i),
      .shftClk(shftClk),
      .sramAddr(sramAddr),
      .sramData_i(sramData_i),
      .sramData_o(sramData_o),
      .sramByteSelect(sramByteSelect),
      .sramCE(sramCE),
      .sramWE(sramWE),
      .sramOE(sramOE),
      .sramBuffDir(sramBuffDir),
      .sramBuffOE(sramBuffOE)
      );
   
   pkmc_flashctrl flashcontroller
     (
      .clk(wb_clk_i),
      .rst(wb_rst_i),
      .ack_o(ack_o_bus[2]),
      .addr_i({8'b0, wb_addr_i[`FLASH_ADDR_WIDTH+1:2], 2'b0}),
      .dat_i(wb_dat_i),
      .dat_o(dat_o_bus[2]),
      .we_i(wb_we_i),
      .active(active[2]),
      .sel_i(wb_sel_i),
      .shftClk(shftClk),
      .flashAddr(flashAddr),
      .flashData_i(flashData_i),
      .flashData_o(flashData_o),
      .flashCE(flashCE),
      .flashWE(flashWE),
      .flashOE(flashOE),
      .flashBuffDir(flashBuffDir),
      .flashBuffOE(flashBuffOE)
      );
   
   pkmc_sdramctrl_top sdramcontroller
     (
      .rst(wb_rst_i),
      .clk(wb_clk_i),
      .ack_o(ack_o_bus[1]),
      .addr_i({6'b0, wb_addr_i[25:2], 2'b0}),
      .dat_i(wb_dat_i),
      .dat_o(dat_o_bus[1]),
      .we_i(wb_we_i),
      .active_i(active[1]),
      .byte_sel(wb_sel_i),
      .shftClk(shftClk),
      .sdramAddr_o(sdramAddr_o),
      .sdramBank_o(sdramBank_o),
      .sdramData_i(sdramData_i),
      .sdramData_o(sdramData_o),
      .sdramCommand_o(sdramCommand_o),
      .sdramCke_o(sdramCke_o),
      .sdramByteSel_o(sdramByteSel_o),
      .sdramIRQ(sdramIRQ),
      .sdramIRQack(sdramIRQack)
      );

endmodule
// Local Variables:
// verilog-library-directories:("." ".." "../or1200" "../jpeg" "../pkmc" "../dvga" "../uart" "../monitor" "../lab1" "../dafk_tb" "../eth" "../wb" "../leela")
// End:
