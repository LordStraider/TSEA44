`include "include/timescale.v"

module transpose(input logic clk, rst, wr , rd, 
		 input logic [95:0] in, 
		 output logic [95:0] ut);
   // Here you have to design the transpose memory
   assign 		ut = in;
endmodule

// Local Variables:
// verilog-library-directories:("." ".." "../or1200" "../jpeg" "../pkmc" "../dvga" "../uart" "../monitor" "../lab1" "../dafk_tb" "../eth" "../wb" "../leela")
// End:
