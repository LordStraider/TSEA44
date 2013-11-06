`include "include/timescale.v"

interface wishbone(input logic clk, rst);
   typedef logic [31:0] adr_t;
   typedef logic [31:0] dat_t;

   adr_t    adr;	// address bus
   dat_t    dat_o;	// write data bus
   dat_t    dat_i;	// read data bus
   logic 	   stb;	// strobe
   logic 	   cyc;	// cycle valid
   logic 	   we;	// indicates write transfer
   logic [3:0] 	   sel;	// byte select
   logic 	   ack;	// normal termination
   logic 	   err;	// termination w/ error
   logic 	   rty;	// termination w/ retry
   logic [2:0] 	   cti;	// cycle type identifier
   logic [1:0] 	   bte;	// burst type extension

   modport master(
    output 	   adr, dat_o, stb, cyc, we, sel, cti, bte, 
    input 	   clk, rst, dat_i, ack, err, rty);
      
   modport slave(
    input 	   clk, rst, adr, dat_o, stb, cyc, we, sel, cti, bte, 
    output 	   dat_i, ack, err, rty);

   modport monitor(
    input 	   clk, rst, adr, dat_o, stb, cyc, we, sel, cti, bte, 
    		   dat_i, ack, err, rty);

   logic dummy;
   assign dummy = ack; 

endinterface: wishbone

module dummy_slave(wishbone.slave wb);
   assign wb.ack = 1'b0;
   assign wb.rty = 1'b0;
   assign wb.dat_i = 32'h0;
   assign wb.err = wb.stb;
endmodule // dummy_slave

module dummy_master(wishbone.master wb);
   assign    wb.adr = 32'h0;
   assign    wb.dat_o = 32'h0;
   assign    wb.stb = 1'b0;
   assign    wb.cyc = 1'b0;
   assign    wb.we = 1'b0;
   assign    wb.sel = 4'h0;
   assign   wb.cti = 3'h0;
   assign   wb.bte = 2'h0;
endmodule // dummy_master
// Local Variables:
// verilog-library-directories:("." ".." "../or1200" "../jpeg" "../pkmc" "../dvga" "../uart" "../monitor" "../lab1" "../dafk_tb" "../eth" "../wb" "../leela")
// End:
