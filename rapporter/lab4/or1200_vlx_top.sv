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
    wire [31:0] 	 su_data_in;
    wire [31:0] 	 spr_dp_dat_o;
    wire 	 write_dp_spr;

    reg     is_sending;
    reg [31:0]  bit_reg;
    reg [5:0]   bit_reg_wr_pos;
    reg [7:0] data_to_be_sent;
    reg [31:0] address_counter;

    reg [2:0] ack_counter;
    reg stall, next_stall;
    reg send_00;
    reg recieved_set_bit;
    reg ack_ff;

    assign store_byte_o = is_sending;

    // Signals for reading and writing SPR address register.
    assign 	set_init_addr = spr_cs & spr_addr[1] & spr_write;
    assign 	write_dp_spr = spr_cs & spr_write & ~spr_addr[1];
    assign 	su_data_in = set_init_addr ? spr_dat_i : bit_reg;
    assign  spr_dat_o = spr_addr[1] ? vlx_addr_o : spr_dp_dat_o;
    assign  vlx_addr_o = address_counter;

    assign dat_o = {24'b0, data_to_be_sent};
    assign stall_cpu_o = stall;

    // Delayed ACK.
    always @(posedge clk_i) begin
        ack_ff <= ack_i;
    end

    // Delayed start signal.
    always @(posedge clk_i) begin
        recieved_set_bit <= set_bit_op_i;
    end

    // Data recieve controller
    always_ff @(posedge clk_i or posedge rst_i) begin
    if(rst_i) begin
        bit_reg         <= 0;
        bit_reg_wr_pos  <= 0;
        address_counter <= 0;
    end else begin
        // If someone just wrote to address register, set the address counter to this value.
        if (set_init_addr) begin
            address_counter <= spr_dat_i;

        // If we just recieved the start signal.
        end else if(set_bit_op_i) begin
            if (bit_reg_wr_pos <= 7) begin
                // Insert num_bits_to_write bits from dat_i into bit_reg by ORing.
                bit_reg <= (bit_reg << num_bits_to_write_i) | dat_i;
                // Update write pointer.
                bit_reg_wr_pos <= bit_reg_wr_pos + num_bits_to_write_i;
            end

        // If we just recieved an ACK.
        end else if (ack_ff && (send_00 || bit_reg_wr_pos > 7)) begin
            // Reset the written bits in bit_reg.
            bit_reg[bit_reg_wr_pos-1] <= 0;
            bit_reg[bit_reg_wr_pos-2] <= 0;
            bit_reg[bit_reg_wr_pos-3] <= 0;
            bit_reg[bit_reg_wr_pos-4] <= 0;
            bit_reg[bit_reg_wr_pos-5] <= 0;
            bit_reg[bit_reg_wr_pos-6] <= 0;
            bit_reg[bit_reg_wr_pos-7] <= 0;
            bit_reg[bit_reg_wr_pos-8] <= 0;

            // Unless we just send the zero-padding for 0xFF, update bit_reg pointer.
            if (~send_00) begin
                bit_reg_wr_pos <= bit_reg_wr_pos - 8;
            end
            // Count up address.
            address_counter <= address_counter + 1;
        end
      end
    end

    // Data send controller
    always @(posedge clk_i) begin
        if (rst_i) begin
            data_to_be_sent <= 0;
            send_00 <= 0;
        // Handling of zero-padding for 0xFF.
        end else if (ack_ff && send_00) begin
            data_to_be_sent <= 0;
            send_00 <= 0;
        // Handling of special cases which could give undefined signals.
        end else if (bit_reg_wr_pos < 8) begin
            data_to_be_sent <= 0;
        end else if (data_to_be_sent == 8'hff) begin
            send_00 <= 1;
        end else begin
            // Put data from the place pointed out by bit_reg pointer to send register.
            data_to_be_sent[7] <= bit_reg[bit_reg_wr_pos-1];
            data_to_be_sent[6] <= bit_reg[bit_reg_wr_pos-2];
            data_to_be_sent[5] <= bit_reg[bit_reg_wr_pos-3];
            data_to_be_sent[4] <= bit_reg[bit_reg_wr_pos-4];
            data_to_be_sent[3] <= bit_reg[bit_reg_wr_pos-5];
            data_to_be_sent[2] <= bit_reg[bit_reg_wr_pos-6];
            data_to_be_sent[1] <= bit_reg[bit_reg_wr_pos-7];
            data_to_be_sent[0] <= bit_reg[bit_reg_wr_pos-8];
        end
    end

    // ACK counter controller
    always @(posedge clk_i) begin
        if (rst_i)
            ack_counter <= 0;

        // If we are currently sending something, and recieves an ACK.
        else if (ack_i == 1 && is_sending) begin
            // Unless we just sent the padding for 0xFF.
            if (data_to_be_sent != 8'hff) begin
                // Decrease the number of ACKs left to recieve.
                ack_counter <= ack_counter - 1;
            end
        // If we just recieved the start command.
        end else if (recieved_set_bit) begin
            // Determine number of ACKs to recieve depending on data length.
            if (bit_reg_wr_pos > 15)
                ack_counter <= 2;
            else if (bit_reg_wr_pos > 7)
                ack_counter <= 1;
        end
    end

    // Memory write signal
    always @(posedge clk_i) begin
        if(rst_i) begin
            is_sending <= 0;
        end else if (~ack_i && ack_counter > 0) begin
            is_sending <= 1;
        end else begin
            is_sending <= 0;
        end
    end

    // Stall controller
    always @(posedge clk_i) begin
        if (rst_i) begin
            next_stall <= 0;
        // If we just have recieved the start signal, begin to stall.
        end else if (set_bit_op_i == 1 || recieved_set_bit == 1) begin
            next_stall <= 1;
        // If we have recieved the required number of ACK-signals, end stall.
        end else if (ack_counter == 0) begin
            next_stall <= 0;
        end
    end

    always_comb begin
        stall = next_stall | set_bit_op_i;
    end

endmodule
// Local Variables:
// verilog-library-directories:("." ".." "../or1200" "../jpeg" "../pkmc" "../dvga" "../uart" "../monitor" "../lab1" "../dafk_tb" "../eth" "../wb" "../leela")
// End:
