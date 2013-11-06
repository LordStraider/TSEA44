//
// Verilog Module leela.leela_mc.arch_name
//
// Created:
//          by - danwi.users (tinuviel.isy.liu.se)
//          at - 13:12:20 05/10/2004
//
// using Mentor Graphics HDL Designer(TM) 2003.2 (Build 28)
//
`resetall
`timescale 1ns/10ps
module leela_mc (
       // Syscon interface
       clk, rst,

       // Slave 0 (Wishbone)
       s0_adr_i, s0_dat_i, s0_dat_o, s0_sel_i, s0_we_i, s0_stb_i, 
       s0_cyc_i, s0_ack_o, s0_err_o, s0_cti_i, s0_bte_i,

       // Slave 1 (Camera)
       s1_adr_i, s1_dat_i, s1_dat_o, s1_sel_i, s1_we_i, s1_stb_i, 
       s1_cyc_i, s1_ack_o, s1_err_o, s1_cti_i, s1_bte_i, 

       // Slave 2 (VGA)
       s2_adr_i, s2_dat_i, s2_dat_o, s2_sel_i, s2_we_i, s2_stb_i, 
       s2_cyc_i, s2_ack_o, s2_err_o, s2_cti_i, s2_bte_i, 

       // Video memory port
       mem_adr_o, mem_dat_io, mem_cs_o, mem_oe_o, mem_we_o, mem_be_o
);

// Syscon interface
input			clk;
input			rst;

// Slave 0 (Wishbone)
input	[31:0]		s0_adr_i;
input	[31:0]		s0_dat_i;
output	[31:0]		s0_dat_o;
reg	[31:0]		s0_dat_o;
input	[3:0]		s0_sel_i;
input			s0_we_i;
input			s0_stb_i;
input			s0_cyc_i;
output			s0_ack_o;
output			s0_err_o;
input	[2:0]		s0_cti_i;
input	[1:0]		s0_bte_i;

// Slave 1 (Camera)
input	[31:0]		s1_adr_i;
input	[31:0]		s1_dat_i; 
output	[31:0]		s1_dat_o;
reg	[31:0]		s1_dat_o;
input	[3:0]		s1_sel_i;
input			s1_we_i; 
input			s1_stb_i; 
input			s1_cyc_i;
output			s1_ack_o;
output			s1_err_o;
input	[2:0]		s1_cti_i;
input	[1:0]		s1_bte_i;

// Slave 2 (VGA)
input	[31:0]		s2_adr_i;
input	[31:0]		s2_dat_i;
output	[31:0]		s2_dat_o;
reg	[31:0]		s2_dat_o;
input	[3:0]		s2_sel_i;
input			s2_we_i;
input			s2_stb_i;
input			s2_cyc_i;
output			s2_ack_o;
output			s2_err_o;
input	[2:0]		s2_cti_i;
input	[1:0]		s2_bte_i;

// Memory port
output	[17:0]		mem_adr_o;
inout	[31:0]		mem_dat_io;
output			mem_cs_o;
output			mem_oe_o;
output			mem_we_o;
output	[3:0]		mem_be_o;

// Internal wires
wire	[2:0]		req;
reg	[2:0]		gnt_next;
reg	[2:0]		gnt;
reg	[2:0]		cti_int;
reg	[1:0]		bte_int;

reg	[17:0]		mem_adr_int;
reg	[17:0]		mem_adr_acc;
wire			use_mem_adr_acc;
reg	[17:0]		mem_adr_r;
reg	[31:0]		mem_dat_wr_r;
reg	[31:0]		mem_dat_wr_int;
reg			mem_oe_r;
reg			mem_cs_r;
reg			mem_we_r;
reg	[3:0]		mem_be_r;
reg			mem_ack;

reg			mem_oe;
wire			mem_cs;
reg			mem_we;
reg	[3:0]		mem_be;

wire			s2_gnt;
wire			s1_gnt;
wire			s0_gnt;

// Ack state machine states
reg  [1:0]  next_ack_state;
reg  [1:0]  ack_state;
parameter [1:0]
  ACK_IDLE = 0,
  ACK_WAIT = 1,
  ACK_ACK  = 3;

//
// Arbiter for memory access
//
// Fixed priority is: S2, S1, S0 (defined by order 
// on next lines - lowest first with highest number)
assign req = { s0_stb_i, s1_stb_i, s2_stb_i };
parameter [1:0]
  S2POS = 0,
  S1POS = 1,
  S0POS = 2;

always @ (req or gnt)
    casez({req,gnt})
	7'bzz100z: gnt_next = 3'b001;
	7'bz100z0: gnt_next = 3'b010;
	7'b100z00: gnt_next = 3'b100;
	7'bzz0001: gnt_next = 3'b000;
	7'bz0z010: gnt_next = 3'b000;
	7'b0zz100: gnt_next = 3'b000;
	7'b000000: gnt_next = 3'b000;
	default:   gnt_next = gnt;
    endcase

always @ (posedge clk)
  if (rst == 1'b1)
    gnt <= 3'b0;
  else
    gnt <= gnt_next;

assign s2_gnt = gnt[S2POS];
assign s1_gnt = gnt[S1POS];
assign s0_gnt = gnt[S0POS];

//
// CTI and BTE connections
//
always @ (gnt_next or gnt or s2_cti_i or s1_cti_i or s0_cti_i)
  if ((gnt_next[0] | gnt[0]) == 1'b1) 
    cti_int = s2_cti_i;     
  else if ((gnt_next[1] | gnt[1]) == 1'b1) 
    cti_int = s1_cti_i;     
  else
    cti_int = s0_cti_i;

always @ (gnt_next or gnt or s2_bte_i or s1_bte_i or s0_bte_i)
  if ((gnt_next[0] | gnt[0]) == 1'b1) 
    bte_int = s2_bte_i;     
  else if ((gnt_next[1] | gnt[1]) == 1'b1) 
    bte_int = s1_bte_i;     
  else
    bte_int = s0_bte_i;

//
// Memory address connections and calculations
//
always @ (posedge clk)
  if (rst == 1'b1)
    mem_adr_acc <= 18'b0;
  else if (use_mem_adr_acc)
    mem_adr_acc <= mem_adr_acc + 1;
  else
    mem_adr_acc <= mem_adr_int + 1;

always @ (gnt_next or gnt or s0_adr_i or s1_adr_i or s2_adr_i or
  use_mem_adr_acc or mem_adr_acc)
  if (use_mem_adr_acc)
    mem_adr_int = mem_adr_acc;
  else if ((gnt_next[0] | gnt[0]) == 1'b1) 
    mem_adr_int = s2_adr_i[19:2];
  else if ((gnt_next[1] | gnt[1]) == 1'b1) 
    mem_adr_int = s1_adr_i[19:2];
  else
    mem_adr_int = s0_adr_i[19:2];

assign use_mem_adr_acc = (ack_state != ACK_IDLE) && (cti_int == 3'b010) &&
                           (bte_int == 2'b00);
//
// Memory write connections
//
always @ (gnt or s0_dat_i or s1_dat_i or s2_dat_i)
    case (gnt)
	3'b001: mem_dat_wr_int = s2_dat_i;
	3'b010: mem_dat_wr_int = s1_dat_i;
	default: mem_dat_wr_int = s0_dat_i;
    endcase

//
// Memory read connections
//
always @ (posedge clk) 
  if (rst == 1'b1) begin
    s2_dat_o <= 32'b0;
    s1_dat_o <= 32'b0;
    s0_dat_o <= 32'b0;
  end else begin
    s2_dat_o <= mem_dat_io;
    s1_dat_o <= mem_dat_io;
    s0_dat_o <= mem_dat_io;
  end

//
// IO registers and (tristate) drivers
//
always @ (posedge clk) begin
  if (rst == 1'b1) begin
    mem_adr_r <= 18'b0;
    mem_dat_wr_r <= 32'b0;
    mem_oe_r <= 1'b1;
    mem_cs_r <= 1'b1;
    mem_we_r <= 1'b1;
    mem_be_r <= 4'b0;
  end else begin
    mem_adr_r <= mem_adr_int;
    mem_dat_wr_r <= mem_dat_wr_int;
    mem_oe_r <= ~mem_oe;
    mem_cs_r <= ~mem_cs;
    mem_we_r <= ~mem_we;
    mem_be_r <= ~mem_be;
  end
end

assign mem_oe_o = mem_oe_r;
assign mem_cs_o = mem_cs_r;
//assign mem_we_o = mem_we_r; // Changed to a DDR FF
assign mem_be_o = mem_be_r;
assign mem_adr_o = mem_adr_r;
assign mem_dat_io = mem_oe_r ? mem_dat_wr_r : 32'bz;

OFDDRRSE weddr0 (
  .CE(1'b1), 
  .S(1'b0),
  .R(1'b0),
  .C0(clk),
  .C1(!clk),
  .D0(1'b1),
  .D1(mem_we_r),
  .Q(mem_we_o)
);

assign mem_cs = 1'b1;

always @ (gnt_next or s0_sel_i or s1_sel_i or s2_sel_i)
  case(gnt_next)
    3'b001: mem_be = s2_sel_i;
    3'b010: mem_be = s1_sel_i;
    3'b100: mem_be = s0_sel_i;
    default: mem_be = 4'b1111;
  endcase

//
// Ack handling
//
assign s0_ack_o = mem_ack & s0_gnt;
assign s1_ack_o = mem_ack & s1_gnt;
assign s2_ack_o = mem_ack & s2_gnt;

//
// Memory output enable signal
//
always @ (gnt_next or s0_we_i or s1_we_i  or s2_we_i)
case (gnt_next)
    3'b001:  mem_oe = !s2_we_i;
    3'b010:  mem_oe = !s1_we_i;
    default: mem_oe = !s0_we_i;
endcase

// 
// Memory write enable
//
always @ (gnt_next or s0_we_i or s1_we_i or s2_we_i or next_ack_state)
case (gnt_next)
    3'b000:  mem_we = 1'b0;
    3'b001:  mem_we = s2_we_i && (next_ack_state == ACK_ACK);
    3'b010:  mem_we = s1_we_i && (next_ack_state == ACK_ACK);
    default: mem_we = s0_we_i && (next_ack_state == ACK_ACK);
endcase

//
// Ack state machine
//

always @ (ack_state or gnt_next or gnt or s2_we_i or 
          s1_we_i or s0_we_i or cti_int or bte_int)
  if (ack_state == ACK_IDLE) begin
    if (((gnt_next == 3'b100)     && (gnt[2] == 1'b1) && (s0_we_i == 1'b1)) ||
        ((gnt_next[1:0] == 2'b10) && (gnt[1] == 1'b1) && (s1_we_i == 1'b1)) ||
        ((gnt_next[0] == 1'b1)    && (gnt[0] == 1'b1) && (s2_we_i == 1'b1)))
      next_ack_state = ACK_ACK ;
    else if (gnt_next == 3'b0 )
      next_ack_state = ACK_IDLE;
    else
      next_ack_state = ACK_WAIT;
  end else if (ack_state == ACK_WAIT)
    next_ack_state = ACK_ACK;
  else if (ack_state == ACK_ACK) begin
    case({cti_int, bte_int})
    5'b01000: next_ack_state = ACK_ACK;
    5'b11100: next_ack_state = ACK_IDLE;
    default:  next_ack_state = ACK_IDLE;
    endcase
  end else
    next_ack_state = ACK_IDLE;

always @ (posedge clk)
  if (rst == 1'b1)
    ack_state <= ACK_IDLE;
  else
    ack_state <= next_ack_state;

// Fulhack...
always @ (posedge clk)
  if (rst == 1'b1)
    mem_ack <= 1'b0;
  else
    mem_ack <= (next_ack_state == ACK_ACK);

//
// The ever-low error signals
//
assign s0_err_o = 1'b0;
assign s1_err_o = 1'b0;
assign s2_err_o = 1'b0;

endmodule // leela_mc

// Local Variables:
// verilog-library-directories:("." ".." "../or1200" "../jpeg" "../pkmc" "../dvga" "../uart" "../monitor" "../lab1" "../dafk_tb" "../eth" "../wb" "../leela")
// End:
