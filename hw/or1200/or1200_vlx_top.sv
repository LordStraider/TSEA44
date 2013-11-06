`include "include/timescale.v"

module or1200_vlx_top(/*AUTOARG*/
   // Outputs
   spr_dat_o, stall_cpu_o, vlx_addr_o, dat_o, store_byte_o, 
   // Inputs
   clk_i, rst_i, ack_i, dat_i, set_bit_op_i, num_bits_to_write_i, 
   spr_cs, spr_write, spr_addr, spr_dat_i
   );
   input clk_i;
   input rst_i;
   
   input  ack_i; //ack
   input [31:0] dat_i; //data to be written

   input 	set_bit_op_i; //high if a set bit operation is in progress 
   input [4:0]	num_bits_to_write_i; //number of bits to write.
   input  spr_cs; //sprs chip select
   input  spr_write; //sprs write
   input [1:0] spr_addr; //sprs address
   input [31:0] spr_dat_i; //sprs data in

   output [31:0] spr_dat_o; //sprs data out
   output 	stall_cpu_o; //if set high the cpu will be staled
   output [31:0] vlx_addr_o; //the address to store vlx data
   output [31:0] dat_o; //data vlx data to be stored
   output 	 store_byte_o; //high when storing a byte

   wire 	 set_init_addr;   
   wire 	 store_reg;
   wire [31:0] 	 bit_reg;
   wire 	 last_byte;
   wire 	 ack_vlx_write_done;
   wire [31:0] 	 su_data_in;
   wire [31:0] 	 spr_dp_dat_o;
   wire 	 write_dp_spr;

   assign 	set_init_addr = spr_cs & spr_addr[1] & spr_write;
   assign 	write_dp_spr = spr_cs & spr_write & ~spr_addr[1];
   assign 	ack_vlx_write_done = ack_i & last_byte;
   assign 	su_data_in = set_init_addr ? spr_dat_i : bit_reg;

   //Here you must generate the stall_cpu_o signal, when high it will stall the cpu,
   //inhibiting it from fetching new instructions.
   assign 	stall_cpu_o = 0;

   assign 	spr_dat_o = spr_addr[1] ? vlx_addr_o : spr_dp_dat_o;
   
   or1200_vlx_su vlx_su
     (
      .vlx_addr_o	(vlx_addr_o),
      .dat_o		(dat_o),
      .last_byte_o	(last_byte),
      .store_byte_o     (store_byte_o),
      .clk_i		(clk_i),
      .rst_i		(rst_i),
      .ack_i		(ack_i),
      .dat_i		(su_data_in),
      .set_init_addr_i  (set_init_addr),
      .store_byte_i     (store_reg)
      );

   or1200_vlx_ctrl vlx_ctrl 
     (
      //Here you must extend the interface.
      .clk_i             (clk_i), 
      .rst_i             (rst_i),
      .dummy_o           ()
      );

   or1200_vlx_dp vlx_dp
     (
      //Here you must extend the interface.
      .bit_reg_o(bit_reg),
      .clk_i(clk_i),
      .rst_i(rst_i),
      .bit_vector_i(dat_i),
      .num_bits_to_write_i(num_bits_to_write_i),
      .spr_addr(spr_addr[0]),
      .spr_dat_o(spr_dp_dat_o),
      .spr_dat_i(spr_dat_i),
      .write_dp_spr_i(write_dp_spr)
      );




endmodule
// Local Variables:
// verilog-library-directories:("." ".." "../or1200" "../jpeg" "../pkmc" "../dvga" "../uart" "../monitor" "../lab1" "../dafk_tb" "../eth" "../wb" "../leela")
// End:
