`timescale 1ns / 1ps
module small_mem(CLK, A, D, WE, SPO);
   parameter addr_width = 3;
   parameter data_width = 9;
   input     CLK;
   input [addr_width-1:0] A;
   input [data_width-1:0] D;
   input 		  WE;
   output [data_width-1:0] SPO;

   reg [data_width-1:0] 		   mem [2**addr_width-1:0];

   always@(posedge CLK) begin
      if(WE) begin
	 mem[A] = D;
      end
   end

   assign SPO = mem[A];
endmodule// Local Variables:
// verilog-library-directories:("." ".." "../or1200" "../jpeg" "../pkmc" "../dvga" "../uart" "../monitor" "../lab1" "../dafk_tb" "../eth" "../wb" "../leela")
// End:
