`include "include/timescale.v"

module sys_sig_gen
  (
   masterClk, masterRst,
   sysclk, nsysclk, sdramclk,
   sysRst
);

  input masterClk;
  input masterRst;
   
  output sysclk;
  output nsysclk;
  output sdramclk;
  output sysRst;

  wire   locked;
  wire   locked_Del;

  reg [2:0] rstDel;
  reg [2:0] rstDel2;

  wire clk_nodelay;
  wire clk_delay;

   
  clkdiv div0 (
    .RST_IN(masterRst),
    .LOCKED_OUT(locked),
    .CLKIN_IN(masterClk),
    .CLKFX_OUT(clk_nodelay),
    .CLK0_OUT(),
    .CLKIN_IBUFG_OUT()
  );

  always@(posedge clk_nodelay or posedge masterRst) begin
    if(masterRst) rstDel <= 3'b111;
    else rstDel <= {rstDel[1:0],~locked};
  end 
   
  clkdel del0 (
    .RST_IN(rstDel[2]), 
    .LOCKED_OUT(locked_Del), 
    .CLKIN_IN(clk_nodelay), 
    .CLK270_OUT(clk_delay), 
    //.CLKIN_IBUFG_OUT(),
    .CLK0_OUT() 
  );

  always@(posedge clk_nodelay or posedge masterRst) begin
    if(masterRst) rstDel2 <= 3'b111;
    else rstDel2 <= {rstDel2[1:0],~locked_Del};
  end 

  assign sysRst   = rstDel2[2];
  assign sysclk   = clk_nodelay;
  assign sdramclk = clk_delay;

   // *********************************************
   // Infer a DDR register for sdram_clk generation
   // *********************************************

   OFDDRRSE ddr0 
     (
      .CE(1'b1), 
      .S(1'b0),
      .R(1'b0),
      .C0(sysclk),
      .C1(!sysclk),
      .D0(1'b0),
      .D1(1'b1),
      .Q(nsysclk)
      );


endmodule
// Local Variables:
// verilog-library-directories:("." ".." "../or1200" "../jpeg" "../pkmc" "../dvga" "../uart" "../monitor" "../lab1" "../dafk_tb" "../eth" "../wb" "../leela")
// End:
