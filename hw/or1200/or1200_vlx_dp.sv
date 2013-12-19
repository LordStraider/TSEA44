`include "include/timescale.v"

module or1200_vlx_dp(/*AUTOARG*/
   // Outputs
   spr_dat_o, bit_reg_o, ready_to_send_o,
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

   //nytt shofräs
   input [3:0]  size;
   input [15:0] code;

   output [31:0] spr_dat_o;
   //output till store unit
   output ready_to_send_o;

   //output to memory.
   output   reg [31:0] vlx_addr_o; //address where data is stored
   output   reg [31:0] dat_o; //actual data stored
   output   last_byte_o; //high when the last byte is being stored.
   output   store_byte_o; //high when a byte should be stored

   reg [31:0] 	bit_reg;
   reg [5:0] 	bit_reg_wr_pos;
   reg send_data_to_su;
   reg [7:0] data_to_be_sent;
   reg ready_to_send;
   reg [31:0] address_counter;



   //Here you must write code for packing bits to a register.
   always_ff @(posedge clk_i or posedge rst_i) begin
      if(rst_i) begin
	 bit_reg <= 0;
	 bit_reg_wr_pos <= 0;
    send_data_to_su <= 0;
    ready_to_send_o <= 0;
    address_counter <= 0; //spr_address shofräs igentligen

      end
      else begin
	 if(write_dp_spr_i) begin
	    if(spr_addr) begin
         //packning av data.
	       //bit_reg <= spr_dat_i;
          if (bit_reg == 0)
            bit_reg = code;
            bit_reg_wr_pos += size;

         else if (bit_reg_wr_pos <= 7) begin
            //keep shifting in bits
            ready_to_send_o <= 0;
            bit_reg[bit_reg_wr_pos + size:bit_reg_wr_pos] = code;
            bit_reg_wr_pos -= 8;

         end else if (bit_reg_wr_pos > 7) begin
            //write data to Store Unit
            if (code == 16'hff) begin


            bit_reg >> 8;
            data_to_be_sent <= bit_reg[7:0];
            send_data <= 1;

         end






	    end
	    else begin
	       //bit_reg_wr_pos <= {26'b0,spr_dat_i[5:0]};
	    end
	 end
      end

   end
   assign bit_reg_o = data_to_be_sent;
   assign dat_o = data_to_be_sent;
   assign spr_dat_o = 0; //hur använder vi denna????
   assign vlx_addr_o = address_counter;
   //assign spr_dat_o = spr_addr ? bit_reg : {26'b0,bit_reg_wr_pos};

endmodule // or1200_vlx_dp
// Local Variables:
// verilog-library-directories:("." ".." "../or1200" "../jpeg" "../pkmc" "../dvga" "../uart" "../monitor" "../lab1" "../dafk_tb" "../eth" "../wb" "../leela")
// End:
