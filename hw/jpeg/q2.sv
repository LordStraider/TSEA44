`include "include/timescale.v"

module q2(output[31:0] x_o,
	      input [31:0] x_i, rec_i);

    reg [31:0] r;
    reg [15:0] zeros;

    always_comb begin : proc_
        r = x_i * rec_i;
        r[16:0] = r[31:14];
        r[31:14] = 17'd0;

        // r = round(r);
    end

   assign x_o = r;

endmodule //
// Local Variables:
// verilog-library-directories:("." ".." "../or1200" "../jpeg" "../pkmc" "../dvga" "../uart" "../monitor" "../lab1" "../dafk_tb" "../eth" "../wb" "../leela")
// End:
