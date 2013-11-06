`include "include/timescale.v"

module sdram(Dq,Addr,Ba,Clk,Cke,Cs_n,Ras_n,Cas_n,We_n,Dqm);
    inout [31:0] Dq;
    input [12:0] Addr;
    input [1:0] Ba;
    input Clk;
    input Cke;
    input Cs_n;
    input Ras_n;
    input Cas_n;
    input We_n;
    input [3:0] Dqm;

// instantiate 2 SDRAMs

	mt48lc16m16a2 sdramL(Dq[15:0], Addr, Ba, Clk, Cke, Cs_n, Ras_n, Cas_n, We_n, Dqm[1:0]);

	mt48lc16m16a2 sdramH(Dq[31:16], Addr, Ba, Clk, Cke, Cs_n, Ras_n, Cas_n, We_n, Dqm[3:2]);

endmodule
// Local Variables:
// verilog-library-directories:("." ".." "../or1200" "../jpeg" "../pkmc" "../dvga" "../uart" "../monitor" "../lab1" "../dafk_tb" "../eth" "../wb" "../leela")
// End:
