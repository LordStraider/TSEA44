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

    /*
     lab0 uart(
        input clk_i,
        input rst_i,
        input rx_i,
        output tx_o,
        output [7:0] led_o,
        input [7:0] switch_i,
        input send_i, 
        output end_char_rx, 
        output ack_o
     );
     */
     
    reg rd;
    reg wr;
    reg wr_o;
    reg end_char;
    reg ack;
    reg uart_ack;
    reg [31:0] tx_reg;
    reg [31:0] rx_reg;  
    reg [7:0] last_8_rx_bits;
    
    lab0 uart(wb.clk, wb.rst, srx_pad_i, stx_pad_o, last_8_rx_bits, tx_reg[31:24], wr_o, end_char, uart_ack);
    
    always @(posedge wb.clk)
    begin
        if (wb.rst) begin
            rd <= 1'b0;
            wr <= 1'b0;
            wr_o <= 1'b0;
        end else begin
            rd <= wb.stb && ~wb.we && wb.sel[3] && ~wb.adr[2];
            wr <= wb.stb && wb.we && wb.sel[3] && ~wb.adr[2];
        end
        
        wr_o <= wr;
    end

    always @(posedge wb.clk)
    begin
        //rx_full
        rx_reg[31:24] <= last_8_rx_bits;
        
        if (wb.rst) 
            rx_reg[16] <= 1'b0;
        else if (end_char)
            rx_reg[16] <= 1'b1;
        else if (rd)
            rx_reg[16] <= 1'b0;        
        
        //tx_empty
        if (wb.rst)
            tx_reg[22:21] <= 2'b0;
        else if (wr)
            tx_reg[22:21] <= 2'b0;
        else if (uart_ack)
            tx_reg[22:21] <= 2'b1;
        
        if (wr)
            tx_reg[31:24] <= wb.dat_o[31:24];
    end
    
    
    //set ack
    always @(posedge wb.clk)
    begin
        if (wb.rst)
            ack <= 1'b0;
        else if (wr)
            ack <= uart_ack;
        else if (rd)
            ack <= 1'b1;
        else
            ack <= 1'b0;
    end
    
    assign wb.ack = ack;
    assign wb.dat_i = rx_reg;

endmodule


// Local Variables:
// verilog-library-directories:("." ".." "../or1200" "../jpeg" "../pkmc" "../dvga" "../uart" "../monitor" "../lab1" "../dafk_tb" "../eth" "../wb" "../leela")
// End:
