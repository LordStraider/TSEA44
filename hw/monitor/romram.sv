//
// A simple ROM/RAM
// Olle Seger
//

`include "include/timescale.v"
`include "include/dafk_defines.v"
  
module romram(wishbone.slave wb);

   //
   // Local signals
   wire [31:0] 	 do_rom;
   wire [31:0] 	 do_ram;
   wire 	 rom_ce;
   wire 	 ram_ce;
   wire [3:0] 	 ram_we;
   reg  	 wbstate;

   // ack FSM
   always_ff @(posedge wb.clk)
     if (wb.rst)
       wbstate <= 0;
     else 
       case (wbstate)
	 1'b0:    if (wb.stb) wbstate <= 1;
	 default: wbstate <= 0;
       endcase

   assign 	 wb.ack = wbstate;
   assign 	 wb.err = 1'b0;
   assign 	 wb.rty = 1'b0;
   
   // stb == 1 means that adr[31:24] == 8`h40
   // ROM 24kB 6k*32 0x40000000-0x40005fff  monitor
   assign 	 rom_ce = wb.stb && ~wb.adr[16];
	
   // RAM  8kB 2k*32 0x40010000-0x40011fff  scratch pad
   assign	ram_ce = wb.stb && wb.adr[16];

   assign	wb.dat_i = rom_ce ? do_rom : 
			   ram_ce ? do_ram :
			   32'h0;

   // RAM
   //
   assign 	ram_we[0] = wb.we & wb.sel[0];
   assign 	ram_we[1] = wb.we & wb.sel[1];
   assign 	ram_we[2] = wb.we & wb.sel[2];
   assign 	ram_we[3] = wb.we & wb.sel[3];

   or1200_spram_2048x32_bw boot_ram
     (
      .clk(wb.clk), .rst(wb.rst),
      .ce(ram_ce), .we(ram_we),
      .oe(1'b1), .addr(wb.adr[12:2]),
      .di(wb.dat_o), .doq(do_ram)
      );
		     
// ROM
// 
   mon_prog_bram boot_prog_bram
     (wb.clk, rom_ce, wb.adr[14:2], do_rom);

endmodule // romram


// Local Variables:
// verilog-library-directories:("." ".." "../or1200" "../jpeg" "../pkmc" "../dvga" "../uart" "../monitor" "../lab1" "../dafk_tb" "../eth" "../wb" "../leela")
// End:
