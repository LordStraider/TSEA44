//
// Verilog Module leela.leela_top.arch_name
//
// Created:
//          by - danwi.users (tinuviel.isy.liu.se)
//          at - 13:12:20 05/10/2004
//
// using Mentor Graphics HDL Designer(TM) 2003.2 (Build 28)
//
`resetall
`timescale 1ns/10ps
//`default net_type none
module leela_cam_cam (
       // Syscon interface
       clk, rst, int_o,

       // Camera interface
       ca_mclk_o, ca_vclk_i, ca_enb_o, ca_hsync_i, ca_vsync_i, ca_sda_io, 
       ca_sck_o, ca_resetb_o, ca_y_i,

       // Control registers
       reg_ctrl_i, reg_fbase0_i, reg_fbase1_i, reg_vbase_i, status_o,

       // Control feedback
       reg_ctrl_reset_o,

       // Camera to MC interface
       mc_adr_o, mc_dat_o, mc_we_o, mc_stb_o, 
       mc_cyc_o, mc_ack_i, mc_cti_o, mc_bte_o,

       // Camera to WBM interface
       wbm_adr_o, wbm_dat_o, wbm_we_o, wbm_stb_o, 
       wbm_cyc_o, wbm_ack_i, wbm_cti_o, wbm_bte_o
);

// Syscon interface
input		clk;
input		rst;
output		int_o;
reg		int_o;

// Camera interface
output		ca_mclk_o;
input		ca_vclk_i;
output		ca_enb_o;
input		ca_hsync_i;
input		ca_vsync_i;
inout		ca_sda_io;
output		ca_sck_o;
output		ca_resetb_o;
reg		ca_resetb_o;
input	[7:0]	ca_y_i;

// Control registers
input   [31:0]		reg_ctrl_i;
input   [31:0]		reg_fbase0_i;
input   [31:0]		reg_fbase1_i;
input   [31:0]		reg_vbase_i;
output  [31:0]          status_o;

// Control feedback
output  [31:0]		reg_ctrl_reset_o;

// Camera to MC interface
output	[31:0]	mc_adr_o;
output  [31:0]		mc_dat_o;
output		mc_we_o;
output			mc_stb_o;
output			mc_cyc_o;
input			mc_ack_i;
output	[2:0]		mc_cti_o;
output	[1:0]		mc_bte_o;

// Camera to WBM interface
output	[31:0]		wbm_adr_o;
output  [31:0]		wbm_dat_o;
output			wbm_we_o;
output			wbm_stb_o;
output			wbm_cyc_o;
input			wbm_ack_i;
output	[2:0]		wbm_cti_o;
output	[1:0]		wbm_bte_o;

// 
// Internal wires
//

// Control wires
wire			c_mc_source_sel;
wire			c_cam_enable;
wire			c_filter_enable;
wire			c_filter_oneshot;
wire			c_filter_polarity;
wire			c_filter_show;
wire			c_frame_interrupt;
wire	[7:0]		c_filter_threshold;
wire			c_filter_alternate;

// Timing-fixed controls
reg			c_filter_enable_sync;
reg			c_filter_active_bank;

// Camera input internals
reg			hsync;
reg			last_hsync;
reg			vsync;
reg			last_vsync;
reg	[7:0]		y_int;
reg	[7:0]		y_filt;

reg	[7:0]		y0_r;
reg	[7:0]		y1_r;
reg	[7:0]		y2_r;
reg	[7:0]		y3_r;

reg			mc_stb_int;

// Camera pixel counters and states
reg    	[10:0]		pos_x;
reg    	[8:0]		pos_y;
wire			pos_x_inc;
wire			pos_y_inc;
wire			pos_x_clear;
wire			pos_y_clear;
wire	[19:0]		mc_adr;
reg	[31:0]		active_vbase;

// Filtered camera signals
reg     [31:0]		filtered_y_r;
reg	[31:0]		f_mc_adr_r;
wire	[31:0]		f_base_adr;
reg			f_inframe;

// Fifo signals
reg			fifo_we;
reg			fifo_re;
wire			fifo_full;
wire			fifo_empty;
wire			fifo_empty_n;
wire	[51:0]		fifo_din;
wire	[51:0]		fifo_dout;

// Fifo to output
reg	[51:0]		fifo_dout_r;
wire			update_dout_r;

// Filter FIFO signals
reg			f_fifo_we;
reg			f_fifo_re;
wire			f_fifo_full;
wire			f_fifo_empty;
wire			f_fifo_empty_n;
wire	[61:0]		f_fifo_din;
wire	[61:0]		f_fifo_dout;

// Fifo to output
reg	[61:0]		f_fifo_dout_r;
wire			f_update_dout_r;
reg			wbm_stb_int;

// Input assignments
always @ (posedge clk) begin
  hsync <= ca_hsync_i;
  vsync <= !ca_vsync_i;
  y_int <= ca_y_i;
end

always @ (y_int or c_filter_threshold or c_filter_polarity)
  if (((y_int<c_filter_threshold)^c_filter_polarity) == 1'b1)
    y_filt = 8'hFF;
  else
    y_filt = 8'h00;

// Control register definition
//
// 31:24      Reserved
// 23:16      Filter threshold
// 15         Reserved
// 14	      Frame interrupt enabled
// 13	      Use alternating banks for filter results (always start in 0)
// 12         Filter and store one frame at a time (1=enabled)
// 11         Show filtered image on VGA (1=enabled)
// 10         Filter polarity (1=bright gives one)
// 9          Filter enabled (1=enabled)
// 8          Camera enabled (1=enabled)
// 7:0	      Reserved (Used by leela_cam.v)

assign c_cam_enable       = reg_ctrl_i[8];
assign c_filter_enable    = reg_ctrl_i[9];
assign c_filter_polarity  = reg_ctrl_i[10];
assign c_filter_show      = reg_ctrl_i[11];
assign c_filter_oneshot   = reg_ctrl_i[12];
assign c_filter_alternate = reg_ctrl_i[13];
assign c_frame_interrupt  = reg_ctrl_i[14];
assign c_filter_threshold = reg_ctrl_i[23:16];

// Status output
//
// 31         Active filter output bank
// 30:9       Reserved
// 8:0        Active line from camera

assign status_o = {c_filter_active_bank, 22'b0, pos_y};

// Timing-fixed control signals
always @ (posedge clk)
  if ((vsync == 1'b1) && (last_vsync == 1'b1))
    c_filter_enable_sync <= c_filter_enable;

assign reg_ctrl_reset_o = {17'b0, 1'b0, 4'b0, f_inframe & c_filter_enable & c_filter_oneshot & vsync & ~last_vsync, 9'b0};

// Camera connections
assign ca_mclk_o = clk;
assign ca_enb_o = c_cam_enable;
assign ca_sck_o = 1'b1;
assign ca_sda_io = 1'bZ;

always @ (posedge clk)
  if (rst == 1'b1)
    ca_resetb_o <= 1'b0;
  else
    ca_resetb_o <= 1'b1;

//
// Internal stores
//
always @ (posedge clk)
  last_hsync <= hsync;

always @ (posedge clk)
  last_vsync <= vsync;

always @ (posedge clk)
  if (rst == 1'b1)
    f_inframe <= 1'b0;
  else if (c_filter_enable && (last_vsync == 1'b0) && (vsync == 1'b1))
    f_inframe <= 1'b1;
  else if (!c_filter_enable)
    f_inframe <= 1'b0;

//
// Camera to VGA memory FIFO interface
//

assign pos_x_inc = c_cam_enable & hsync & vsync;
assign pos_y_inc = c_cam_enable & !last_hsync & hsync;
assign pos_x_clear = !hsync | !vsync;
assign pos_y_clear = !vsync;

always @ (posedge clk)
  if (rst == 1'b1)
    active_vbase <= 32'b0;
  else if ((last_vsync == 1'b1) && (vsync == 1'b0))
    active_vbase <= reg_vbase_i;

always @ (posedge clk)
  if ((rst == 1'b1) || (pos_x_clear == 1'b1))
    pos_x <= 11'b0;
  else if (pos_x_inc && (pos_x < 11'h4ff))
    pos_x <= pos_x + 1;
    
always @ (posedge clk)
  if ((rst == 1'b1) || (pos_y_clear == 1'b1))
    pos_y <= 9'h1FF;
  else if (pos_y_inc && ((pos_y < 9'h1df) || (pos_y == 9'h1FF)))
    pos_y <= pos_y + 1;

assign mc_adr = {active_vbase[31:2] + (pos_y*160) + pos_x[10:3], 2'b0};

always @ (posedge clk)
  if (rst == 1'b1) begin
    y0_r <= 8'b0;
    y1_r <= 8'b0;
    y2_r <= 8'b0;
    y3_r <= 8'b0;
  end else 
    case({c_filter_show, pos_x_inc, pos_x[2:0]})
    5'b01000: y0_r <= y_int;
    5'b01010: y1_r <= y_int;
    5'b01100: y2_r <= y_int;
    5'b01110: y3_r <= y_int;
    5'b11000: y0_r <= y_filt;
    5'b11010: y1_r <= y_filt;
    5'b11100: y2_r <= y_filt;
    5'b11110: y3_r <= y_filt;
    endcase

always @ (posedge clk)
  if (rst == 1'b1) 
    fifo_we <= 1'b0;
  else if (pos_x_inc && (pos_x[2:0] == 3'b110))
    fifo_we <= 1'b1;
  else
    fifo_we <= 1'b0;

assign fifo_din = {mc_adr, y0_r, y1_r, y2_r, y3_r};

// 
// VGA memory FIFO
//

generic_fifo_sc_a #(52,5,8) fifo0 (
  .clk(clk),              .rst(1'b1),
  .clr(rst),              .din(fifo_din),
  .we(fifo_we),           .dout(fifo_dout),
  .re(fifo_re),           .full(fifo_full),
  .empty(fifo_empty),     .full_r(),
  .empty_r(),             .full_n(), 
  .empty_n(fifo_empty_n), .full_n_r(),
  .empty_n_r(), .level()
);

// 
// VGA memory FIFO to MC interface
//

parameter [1:0]
  S_IDLE    = 0,
  S_PREREAD = 1,
  S_WRITE   = 2,
  S_LAST    = 3;

reg	[1:0]		current_state;
reg	[1:0]		next_state;

always @ (fifo_empty_n or fifo_empty or current_state or mc_ack_i)
  case(current_state)
  S_IDLE:
    if (!fifo_empty_n)
      next_state = S_PREREAD;
    else
      next_state = S_IDLE;
  S_PREREAD:
    next_state = S_WRITE;
  S_WRITE:
    if (fifo_empty)
      next_state = S_LAST;
    else
      next_state = S_WRITE;
  S_LAST:
    if (mc_ack_i)
      next_state = S_IDLE;
    else
      next_state = S_LAST;
  default:
    next_state = S_IDLE;
  endcase

always @ (posedge clk)
  if (rst == 1'b1)
    current_state <= S_IDLE;
  else
    current_state <= next_state;

always @ (current_state or mc_ack_i)
  if (current_state == S_PREREAD)
    fifo_re = 1'b1;
  else if (current_state == S_WRITE)
    fifo_re = mc_ack_i;
  else
    fifo_re = 1'b0;

always @ (current_state)
  if (current_state == S_WRITE || current_state == S_LAST)
    mc_stb_int = 1'b1;
  else
    mc_stb_int = 1'b0;

assign update_dout_r = mc_ack_i || current_state == S_PREREAD;
always @ (posedge clk)
  if (rst == 1'b1)
    fifo_dout_r <= 2'b0;
  else if (update_dout_r)
    fifo_dout_r <= fifo_dout;

assign mc_dat_o = fifo_dout_r[31:0];
assign mc_adr_o = {12'b0, fifo_dout_r[51:32]};
assign mc_we_o  = 1'b1;
assign mc_cti_o = 3'b0;
assign mc_bte_o = 2'b0;
assign mc_cyc_o = mc_stb_int;
assign mc_stb_o = mc_stb_int;

//
// Camera to filter FIFO interface
//

always @ (posedge clk)
  if (rst == 1'b1)
    filtered_y_r <= 32'b0;
  else 
    case({pos_x_inc, pos_x[5:0]})
    7'b1000000: filtered_y_r[31] <= y_filt[7];
    7'b1000010: filtered_y_r[30] <= y_filt[7];
    7'b1000100: filtered_y_r[29] <= y_filt[7];
    7'b1000110: filtered_y_r[28] <= y_filt[7];
    7'b1001000: filtered_y_r[27] <= y_filt[7];
    7'b1001010: filtered_y_r[26] <= y_filt[7];
    7'b1001100: filtered_y_r[25] <= y_filt[7];
    7'b1001110: filtered_y_r[24] <= y_filt[7];
    7'b1010000: filtered_y_r[23] <= y_filt[7];
    7'b1010010: filtered_y_r[22] <= y_filt[7];
    7'b1010100: filtered_y_r[21] <= y_filt[7];
    7'b1010110: filtered_y_r[20] <= y_filt[7];
    7'b1011000: filtered_y_r[19] <= y_filt[7];
    7'b1011010: filtered_y_r[18] <= y_filt[7];
    7'b1011100: filtered_y_r[17] <= y_filt[7];
    7'b1011110: filtered_y_r[16] <= y_filt[7];
    7'b1100000: filtered_y_r[15] <= y_filt[7];
    7'b1100010: filtered_y_r[14] <= y_filt[7];
    7'b1100100: filtered_y_r[13] <= y_filt[7];
    7'b1100110: filtered_y_r[12] <= y_filt[7];
    7'b1101000: filtered_y_r[11] <= y_filt[7];
    7'b1101010: filtered_y_r[10] <= y_filt[7];
    7'b1101100: filtered_y_r[9]  <= y_filt[7];
    7'b1101110: filtered_y_r[8]  <= y_filt[7];
    7'b1110000: filtered_y_r[7]  <= y_filt[7];
    7'b1110010: filtered_y_r[6]  <= y_filt[7];
    7'b1110100: filtered_y_r[5]  <= y_filt[7];
    7'b1110110: filtered_y_r[4]  <= y_filt[7];
    7'b1111000: filtered_y_r[3]  <= y_filt[7];
    7'b1111010: filtered_y_r[2]  <= y_filt[7];
    7'b1111100: filtered_y_r[1]  <= y_filt[7];
    7'b1111110: filtered_y_r[0]  <= y_filt[7];
    endcase

always @ (posedge clk)
  if (rst == 1'b1) 
    f_fifo_we <= 1'b0;
  else if (pos_x_inc && (pos_x[5:0] == 6'b111111) && c_filter_enable_sync)
    f_fifo_we <= 1'b1;
  else
    f_fifo_we <= 1'b0;

always @ (posedge clk)
  if (rst == 1'b1)
    c_filter_active_bank <= 1'b0;
  else  if (c_cam_enable == 1'b1)
    c_filter_active_bank <= 1'b0;
  else if ((vsync == 1'b0) && (last_vsync == 1'b1))
    c_filter_active_bank <= c_filter_alternate & (~c_filter_active_bank);

assign f_base_adr = (c_filter_active_bank==1'b1)?reg_fbase1_i:reg_fbase0_i;
assign f_fifo_din = {f_mc_adr_r[31:2], filtered_y_r};
always @ (posedge clk)
  f_mc_adr_r <= {(pos_y*20) + pos_x[10:6] + f_base_adr[31:2], 2'b0};

//
// Filter FIFO
//

generic_fifo_sc_a #(62,5,8) fifo1 (
  .clk(clk),                .rst(1'b1),
  .clr(rst),                .din(f_fifo_din),
  .we(f_fifo_we),           .dout(f_fifo_dout),
  .re(f_fifo_re),           .full(f_fifo_full),
  .empty(f_fifo_empty),     .full_r(),
  .empty_r(),               .full_n(),
  .empty_n(f_fifo_empty_n), .full_n_r(),
  .empty_n_r(),             .level()
);

//
// Filter FIFO to WBM interface
//

reg	[1:0]		f_current_state;
reg	[1:0]		f_next_state;

always @ (f_fifo_empty_n or f_fifo_empty or f_current_state or wbm_ack_i)
  case(f_current_state)
  S_IDLE:
    if (!f_fifo_empty_n)
      f_next_state = S_PREREAD;
    else
      f_next_state = S_IDLE;
  S_PREREAD:
    f_next_state = S_WRITE;
  S_WRITE:
    if (f_fifo_empty)
      f_next_state = S_LAST;
    else
      f_next_state = S_WRITE;
  S_LAST:
    if (wbm_ack_i)
      f_next_state = S_IDLE;
    else
      f_next_state = S_LAST;
  default:
    f_next_state = S_IDLE;
  endcase

always @ (posedge clk)
  if (rst == 1'b1)
    f_current_state <= S_IDLE;
  else
    f_current_state <= f_next_state;

always @ (f_current_state or wbm_ack_i or f_fifo_empty)
  if (f_current_state == S_PREREAD)
    f_fifo_re = 1'b1;
  else if (f_current_state == S_WRITE)
    f_fifo_re = wbm_ack_i && !f_fifo_empty;
  else
    f_fifo_re = 1'b0;

always @ (f_current_state)
  if (f_current_state == S_WRITE || f_current_state == S_LAST)
    wbm_stb_int = 1'b1;
  else
    wbm_stb_int = 1'b0;

assign f_update_dout_r = wbm_ack_i || f_current_state == S_PREREAD;

always @ (posedge clk)
  if (rst == 1'b1)
    f_fifo_dout_r <= 62'b0;
  else if (f_update_dout_r)
    f_fifo_dout_r <= f_fifo_dout;

assign wbm_dat_o = f_fifo_dout_r[31:0];
assign wbm_adr_o = {f_fifo_dout_r[61:32], 2'b0};
assign wbm_we_o  = 1'b1;
assign wbm_cti_o = 3'b0;
assign wbm_bte_o = 2'b0;
assign wbm_cyc_o = wbm_stb_int;
assign wbm_stb_o = wbm_stb_int;

always @ (posedge clk)
  if (rst == 1'b1)
    int_o <= 1'b0;
  else if ((c_frame_interrupt == 1'b1) && (last_vsync == 1'b0) && (vsync == 1'b1))
    int_o <= 1'b1;
  else
    int_o <= 1'b0;

endmodule // leela_cam_cam
// Local Variables:
// verilog-library-directories:("." ".." "../or1200" "../jpeg" "../pkmc" "../dvga" "../uart" "../monitor" "../lab1" "../dafk_tb" "../eth" "../wb" "../leela")
// End:
