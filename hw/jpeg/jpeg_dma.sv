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

   reg [3:0] 	       next_dma_bram_addr;
   wire [3:0] 	       dma_bram_addr_plus1;

   wire 	       endframe;
   wire 	       endblock;
   wire 	       endline;
   reg [9:0] 	       ctr;

   
   assign    wbm.dat_o = 32'b0; // We never write from this module
   assign    dma_bram_data = 32'h0; // You need to create this signal...

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

   // Decode the control bit that starts the DMA engine
   assign startfsm = dmaen_i && wb_we_i && (wb_adr_i[4:2] == 3'b100)
	  && (wb_dat_i[0] == 1'b1);
   assign startnextblock = dmaen_i && wb_we_i && (wb_adr_i[4:2] == 3'b100)
	  && (wb_dat_i[1] == 1'b1);

   reg fetch_ready;
   wire dct_ready;

   assign dct_ready = !dct_busy && fetch_ready;

   always_comb begin
      wb_dat_o = 32'h00000000; // Default value
      case(wb_adr_i[4:2])
	3'b000: wb_dat_o = dma_srcaddr;
	3'b001: wb_dat_o = dma_pitch;
	3'b010: wb_dat_o = dma_endblock_x;
	3'b011: wb_dat_o = dma_endblock_y;
	3'b100: wb_dat_o = {20'b0, ctr, dct_ready, dma_is_running};
      endcase // case(wb_adr_i[4:2])
   end
   // FIXME - what is ctr? Should the students create this?
   
   always_ff @(posedge clk_i) begin
      if(startfsm | startnextblock)
	ctr <= 10'h0;
      else if ( dma_is_running | dct_busy)
	ctr <= ctr + 1;
   end


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

      wbm.sel = 4'b1111; // We always want to read all bytes
      wbm.we = 0; // We never write to the bus

      dma_bram_we = 0;

      fetch_ready = 0;

      if(rst_i) begin
	 next_state = DMA_IDLE;
	 next_dma_bram_addr = 0;
      end else begin
	 case(state)
	   DMA_IDLE: begin
	      if(startfsm) begin
		 next_state = DMA_GETBLOCK;
		 resetaddr = 1; // Start from the beginning of the frame
		 next_dma_bram_addr = 0;
	      end
	   end


	   DMA_GETBLOCK: begin
	      // Hint: look at endframe, endblock, endline and wbm_ack_i...
	   end

	   DMA_RELEASEBUS: begin
	      // Hint: Just wait a clock cycle so that someone else can access the bus if necessary
	   end

	   DMA_WAITREADY: begin
	      // Hint: Need to tell the status register that we are waiting here...
	   end

	   DMA_WAITREADY_LAST: begin
	      // Hint: Need to tell the status register that we are waiting here...
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
