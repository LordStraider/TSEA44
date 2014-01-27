`include "include/timescale.v"


module lab1_uart_top (
    wishbone.slave wb,
    output wire int_o,
    input wire 	srx_pad_i,
    output wire stx_pad_o);

    assign int_o = 1'b0;  // Interrupt, not used in this lab
    assign wb.err = 1'b0; // Error, not used in this lab
    assign wb.rty = 1'b0; // Retry, not used in this course

    // Here you must instantiate lab0_uart or cut and paste
    // You will also have to change the interface of lab0_uart to make this work.

     
    reg rd;
    reg wr;
    reg wr_o;
    reg end_char;
    reg ack;
    reg uart_ack;
    reg rx_full;
    reg [7:0] tx_reg;
    reg [1:0] tx_empty;
    reg [7:0] last_8_rx_bits;
    reg [7:0] rx_reg;
    lab0 uart(wb.clk, wb.rst, srx_pad_i, stx_pad_o, last_8_rx_bits, tx_reg, wr_o, end_char, uart_ack);
    
    
    //the reset signal to the rx_full F/F
    always_comb 
    begin
        if (wb.rst) begin
            rd <= 1'b0;
            wr <= 1'b0;
        end else begin
            rd <= wb.stb && ~wb.we && wb.sel[3] && ~wb.adr[2];
            wr <= wb.stb && wb.we && wb.sel[3] && ~wb.adr[2];
        end
    end

   //
   always @(posedge wb.clk)
    begin
        wr_o <= wr;
        //rx_full
        if (wb.rst) begin
            rx_full <= 1'b0;
            tx_empty <= 2'b11;
            tx_reg <= 8'b0;
        end else if (rd)
            rx_full <= 1'b0;
        else if (end_char)
            rx_full <= 1'b1;
        
        //tx_empty
        if (wr) begin
            tx_empty <= 2'b0;
            tx_reg <= wb.dat_o[31:24];
        end else if (uart_ack)
            tx_empty <= 2'b11;
    end
    
    always @(posedge wb.clk)
    begin
        if(end_char)
            rx_reg <= last_8_rx_bits;
    end
    
    //set ack
    always @(posedge wb.clk)
    begin
        if (wb.rst)
            ack <= 1'b0;                        
        else if (wb.stb)
            ack <= 1'b1;
        else
            ack <= 1'b0;
    end
    
    assign wb.ack = ack;
    assign wb.dat_i[31:24] = rx_reg;
    assign wb.dat_i[16] = rx_full;
    assign wb.dat_i[22:21] = tx_empty;

endmodule


// Local Variables:
// verilog-library-directories:("." ".." "../or1200" "../jpeg" "../pkmc" "../dvga" "../uart" "../monitor" "../lab1" "../dafk_tb" "../eth" "../wb" "../leela")
// End:
