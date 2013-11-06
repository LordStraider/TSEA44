`timescale 1ns/1ps

module dvga_tb_wbs_master(
  clk, reset, wb_adr_o, wb_dat_o, wb_dat_i, wb_sel_o, 
  wb_we_o, wb_stb_o, wb_cyc_o, wb_ack_i, wb_err_i,
  wb_cti_o, wb_bte_o, start
);

parameter baseaddr = 32'h0000_0000;
parameter outdelay = 10;

input			clk;
input			reset;
output  [31:0]		wb_adr_o;
output  [31:0]		wb_dat_o;
input   [31:0]		wb_dat_i;
output  [3:0]		wb_sel_o;
output			wb_we_o;
output			wb_stb_o;
output			wb_cyc_o;
input			wb_ack_i;
input			wb_err_i;
output	[2:0]		wb_cti_o;
output	[1:0]		wb_bte_o;
input			start;

reg	[31:0]		wb_adr_o;
reg	[31:0]		wb_dat_o;
reg	[3:0]		wb_sel_o;
reg			wb_we_o;
reg			wb_stb_o;
reg			wb_cyc_o;
reg	[2:0]		wb_cti_o;
reg	[1:0]		wb_bte_o;

parameter sw = 2;
parameter [sw-1:0]
  M_IDLE = 0,
  M_SINGLE = 1,
  M_WAIT = 2;

reg	[sw-1:0]	next_state;
reg	[sw-1:0]	cur_state;
reg	[3:0]		count;
reg			do_count;

reg	[31:0]		adr;
reg	[31:0]		dat;
wire	[3:0]		sel;
reg	[2:0]		cti;
wire	[1:0]		bte;
wire			cyc;
reg			stb;
reg			we;
wire			ack;
wire	[31:0]		dato;

initial
  we <= 1'b1;

always @ (posedge clk)
  if (reset)
    cur_state <= M_IDLE;
  else
    cur_state <= next_state;

always @ (cur_state or start or count or ack)
  case(cur_state)
  M_IDLE: begin
    if (start)
      next_state <= M_SINGLE;
    else
      next_state <= M_IDLE;
  end
  M_SINGLE: begin
    if (count == 8 && ack)
      next_state <= M_IDLE;
    else if (ack)
      next_state <= M_WAIT;
    else
      next_state <= M_SINGLE;
  end 
  M_WAIT: next_state <= M_SINGLE;
  default: next_state <= M_IDLE;
  endcase

always @ (ack or cur_state)
  case(cur_state)
    M_SINGLE: do_count <= ack;
    default:  do_count <= 1'b0;
  endcase

always @ (posedge clk)
  if (reset || start)
    adr <= baseaddr;
  else if (ack)
    adr <= adr+4;

always @ (count)
  case(count)
  4'h0:    dat <= 32'h20000009;
  4'h1:    dat <= 32'h00010000;
  4'h2:    dat <= 32'h00810000;
  4'h3:    dat <= 32'h00000000;
  4'h4:    dat <= 32'h00000002;
  4'h5:    dat <= 32'h00000000;
  4'h6:    dat <= 32'h00000024;
  4'h7:    dat <= 32'h00000001;
  default: dat <= 32'h20000009;
  endcase

always @ (posedge clk)
  if (reset || start)
    count <= 'b0;
  else if (do_count)
    count <= count + 1;
  else
    count <= count;

always @ (cur_state)
  case(cur_state)
  default: cti <= 3'b000;
  endcase

always @ (cur_state)
  if (cur_state == M_SINGLE)
    stb <= 1'b1;
  else
    stb <= 1'b0;

assign bte = 2'b0;
assign cyc = stb;
assign sel = 4'b1111;

always @ (dat)
  wb_dat_o <= #outdelay dat;
always @ (adr)
  wb_adr_o <= #outdelay adr;
always @ (sel)
  wb_sel_o <= #outdelay sel;
always @ (we)
   wb_we_o  <= #outdelay we;
always @ (cyc)
   wb_cyc_o <= #outdelay cyc;
always @ (cti)
   wb_cti_o <= #outdelay cti;
always @ (bte)
   wb_bte_o <= #outdelay bte;
always @ (stb)
   wb_stb_o <= #outdelay stb;

assign ack   = wb_ack_i;
assign dato  = wb_dat_i;

endmodule
// Local Variables:
// verilog-library-directories:("." ".." "../or1200" "../jpeg" "../pkmc" "../dvga" "../uart" "../monitor" "../lab1" "../dafk_tb" "../eth" "../wb" "../leela")
// End:
