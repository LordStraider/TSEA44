`include "include/dafk_defines.v"
`include "include/timescale.v"

module lab1_tb();
   logic clk,rst;
   
   initial
   begin
      clk = 1'b0;
      rst = 1'b1;
      #1000 rst = 1'b0; 
   end

   // This the clock on the board = 40 MHz
   always #12.5 clk = ~clk;

   // Clock inside this is 25 MHz
   computer_lab1 computer0(.*);
   
   testcomputer_lab1 tester1(.*);
endmodule // dafk_mikro_tb

// *****************************************
// The test program                        *
// *****************************************
program testcomputer_lab1(input clk,rst);
initial
  begin
     forever
       computer0.uart1.getch();
  end

initial
  begin
     // test monitor with "d 00002000\r"
     #7000000 computer0.uart1.putstr("d 00002000"); 
  end
   
endprogram // tester

// *****************************************
// The computer under test                 *
// *****************************************
module computer_lab1(input clk,rst) ;
   wire [7:0] 	out_pad_o;
   wire 	uart_tx, uart_rx;

   // Memory Bus
   wire [31:0] 	mc_dio;
   wire [23:0] 	mc_addr;
   wire [2:0] 	mc_cs;
   wire 	mc_we, mc_oe;
   wire 	mc_ras, mc_cas;
   wire 	mc_cke;
   wire 	mc_rp;
   wire [3:0] 	mc_sel;
   wire 	sdram_clk;
   wire [23:0] 	baddr; 
   wire [31:0] 	bdata;
   wire 	mdbuf_oe;
   wire 	mabuf_oe;
   wire 	mdbuf_dir;

   
   uart_tasks uart1(.*);

   // Simulate SDRAM 0x0000_0000 to 0x03ff_ffff
   sdram sdram0
     (
      .Dq(mc_dio),
      .Addr(mc_addr[12:0]),
      .Ba(mc_addr[14:13]),
      .Clk(sdram_clk),
      .Cke(mc_cke),
      .Cs_n(mc_cs[2]),
      .Ras_n(mc_ras),
      .Cas_n(mc_cas),
      .We_n(mc_we),
      .Dqm(mc_sel)
      );

   // Instantiate FPGA Computer 
   lab1 dafk_top
     (
      .clk_i(clk), .rst_i(rst),
      // UART
      .stx_pad_o(uart_tx), .srx_pad_i(uart_rx), 
      // PIA
      .in_pad_i(8'h80), .out_pad_o(out_pad_o),
      // PKMC
      .mc_addr_pad_o(mc_addr), // 24 address bus
      .mc_dio(mc_dio), 	 // 32 data bus
      .mc_dqm_pad_o(mc_sel), 	 // 4 byte enables
      .mc_oe_pad_o_(mc_oe), .mc_we_pad_o_(mc_we), // OE, WE
      .mc_cas_pad_o_(mc_cas), .mc_ras_pad_o_(mc_ras),
      .mc_cke_pad_o_(mc_cke),
      .mc_cs_pad_o_(mc_cs),	 // 8 chip selects
      .mc_rp_pad_o_(mc_rp),
      .sdram_clk(sdram_clk),
      .mdbuf_oe(mdbuf_oe), 
      .mdbuf_dir(mdbuf_dir), 
      .mabuf_oe(mabuf_oe),
      .flashCE(flashCE), .kboomFlashCE(kboomFlashCE), .pmcBuffOE(pmcBuffOE)
      );
   
endmodule

// Local Variables:
// verilog-library-directories:("." ".." "../or1200" "../jpeg" "../pkmc" "../dvga" "../uart" "../monitor" "../lab1" "../dafk_tb" "../eth" "../wb" "../leela")
// End:
