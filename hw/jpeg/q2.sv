`include "include/timescale.v"

module q2(output[31:0] x_o, 
	  input [31:0] x_i, rec_i);

   //Change this
   assign x_o = x_i;
   
endmodule //
// Local Variables:
// verilog-library-directories:("." ".." "../or1200" "../jpeg" "../pkmc" "../dvga" "../uart" "../monitor" "../lab1" "../dafk_tb" "../eth" "../wb" "../leela")
// End:
