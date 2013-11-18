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


always @(posedge clk) begin
    if (rst) begin
        row_count[7:0] <= 8'd0;
    end else if(t_wr) begin
        //memory[(row_count+1)*96:row_count*96] <= data_in;
        row_count <= row_count + 1;
        if (row_count == 8'd8)
            row_count <= 8'd0;
    end
end

always @(posedge clk) begin
    if (rst) begin
        out_reg <= 96'b0;
        col_count[7:0] <= 8'b0;
    end else if(t_rd) begin
        //out_reg <= memory[7:0][col_count][11:0];
        col_count <= col_count + 1;
        if (col_count == 8'd8)
            col_count = 8'b0;
    end
end

assign data_out = out_reg;

endmodule

// Local Variables:
// verilog-library-directories:("." ".." "../or1200" "../jpeg" "../pkmc" "../dvga" "../uart" "../monitor" "../lab1" "../dafk_tb" "../eth" "../wb" "../leela")
// End:
