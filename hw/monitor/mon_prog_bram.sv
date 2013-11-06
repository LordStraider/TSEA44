//**********************************
//*     monitor                    *
//**********************************
`include "include/timescale.v"
`include "include/dafk_defines.v"

module mon_prog_bram
  (
    input clk, rom_ce,
    input [12:0] addr, 
    output logic [31:0] dat_o
   );

   wire [2:0][31:0] do_rom;
   wire [23:0] 	nc;  //not connected
   
   always_comb begin
      case (addr[12:11])
	2'h0: dat_o = do_rom[0];
	2'h1: dat_o = do_rom[1];
	2'h2: dat_o = do_rom[2];
	default : dat_o = 32'h0;
      endcase // case endcase
   end
   
   `include "monitor/firmware/src/mon_prog_bram_contents.v"

   // **********************************************				

   RAMB16_S9 monitor_rom_0
     (
      .DO(do_rom[0][7:0]),
      .ADDR(addr[10:0]),
      .CLK(clk),
      .DI(8'b0),
      .DIP(1'b0),
      .EN(rom_ce),
      .SSR(1'b0),
      .WE(1'b0),
      .DOP(nc[0])
      );
   
   RAMB16_S9 monitor_rom_1
     (
      .DO(do_rom[0][15:8]),
      .ADDR(addr[10:0]),
      .CLK(clk),
      .DI(8'b0),
      .DIP(1'b0),
      .EN(rom_ce),
      .SSR(1'b0),
      .WE(1'b0),
      .DOP(nc[1])
      );

   RAMB16_S9 monitor_rom_2
     (
      .DO(do_rom[0][23:16]),
      .ADDR(addr[10:0]),
      .CLK(clk),
      .DI(8'b0),
      .DIP(1'b0),
      .EN(rom_ce),
      .SSR(1'b0),
      .WE(1'b0),
      .DOP(nc[2])
      );

   RAMB16_S9 monitor_rom_3
     (
      .DO(do_rom[0][31:24]),
      .ADDR(addr[10:0]),
      .CLK(clk),
      .DI(8'b0),
      .DIP(1'b0),
      .EN(rom_ce),
      .SSR(1'b0),
      .WE(1'b0),
      .DOP(nc[3])
      );

   // **********************************************				
   RAMB16_S9 monitor_rom_4
     (
      .DO(do_rom[1][7:0]),
      .ADDR(addr[10:0]),
      .CLK(clk),
      .DI(8'b0),
      .DIP(1'b0),
      .EN(rom_ce),
      .SSR(1'b0),
      .WE(1'b0),
      .DOP(nc[4])
      );

   RAMB16_S9 monitor_rom_5
     (
      .DO(do_rom[1][15:8]),
      .ADDR(addr[10:0]),
      .CLK(clk),
      .DI(8'b0),
      .DIP(1'b0),
      .EN(rom_ce),
      .SSR(1'b0),
      .WE(1'b0),
      .DOP(nc[5])
      );

   RAMB16_S9 monitor_rom_6
     (
      .DO(do_rom[1][23:16]),
      .ADDR(addr[10:0]),
      .CLK(clk),
      .DI(8'b0),
      .DIP(1'b0),
      .EN(rom_ce),
      .SSR(1'b0),
      .WE(1'b0),
      .DOP(nc[6])
      );

   RAMB16_S9 monitor_rom_7
     (
      .DO(do_rom[1][31:24]),
      .ADDR(addr[10:0]),
      .CLK(clk),
      .DI(8'b0),
      .DIP(1'b0),
      .EN(rom_ce),
      .SSR(1'b0),
      .WE(1'b0),
      .DOP(nc[7])
      );

   // **********************************************				
   RAMB16_S9 monitor_rom_8
     (
      .DO(do_rom[2][7:0]),
      .ADDR(addr[10:0]),
      .CLK(clk),
      .DI(8'b0),
      .DIP(1'b0),
      .EN(rom_ce),
      .SSR(1'b0),
      .WE(1'b0),
      .DOP(nc[8])
      );

   RAMB16_S9 monitor_rom_9
     (
      .DO(do_rom[2][15:8]),
      .ADDR(addr[10:0]),
      .CLK(clk),
      .DI(8'b0),
      .DIP(1'b0),
      .EN(rom_ce),
      .SSR(1'b0),
      .WE(1'b0),
      .DOP(nc[9])
      );

   RAMB16_S9 monitor_rom_10
     (
      .DO(do_rom[2][23:16]),
      .ADDR(addr[10:0]),
      .CLK(clk),
      .DI(8'b0),
      .DIP(1'b0),
      .EN(rom_ce),
      .SSR(1'b0),
      .WE(1'b0),
      .DOP(nc[10])
      );

   RAMB16_S9 monitor_rom_11
     (
      .DO(do_rom[2][31:24]),
      .ADDR(addr[10:0]),
      .CLK(clk),
      .DI(8'b0),
      .DIP(1'b0),
      .EN(rom_ce),
      .SSR(1'b0),
      .WE(1'b0),
      .DOP(nc[11])
      );

endmodule
// Local Variables 		      :
// verilog-library-directories:("." ".." "../or1200" "../jpeg" "../pkmc" "../dvga" "../uart" "../monitor" "../lab1" "../dafk_tb" "../eth" "../wb" "../leela")
// End:
