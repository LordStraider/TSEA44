`include "include/timescale.v"


module perf_top (
    wishbone.slave wb,
    wishbone.monitor m0, m1);
    
    reg [31:0] counter1, counter2, counter3, counter4;
    reg [31:0] rx_reg;

    reg rd, wr, ack;

    always @(posedge wb.clk) begin
        if (wb.rst) begin
            counter1 <= 32'b0;
            counter2 <= 32'b0;
            counter3 <= 32'b0;
            counter4 <= 32'b0;
        end else if (wr) begin
            if (wb.adr == 32'h99000000)
                counter1 <= wb.dat_o;

            else if (wb.adr == 32'h99000004)
                counter2 <= wb.dat_o;

            else if (wb.adr == 32'h99000008)
                counter3 <= wb.dat_o;

            else if (wb.adr == 32'h9900000c)
                counter4 <= wb.dat_o;

        end else begin
            if (m0.cyc && m0.stb)
                counter1 <= counter1 + 1;
        
            if (m0.ack) 
                counter2 <= counter2 + 1;
            
            if (m1.cyc && m1.stb)
                counter3 <= counter3 + 1;

            if (m1.ack)
                counter4 <= counter4 + 1;
        end
    end
    
    always_comb begin
        if (wb.rst) begin
            rd <= 1'b0;
            wr <= 1'b0;
        end else begin
            rd <= wb.stb && ~wb.we;
            wr <= wb.stb && wb.we;
        end
    end
    
    always_comb begin
        case (wb.adr[3:2])
            2'b00:  rx_reg = counter1;
            2'b01:  rx_reg = counter2;
            2'b10:  rx_reg = counter3;
            2'b11:  rx_reg = counter4;
        endcase
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
    assign wb.dat_i = rx_reg;
    assign wb.rty = 1'b0;
    assign wb.err = 1'b0;


endmodule // perf_top

// Local Variables:
// verilog-library-directories:("." "or1200" "jpeg" "pkmc" "dvga" "uart" "monitor" "lab1" "dafk_tb" "eth" "wb" "leela")
// End:
