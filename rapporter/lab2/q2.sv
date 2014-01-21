`include "include/timescale.v"

module q2(output [31:0] x_o,
	      input [31:0] x_i,
	      input [15:0] rec_i1,
	      input [15:0] rec_i2);

    logic signed [15:0] a_signed;
    logic signed [15:0] b_signed;
    logic signed [15:0] rec_i1_signed;
    logic signed [15:0] rec_i2_signed;
    logic signed [31:0] r1;
    logic signed [31:0] r2;
    logic rnd1, bits1, pos1;
    logic rnd2, bits2, pos2;

    always_comb begin
        a_signed = x_i[31:16];
        rec_i1_signed = rec_i1;
        r1 = a_signed * rec_i1_signed;

        rnd1 = r1[16]; // (r1 & 0x10000) != 0 ;
        bits1 = r1[15:0] != 16'h0; // (r1 & 0xffff) != 0;
        pos1 = ~r1[31]; //(r1 & 0x80000000) == 0;

        r1[14:0] = r1[31:17];
        r1[31:15] = {17{r1[31]}};

        if (rnd1 && (pos1 || bits1))
            r1 = r1 + 1;
    end

    always_comb begin
        b_signed = x_i[15:0];
        rec_i2_signed = rec_i2;
        r2 = b_signed * rec_i2_signed;

        rnd2 = r2[16]; // (r2 & 0x10000) != 0 ;
        bits2 = r2[15:0] != 16'h0; // (r2 & 0xffff) != 0;
        pos2 = ~r2[31]; //(r2 & 0x80000000) == 0;

        r2[14:0] = r2[31:17];
        r2[31:15] = {17{r2[31]}};

        if (rnd2 && (pos2 || bits2))
            r2 = r2 + 1;
    end

    assign x_o[31:16] = r1[15:0];
    assign x_o[15:0] = r2[15:0];

endmodule //
// Local Variables:
// verilog-library-directories:("." ".." "../or1200" "../jpeg" "../pkmc" "../dvga" "../uart" "../monitor" "../lab1" "../dafk_tb" "../eth" "../wb" "../leela")
// End:
