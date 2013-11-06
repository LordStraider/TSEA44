`include "include/timescale.v"

module or1200_vlx_ctrl(/*AUTOARG*/
   // Outputs
   dummy_o,
   // Inputs
   clk_i, rst_i
   );
   input clk_i;
   input rst_i;

//**** Dummy code to make synthesis possible --->
   output dummy_o;
   assign dummy_o = 0;
//<---- Dummy code ends ****
   
endmodule
// Local Variables:
// verilog-library-directories:("." ".." "../or1200" "../jpeg" "../pkmc" "../dvga" "../uart" "../monitor" "../lab1" "../dafk_tb" "../eth" "../wb" "../leela")
// End:
