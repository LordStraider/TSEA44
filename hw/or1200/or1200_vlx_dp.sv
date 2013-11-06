`include "include/timescale.v"

module or1200_vlx_dp(/*AUTOARG*/
   // Outputs
   spr_dat_o, bit_reg_o, 
   // Inputs
   clk_i, rst_i, bit_vector_i, num_bits_to_write_i, spr_addr, 
   write_dp_spr_i, spr_dat_i
   );

   input clk_i;
   input rst_i;
   
   input [31:0] bit_vector_i;
   input [4:0] 	num_bits_to_write_i;
   input 	spr_addr;
   input 	write_dp_spr_i;
   input [31:0] spr_dat_i;

   output [31:0] spr_dat_o;
   output [31:0] bit_reg_o;

   reg [31:0] 	bit_reg;
   reg [5:0] 	bit_reg_wr_pos;

   //Here you must write code for packing bits to a register.
   always_ff @(posedge clk_i or posedge rst_i) begin
      if(rst_i) begin
	 bit_reg <= 0;
	 bit_reg_wr_pos <= 31;
      end
      else begin
	 if(write_dp_spr_i) begin
	    if(spr_addr) begin
	       bit_reg <= spr_dat_i;
	    end
	    else begin
	       bit_reg_wr_pos <= {26'b0,spr_dat_i[5:0]};
	    end
	 end
      end
   end

   assign spr_dat_o = spr_addr ? bit_reg : {26'b0,bit_reg_wr_pos};

endmodule // or1200_vlx_dp
// Local Variables:
// verilog-library-directories:("." ".." "../or1200" "../jpeg" "../pkmc" "../dvga" "../uart" "../monitor" "../lab1" "../dafk_tb" "../eth" "../wb" "../leela")
// End:
