`include "include/pkmc_memctrl_defines.v"
`include "include/pkmc_sdram_defines.v"

module pkmc_sdram_initcount(clk,rst,out);
   input clk;
   input rst;
   output out;

   reg [`INIT_COUNT_LEN-1:0] initCounter;

   reg 		    keeper;
   wire 		    init;

`ifdef SIMULATE
`ifdef TIMECHECK
   time 		    riseEvent;
   time 		    fallEvent;
   time 		    lastCount;
   time 		    startCount;

   integer 		    initDone;
   
   always@(posedge clk) riseEvent = $time;
   always@(negedge clk) fallEvent = $time;

   initial begin
      riseEvent = 0;
      fallEvent = 0;
      lastCount = 0;
      startCount = 0;
      initDone = 0;
   end
   
   
   always@(riseEvent or fallEvent) begin
      //Checking negative half period
      if((riseEvent > fallEvent) && (riseEvent - fallEvent < `MIN_CLK_LP)) begin 
	 $display("### In %m: Low clock period to short according to definition ###");
	 $stop;
      end
      //Checking positive half period
      else if((riseEvent < fallEvent) && (fallEvent - riseEvent < `MIN_CLK_HP)) begin 
	 $display("### In %m: High clock period to short according to definition ###");
	 $stop;
      end
   end // always@ (riseEvent or fallEvent)
`endif //  `ifdef TIMECHECK
`endif //  `ifdef SIMULATE
   
      
	 
   
   always@(posedge clk or posedge rst) begin
      if(rst) begin
	 		initCounter <= 0;
`ifdef SIMULATE
 `ifdef TIMECHECK
	 initDone <= 0;
 `endif
`endif
      end
      else begin
`ifdef SIMULATE
`ifdef TIMECHECK
	 lastCount <= $time;
	 if(initCounter == 0 && initDone == 0) startCount <= $time;
`endif
`endif
	 initCounter <= initCounter + 1;
      end
`ifdef SIMULATE
`ifdef TIMECHECK
      if(preOut) begin
	 initDone <= 1;
	 if(lastCount - startCount < 100000) begin
	    $display("### In %m: Init period must be at least 100us ###");
	    //$stop;
	 end
      end
`endif
`endif
   end

	always@(posedge clk or posedge rst) begin
		if(rst) begin
			keeper <= 0;
		end
		else begin
			keeper <= out;
		end
	end

   assign #1 init = (initCounter[`INIT_COUNT_LEN-1] & initCounter[`INIT_COUNT_BIT_1]) 
     & initCounter[`INIT_COUNT_BIT_2];
   assign    out = keeper | init;

   
endmodule
// Local Variables:
// verilog-library-directories:("." ".." "../or1200" "../jpeg" "../pkmc" "../dvga" "../uart" "../monitor" "../lab1" "../dafk_tb" "../eth" "../wb" "../leela")
// End:
