`include "include/timescale.v"


module lab1_uart_top 
  (wishbone.slave wb,
    output wire int_o,
    input wire 	srx_pad_i,
    output wire stx_pad_o);

   assign int_o = 1'b0;  // Interrupt, not used in this lab
   assign wb.err = 1'b0; // Error, not used in this lab
   assign wb.rty = 1'b0; // Retry, not used in this course

   // Here you must instantiate lab0_uart or cut and paste
   // You will also have to change the interface of lab0_uart to make this work.
   assign wb.ack = wb.stb;   // Change this line
   assign stx_pad_o = srx_pad_i; // Change this line.. :)
endmodule


// Local Variables:
// verilog-library-directories:("." ".." "../or1200" "../jpeg" "../pkmc" "../dvga" "../uart" "../monitor" "../lab1" "../dafk_tb" "../eth" "../wb" "../leela")
// End:
