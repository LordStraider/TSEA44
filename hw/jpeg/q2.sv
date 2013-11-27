`include "include/timescale.v"

module q2(output[31:0] x_o,
	      input [31:0] x_i, 
	      input [15:0] rec_i1, 
	      input [15:0] rec_i2);



    reg [31:0] r1;
    reg [31:0] r2;
    
    
    always_comb begin 
        r1 = x_i[31:16] * rec_i1;
        if (r1[16] == 1'b1) begin 
            r1[16:0] = r1[31:15];
            r1[31:15] = 17'd0;
            r1 = r1 +1;
        end else begin 
            r1[16:0] = r1[31:15];
            r1[31:15] = 17'd0;
        end
    end
    
    always_comb begin 
        r2 = x_i[15:0] * rec_i2;
        if (r2[16] == 1'b1) begin 
            r2[16:0] = r2[31:15];
            r2[31:15] = 17'd0;
            r2 = r2 +1;
        end else begin 
            r2[16:0] = r2[31:15];
            r2[31:15] = 17'd0;
        end
    end           

    assign x_o[31:16] = r1;
    assign x_o[15:0] = r2;

endmodule //
// Local Variables:
// verilog-library-directories:("." ".." "../or1200" "../jpeg" "../pkmc" "../dvga" "../uart" "../monitor" "../lab1" "../dafk_tb" "../eth" "../wb" "../leela")
// End:
