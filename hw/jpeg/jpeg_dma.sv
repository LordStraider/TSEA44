`include "include/timescale.v"
  
module jpeg_dma(
    input clk_i,
    input rst_i,

    input wire [31:0] wb_adr_i,	// Slave interface port, this is not the complete wb bus
    input wire [31:0] wb_dat_i,
    input wire 	      wb_we_i,
    output reg [31:0] wb_dat_o,
    input wire 	      dmaen_i,
	
    wishbone.master wbm, // Master interface
		
    output wire [31:0] dma_bram_data, 		// To the input block ram
    output reg [8:0]   dma_bram_addr,
    output reg 	       dma_bram_we,
		
    output reg 	       start_dct, 		// DCT control signals
    input wire 	       dct_busy);
   

   reg [31:0] 	       dma_srcaddr;           // Start address of image
   reg [11:0] 	       dma_pitch;             // Width of image in bytes
   reg [7:0] 	       dma_endblock_x;        // Number of macroblocks in a row - 1
   reg [7:0] 	       dma_endblock_y;        // Number of macroblocks in a column - 1


   reg 	       incaddr;
   reg 	       resetaddr;

   wire 	       startfsm;
   wire 	       startnextblock;
   
   reg [3:0] 	       next_state;
   reg [3:0] 	       state;
   wire 	       dma_is_running;

   reg [8:0] 	       next_dma_bram_addr;
   wire [3:0] 	       dma_bram_addr_plus1;

   wire 	       endframe;
   wire 	       endblock;
   logic  	       endblock_reached;
   wire 	       endline;
   reg [9:0] 	       ctr;

   reg [1:0]      goToRelease;
   
  //  reg [31:0] toDatI;
    // You must create the wb.dat_i signal somewhere...
//    assign wb_dat_i = toDatI;


    reg [31:0] jpeg_data;

   
   assign    wbm.dat_o = 32'b0; // We never write from this module
   assign    dma_bram_data = jpeg_data; 

   assign    dma_bram_addr_plus1 = dma_bram_addr + 1;
   
   addrgen agen(
		.clk_i			(clk_i),
		.rst_i			(rst_i),

		// Control signals
		.resetaddr_i		(resetaddr),
		.incaddr_i		(incaddr),

		.address_o		(wbm.adr),

		.endframe_o		(endframe),
		.endblock_o             (endblock),
		.endline_o              (endline),

		// Parameters
		.dma_srcaddr		(dma_srcaddr),
		.dma_pitch		(dma_pitch),
		.dma_endblock_x		(dma_endblock_x),
		.dma_endblock_y		(dma_endblock_y)
		);

   always @(posedge clk_i) begin
      if (startfsm) 
          $fwrite(1,"Starting dma from sv\n");
   
   end
   
   // Memory address registers
   always_ff @(posedge clk_i) begin
      if(rst_i) begin
	 dma_srcaddr <= 0;
	 dma_pitch <= 0;
	 dma_endblock_x <= 0;
	 dma_endblock_y <= 0;
      end else if(dmaen_i && wb_we_i) begin
	 case(wb_adr_i[4:2])
	   3'b000: dma_srcaddr    <= wb_dat_i;
	   3'b001: dma_pitch      <= wb_dat_i;
	   3'b010: dma_endblock_x <= wb_dat_i;
	   3'b011: dma_endblock_y <= wb_dat_i;
	 endcase // case(wb_adr_i[4:2])
      end
   end
   
   always_ff @(posedge clk_i) begin
      if(rst_i)
        endblock_reached <= 1'b0;
      else
        endblock_reached <= endblock;
   end

   // Decode the control bit that starts the DMA engine
   assign startfsm = dmaen_i && wb_we_i && (wb_adr_i[4:2] == 3'b100)
	  && (wb_dat_i[0] == 1'b1);
   assign startnextblock = dmaen_i && wb_we_i && (wb_adr_i[4:2] == 3'b100)
	  && (wb_dat_i[1] == 1'b1);

   reg fetch_ready;
   reg been_in_wait_ready;
   wire dct_ready;

   assign dct_ready = !dct_busy && fetch_ready;
   
   
   
always @(posedge clk_i) begin
if (incaddr == 1 || been_in_wait_ready)
    been_in_wait_ready = 1'b1;
    else
    been_in_wait_ready = 1'b0;
end



   always_comb begin
      wb_dat_o = 32'h00000000; // Default value
      case(wb_adr_i[4:2])
	3'b000: wb_dat_o = dma_srcaddr;
	3'b001: wb_dat_o = dma_pitch;
	3'b010: wb_dat_o = dma_endblock_x;
	3'b011: wb_dat_o = dma_endblock_y;
	3'b100: wb_dat_o = {22'b0, dmaen_i, been_in_wait_ready, state, fetch_ready, dct_busy, dct_ready, dma_is_running}; //{20'b0, ctr, dct_ready, dma_is_running};
	3'b101: wb_dat_o = next_dma_bram_addr;
	3'b110: wb_dat_o = dma_bram_data;
	3'b111: wb_dat_o = jpeg_data;
      endcase // case(wb_adr_i[4:2])
   end
   // FIXME - what is ctr? Should the students create this?
   
   /*always_ff @(posedge clk_i) begin
      if(startfsm | startnextblock | rst_i)
	ctr <= 10'h0;
      else if ( dma_is_running | dct_busy)
	ctr <= ctr + 1;
   end*/


   localparam DMA_IDLE             = 4'd0;
   localparam DMA_GETBLOCK         = 4'd4;
   localparam DMA_RELEASEBUS       = 4'd5;
   localparam DMA_WAITREADY        = 4'd6;
   localparam DMA_WAITREADY_LAST   = 4'd7;

   assign dma_is_running = (state != DMA_IDLE);

   // Combinatorial part of the FSM
   always_comb begin
      next_state = state;
      next_dma_bram_addr = dma_bram_addr;
	
      resetaddr = 0;
      incaddr = 0;

      // By default we don't try to access the WB bus

      wbm.stb = 0;
      wbm.cyc = 0;
      start_dct = 0;
      dma_bram_we = 1;
      goToRelease = 0;

      wbm.sel = 4'b1111; // We always want to read all bytes
      wbm.we = 0; // We never write to the bus


      jpeg_data = 32'h81;
      fetch_ready = 1'b0;
      
      if(rst_i) begin
	      next_state = DMA_IDLE;
        next_dma_bram_addr = 0;
        jpeg_data = 32'h0;
        start_dct = 0;
        dma_bram_we = 0;
        wbm.stb = 0;
        wbm.cyc = 0;
        goToRelease = 0;
      end else begin
	 case(state)
	   DMA_IDLE: begin
	      dma_bram_we = 0;
	      if(startfsm) begin
		       next_state = DMA_GETBLOCK;
		       resetaddr = 1; // Start from the beginning of the frame
		       next_dma_bram_addr = 0;
		       jpeg_data = 32'h0;
           start_dct = 0;
           wbm.stb = 0;
           wbm.cyc = 0;
        end
	   end


	   DMA_GETBLOCK: begin
	      // Hint: look at endframe, endblock, endline and wbm_ack_i...
	      
	      if (endframe) begin
           start_dct = 1;
		       next_dma_bram_addr = -4;
           next_state = DMA_WAITREADY_LAST;
           
        end else if (endblock_reached) begin
           start_dct = 1;
		       next_dma_bram_addr = -4;
           next_state = DMA_WAITREADY;
           
        end else if(endline) begin
	         next_state = DMA_RELEASEBUS;
	          
	      end else begin
      		 next_state = DMA_GETBLOCK;
	      end
	      
	      
	      if (wbm.ack) begin
	          jpeg_data = wbm.dat_i;
	          wbm.stb = 1'b0;
	          wbm.cyc = 1'b0;
	          
	          
	          next_dma_bram_addr = next_dma_bram_addr + 4;
            incaddr = 1;

         end else begin
	          wbm.stb = 1'b1;
	          wbm.cyc = 1'b1;
	       end
	   end

	   DMA_RELEASEBUS: begin
	      // Hint: Just wait a clock cycle so that someone else can access the bus if necessary
   		  next_state = DMA_GETBLOCK;
        wbm.stb = 1'b0;
        wbm.cyc = 1'b0;
	   end

	   DMA_WAITREADY: begin
	      // Hint: Need to tell the status register that we are waiting here...
	      dma_bram_we = 0;
	      if (!dct_busy) begin
           fetch_ready = 1;
        end
        
        if (startnextblock) begin
      	   next_state = DMA_GETBLOCK;
        end else begin
           next_state = DMA_WAITREADY;
        end
        
	   end

	   DMA_WAITREADY_LAST: begin
	      dma_bram_we = 0;
	      // Hint: Need to tell the status register that we are waiting here...
	      if (!dct_busy) begin
           fetch_ready = 1;
        end
        
        if (startnextblock) begin
      	   next_state = DMA_IDLE;
        end else begin
           next_state = DMA_WAITREADY;
        end
	   end

	 endcase // case(state)
      end
   end //
   
   // The flip flops for the FSM
   always_ff @(posedge clk_i) begin
      state         <= next_state;
      dma_bram_addr <= next_dma_bram_addr;
   end


endmodule // jpeg_dma

// Local Variables:
// verilog-library-directories:("." ".." "../or1200" "../jpeg" "../pkmc" "../dvga" "../uart" "../monitor" "../lab1" "../dafk_tb" "../eth" "../wb" "../leela")
// End:
