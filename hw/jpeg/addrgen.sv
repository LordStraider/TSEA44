`include "include/timescale.v"

module addrgen(input wire         clk_i,
	       input wire 	   rst_i,
	       
	       input wire [31:0]   dma_srcaddr, // Start address of image
	       input wire [11:0]   dma_pitch, // Width of image in bytes
	       input wire [7:0]    dma_endblock_x, // Number of macroblocks in a row - 1
	       input wire [7:0]    dma_endblock_y, // Number of macroblocks in a column - 1
	       
	       
	       // Control signals for address generation
	       input wire 	   resetaddr_i,
	       input wire 	   incaddr_i,
	       output logic [31:0] address_o,
	       output wire 	   endblock_o,
	       output wire 	   endframe_o,
	       output wire 	   endline_o
	       );


   wire 	      newline, newblock, newblockline, endframe;

   // Keep track of where we are in a macroblock
   reg [2:0] 	      dma_x;
   reg [2:0] 	      dma_y;
   
   // Keep track of which macroblock we are currently processing
   reg [7:0] 	      dma_block_x;
   reg [7:0] 	      dma_block_y;
   
   // Keep track of the starting address for the current line of a macroblock
   reg [31:0] 	      dma_lineaddress;
   // Keep track of the starting address for the current macroblock
   reg [31:0] 	      dma_blockaddress;
   // Keep track of the starting address for the current row of macroblocks
   reg [31:0] 	      dma_blocklineaddress;
   // Keep track of the current address
   reg [31:0] 	      dma_address;
   
   // The next value for the above registers
   reg [2:0] 	      next_dma_x;
   reg [2:0] 	      next_dma_y;
   reg [7:0] 	      next_dma_block_x;
   reg [7:0] 	      next_dma_block_y;
   reg [31:0] 	      next_dma_lineaddress;
   reg [31:0] 	      next_dma_blockaddress;
   reg [31:0] 	      next_dma_blocklineaddress;
   reg [31:0] 	      next_dma_address;



   // Keep track of if we reach the boundaries of a macroblock
   assign newline      = dma_x == 1'd1;
   assign newblock     = dma_y == 3'd7 && newline;
   // Keep track of if we need to move to the next row of macroblocks
   // or if the frame is finished
   assign newblockline = newblock && (dma_block_x == dma_endblock_x);
   assign endframe     = newblockline && (dma_block_y == dma_endblock_y);

   assign endframe_o   = endframe;
   assign endblock_o   = newblock;
   assign endline_o    = newline;

   // Some adders we use to find our next address for the DMA read
   wire [31:0] new_dma_blocklineaddress;
   wire [31:0] new_dma_blockaddress;
   wire [31:0] new_dma_lineaddress;

   assign      new_dma_blocklineaddress = dma_blocklineaddress + dma_pitch * 8;
   assign      new_dma_blockaddress = dma_blockaddress + 8;
   assign      new_dma_lineaddress = dma_lineaddress + dma_pitch;


   // Combinatorial part of the state machine
   always_comb begin
      // Default values, don't change
      next_dma_x = dma_x;
      next_dma_y = dma_y;

      next_dma_block_x = dma_block_x;
      next_dma_block_y = dma_block_y;
      next_dma_address = dma_address;
      next_dma_lineaddress = dma_lineaddress;
      next_dma_blocklineaddress = dma_blocklineaddress;
      next_dma_blockaddress = dma_blockaddress;

      if(resetaddr_i) begin
	 next_dma_blocklineaddress = dma_srcaddr;
	 next_dma_blockaddress = dma_srcaddr;
	 next_dma_lineaddress = dma_srcaddr;
	 next_dma_address     = dma_srcaddr;
	 next_dma_x = 0;
	 next_dma_y = 0;
	 next_dma_block_x = 0;
	 next_dma_block_y = 0;
      end else if(incaddr_i) begin
	 if (newblockline) begin
            // We finished a row of macroblocks, move to next row of blocks
	    next_dma_x = 0;
	    next_dma_y = 0;
	    next_dma_block_x = 0;
	    next_dma_block_y = dma_block_y + 1;
	    
	    next_dma_address = new_dma_blocklineaddress;
	    next_dma_blocklineaddress = new_dma_blocklineaddress;
	    next_dma_blockaddress = new_dma_blocklineaddress;
	    next_dma_lineaddress = new_dma_blocklineaddress;

	 end else if (newblock) begin
	    // We finished a block, move to next block
	    next_dma_x = 0;
	    next_dma_y = 0;
	    next_dma_block_x = dma_block_x + 1;
	    
	    next_dma_address     = new_dma_blockaddress;
	    next_dma_blockaddress = new_dma_blockaddress;
	    next_dma_lineaddress = new_dma_blockaddress;
	    
	 end else if (newline) begin
	    // We finished a line in a block
	    next_dma_x = 0;
	    next_dma_y = dma_y + 1;
	    next_dma_address = new_dma_lineaddress;
	    next_dma_lineaddress = new_dma_lineaddress;

	 end else begin
	    // Just move to the next word of pixels
	    next_dma_x = dma_x + 1;
	    next_dma_address = dma_address + 4;
	 end
				       
      end // if (incaddr_i)
   end // always @ (*)
   


   // Flip flops for the state machine
   always_ff @(posedge clk_i) begin
      if (rst_i) begin
	 // Coordinates in the block
	 dma_x       <= 0;
	 dma_y       <= 0;

	 // Block coordinates in the frame
	 dma_block_x <= 0;
	 dma_block_y <= 0;

	 // Addresses
	 dma_blocklineaddress <= 0;
	 dma_blockaddress     <= 0;
	 dma_lineaddress      <= 0;
	 dma_address          <= 0;
      end else begin

	 // Coordinates in the block
	 dma_x       <= next_dma_x;
	 dma_y       <= next_dma_y;

	 // Block coordinates in the frame
	 dma_block_x <= next_dma_block_x;
	 dma_block_y <= next_dma_block_y;

	 // Addresses
	 dma_blocklineaddress <= next_dma_blocklineaddress;
	 dma_blockaddress     <= next_dma_blockaddress;
	 dma_lineaddress      <= next_dma_lineaddress;
	 dma_address          <= next_dma_address;
      end
   end
   

   always_comb address_o = dma_address;
   
endmodule // addrgen

	       // Local Variables:
// verilog-library-directories:("." ".." "../or1200" "../jpeg" "../pkmc" "../dvga" "../uart" "../monitor" "../lab1" "../dafk_tb" "../eth" "../wb" "../leela")
// End:
