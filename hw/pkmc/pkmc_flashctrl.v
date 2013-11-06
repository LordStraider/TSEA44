`include "include/pkmc_flash_defines.v"
`include "include/pkmc_memctrl_defines.v"

module pkmc_flashctrl(//Controller interface
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
		     flashAddr,
		     flashData_i,
		     flashData_o,
		     flashCE,
		     flashWE,
		     flashOE,
		     flashBuffDir,
		     flashBuffOE
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
   
   //FLASH I/F
   output [`FLASH_ADDR_WIDTH-1:0] flashAddr;
   input [`FLASH_DATA_WIDTH-1:0]  flashData_i;
   output [`FLASH_DATA_WIDTH-1:0] flashData_o;
   output 			 flashCE;
   output 			 flashWE;
   output 			 flashOE;
   output 			 flashBuffDir;
   output 			 flashBuffOE;

   reg [5:0] 			 ackDel_R; // Read
   reg [3:0] 			 ackDel_W; // Write

   // Read
   always@(posedge clk or posedge rst) begin
      if(rst) begin
	 ackDel_R <= 6'b100000;
      end
      else if(active & ~we_i) begin
	 ackDel_R <= {ackDel_R[0], ackDel_R[5:1]};
      end
      else if(~active) begin
	 ackDel_R <= 6'b100000;
      end
      
   end

   // Write
   always@(posedge clk or posedge rst) begin
      if(rst) begin
	 ackDel_W <= 4'b1000;
      end
      else if(active & we_i) begin
	 ackDel_W <= {ackDel_W[0], ackDel_W[3:1]};
      end
      else if(~active) begin
	 ackDel_W <= 4'b1000;
      end

   end
   
   
   assign #1			 ack_o = we_i ? ackDel_W[0] : ackDel_R[0];
   assign  			 dat_o = flashData_i;
   
   assign #1 			 flashAddr = addr_i[`FLASH_ADDR_WIDTH+1:2];
   assign 			 flashData_o = dat_i;

   assign #1 			 flashCE = ~active; //Max 25 Mhz
   assign #1 			 flashWE = ~we_i | ackDel_W[0];
   assign #1 			 flashOE = ~(active & ~we_i);
   assign #1 			 flashBuffDir = we_i;
   assign #1 			 flashBuffOE = ~active;
		

   specify
      $hold(negedge clk, posedge clk, 20); //Ensure t_rc
   endspecify

endmodule
// Local Variables:
// verilog-library-directories:("." ".." "../or1200" "../jpeg" "../pkmc" "../dvga" "../uart" "../monitor" "../lab1" "../dafk_tb" "../eth" "../wb" "../leela")
// End:
