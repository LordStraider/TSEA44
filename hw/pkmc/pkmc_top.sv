`include "include/timescale.v"
`include "include/or1200_defines.v"
`include "include/dafk_defines.v"

`include "include/pkmc_sdram_defines.v"
`include "include/pkmc_flash_defines.v"
`include "include/pkmc_sram_defines.v"
`include "include/pkmc_memctrl_defines.v"


module pkmc_top(   
    // WB i/f
    wishbone.slave wb,
    input wire shftClk, wb_lock_i,
    // Board i/f
    output wire sramCE_bi, sramOE_bi, //SRAM
    output wire sramBuffDir_bi, sramBuffOE_bi,
    output wire flashCE_bi, //FLASH
    output wire sdramCke_o_bi, //SDRAM
    output wire [`COMMAND_LEN-1:0] sdramCommand_o_bi, //Common interface
    inout wire [`DATA_BUS_OUT-1:0] data_io_bi, 
    output wire [`ADDR_BUS_OUT-1:0] addr_o_bi,
    output wire [`SEL_I_WIDTH-1:0]  byteSel_o_bi);

   // *******************************************************
   // *              FPGA interface                         *
   // *******************************************************
   //SRAM
   wire [`SRAM_ADDR_WIDTH-1:0] sramAddr_o_fi;
   wire [`SRAM_DATA_WIDTH-1:0] sramData_o_fi;
   wire [`SRAM_DATA_WIDTH-1:0] sramData_i_fi;
   wire [`SEL_I_WIDTH-1:0]     sramByteSel_o_fi;   
   wire 		       sramCE_fi;
   wire 		       sramWE_fi;
   wire 		       sramOE_fi;
   wire 		       sramBuffDir_fi;
   wire 		       sramBuffOE_fi;
   
   //FLASH
   wire [`FLASH_ADDR_WIDTH-1:0] flashAddr_o_fi;
   wire [`FLASH_DATA_WIDTH-1:0] flashData_o_fi;
   wire [`FLASH_DATA_WIDTH-1:0] flashData_i_fi;
   wire 		       flashCE_fi;
   wire 		       flashWE_fi;
   wire 		       flashOE_fi;
   wire 		       flashBuffDir_fi;
   wire 		       flashBuffOE_fi;
   
   //SDRAM
   wire [`SDRAM_ADDRLEN-1:0]   sdramAddr_o_fi;
   wire [`BANKLEN-1:0] 	       sdramBank_o_fi;
   wire [`DATALEN-1:0] 	       sdramData_o_fi;
   wire [`DATALEN-1:0] 	       sdramData_i_fi;
   wire [`COMMAND_LEN-1:0]     sdramCommand_o_fi;
   wire 		       sdramCke_o_fi;
   wire [`SEL_I_WIDTH-1:0]     sdramByteSel_o_fi;

   wire [7:0] 		       dummy;
   
   //Control
   wire [1:0] 		       memSelect_fi;
   wire 		       we_o_fi;

   // *******************************************************
   // *      Instantiate memory controller                  *
   // *******************************************************
   pkmc_wbmemctrl pkmc_mc
     (
      // WB i/f
      .wb_rst_i(wb.rst),
      .wb_clk_i(wb.clk),
      .wb_ack_o(wb.ack),
      .wb_addr_i(wb.adr),
      .wb_cyc_i(wb.cyc),
      .wb_err_o(wb.err),
      .wb_lock_i(wb_lock_i),
      .wb_rty_o(wb.rty),
      .wb_sel_i(wb.sel),
      .wb_stb_i(wb.stb),
      .wb_we_i(wb.we),
      .wb_dat_i(wb.dat_o),
      .wb_dat_o(wb.dat_i),
      .shftClk(shftClk),
      //SRAM i/f
      .sramAddr(sramAddr_o_fi),
      .sramData_i(sramData_i_fi),
      .sramData_o(sramData_o_fi),
      .sramByteSelect(sramByteSel_o_fi),
      .sramCE(sramCE_fi),
      .sramWE(sramWE_fi),
      .sramOE(sramOE_fi),
      .sramBuffDir(sramBuffDir_fi),
      .sramBuffOE(sramBuffOE_fi),
      //FLASH
      .flashAddr(flashAddr_o_fi),
      .flashData_o(flashData_o_fi),
      .flashData_i(flashData_i_fi),
      .flashCE(flashCE_fi),
      .flashWE(flashWE_fi),
      .flashOE(flashOE_fi),
      .flashBuffDir(flashBuffDir_fi),
      .flashBuffOE(flashBuffOE_fi),
      //SDRAM i/f
      .sdramAddr_o(sdramAddr_o_fi),
      .sdramBank_o(sdramBank_o_fi),
      .sdramData_i(sdramData_i_fi),
      .sdramData_o(sdramData_o_fi),
      .sdramCommand_o(sdramCommand_o_fi),
      .sdramCke_o(sdramCke_o_fi),
      .sdramByteSel_o(sdramByteSel_o_fi),
      //Controll i/f
      .muxSel(memSelect_fi),
      .we_o(we_o_fi)
      );

   // *******************************************************
   // * Instantiate board interface                         *
   // *******************************************************

   mem_fpga_board_if mem_fpga_board_if
     (
      .clk(wb.clk),
      //Memory controller interface fi := Fpga Interface
      //SRAM
      .sramAddr_o_fi(sramAddr_o_fi),
      .sramData_o_fi(sramData_o_fi),
      .sramData_i_fi(sramData_i_fi),
      .sramByteSel_o_fi(sramByteSel_o_fi),
      .sramCE_fi(sramCE_fi),
      .sramWE_fi(sramWE_fi),
      .sramOE_fi(sramOE_fi),
      .sramBuffDir_fi(sramBuffDir_fi),
      .sramBuffOE_fi(sramBuffOE_fi),
      //FLASH
      .flashAddr_o_fi(flashAddr_o_fi),
      .flashData_o_fi(flashData_o_fi),
      .flashData_i_fi(flashData_i_fi),
      .flashCE_fi(flashCE_fi),
      .flashWE_fi(flashWE_fi),
      .flashOE_fi(flashOE_fi),
      .flashBuffDir_fi(flashBuffDir_fi),
      .flashBuffOE_fi(flashBuffOE_fi),
      //SDRAM
      .sdramAddr_o_fi(sdramAddr_o_fi),
      .sdramBank_o_fi(sdramBank_o_fi),
      .sdramData_o_fi(sdramData_o_fi),
      .sdramData_i_fi(sdramData_i_fi),
      .sdramCommand_o_fi(sdramCommand_o_fi),
      .sdramCke_o_fi(sdramCke_o_fi),
      .sdramByteSel_o_fi(sdramByteSel_o_fi),
      //Controll
      .memSelect_fi(memSelect_fi), //0 -> SRAM, 1 -> SDRAM 2->FLASH
      .we_o_fi(we_o_fi),
      
      //Board infterface, bi := Board Interface
      //SRAM
      .sramCE_bi(sramCE_bi),
      .sramOE_bi(sramOE_bi),
      .sramBuffDir_bi(sramBuffDir_bi),
      .sramBuffOE_bi(sramBuffOE_bi),
      //FLASH
      .flashCE_bi(flashCE_bi),
      //SDRAM
      .sdramCke_o_bi(sdramCke_o_bi),
      //Common interface
      .sdramCommand_o_bi(sdramCommand_o_bi),
      .data_io_bi(data_io_bi),
      .addr_o_bi(addr_o_bi),
      .byteSel_o_bi(byteSel_o_bi)
      );

endmodule // pkmc_top

   // Local Variables:
// verilog-library-directories:("." ".." "../or1200" "../jpeg" "../pkmc" "../dvga" "../uart" "../monitor" "../lab1" "../dafk_tb" "../eth" "../wb" "../leela")
// End:
