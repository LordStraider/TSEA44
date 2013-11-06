`ifdef DVGA_DEFINES
`else
`define DVGA_DEFINES

`timescale 1ns/10ps

`define XCNTW 10
`define YCNTW 10
// ADRCNTW should be the sum of XCNTW and YCNTW
`define ADRCNTW 20
// ADRCNTZEROS should be 30 minus ADRCNTW
`define ADRCNTZEROS 10

`define THSYNC  96
`define THGDEL  45
`define THGATE 640
`define THLEN  800
`define TVSYNC   2
`define TVGDEL  30
`define TVGATE 480
`define TVLEN  525

`define SPRW    32
`define SPRH    32

//`define FIFO_RD_POS (`THSYNC+`THGDEL-1)%4
`define FIFO_RD_POS (`THSYNC+`THGDEL-2)%4
`define PIXIDX0     (`THSYNC+`THGDEL+0)%4
`define PIXIDX1     (`THSYNC+`THGDEL+1)%4
`define PIXIDX2     (`THSYNC+`THGDEL+2)%4
`define PIXIDX3     (`THSYNC+`THGDEL+3)%4
`define XOFFSET     `THSYNC - `THGDEL
`define YOFFSET     `TVSYNC - `TVGDEL

`endif// Local Variables:
// verilog-library-directories:("." ".." "../or1200" "../jpeg" "../pkmc" "../dvga" "../uart" "../monitor" "../lab1" "../dafk_tb" "../eth" "../wb" "../leela")
// End:
