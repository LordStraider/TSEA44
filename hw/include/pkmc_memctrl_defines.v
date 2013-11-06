`ifndef MEMCTRL_DEFINES
 `define MEMCTRL_DEFINES

//`define SIMULATE

 `timescale 1ns/1ns

//WB I/F Widths
 `define ADDR_I_WIDTH 32
 `define DAT_I_WIDTH 32
 `define DAT_O_WIDTH 32
 `define SEL_I_WIDTH 4

//If defined various timingchecks are performed
// `define TIMECHECK

//Number of internal memory controllers
 `define NUM_MEMS 3

//Number of inputs to data select muxes. Should be roof(log2(`NUM_MEMS))
 `define SEL_MUX_WIDTH 2 

//Start addresses for the memories, Currently the hardware must be modified
//if this is changed.
 `define SRAM_START 32'h20000000
 `define SRAM_SIZE  32'h00100000

 `define FLASH_START 32'h24000000
 `define FLASH_SIZE  32'h01000000

 `define SDRAM_START 32'h28000000
 `define SDRAM_SIZE  32'h04000000

//Uncomment if run should result in error signal going high
//`define SHOULD_FAIL

//Memory interface busswidths
 `define ADDR_BUS_OUT 32
 `define DATA_BUS_OUT 32

`endif// Local Variables:
// verilog-library-directories:("." ".." "../or1200" "../jpeg" "../pkmc" "../dvga" "../uart" "../monitor" "../lab1" "../dafk_tb" "../eth" "../wb" "../leela")
// End:
