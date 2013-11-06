`include "include/timescale.v"

module flash(dq, addr, ceb, oeb, web, rpb, wpb, vpp, vcc);
   inout [31:0] dq;     //16 outputs
   input [19:0]   addr;   //address pins.
   input                   ceb,    //CE# - chip enable bar
                           oeb,    //OE# - output enable bar
                           web,    //WE# - write enable bar
                           rpb,    //RP# - reset bar, powerdown
                           wpb;    //WP# = write protect bar
   input [31:0] 	   vpp,    //vpp in millivolts
                           vcc;    //vcc in millivolts




// instantiate 2 Flash memories
   fl28f16 #(.LoadFileName("dafk_tb/flash_L.txt")) flash_L
     (
      .dq(dq[15:0]),
      .addr(addr),
      .ceb(ceb),
      .oeb(oeb),
      .web(web),
      .rpb(rpb),
      .wpb(wpb),
      .vpp(vpp),
      .vcc(vcc)
      );

   fl28f16 #(.LoadFileName("dafk_tb/flash_H.txt")) flash_H
     (
      .dq(dq[31:16]),
      .addr(addr),
      .ceb(ceb),
      .oeb(oeb),
      .web(web),
      .rpb(rpb),
      .wpb(wpb),
      .vpp(vpp),
      .vcc(vcc)
      );

endmodule // flash

   
// Local Variables:
// verilog-library-directories:("." ".." "../or1200" "../jpeg" "../pkmc" "../dvga" "../uart" "../monitor" "../lab1" "../dafk_tb" "../eth" "../wb" "../leela")
// End:
