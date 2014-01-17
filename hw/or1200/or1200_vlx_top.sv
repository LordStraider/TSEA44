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
    input [4:0]	num_bits_to_write_i; //.size
    input  spr_cs; //sprs chip select
    input  spr_write; //sprs write
    input [1:0] spr_addr; //sprs address
    input [31:0] spr_dat_i; //sprs data in

    output [31:0] spr_dat_o; //sprs data out
    output 	stall_cpu_o; //if set high the cpu will be stalled
    output [31:0] vlx_addr_o; //the address to store vlx data
    output [31:0] dat_o; //data vlx data to be stored
    output 	 store_byte_o; //high when storing a byte

    wire 	 set_init_addr;
    wire 	 store_reg;
//    wire 	 last_byte;
//    wire 	 ack_vlx_write_done;
    wire [31:0] 	 su_data_in;
    wire [31:0] 	 spr_dp_dat_o;
    wire 	 write_dp_spr;

    // own defined signal registerzzzzzzz
    reg     is_sending;
    reg [1:0]   this_ack;

    reg [31:0]  bit_reg;
    reg [5:0]   bit_reg_wr_pos;
    reg [15:0] data_to_be_sent;
    reg ready_to_send;
    reg [31:0] address_counter;

    reg [1:0] ack_counter;
    reg stall, next_stall, running;

    assign store_byte_o = is_sending;

    assign 	set_init_addr = spr_cs & spr_addr[1] & spr_write;
    assign 	write_dp_spr = spr_cs & spr_write & ~spr_addr[1];
//    assign 	ack_vlx_write_done = ack_i & last_byte;
    assign 	su_data_in = set_init_addr ? spr_dat_i : bit_reg;

    //Here you must generate the stall_cpu_o signal, when high it will stall the cpu,
    //inhibiting it from fetching new instructions.
    assign 	stall_cpu_o = stall;
    assign 	spr_dat_o = spr_addr[1] ? vlx_addr_o : spr_dp_dat_o;

   // assign spr_dat_o = 0; //hur använder vi denna????
    assign vlx_addr_o = address_counter;
    assign dat_o = {16'b0, data_to_be_sent};


    always_comb begin
        if (bit_reg[8:0] == 8'hff) begin
            data_to_be_sent <= 16'hff00;
        end else begin
            data_to_be_sent <= {8'h0, bit_reg[bit_reg_wr_pos-1 -: 8]};
        end
    end


   always_ff @(posedge clk_i or posedge rst_i) begin
    if(rst_i) begin
        is_sending      <= 0;
        bit_reg         <= 0;
        bit_reg_wr_pos  <= 0;
        running <= 0;
        ready_to_send <= 0;
        this_ack <= ack_counter;
        address_counter <= 32'h383c2d0; //spr_address shofräs egentligen

    end else begin

        if(set_bit_op_i) begin
        //packning av data.
            running <= 1;
            if (bit_reg_wr_pos <= 7) begin
            //keep shifting in bits
                ready_to_send <= 0;

                bit_reg <= (bit_reg << num_bits_to_write_i) | dat_i;

                if (bit_reg_wr_pos + num_bits_to_write_i > 15)
                    this_ack <= 2;
                else if (bit_reg_wr_pos + num_bits_to_write_i > 7)
                    this_ack <= 1;
                else
                    this_ack <= 0;

                bit_reg_wr_pos <= bit_reg_wr_pos + num_bits_to_write_i;
            end
        end else if (bit_reg_wr_pos > 7 && this_ack != ack_counter) begin
            //write data to Store Unit
            bit_reg[bit_reg_wr_pos-1 -: 8] <= 8'h0;
//            bit_reg <= bit_reg >> 8;
            this_ack <= ack_counter;

            /*we want to send ff00 if ff is encountered in bitreg [8:0]*/
            if (bit_reg[8:0] == 8'hff) begin
                address_counter <= address_counter + 2;
                bit_reg_wr_pos <= bit_reg_wr_pos - 8;
            end else
                ready_to_send <= 1;
                address_counter <= address_counter + 1;
                bit_reg_wr_pos <= bit_reg_wr_pos - 8;
            end

            is_sending <= 1;

            if (ack_counter == 0) begin
                running <= 0;
                is_sending <= 0;
            end
        end
    end


    always @(posedge clk_i) begin
      if (rst_i)
        ack_counter <= 0;
      else if (ack_i == 1 && is_sending)
        ack_counter <= ack_counter - 1;
      else if (bit_reg_wr_pos + num_bits_to_write_i > 15 && set_bit_op_i)
        ack_counter <= 2;
      else if (bit_reg_wr_pos + num_bits_to_write_i > 7  && set_bit_op_i)
        ack_counter <= 1;
    end


    always @(posedge clk_i) begin
        if (rst_i) begin
            next_stall <= 0;
        end else if (set_bit_op_i == 1 || ack_counter != 0) begin
            next_stall <= 1;
        end else if (ack_counter == 0) begin
            next_stall <= 0;
        end
    end


    always_comb begin
        stall = next_stall | set_bit_op_i;
    end

/*    always @(posedge clk_i) begin
       if(rst_i) begin
        //nbhttrbtrbhtr
       end else if (ready_to_send == 1) begin

    end
*/
endmodule
// Local Variables:
// verilog-library-directories:("." ".." "../or1200" "../jpeg" "../pkmc" "../dvga" "../uart" "../monitor" "../lab1" "../dafk_tb" "../eth" "../wb" "../leela")
// End:
