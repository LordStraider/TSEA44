`include "include/timescale.v"

module perf_top
  (
   wishbone.slave wb,
      // Master signals
   wishbone.monitor m0, m1
   );

   assign 	wb.rty = 1'b0;	// not used in this course
   assign 	wb.err = 1'b0;  // not used in this course
   assign 	wb.ack = wb.stb && wb.cyc; // change if needed
   


   
endmodule // perf_top
// Local Variables:
// verilog-library-directories:("." "or1200" "jpeg" "pkmc" "dvga" "uart" "monitor" "lab1" "dafk_tb" "eth" "wb" "leela")
// End:
