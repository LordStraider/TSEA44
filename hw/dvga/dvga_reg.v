`resetall
`timescale 1ns/10ps
  
module dvga_reg (
       clk, rst, 

       wbs_adr_i, wbs_dat_i, wbs_dat_o, wbs_sel_i, wbs_we_i, wbs_stb_i, 
       wbs_cyc_i, wbs_ack_o, wbs_err_o, wbs_cti_i, wbs_bte_i,

       reg0_o, reg1_o, reg2_o, reg3_o, reg4_o, reg5_o, reg6_o, reg7_o,

       pal0_adr_i, pal0_dat_o,
       spr0_adr_i, spr0_dat_o, spr1_adr_i, spr1_dat_o
);

input		clk;
input		rst;

input	[31:0]	wbs_adr_i;
input	[31:0]	wbs_dat_i;
output	[31:0]	wbs_dat_o;
reg	[31:0]	wbs_dat_o;
input	[3:0]	wbs_sel_i;
input		wbs_we_i;
input		wbs_stb_i;
input		wbs_cyc_i;
output		wbs_ack_o;
output		wbs_err_o;
input	[2:0]	wbs_cti_i;
input	[1:0]	wbs_bte_i;

output  [31:0]  reg0_o;
output  [31:0]  reg1_o;
output  [31:0]  reg2_o;
output  [31:0]  reg3_o;
output  [31:0]  reg4_o;
output  [31:0]  reg5_o;
output  [31:0]  reg6_o;
output  [31:0]  reg7_o;

input   [7:0]   pal0_adr_i;
output  [31:0]  pal0_dat_o;

input   [9:0]   spr0_adr_i;
input   [9:0]   spr1_adr_i;
output  [15:0]  spr0_dat_o;
output  [15:0]  spr1_dat_o;

reg	[31:0]	reg0;
reg	[31:0]	reg1;
reg	[31:0]	reg2;
reg	[31:0]	reg3;
reg	[31:0]	reg4;
reg	[31:0]	reg5;
reg	[31:0]	reg6;
reg	[31:0]	reg7;

wire            regs_we;
wire            spr0_we;
wire            spr1_we;
wire            pal0_we;
wire    [31:0]  spr0_rdatb;
wire    [31:0]  spr1_rdatb;
wire    [31:0]  pal0_rdatb;
wire    [31:0]  spr0_rdata;
wire    [31:0]  spr1_rdata;
wire    [31:0]  pal0_rdata;

reg     [1:0]   ack_state;
reg     [1:0]   next_ack_state;
parameter [1:0] 
  STATE_IDLE = 2'b00,
  STATE_WAIT = 2'b01,
  STATE_ACK  = 2'b10;

always @ (posedge clk)
  if (rst)
    ack_state <= STATE_IDLE;
  else
    ack_state <= next_ack_state;

always @ (ack_state or wbs_stb_i or wbs_cyc_i or wbs_adr_i)
  case(ack_state) 
    2'b00:   if (wbs_stb_i & wbs_cyc_i) begin
               if (wbs_adr_i[12]) next_ack_state = STATE_WAIT;
               else next_ack_state = STATE_ACK;
             end else next_ack_state = STATE_IDLE;
    2'b01:   next_ack_state = STATE_ACK;
    default: next_ack_state = STATE_IDLE;
  endcase

assign wbs_ack_o = (ack_state == STATE_ACK);
assign wbs_err_o = 1'b0;

assign regs_we = wbs_we_i & wbs_cyc_i & wbs_stb_i & !wbs_adr_i[12] & !wbs_adr_i[11];
assign pal0_we = wbs_we_i & wbs_cyc_i & wbs_stb_i & !wbs_adr_i[12] & wbs_adr_i[11];
assign spr0_we = wbs_we_i & wbs_cyc_i & wbs_stb_i & wbs_adr_i[12] & !wbs_adr_i[11];
assign spr1_we = wbs_we_i & wbs_cyc_i & wbs_stb_i & wbs_adr_i[12] & wbs_adr_i[11];

always @ (posedge clk)
  if (rst)
    reg0 <= 32'b0;
  else if (regs_we & (wbs_adr_i[4:2] == 3'h0))
    reg0 <= wbs_dat_i;

always @ (posedge clk)
  if (rst)
    reg1 <= 32'b0;
  else if (regs_we & (wbs_adr_i[4:2] == 3'h1))
    reg1 <= wbs_dat_i;

always @ (posedge clk)
  if (rst)
    reg2 <= 32'b0;
  else if (regs_we & (wbs_adr_i[4:2] == 3'h2))
    reg2 <= wbs_dat_i;

always @ (posedge clk)
  if (rst)
    reg3 <= 32'b0;
  else if (regs_we & (wbs_adr_i[4:2] == 3'h3))
    reg3 <= wbs_dat_i;

always @ (posedge clk)
  if (rst)
    reg4 <= 32'b0;
  else if (regs_we & (wbs_adr_i[4:2] == 3'h4))
    reg4 <= wbs_dat_i;

always @ (posedge clk)
  if (rst)
    reg5 <= 32'b0;
  else if (regs_we & (wbs_adr_i[4:2] == 3'h5))
    reg5 <= wbs_dat_i;

always @ (posedge clk)
  if (rst)
    reg6 <= 32'b0;
  else if (regs_we & (wbs_adr_i[4:2] == 3'h6))
    reg6 <= wbs_dat_i;

always @ (posedge clk)
  if (rst)
    reg7 <= 32'b0;
  else if (regs_we & (wbs_adr_i[4:2] == 3'h7))
    reg7 <= wbs_dat_i;

dpram512w sprmem0 (
  .clka(clk),
  .clkb(clk),
  .addra(wbs_adr_i[10:2]),
  .dina(wbs_dat_i),
  .douta(spr0_rdata),
  .wea(spr0_we),
  .addrb(spr0_adr_i[9:1]),
  .doutb(spr0_rdatb)
);

dpram512w sprmem1 (
  .clka(clk),
  .clkb(clk),
  .addra(wbs_adr_i[10:2]),
  .dina(wbs_dat_i),
  .douta(spr1_rdata),
  .wea(spr1_we),
  .addrb(spr1_adr_i[9:1]),
  .doutb(spr1_rdatb)
);


always @ (wbs_adr_i or reg0 or reg1 or reg2 or reg3
                    or reg4 or reg5 or reg6 or reg7
		    or spr0_rdata or spr1_rdata
		    or pal0_rdata)
casex (wbs_adr_i[12:0])
     13'b0_0xxx_xxx0_01xx:    wbs_dat_o = reg1;
     13'b0_0xxx_xxx0_10xx:    wbs_dat_o = reg2;
     13'b0_0xxx_xxx0_11xx:    wbs_dat_o = reg3;
     13'b0_0xxx_xxx1_00xx:    wbs_dat_o = reg4;
     13'b0_0xxx_xxx1_01xx:    wbs_dat_o = reg5;
     13'b0_0xxx_xxx1_10xx:    wbs_dat_o = reg6;
     13'b0_0xxx_xxx1_11xx:    wbs_dat_o = reg7;
     13'b0_1xxx_xxxx_xxxx:    wbs_dat_o = pal0_rdata;
     13'b1_0xxx_xxxx_xxxx:    wbs_dat_o = spr0_rdata;
     13'b1_1xxx_xxxx_xxxx:    wbs_dat_o = spr1_rdata;
     default:		      wbs_dat_o = reg0;
endcase

assign spr0_dat_o = spr0_adr_i[0]?spr0_rdatb[15:0]:spr0_rdatb[31:16];
assign spr1_dat_o = spr1_adr_i[0]?spr1_rdatb[15:0]:spr1_rdatb[31:16];

assign reg0_o = reg0;
assign reg1_o = reg1;
assign reg2_o = reg2;
assign reg3_o = reg3;
assign reg4_o = reg4;
assign reg5_o = reg5;
assign reg6_o = reg6;
assign reg7_o = reg7;

RAMB16_S36_S36 pal0 (
  .CLKA (clk), 
  .CLKB (clk), 
  .SSRA (rst), 
  .SSRB (rst), 

  .ADDRA ({1'b0,wbs_adr_i[9:2]}), 
  .WEA (pal0_we),
  .DIA (wbs_dat_i), 
  .DOA (pal0_rdata), 

  .ADDRB ({1'b0, pal0_adr_i}), 
  .WEB (1'b0),
  .DIB (32'b0), 
  .DOB (pal0_dat_o), 

  .ENA (1'b1), 
  .DIPA (4'b0), 
  .DOPA (), 
  .ENB (1'b1), 
  .DIPB (4'b0), 
  .DOPB ()
);

// BRAM 0 in address block [0x00000000:0x000007FF], bit lane [31:0]
defparam pal0.INIT_00 = 256'h0007070700060606000505050004040400030303000202020001010100000000;
defparam pal0.INIT_01 = 256'h000F0F0F000E0E0E000D0D0D000C0C0C000B0B0B000A0A0A0009090900080808;
defparam pal0.INIT_02 = 256'h0017171700161616001515150014141400131313001212120011111100101010;
defparam pal0.INIT_03 = 256'h001F1F1F001E1E1E001D1D1D001C1C1C001B1B1B001A1A1A0019191900181818;
defparam pal0.INIT_04 = 256'h0027272700262626002525250024242400232323002222220021212100202020;
defparam pal0.INIT_05 = 256'h002F2F2F002E2E2E002D2D2D002C2C2C002B2B2B002A2A2A0029292900282828;
defparam pal0.INIT_06 = 256'h0037373700363636003535350034343400333333003232320031313100303030;
defparam pal0.INIT_07 = 256'h003F3F3F003E3E3E003D3D3D003C3C3C003B3B3B003A3A3A0039393900383838;
defparam pal0.INIT_08 = 256'h0047474700464646004545450044444400434343004242420041414100404040;
defparam pal0.INIT_09 = 256'h004F4F4F004E4E4E004D4D4D004C4C4C004B4B4B004A4A4A0049494900484848;
defparam pal0.INIT_0A = 256'h0057575700565656005555550054545400535353005252520051515100505050;
defparam pal0.INIT_0B = 256'h005F5F5F005E5E5E005D5D5D005C5C5C005B5B5B005A5A5A0059595900585858;
defparam pal0.INIT_0C = 256'h0067676700666666006565650064646400636363006262620061616100606060;
defparam pal0.INIT_0D = 256'h006F6F6F006E6E6E006D6D6D006C6C6C006B6B6B006A6A6A0069696900686868;
defparam pal0.INIT_0E = 256'h0077777700767676007575750074747400737373007272720071717100707070;
defparam pal0.INIT_0F = 256'h007F7F7F007E7E7E007D7D7D007C7C7C007B7B7B007A7A7A0079797900787878;
defparam pal0.INIT_10 = 256'h0087878700868686008585850084848400838383008282820081818100808080;
defparam pal0.INIT_11 = 256'h008F8F8F008E8E8E008D8D8D008C8C8C008B8B8B008A8A8A0089898900888888;
defparam pal0.INIT_12 = 256'h0097979700969696009595950094949400939393009292920091919100909090;
defparam pal0.INIT_13 = 256'h009F9F9F009E9E9E009D9D9D009C9C9C009B9B9B009A9A9A0099999900989898;
defparam pal0.INIT_14 = 256'h00A7A7A700A6A6A600A5A5A500A4A4A400A3A3A300A2A2A200A1A1A100A0A0A0;
defparam pal0.INIT_15 = 256'h00AFAFAF00AEAEAE00ADADAD00ACACAC00ABABAB00AAAAAA00A9A9A900A8A8A8;
defparam pal0.INIT_16 = 256'h00B7B7B700B6B6B600B5B5B500B4B4B400B3B3B300B2B2B200B1B1B100B0B0B0;
defparam pal0.INIT_17 = 256'h00BFBFBF00BEBEBE00BDBDBD00BCBCBC00BBBBBB00BABABA00B9B9B900B8B8B8;
defparam pal0.INIT_18 = 256'h00C7C7C700C6C6C600C5C5C500C4C4C400C3C3C300C2C2C200C1C1C100C0C0C0;
defparam pal0.INIT_19 = 256'h00CFCFCF00CECECE00CDCDCD00CCCCCC00CBCBCB00CACACA00C9C9C900C8C8C8;
defparam pal0.INIT_1A = 256'h00D7D7D700D6D6D600D5D5D500D4D4D400D3D3D300D2D2D200D1D1D100D0D0D0;
defparam pal0.INIT_1B = 256'h00DFDFDF00DEDEDE00DDDDDD00DCDCDC00DBDBDB00DADADA00D9D9D900D8D8D8;
defparam pal0.INIT_1C = 256'h00E7E7E700E6E6E600E5E5E500E4E4E400E3E3E300E2E2E200E1E1E100E0E0E0;
defparam pal0.INIT_1D = 256'h00EFEFEF00EEEEEE00EDEDED00ECECEC00EBEBEB00EAEAEA00E9E9E900E8E8E8;
defparam pal0.INIT_1E = 256'h00F7F7F700F6F6F600F5F5F500F4F4F400F3F3F300F2F2F200F1F1F100F0F0F0;
defparam pal0.INIT_1F = 256'h00FFFFFF00FEFEFE00FDFDFD00FCFCFC00FBFBFB00FAFAFA00F9F9F900F8F8F8;
defparam pal0.INIT_20 = 256'h0007070700060606000505050004040400030303000202020001010100000000;
defparam pal0.INIT_21 = 256'h000F0F0F000E0E0E000D0D0D000C0C0C000B0B0B000A0A0A0009090900080808;
defparam pal0.INIT_22 = 256'h0017171700161616001515150014141400131313001212120011111100101010;
defparam pal0.INIT_23 = 256'h001F1F1F001E1E1E001D1D1D001C1C1C001B1B1B001A1A1A0019191900181818;
defparam pal0.INIT_24 = 256'h0027272700262626002525250024242400232323002222220021212100202020;
defparam pal0.INIT_25 = 256'h002F2F2F002E2E2E002D2D2D002C2C2C002B2B2B002A2A2A0029292900282828;
defparam pal0.INIT_26 = 256'h0037373700363636003535350034343400333333003232320031313100303030;
defparam pal0.INIT_27 = 256'h003F3F3F003E3E3E003D3D3D003C3C3C003B3B3B003A3A3A0039393900383838;
defparam pal0.INIT_28 = 256'h0047474700464646004545450044444400434343004242420041414100404040;
defparam pal0.INIT_29 = 256'h004F4F4F004E4E4E004D4D4D004C4C4C004B4B4B004A4A4A0049494900484848;
defparam pal0.INIT_2A = 256'h0057575700565656005555550054545400535353005252520051515100505050;
defparam pal0.INIT_2B = 256'h005F5F5F005E5E5E005D5D5D005C5C5C005B5B5B005A5A5A0059595900585858;
defparam pal0.INIT_2C = 256'h0067676700666666006565650064646400636363006262620061616100606060;
defparam pal0.INIT_2D = 256'h006F6F6F006E6E6E006D6D6D006C6C6C006B6B6B006A6A6A0069696900686868;
defparam pal0.INIT_2E = 256'h0077777700767676007575750074747400737373007272720071717100707070;
defparam pal0.INIT_2F = 256'h007F7F7F007E7E7E007D7D7D007C7C7C007B7B7B007A7A7A0079797900787878;
defparam pal0.INIT_30 = 256'h0087878700868686008585850084848400838383008282820081818100808080;
defparam pal0.INIT_31 = 256'h008F8F8F008E8E8E008D8D8D008C8C8C008B8B8B008A8A8A0089898900888888;
defparam pal0.INIT_32 = 256'h0097979700969696009595950094949400939393009292920091919100909090;
defparam pal0.INIT_33 = 256'h009F9F9F009E9E9E009D9D9D009C9C9C009B9B9B009A9A9A0099999900989898;
defparam pal0.INIT_34 = 256'h00A7A7A700A6A6A600A5A5A500A4A4A400A3A3A300A2A2A200A1A1A100A0A0A0;
defparam pal0.INIT_35 = 256'h00AFAFAF00AEAEAE00ADADAD00ACACAC00ABABAB00AAAAAA00A9A9A900A8A8A8;
defparam pal0.INIT_36 = 256'h00B7B7B700B6B6B600B5B5B500B4B4B400B3B3B300B2B2B200B1B1B100B0B0B0;
defparam pal0.INIT_37 = 256'h00BFBFBF00BEBEBE00BDBDBD00BCBCBC00BBBBBB00BABABA00B9B9B900B8B8B8;
defparam pal0.INIT_38 = 256'h00C7C7C700C6C6C600C5C5C500C4C4C400C3C3C300C2C2C200C1C1C100C0C0C0;
defparam pal0.INIT_39 = 256'h00CFCFCF00CECECE00CDCDCD00CCCCCC00CBCBCB00CACACA00C9C9C900C8C8C8;
defparam pal0.INIT_3A = 256'h00D7D7D700D6D6D600D5D5D500D4D4D400D3D3D300D2D2D200D1D1D100D0D0D0;
defparam pal0.INIT_3B = 256'h00DFDFDF00DEDEDE00DDDDDD00DCDCDC00DBDBDB00DADADA00D9D9D900D8D8D8;
defparam pal0.INIT_3C = 256'h00E7E7E700E6E6E600E5E5E500E4E4E400E3E3E300E2E2E200E1E1E100E0E0E0;
defparam pal0.INIT_3D = 256'h00EFEFEF00EEEEEE00EDEDED00ECECEC00EBEBEB00EAEAEA00E9E9E900E8E8E8;
defparam pal0.INIT_3E = 256'h00F7F7F700F6F6F600F5F5F500F4F4F400F3F3F300F2F2F200F1F1F100F0F0F0;
defparam pal0.INIT_3F = 256'h00FFFFFF00FEFEFE00FDFDFD00FCFCFC00FBFBFB00FAFAFA00F9F9F900F8F8F8;

endmodule

// Local Variables:
// verilog-library-directories:("." ".." "../or1200" "../jpeg" "../pkmc" "../dvga" "../uart" "../monitor" "../lab1" "../dafk_tb" "../eth" "../wb" "../leela")
// End:
