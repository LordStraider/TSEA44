`include "include/pkmc_sram_defines.v"
`include "include/pkmc_flash_defines.v"
`include "include/pkmc_sdram_defines.v"
`include "include/pkmc_memctrl_defines.v"

`default_nettype none

module pkmc_wbmemctrl_tb();

   reg wb_rst_i;
   reg wb_clk_i;
   
   reg [`ADDR_I_WIDTH-1:0] wb_addr_i;
   reg 		     wb_cyc_i;
   
   reg 		     wb_lock_i;
   
   reg [`SEL_I_WIDTH-1:0]  wb_sel_i;
   reg 		     wb_stb_i;
   reg 		     wb_we_i;
   reg [`DAT_I_WIDTH-1:0]  wb_dat_i;
   

   reg 			 shftClk;


   
   
   wire 		 wb_ack_o;
   wire 		 wb_err_o;
   wire 		 wb_rty_o;
   
   wire [`DAT_O_WIDTH-1:0] wb_dat_o;


   //SDRAM i/f
   wire [31:0] 		   data_io_bi;
   wire 			 sdramCke_o_bi;
   wire [`COMMAND_LEN-1:0] 	 sdramCommand_o_bi;
   wire [`ADDR_BUS_OUT-1:0] 	 addr_o_bi;
   wire [`SEL_I_WIDTH-1:0] 	 byteSel_o_bi;


   parameter 			 cc = 40;   

  sdram sdram(.Dq(data_io_bi),
	      .Addr(addr_o_bi[12:0]),
	      .Ba(addr_o_bi[14:13]),
	      .Clk(shftClk),
	      .Cke(sdramCke_o_bi),
	      .Cs_n(sdramCommand_o_bi[3]),
	      .Ras_n(sdramCommand_o_bi[2]),
	      .Cas_n(sdramCommand_o_bi[1]),
	      .We_n(sdramCommand_o_bi[0]),
	      .Dqm(byteSel_o_bi));

   pkmc_top dut(// Outputs
		.wb_ack_o		(wb_ack_o),
		.wb_err_o		(wb_err_o),
		.wb_rty_o		(wb_rty_o),
		.wb_dat_o		(wb_dat_o[31:0]),
		.sramCE_bi		(),
		.sramOE_bi		(),
		.sramBuffDir_bi		(),
		.sramBuffOE_bi		(),
		.flashCE_bi		(),
		.sdramCke_o_bi		(sdramCke_o_bi),
		.sdramCommand_o_bi	(sdramCommand_o_bi),
		.addr_o_bi		(addr_o_bi),
		.byteSel_o_bi		(byteSel_o_bi),
		// Inouts
		.data_io_bi		(data_io_bi),
		// Inputs
		.wb_rst_i		(wb_rst_i),
		.wb_clk_i		(wb_clk_i),
		.wb_addr_i		(wb_addr_i[31:0]),
		.wb_cyc_i		(wb_cyc_i),
		.wb_lock_i		(wb_lock_i),
		.wb_sel_i		(wb_sel_i[3:0]),
		.wb_stb_i		(wb_stb_i),
		.wb_we_i		(wb_we_i),
		.wb_dat_i		(wb_dat_i[31:0]),
		.shftClk		(shftClk));

   always #(cc/2) wb_clk_i = ~wb_clk_i;
   always@(*) begin shftClk = ~wb_clk_i; end

   integer i,b;


   reg [7:0] slice [3:0];

   reg [`ADDR_I_WIDTH:0] addr;

   
   reg [8+1:0] 		 column;
   reg [12+1:0] 	 row;
   reg [1:0] 		 bank;
   
   initial begin
      wb_rst_i = 1;
      wb_clk_i = 1;
      wb_cyc_i = 0;
      wb_lock_i = 0;
      wb_sel_i = 0;
      wb_stb_i = 0;
      wb_we_i = 0;
      wb_dat_i = 0;
      column = 0;
      row = 0;
      bank = 0;
      #3;
      #(cc);
      wb_rst_i = 0;
      #cc;
      wb_cyc_i = 1;
      wb_stb_i = 1;
      wb_sel_i = 4'b1111;
      for(b=0;b<4;b=b+1) begin
	 bank = b;
	 wb_we_i = 1;
	 for(i=0;i<4;i=i+1) begin
	    column = 0;
	    row = i;
	    while(~column[9]) begin
 	       while(~wb_ack_o) begin
		  #cc;
	       end
	       #cc;
	       column = column + 1;
	       //$display("Writing %x to %x",wb_dat_i,wb_addr_i);
	    end
	 end
	 for(i = 0;i<4;i=i+1) begin
	    row = i;
	    column = 0;
	    wb_we_i = 0;
	    while(~column[9]) begin
 	       while(~wb_ack_o) begin
		  #cc;
	       end
	       #cc;
	       if(wb_dat_o !== (wb_addr_i >>2)) begin
		  $display("Error");
		  $stop;
	       end
	       column = column + 1;
	       //$display("Reading from %x",wb_addr_i);
	    end // while (~column[9])
	 end // for (i = 0;i<4;i=i+1)
      end // for (b=0;b<4;b=b+1)

      wb_we_i = 1;
      row = 5;
      column = 3;
      bank = 2;
      while(~wb_ack_o) begin
	 #cc;
      end
      #cc;

      row = 7;
      column = 8;
      bank = 1;
      while(~wb_ack_o) begin
	 #cc;
      end
      #cc;

      row = 89;
      column = 100;
      bank = 0;
      while(~wb_ack_o) begin
	 #cc;
      end
      #cc;

      row = 234;
      column = 101;
      bank = 3;
      while(~wb_ack_o) begin
	 #cc;
      end
      #cc;

      wb_we_i = 0;

      
      row = 5;
      column = 3;
      bank = 2;
      while(~wb_ack_o) begin
	 #cc;
      end
      #(cc/2);
      if(wb_dat_o != wb_addr_i >> 2) begin
	 $display("Error");
	 $stop;
      end  
      #(cc/2);

      row = 7;
      column = 8;
      bank = 1;
      while(~wb_ack_o) begin
	 #cc;
      end
      #(cc/2);
      if(wb_dat_o != wb_addr_i >> 2) begin
	 $display("Error");
	 $stop;
      end  
      #(cc/2);

      row = 89;
      column = 100;
      bank = 0;
      while(~wb_ack_o) begin
	 #cc;
      end
      #(cc/2);
      if(wb_dat_o != wb_addr_i >> 2) begin
	 $display("Error");
	 $stop;
      end  
      #(cc/2);


      row = 234;
      column = 101;
      bank = 3;
      while(~wb_ack_o) begin
	 #cc;
      end
      #(cc/2);
      if(wb_dat_o != wb_addr_i >> 2) begin
	 $display("Error");
	 $stop;
      end  
      #(cc/2);

      wb_we_i = 1;
      
      row = 275;
      column = 23;
      bank = 2;
      while(~wb_ack_o) begin
	 #cc;
      end
      #(cc/2);
      if(wb_dat_o != wb_addr_i >> 2) begin
	 $display("Error");
	 $stop;
      end  
      #(cc/2);

      wb_we_i = 0;
      
      row = 234;
      column = 101;
      bank = 3;
      while(~wb_ack_o) begin
	 #cc;
      end
      #(cc/2);
      if(wb_dat_o != wb_addr_i >> 2) begin
	 $display("Error");
	 $stop;
      end  
      #(cc/2);

      row = 275;
      column = 23;
      bank = 2;
      while(~wb_ack_o) begin
	 #cc;
      end
      #(cc/2);
      if(wb_dat_o != wb_addr_i >> 2) begin
	 $display("Error");
	 $stop;
      end  
      #(cc/2);
      
      $stop;
   end // initial begin
      
      always@(*) begin
	 wb_addr_i = {bank,row,column[8:0],2'b00};
	 wb_dat_i = wb_addr_i >> 2;
      end
   
   
endmodule // pkmc_wbmemctrl_tb
// Local Variables:
// verilog-library-directories:("." ".." "../or1200" "../jpeg" "../pkmc" "../dvga" "../uart" "../monitor" "../lab1" "../dafk_tb" "../eth" "../wb" "../leela")
// End:
