`include "include/pkmc_sram_defines.v"
`include "include/pkmc_memctrl_defines.v"

module pkmc_sramctrl(//Controller interface
		     clk,
		     rst,
		     ack_o,
		     addr_i,
		     dat_i,
		     dat_o,
		     we_i,
		     active,
		     sel_i,
		     shftClk,
		     //Memory interface
		     sramAddr,
		     sramData_i,
		     sramData_o,
		     sramByteSelect,
		     sramCE,
		     sramWE,
		     sramOE,
		     sramBuffDir,
		     sramBuffOE
		     );

   
   //Controller I/F
   input clk;
   output ack_o;
   input [`ADDR_I_WIDTH-1:0] addr_i;
   input [`DAT_I_WIDTH-1:0]  dat_i;
   output [`DAT_O_WIDTH-1:0] dat_o;
   input 		     we_i;
   input 		     active;
   input [`SEL_I_WIDTH-1:0]  sel_i;
   input 		     shftClk;
   input 		     rst;
   
   //SRAM I/F
   output [`SRAM_ADDR_WIDTH-1:0] sramAddr;
   input [`SRAM_DATA_WIDTH-1:0]  sramData_i;
   output [`SRAM_DATA_WIDTH-1:0] sramData_o;
   output [`SRAM_BS_WIDTH-1:0] 	 sramByteSelect;
   output 			 sramCE;
   output 			 sramWE;
   output 			 sramOE;
   output 			 sramBuffDir;
   output 			 sramBuffOE;

   reg [2:0] 			 ackDel;
   reg [1:0] 			 ackDel2;

   always@(posedge clk or posedge rst) begin
      if(rst) begin
	 ackDel <= 3'b100;
      end
      else if(active & ~we_i) begin
	 {ackDel[1:0], ackDel[2]} <= ackDel;
      end
      else if(~active) begin
	 ackDel <= 3'b100;
      end
      
   end

   always@(posedge clk or posedge rst) begin
      if(rst) begin
	 ackDel2 <= 3'b10;
      end
      else if(active & we_i) begin
	 {ackDel2[0], ackDel2[1]} <= ackDel2;
      end
      else if(~active) begin
	 ackDel2 <= 2'b10;
      end

   end
   
   
   assign #1			 ack_o = we_i ? ackDel2[0] : ackDel[0];
   assign  			 dat_o = sramData_i;
   
   assign #1 			 sramAddr = addr_i[`SRAM_ADDR_WIDTH+1:2];
   assign 			 sramData_o = dat_i;
   assign #1 			 sramByteSelect = ~sel_i;
//   assign #12 			 sramCE = (~clk & we_i) | ~active;//Max 25 Mhz
   assign #12 			 sramCE = (~ackDel2[0] & we_i) | ~active;//Max 25 Mhz
   assign #1 			 sramWE = ~we_i | ~active;
   assign 			 sramOE = 1'b0;
   assign #1 			 sramBuffDir = we_i;
   assign #1 			 sramBuffOE = ~active;
		

   specify
      $hold(negedge clk, posedge clk, 20); //Ensure t_rc
   endspecify

endmodule
// Local Variables:
// verilog-library-directories:("." ".." "../or1200" "../jpeg" "../pkmc" "../dvga" "../uart" "../monitor" "../lab1" "../dafk_tb" "../eth" "../wb" "../leela")
// End:
