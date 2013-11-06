`include "dvga_defines.v"

module dvga_clock();  

   reg clk;
   reg rst;

   dvga_tb uut(.clk(clk), .rst(rst)) ;

   initial
     begin
        clk = 1'b0;
        rst = 1'b1;
        #130 rst = 1'b0; 
     end

   always #20 clk = ~clk;

endmodule

// Local Variables:
// verilog-library-directories:("." ".." "../or1200" "../jpeg" "../pkmc" "../dvga" "../uart" "../monitor" "../lab1" "../dafk_tb" "../eth" "../wb" "../leela")
// End:
