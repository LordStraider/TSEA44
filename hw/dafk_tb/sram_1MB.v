`include "include/timescale.v"

module sram_1MB(address,dio,oe,ce,we, sel);

input [17:0] address;
inout [31:0] dio;
input oe;
input ce;
input we;
input [3:0] sel;

wire ce0, ce1, ce2, ce3;
wire ce4, ce5, ce6, ce7;

// active low!
assign ce0 =   address[17]  | ce | sel[0];
assign ce1 =   address[17]  | ce | sel[1];
assign ce2 =   address[17]  | ce | sel[2];
assign ce3 =   address[17]  | ce | sel[3];
assign ce4 = (!address[17]) | ce | sel[0];
assign ce5 = (!address[17]) | ce | sel[1];
assign ce6 = (!address[17]) | ce | sel[2];
assign ce7 = (!address[17]) | ce | sel[3];

// //wire [7:0] foo0, foo1, foo2, foo3;

// assign foo0 = {address[5:0], 2'b00};
// assign foo1 = {address[5:0], 2'b01};
// assign foo2 = {address[5:0], 2'b10};
// assign foo3 = {address[5:0], 2'b11};

// wire [31:0] diot;
// assign dio = oe?32'bZ:{foo0, foo1, foo2, foo3};

A128Kx8 sram0(address[16:0], dio[7:0], oe, ce0, we);
A128Kx8 sram1(address[16:0], dio[15:8], oe, ce1, we);
A128Kx8 sram2(address[16:0], dio[23:16], oe, ce2, we);
A128Kx8 sram3(address[16:0], dio[31:24], oe, ce3, we);
A128Kx8 sram4(address[16:0], dio[7:0], oe, ce4, we);
A128Kx8 sram5(address[16:0], dio[15:8], oe, ce5, we);
A128Kx8 sram6(address[16:0], dio[23:16], oe, ce6, we);
A128Kx8 sram7(address[16:0], dio[31:24], oe, ce7, we);

endmodule
// Local Variables:
// verilog-library-directories:("." ".." "../or1200" "../jpeg" "../pkmc" "../dvga" "../uart" "../monitor" "../lab1" "../dafk_tb" "../eth" "../wb" "../leela")
// End:
