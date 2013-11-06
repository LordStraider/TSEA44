`include "dvga_defines.v"

module dvga_tb(clk, rst);  

   input clk;
   input rst;

   // uut inputs

   wire [31:0] wbm_dat_i;
   wire        wbm_ack_i;
   wire        wbm_err_i;

   wire [31:0] wbs_adr_i;
   wire [31:0] wbs_dat_i;
   wire [31:0] wbs_dat_o;
   wire [3:0]  wbs_sel_i;
   wire        wbs_we_i;
   wire        wbs_stb_i;
   wire        wbs_cyc_i;
   wire        wbs_ack_o;
   wire        wbs_err_o;
   wire [2:0]  wbs_cti_i; 
   wire [1:0]  wbs_bte_i; 

   wire [31:0] wbm_adr_o;
   wire [31:0] wbm_dat_o;
   wire [3:0]  wbm_sel_o;
   wire        wbm_we_o;
   wire        wbm_stb_o;
   wire        wbm_cyc_o;
   wire [2:0]  wbm_cti_o;
   wire [1:0]  wbm_bte_o;

   reg [7:0]   di;
   reg         m0_start;

   wire [17:0] mem_adr;
   wire [31:0] mem_dat;
   wire        mem_cs;
   wire        mem_oe;
   wire        mem_we;
   wire [3:0]  mem_be;

   dvga_top dvga(
                 .clk(clk),             .rst(rst),

                 .wbm_adr_o(wbm_adr_o), .wbm_dat_o(wbm_dat_o),
                 .wbm_dat_i(wbm_dat_i), .wbm_sel_o(wbm_sel_o),
                 .wbm_we_o(wbm_we_o),   .wbm_stb_o(wbm_stb_o),
                 .wbm_cyc_o(wbm_cyc_o), .wbm_ack_i(wbm_ack_i),
                 .wbm_err_i(wbm_err_i), .wbm_cti_o(wbm_cti_o),
                 .wbm_bte_o(wbm_bte_o), 

                 .wbs_adr_i(wbs_adr_i), .wbs_dat_i(wbs_dat_i),
                 .wbs_dat_o(wbs_dat_o), .wbs_sel_i(wbs_sel_i),
                 .wbs_we_i(wbs_we_i),   .wbs_stb_i(wbs_stb_i),
                 .wbs_cyc_i(wbs_cyc_i), .wbs_ack_o(wbs_ack_o),
                 .wbs_err_o(wbs_err_o), .wbs_cti_i(wbs_cti_i),
                 .wbs_bte_i(wbs_bte_i),

                 .clk_p_o(),            .hsync_pad_o(),
                 .vsync_pad_o(),        .blank_pad_o(),
                 .r_pad_o(),            .g_pad_o(),
                 .b_pad_o()
                 );

   leela_mc lmc (
                 .clk(clk),            .rst(rst), 
                 .s0_adr_i(32'b0),     .s0_dat_i(32'b0), 
                 .s0_dat_o(),          .s0_sel_i(4'b0), 
                 .s0_we_i(1'b0),       .s0_stb_i(1'b0), 
                 .s0_cyc_i(1'b0),      .s0_ack_o(), 
                 .s0_err_o(),          .s0_cti_i(3'b0), 
                 .s0_bte_i(2'b0), 
                 .s1_adr_i(32'b0),     .s1_dat_i(32'b0), 
                 .s1_dat_o(),          .s1_sel_i(4'b0), 
                 .s1_we_i(1'b0),       .s1_stb_i(1'b0), 
                 .s1_cyc_i(1'b0),      .s1_ack_o(), 
                 .s1_err_o(),          .s1_cti_i(3'b0), 
                 .s1_bte_i(2'b0), 
                 .s2_adr_i(wbm_adr_o), .s2_dat_i(wbm_dat_o), 
                 .s2_dat_o(), .s2_sel_i(wbm_sel_o), 
                 .s2_we_i(wbm_we_o),   .s2_stb_i(wbm_stb_o), 
                 .s2_cyc_i(wbm_cyc_o), .s2_ack_o(wbm_ack_i), 
                 .s2_err_o(wbm_err_i), .s2_cti_i(wbm_cti_o), 
                 .s2_bte_i(wbm_bte_o), 
                 .mem_adr_o(mem_adr),  .mem_dat_io(mem_dat), 
                 .mem_cs_o(mem_cs),    .mem_oe_o(mem_oe), 
                 .mem_we_o(mem_we),    .mem_be_o(mem_be), 
                 .debug_o()
                 );

   wire [7:0]  foo0;
   wire [7:0]  foo1;
   wire [7:0]  foo2;
   wire [7:0]  foo3;
   assign      foo0 = di;
   assign      foo1 = di+1;
   assign      foo2 = di+2;
   assign      foo3 = di+3;

   assign      wbm_dat_i = {foo0, foo1, foo2, foo3};

   always @ (posedge clk)
     if (rst) 
       di <= 8'h01;
     else if (wbm_ack_i)
       di <= di + 4;
     else 
       di <= di;

   sram mem0 (
              .address(mem_adr), .dio(mem_dat),
              .oe(mem_oe),       .ce(mem_cs),
              .we(mem_we),       .sel(mem_be)
              );

   dvga_tb_wbs_master m0(
                         .clk(clk),            .reset(rst), 
                         .wb_adr_o(wbs_adr_i), .wb_dat_o(wbs_dat_i), 
                         .wb_dat_i(wbs_dat_o), .wb_sel_o(wbs_sel_i), 
                         .wb_we_o(wbs_we_i),   .wb_stb_o(wbs_stb_i), 
                         .wb_cyc_o(wbs_cyc_i), .wb_ack_i(wbs_ack_o), 
                         .wb_err_i(wbs_err_o), .wb_cti_o(wbs_cti_i), 
                         .wb_bte_o(wbs_bte_i), .start(m0_start)
                         );

   initial begin
      m0_start = 0;
      #410 m0_start = 1;
      #40 m0_start = 0;
      #1100000 m0_start = 1;
      #40 m0_start = 0;
   end

endmodule
// Local Variables:
// verilog-library-directories:("." ".." "../or1200" "../jpeg" "../pkmc" "../dvga" "../uart" "../monitor" "../lab1" "../dafk_tb" "../eth" "../wb" "../leela")
// End:
