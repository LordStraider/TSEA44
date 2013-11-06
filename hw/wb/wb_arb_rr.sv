/////////////////////////////////////////////////////////////////////
////                                                             ////
//// Wishbone Creator                                            ////
//// Copyright (C) 2004 Daniel Wiklund, Linköping University     ////
////                                                             ////
//// This source file may be used and distributed without        ////
//// restriction provided that this copyright statement is not   ////
//// removed from the file and that any derivative work contains ////
//// the original copyright notice and the associated disclaimer.////
////                                                             ////
////     THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY     ////
//// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED   ////
//// TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS   ////
//// FOR A PARTICULAR PURPOSE. IN NO EVENT SHALL THE AUTHOR      ////
//// OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,         ////
//// INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES    ////
//// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE   ////
//// GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR        ////
//// BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF  ////
//// LIABILITY, WHETHER IN  CONTRACT, STRICT LIABILITY, OR TORT  ////
//// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT  ////
//// OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE         ////
//// POSSIBILITY OF SUCH DAMAGE.                                 ////
////                                                             ////
/////////////////////////////////////////////////////////////////////

`include "include/wb_def.v"

module wb_arb_rr(clk_i, rst_i, req_i, gnt_o);

   input            clk_i;
   input            rst_i;
   input [`Nm-1:0]  req_i;
   output [`gntw-1:0] gnt_o;

   const logic [`gntw-1:0] grant0 = 3'h0,
     grant1 = 3'h1,
     grant2 = 3'h2,
     grant3 = 3'h3,
     grant4 = 3'h4,
     grant5 = 3'h5,
     grant6 = 3'h6,
     grant7 = 3'h7;

   reg [`gntw-1:0] 	 state, next_state;

   always_ff @(posedge clk_i)
     if (rst_i) 
       state <= grant0;
     else 
       state <= next_state;

   assign 		 gnt_o = state;
   
   always_comb begin
      case(state)
	grant0:
	  if (req_i[0]) next_state = grant0;
	  else if (req_i[1]) next_state = grant1;
	  else if (req_i[2]) next_state = grant2;
	  else if (req_i[3]) next_state = grant3;
	  else if (req_i[4]) next_state = grant4;
	  else if (req_i[5]) next_state = grant5;
	  else if (req_i[6]) next_state = grant6;
	  else if (req_i[7]) next_state = grant7;
	  else next_state = grant0;
	grant1:
	  if (req_i[1]) next_state = grant1;
	  else if (req_i[2]) next_state = grant2;
	  else if (req_i[3]) next_state = grant3;
	  else if (req_i[4]) next_state = grant4;
	  else if (req_i[5]) next_state = grant5;
	  else if (req_i[6]) next_state = grant6;
	  else if (req_i[7]) next_state = grant7;
	  else if (req_i[0]) next_state = grant0;
	  else next_state = grant1;
	grant2:
	  if (req_i[2]) next_state = grant2;
	  else if (req_i[3]) next_state = grant3;
	  else if (req_i[4]) next_state = grant4;
	  else if (req_i[5]) next_state = grant5;
	  else if (req_i[6]) next_state = grant6;
	  else if (req_i[7]) next_state = grant7;
	  else if (req_i[0]) next_state = grant0;
	  else if (req_i[1]) next_state = grant1;
	  else next_state = grant2;
	grant3:
	  if (req_i[3]) next_state = grant3;
	  else if (req_i[4]) next_state = grant4;
	  else if (req_i[5]) next_state = grant5;
	  else if (req_i[6]) next_state = grant6;
	  else if (req_i[7]) next_state = grant7;
	  else if (req_i[0]) next_state = grant0;
	  else if (req_i[1]) next_state = grant1;
	  else if (req_i[2]) next_state = grant2;
	  else next_state = grant3;
	grant4:
	  if (req_i[4]) next_state = grant4;
	  else if (req_i[5]) next_state = grant5;
	  else if (req_i[6]) next_state = grant6;
	  else if (req_i[7]) next_state = grant7;
	  else if (req_i[0]) next_state = grant0;
	  else if (req_i[1]) next_state = grant1;
	  else if (req_i[2]) next_state = grant2;
	  else if (req_i[3]) next_state = grant3;
	  else next_state = grant4;
	grant5:
	  if (req_i[5]) next_state = grant5;
	  else if (req_i[6]) next_state = grant6;
	  else if (req_i[7]) next_state = grant7;
	  else if (req_i[0]) next_state = grant0;
	  else if (req_i[1]) next_state = grant1;
	  else if (req_i[2]) next_state = grant2;
	  else if (req_i[3]) next_state = grant3;
	  else if (req_i[4]) next_state = grant4;
	  else next_state = grant5;
	grant6:
	  if (req_i[6]) next_state = grant6;
	  else if (req_i[7]) next_state = grant7;
	  else if (req_i[0]) next_state = grant0;
	  else if (req_i[1]) next_state = grant1;
	  else if (req_i[2]) next_state = grant2;
	  else if (req_i[3]) next_state = grant3;
	  else if (req_i[4]) next_state = grant4;
	  else if (req_i[5]) next_state = grant5;
	  else next_state = grant6;
	grant7:
	  if (req_i[7]) next_state = grant7;
	  else if (req_i[0]) next_state = grant0;
	  else if (req_i[1]) next_state = grant1;
	  else if (req_i[2]) next_state = grant2;
	  else if (req_i[3]) next_state = grant3;
	  else if (req_i[4]) next_state = grant4;
	  else if (req_i[5]) next_state = grant5;
	  else if (req_i[6]) next_state = grant6;
	  else next_state = grant7;
      endcase
   end

endmodule
// Local Variables:
// verilog-library-directories:("." ".." "../or1200" "../jpeg" "../pkmc" "../dvga" "../uart" "../monitor" "../lab1" "../dafk_tb" "../eth" "../wb" "../leela")
// End:
