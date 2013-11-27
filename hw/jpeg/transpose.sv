`include "include/timescale.v"

module transpose(
    input clk, rst,
    input t_rd,
    input t_wr,
    input [7:0][11:0] data_in,
    output [7:0][11:0] data_out
);
    reg [7:0][7:0][11:0] memory;
    reg [7:0][11:0] out_reg;
    reg [7:0] col_count;
    reg [7:0] row_count;
    reg [3:0] clk_counter;

    always @(posedge clk) begin
        if (rst) begin
            clk_counter <= 0;
        end else begin
            clk_counter <= clk_counter + 1;
            if (clk_counter == 3'h3) 
                clk_counter <= 3'h0;
        end
    end

    always @(posedge clk) begin
        if (rst) begin
            row_count[7:0] <= 8'd0;
        end else if(t_wr && clk_counter == 3'h3) begin
            memory[row_count] <= data_in;
            row_count <= row_count + 1;
            if (row_count == 8'd8)
                row_count <= 8'd0;
        end
    end

    always @(posedge clk) begin
        if (rst) begin
            col_count[7:0] <= 8'b0;
        end else if(t_rd && clk_counter == 3'h3) begin
        
        //({y[7][11:0],y[6][11:0],y[5][11:0],y[4][11:0],y[3][11:0],y[2][11:0],y[1][11:0],y[0][11:0]})
          //  out_reg <= memory[7:0][col_count][11:0];
            col_count <= col_count + 1;
            if (col_count == 8'd8)
                col_count = 8'b0;
        end
    end

    always_comb begin
        out_reg[7] = memory[7][7-col_count];
        out_reg[6] = memory[6][7-col_count];
        out_reg[5] = memory[5][7-col_count];
        out_reg[4] = memory[4][7-col_count];
        out_reg[3] = memory[3][7-col_count];
        out_reg[2] = memory[2][7-col_count];
        out_reg[1] = memory[1][7-col_count];
        out_reg[0] = memory[0][7-col_count];
    end

    assign data_out = out_reg;

endmodule

// Local Variables:
// verilog-library-directories:("." ".." "../or1200" "../jpeg" "../pkmc" "../dvga" "../uart" "../monitor" "../lab1" "../dafk_tb" "../eth" "../wb" "../leela")
// End:
