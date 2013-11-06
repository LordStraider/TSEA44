`include "include/dvga_defines.v"

module dvga_renderer(
  clk, rst, int_o,

  // Wishbone master interface
  wbm_adr_o, wbm_dat_o, wbm_dat_i, wbm_sel_o, wbm_we_o, wbm_stb_o, 
  wbm_cyc_o, wbm_ack_i, wbm_err_i, wbm_cti_o, wbm_bte_o,

  xpos, ypos,
  r_o, g_o, b_o, hsync_o, vsync_o, blank_o,

  pal0_adr_o, pal0_dat_i, 
  control, base0, base1
);

input			clk;
input			rst;
output			int_o;
reg			int_o;

// Wishbone master interface
output	[31:0]		wbm_adr_o;
output	[31:0]		wbm_dat_o;
input	[31:0]		wbm_dat_i;
output	[3:0]		wbm_sel_o;
output			wbm_we_o;
output			wbm_stb_o;
//reg			wbm_stb_o;
output			wbm_cyc_o;
//reg			wbm_cyc_o;
input			wbm_ack_i;
input			wbm_err_i;
output	[2:0]		wbm_cti_o;
output	[1:0]		wbm_bte_o;

output  [`XCNTW-1:0]    xpos;
reg     [`XCNTW-1:0]    xpos;
output  [`YCNTW-1:0]    ypos;
reg     [`YCNTW-1:0]    ypos;

output  [7:0]           r_o;
output  [7:0]           g_o;
output  [7:0]           b_o;
output                  hsync_o;
output                  vsync_o;
output                  blank_o;

output  [7:0]           pal0_adr_o;
input   [31:0]          pal0_dat_i;

input	[31:0]		control;
input	[31:0]		base0;
input	[31:0]		base1;

reg     [`XCNTW+`YCNTW-1:0] adrcnt;
reg	[2:0]		burstcnt;

reg     [`XCNTW-1:0]    xcnt;
reg     [`YCNTW-1:0]    ycnt;

reg	[7:0]		pixel_grey;
wire	[7:0]		pixel_r;
wire	[7:0]		pixel_g;
wire	[7:0]		pixel_b;
reg                     hsync;
reg                     vsync;
reg                     last_vsync;
reg                     hblank;
reg                     vblank;
reg                     last_vblank;
wire                    blank;

reg			fifo_pending_reset;
wire			fifo_reset;
wire	[31:0]		fifo_din;
wire			fifo_wr;
wire	[31:0]		fifo_dout;
wire			fifo_rd;
wire			fifo_empty;
wire			fifo_almost_empty;
wire			fifo_full;
wire			fifo_almost_full;

generic_fifo_sc_a #(32,6,12) fifo0 (
  .clk(clk),              .rst(1'b1),
  .clr(fifo_reset),       .din(fifo_din),
  .we(fifo_wr),           .dout(fifo_dout),
  .re(fifo_rd),           .full(fifo_full),
  .empty(fifo_empty),     .full_r(),
  .empty_r(),             .full_n(fifo_almost_full), 
  .empty_n(fifo_almost_empty), .full_n_r(),
  .empty_n_r(), .level()
);

always @ (posedge clk)
  if (rst) 
    xcnt <= `XCNTW'b0;
  else if (xcnt == `THLEN-1)
    xcnt <= `XCNTW'b0;
  else
    xcnt <= xcnt + 1;

always @ (posedge clk)
  if (rst) 
    ycnt <= `YCNTW'b0;
  else if (xcnt == `THLEN-1) begin
    if (ycnt == `TVLEN-1)
      ycnt <= `YCNTW'b0;
    else
      ycnt <= ycnt + 1;
  end
always @ (posedge clk)
  if (rst)
    hsync <= 1'b1;
  else if (xcnt < `THSYNC)
    hsync <= 1'b1;
  else 
    hsync <= 1'b0;

always @ (posedge clk)
  if (rst)
    vsync <= 1'b1;
  else if (ycnt < `TVSYNC)
    vsync <= 1'b1;
  else 
    vsync <= 1'b0;

 always @ (posedge clk)
  if (rst)
    hblank <= 1'b1;
  else if (xcnt < `THSYNC+`THGDEL)
    hblank <= 1'b1;
  else if (xcnt >= `THSYNC+`THGDEL+`THGATE)
    hblank <= 1'b1;
  else
    hblank <= 1'b0;

always @ (posedge clk)
  if (rst)
    vblank <= 1'b1;
  else if (ycnt < `TVSYNC+`TVGDEL)
    vblank <= 1'b1;
  else if (ycnt >= `TVSYNC+`TVGDEL+`TVGATE)
    vblank <= 1'b1;
  else
    vblank <= 1'b0;

always @ (posedge clk)
  if (rst) begin
    xpos <= `XCNTW'b0;
    ypos <= `YCNTW'b0;
  end else begin
    xpos <= xcnt - `XOFFSET;
    ypos <= ycnt - `YOFFSET;
  end

assign fifo_rd = ((xcnt[1:0] == `FIFO_RD_POS) && !blank) && !fifo_empty;

always @ (posedge clk)
  if (rst == 1'b1)
    pixel_grey <= 8'b0;
  else if (xcnt[1:0] == `PIXIDX0)
    pixel_grey <= fifo_dout[31:24];
  else if (xcnt[1:0] == `PIXIDX1)
    pixel_grey <= fifo_dout[23:16];
  else if (xcnt[1:0] == `PIXIDX2)
    pixel_grey <= fifo_dout[15:8];
  else
    pixel_grey <= fifo_dout[7:0];

always @ (posedge clk)
  if (rst) begin
    last_vsync  <= 1'b0;
    last_vblank <= 1'b0;
  end else begin
    last_vsync  <= vsync;
    last_vblank <= vblank;
  end

always @ (posedge clk)
  if (rst)
    adrcnt <= `ADRCNTW'b0;
  else if (fifo_pending_reset)
    adrcnt <= `ADRCNTW'b0;
  else if (wbm_ack_i)
    adrcnt <= adrcnt + 1;

// State machine for fetching data from video memory (WB master)

parameter [1:0] 
  IDLE = 2'b00,
  READ = 2'b01,
  TERM = 2'b10;

reg [1:0] next_state, state;

always @ (posedge clk)
  if (rst)
    state <= IDLE;
  else
    state <= next_state;

always @ (state or fifo_almost_empty or fifo_almost_full or burstcnt or fifo_pending_reset)
  casex ({state, fifo_almost_empty, fifo_almost_full, burstcnt, fifo_pending_reset})
    8'b00x0xxx0: next_state = READ;
    8'b01xx0xx0: next_state = READ;
    8'b01xx10x0: next_state = READ;
    8'b01xx1100: next_state = TERM;
    8'b10xxxxx0: next_state = IDLE;
    default:     next_state = IDLE;
  endcase

always @ (posedge clk)
  if (rst || (state == IDLE))
    burstcnt <= 3'b0;
  else if ((state != IDLE) && wbm_ack_i)
    burstcnt <= burstcnt + 1;

assign fifo_reset = rst | fifo_pending_reset;
always @ (posedge clk)
  if (rst)
    fifo_pending_reset <= 1'b0;
  else if (vsync & !last_vsync)
    fifo_pending_reset <= 1'b1;
  else if (state == IDLE)
    fifo_pending_reset <= 1'b0;

assign fifo_din = wbm_dat_i;
assign fifo_wr  = wbm_ack_i;

wire [31:0] base;
wire [31:0] offs;
assign base = (control[1]?base1:base0);
assign offs = {`ADRCNTZEROS'b0, adrcnt, 2'b0};

assign wbm_adr_o = base + offs;
assign wbm_stb_o = (state != IDLE)?1'b1:1'b0;
assign wbm_cyc_o = (state != IDLE)?1'b1:1'b0;
assign wbm_cti_o = (state == TERM)?3'b111:3'b010;
assign wbm_bte_o = 2'b0;

assign wbm_dat_o = 32'b0;
assign wbm_sel_o = 4'hF;
assign wbm_we_o  = 1'b0;

always @ (posedge clk)
  if (rst == 1'b1)
    int_o <= 1'b0;
  else if ((control[2] == 1'b1) && (last_vblank == 1'b0) && (vblank == 1'b1))
    int_o <= 1'b1;
  else
    int_o <= 1'b0;

assign pal0_adr_o = pixel_grey;

assign pixel_r    = pal0_dat_i[23:16];
assign pixel_g    = pal0_dat_i[15:8];
assign pixel_b    = pal0_dat_i[7:0];
assign blank      = hblank | vblank;

// Pipeline step 0
reg	[7:0]           pixel_grey0;
reg     [`XCNTW-1:0]    xpos0;
reg     [`YCNTW-1:0]    ypos0;
reg			hsync0;
reg			vsync0;
reg			blank0;
always @ (posedge clk) begin
  pixel_grey0 <= pixel_grey;
  xpos0       <= xpos;
  ypos0       <= ypos;
  hsync0      <= hsync;
  vsync0      <= vsync;
  blank0      <= blank;
end

// Assign outputs
assign r_o        = (control[3]?pixel_r:pixel_grey0);
assign g_o        = (control[3]?pixel_g:pixel_grey0);
assign b_o        = (control[3]?pixel_b:pixel_grey0);
assign hsync_o    = hsync0;
assign vsync_o    = vsync0;
assign blank_o    = blank0;

endmodule// Local Variables:
// verilog-library-directories:("." ".." "../or1200" "../jpeg" "../pkmc" "../dvga" "../uart" "../monitor" "../lab1" "../dafk_tb" "../eth" "../wb" "../leela")
// End:
