`include "include/timescale.v"

module q2(output[31:0] x_o,
	      input [31:0] x_i, 
	      input [15:0] rec_i1, 
	      input [15:0] rec_i2);



    reg [31:0] r;
    
    
    always_comb begin : proc_
        r = x_i * rec_i;
        if (r[16] == 1) begin 
            r[16:0] = r[31:14];
            r[31:14] = 17'd0;
            r +=1;
        end else begin 
            r[16:0] = r[31:14];
            r[31:14] = 17'd0;
        end
        
        // r = round(r);
        
    end

   assign x_o = r;

endmodule //
// Local Variables:
// verilog-library-directories:("." ".." "../or1200" "../jpeg" "../pkmc" "../dvga" "../uart" "../monitor" "../lab1" "../dafk_tb" "../eth" "../wb" "../leela")
// End:
