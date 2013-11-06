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

module wb_top(
  input clk_i, rst_i,

  // Connect to Masters
  wishbone.slave Mx[0:`Nm-1],

  // Connect to Slaves
  wishbone.master Sx[0:`Ns-1]
  );

   parameter s_addr_w = 8;
   parameter s0_addr = 8'h90;
   parameter s1_addr = 8'h91;
   parameter s2_addr = 8'h92;
   parameter s3_addr = 8'h93;
   parameter s4_addr = 8'h94;
   parameter s5_addr = 8'h95;
   parameter s6_addr = 8'h96;
   parameter s7_addr = 8'h97;
   parameter s8_addr = 8'h98;
   parameter s9_addr = 8'h99;

   localparam logic [0:`Ns-1][s_addr_w-1:0] sx_addr = {s0_addr,s1_addr,s2_addr,s3_addr,s4_addr,
						      s5_addr,s6_addr,s7_addr,s8_addr,s9_addr};
   
   typedef   struct {logic [`aw-1:0] adr;
		     logic [`dw-1:0] dat_o;
		     logic [`selw:0] sel;
		     logic we,cyc,stb;
		     logic cab;
		     logic [2:0] cti;
		     logic [1:0] bte;
		     } m_bus_t;
   
   typedef   struct {logic [`dw-1:0] dat_i;
		     logic ack,err,rty;
		     } s_bus_t;
   
   // Master and slave input/output signals for mux bus
   logic [`gntw-1:0] 	   gnt;
   logic [`Nm-1:0] 	   req, gnt_dec;
   logic [`Ns-1:0] 	   m_dec, m_decx [`Nm-1:0];
   m_bus_t m_bus, m_busx[`Nm-1:0];
   s_bus_t s_bus, s_busx[`Ns-1:0];

   // Connect master interfaces to local busses
   genvar i,j;
   generate
      for (i=0; i<`Nm; i++) begin
	assign req[i] = Mx[i].cyc;
	
	assign m_busx[i].adr = Mx[i].adr;
	assign m_busx[i].dat_o = Mx[i].dat_o;
	assign m_busx[i].sel = Mx[i].sel;
	assign m_busx[i].we = Mx[i].we;
	assign m_busx[i].cyc = Mx[i].cyc;
	assign m_busx[i].stb = Mx[i].stb;
	assign m_busx[i].cti = Mx[i].cti;
	assign m_busx[i].bte = Mx[i].bte;
      
	assign Mx[i].dat_i = s_bus.dat_i;
	assign Mx[i].ack = s_bus.ack & gnt_dec[i];
	assign Mx[i].err = s_bus.err & gnt_dec[i];
	assign Mx[i].rty = s_bus.rty & gnt_dec[i];
     end
   endgenerate
   
   // The arbiter
   generate
      if (1)
	wb_arb_rr arb(.clk_i(clk_i), // Round robin
		      .rst_i(rst_i),
		      .req_i(req),
		      .gnt_o(gnt)
		      );
      else
	wb_arb_prio arb(.clk_i(clk_i), // Priority
		      .rst_i(rst_i),
		      .req_i(req),
		      .gnt_o(gnt)
		      );
   endgenerate

   // grant decoder
   always_comb begin
      gnt_dec = 0;
      gnt_dec[gnt] = 1;
   end

   // m_bus MUX
   assign    m_bus = m_busx[gnt];

   // Address compare Nm masters against Ns slaves
   // => Nm * Ns comparators
   generate
     for (i=0; i<`Nm; i++) begin
	assign m_decx[i][0] = !(|m_decx[i][`Ns-1:1]);
	for (j=1; j<`Ns; j++) begin
	   assign m_decx[i][j] = (Mx[i].adr[`aw-1 : `aw - s_addr_w ] == sx_addr[j]);
	end
     end 
   endgenerate
   
   assign      m_dec = m_decx[gnt];

   // Connect slave interfaces with local busses
   generate
      for (i=0; i<`Ns; i++) begin
	 assign s_busx[i].dat_i = Sx[i].dat_i;
	 assign s_busx[i].ack = Sx[i].ack;
	 assign s_busx[i].err = Sx[i].err;
	 assign s_busx[i].rty = Sx[i].rty;

	 assign Sx[i].adr = m_bus.adr;
	 assign Sx[i].dat_o = m_bus.dat_o;
	 assign Sx[i].sel = m_bus.sel;
	 assign Sx[i].we  = m_bus.we;
	 assign Sx[i].cyc = m_bus.cyc;
	 assign Sx[i].stb = m_bus.stb & m_bus.cyc & m_dec[i];
	 assign Sx[i].cti = m_bus.cti;
	 assign Sx[i].bte = m_bus.bte;
      end
   endgenerate
   
   always_comb
     unique if (m_dec[0])
       s_bus = s_busx[0];
     else if (m_dec[1])
       s_bus = s_busx[1];
     else if (m_dec[2])
       s_bus = s_busx[2];
     else if (m_dec[3])
       s_bus = s_busx[3];
     else if (m_dec[4])
       s_bus = s_busx[4];
     else if (m_dec[5])
       s_bus = s_busx[5];
     else if (m_dec[6])
       s_bus = s_busx[6];
     else if (m_dec[7])
       s_bus = s_busx[7];
     else if (m_dec[8])
       s_bus = s_busx[8];
     else if (m_dec[9])
       s_bus = s_busx[9];
     else
       s_bus = s_busx[0];
       
endmodule
// Local Variables:
// verilog-library-directories:("." ".." "../or1200" "../jpeg" "../pkmc" "../dvga" "../uart" "../monitor" "../lab1" "../dafk_tb" "../eth" "../wb" "../leela")
// End:
