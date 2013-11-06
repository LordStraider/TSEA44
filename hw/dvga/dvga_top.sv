`include "include/timescale.v"
`include "include/dvga_defines.v"

  
module dvga_top(
  // Wishbone slave interface
  wishbone.slave wbs,

  // Wishbone master interface
  wishbone.master wbm,
		
    output logic int_o,
  // VGA port
    output 	       logic  clk_p_o, hsync_pad_o, vsync_pad_o, blank_pad_o, 
    output 	       logic [7:0] r_pad_o, g_pad_o, b_pad_o  
);

// Syscon interface
   logic 	       clk;
   logic 	       rst;
   assign 	       clk = wbs.clk;
   assign 	       rst = wbs.rst;
   
// Wishbone slave interface
   logic [31:0]        wbs_adr_i;
   logic [31:0]        wbs_dat_i;
   logic [31:0]        wbs_dat_o;
   logic [3:0] 	       wbs_sel_i;
   logic 	       wbs_we_i, wbs_stb_i, wbs_cyc_i;
   logic 	       wbs_ack_o, wbs_err_o;
   logic [2:0] 	       wbs_cti_i;
   logic [1:0] 	       wbs_bte_i;

   assign 	       wbs_adr_i = wbs.adr;
   assign 	       wbs_dat_i = wbs.dat_o;
   assign 	       wbs_sel_i = wbs.sel;
   assign 	       wbs_we_i = wbs.we;
   assign 	       wbs_stb_i = wbs.stb;
   assign 	       wbs_cyc_i = wbs.cyc;
   assign 	       wbs_cti_i = wbs.cti;
   assign 	       wbs_bte_i = wbs.bte;
   
   assign 	       wbs.dat_i = wbs_dat_o;
   assign 	       wbs.ack = wbs_ack_o;
   assign 	       wbs.err = wbs_err_o;
   assign 	       wbs.rty = 1'b0;
   
// Wishbone master interface
   logic [31:0]        wbm_adr_o;
   logic [31:0]        wbm_dat_o;
   logic [31:0]        wbm_dat_i;
   logic [3:0] 	       wbm_sel_o;
   logic 	       wbm_we_o, wbm_stb_o, wbm_cyc_o;
   logic 	       wbm_ack_i, wbm_err_i;
   logic [2:0] 	       wbm_cti_o;
   logic [1:0] 	       wbm_bte_o;

   assign wbm.adr = wbm_adr_o;
   assign wbm.dat_o = wbm_dat_o;
   assign wbm.sel = wbm_sel_o;
   assign wbm.we = wbm_we_o;
   assign wbm.stb = wbm_stb_o;
   assign wbm.cyc =  wbm_cyc_o;
   assign wbm.cti = wbm_cti_o;
   assign wbm.bte = wbm_bte_o;
   
   assign wbm_dat_i = wbm.dat_i;
   assign wbm_ack_i = wbm.ack;
   assign wbm_err_i = wbm.err;
   
// -------------------------------------------------------
wire    [31:0]          reg0;
wire    [31:0]          reg1;
wire    [31:0]          reg2;
wire    [31:0]          reg3;
wire    [31:0]          reg4;
wire    [31:0]          reg5;
wire    [31:0]          reg6;
wire    [31:0]          reg7;

wire    [9:0]           spr0_adr;
wire    [15:0]          spr0_dat;
wire    [9:0]           spr1_adr;
wire    [15:0]          spr1_dat;
wire    [7:0]           pal0_adr;
wire    [31:0]          pal0_dat;

wire    [`XCNTW-1:0]    xpos;
wire    [`YCNTW-1:0]    ypos;
wire    [7:0]           r;
wire    [7:0]           g;
wire    [7:0]           b;
wire                    hsync;
wire                    vsync;
wire                    blank;

wire    [7:0]           r_o;
wire    [7:0]           g_o;
wire    [7:0]           b_o;
wire                    hsync_o;
wire                    vsync_o;
wire                    blank_o;

assign clk_p_o = clk;

dvga_reg regs(
       .clk(clk),             .rst(rst), 

       .wbs_adr_i(wbs_adr_i), .wbs_dat_i(wbs_dat_i), 
       .wbs_dat_o(wbs_dat_o), .wbs_sel_i(wbs_sel_i), 
       .wbs_we_i (wbs_we_i),  .wbs_stb_i(wbs_stb_i),
       .wbs_cyc_i(wbs_cyc_i), .wbs_ack_o(wbs_ack_o),
       .wbs_err_o(wbs_err_o), .wbs_cti_i(wbs_cti_i),
       .wbs_bte_i(wbs_bte_i),

       .reg0_o(reg0),         .reg1_o(reg1),
       .reg2_o(reg2),         .reg3_o(reg3),
       .reg4_o(reg4),         .reg5_o(reg5),
       .reg6_o(reg6),         .reg7_o(reg7),

       .pal0_adr_i(pal0_adr), .pal0_dat_o(pal0_dat), 
       .spr0_adr_i(spr0_adr), .spr0_dat_o(spr0_dat), 
       .spr1_adr_i(spr1_adr), .spr1_dat_o(spr1_dat)
);

dvga_renderer rend(
       .clk(clk),             .rst(rst), 
       .int_o(int_o),

       .wbm_adr_o(wbm_adr_o), .wbm_dat_o(wbm_dat_o), 
       .wbm_dat_i(wbm_dat_i), .wbm_sel_o(wbm_sel_o), 
       .wbm_we_o(wbm_we_o) ,  .wbm_stb_o(wbm_stb_o), 
       .wbm_cyc_o(wbm_cyc_o), .wbm_ack_i(wbm_ack_i), 
       .wbm_err_i(wbm_err_i), .wbm_cti_o(wbm_cti_o), 
       .wbm_bte_o(wbm_bte_o),

       .xpos(xpos),           .ypos(ypos),
       .r_o(r),               .g_o(g), 
       .b_o(b),               .hsync_o(hsync),
       .vsync_o(vsync),       .blank_o(blank),

       .pal0_adr_o(pal0_adr), .pal0_dat_i(pal0_dat), 
       .control(reg0),        .base0(reg1),
       .base1(reg2)
);

dvga_sprite spr(
       .clk(clk),                 .rst(rst), 

       .xpos_i(xpos),             .ypos_i(ypos),
       .r_i(r),                   .g_i(g), 
       .b_i(b),                   .hsync_i(hsync),
       .vsync_i(vsync),           .blank_i(blank),

       .r_o(r_o),                 .g_o(g_o),  
       .b_o(b_o),                 .hsync_o(hsync_o),
       .vsync_o(vsync_o),         .blank_o(blank_o),

       .swapcolor0_i(reg0[10:8]), .swapcolor1_i(reg0[6:4]),

       .spr0en_i(reg0[31]),       .spr0x_i(reg4),
       .spr0y_i(reg5),
       .spr0offsx_i(reg3[28:24]), .spr0offsy_i(reg3[20:16]),

       .spr1en_i(reg0[30]),       .spr1x_i(reg6),
       .spr1y_i(reg7),
       .spr1offsx_i(reg3[12:8]),  .spr1offsy_i(reg3[4:0]),

       .spr0_adr_o(spr0_adr),     .spr0_dat_i(spr0_dat), 
       .spr1_adr_o(spr1_adr),     .spr1_dat_i(spr1_dat)
);

wire outen;
assign outen = reg0[0];

always @ (posedge clk) begin
  r_pad_o     <= outen&&!blank_o?r_o:8'b0;
  g_pad_o     <= outen&&!blank_o?g_o:8'b0;
  b_pad_o     <= outen&&!blank_o?b_o:8'b0;
  hsync_pad_o <= outen?(reg0[27]^hsync_o):8'b0;
  vsync_pad_o <= outen?(reg0[28]^vsync_o):8'b0;
  blank_pad_o <= outen?(reg0[29]^blank_o):8'b0;
end

endmodule// Local Variables:
// verilog-library-directories:("." ".." "../or1200" "../jpeg" "../pkmc" "../dvga" "../uart" "../monitor" "../lab1" "../dafk_tb" "../eth" "../wb" "../leela")
// End:
