`ifndef DAFK_DEFINES_V
`define DAFK_DEFINES_V

`define BOOT_ADDR 32'h40000000
`define RAM_ADDR  32'h40004000

// ORP Address Space

// 0xf000_0000 - 0xffff_ffff  Cached	256MB	ROM
// 0xc000_0000 - 0xefff_ffff  Cached	768MB	Reserved
// 0xb800_0000 - 0xbfff_ffff  Uncached	128MB	Reserved for custom devices
// 0xa600_0000 - 0xb7ff_ffff  Uncached	288MB	Reserved
// 0xa500_0000 - 0xa5ff_ffff  Uncached	16MB	Debug 0-15
// 0xa400_0000 - 0xa4ff_ffff  Uncached	16MB	Digital Camera Controller 0-15
// 0xa300_0000 - 0xa3ff_ffff  Uncached	16MB	I2C Controller 0-15
// 0xa200_0000 - 0xa2ff_ffff  Uncached	16MB	TDM Controller 0-15
// 0xa100_0000 - 0xa1ff_ffff  Uncached	16MB	HDLC Controller 0-15
// 0xa000_0000 - 0xa0ff_ffff  Uncached	16MB	Real-Time Clock 0-15
// 0x9f00_0000 - 0x9fff_ffff  Uncached	16MB	Firewire Controller 0-15
// 0x9e00_0000 - 0x9eff_ffff  Uncached	16MB	IDE Controller 0-15
// 0x9d00_0000 - 0x9dff_ffff  Uncached	16MB	Audio Controller 0-15
// 0x9c00_0000 - 0x9cff_ffff  Uncached	16MB	USB Host Controller 0-15
// 0x9b00_0000 - 0x9bff_ffff  Uncached	16MB	USB Func Controller 0-15
// 0x9a00_0000 - 0x9aff_ffff  Uncached	16MB	General-Purpose DMA 0-15
// 0x9900_0000 - 0x99ff_ffff  Uncached	16MB	PCI Controller 0-15
// 0x9800_0000 - 0x98ff_ffff  Uncached	16MB	IrDA Controller 0-15
// 0x9700_0000 - 0x97ff_ffff  Uncached	16MB	Graphics Controller 0-15
// 0x9600_0000 - 0x96ff_ffff  Uncached	16MB	PWM/Timer/Counter Controller 0-15
// 0x9500_0000 - 0x95ff_ffff  Uncached	16MB	Traffic COP 0-15
// 0x9400_0000 - 0x94ff_ffff  Uncached	16MB	PS/2 Controller 0-15
// 0x9300_0000 - 0x93ff_ffff  Uncached	16MB	Memory Controller 0-15
// 0x9200_0000 - 0x92ff_ffff  Uncached	16MB	Ethernet Controller 0-15
// 0x9100_0000 - 0x91ff_ffff  Uncached	16MB	General-Purpose I/O 0-15
// 0x9000_0000 - 0x90ff_ffff  Uncached	16MB	UART16550 Controller 0-15
// 0x8000_0000 - 0x8fff_ffff  Uncached	256MB	PCI I/O
// 0x4000_0000 - 0x7fff_ffff  Uncached	1GB	Reserved Boot Monitor QMEM
// 0x0000_0000 - 0x3fff_ffff  Cached	1GB	RAM



//
// Address map
//
// peripheral decode length
`define ADDR_DEC_W    8	// port 0
`define ADDR_BOOT_W   8	// port 1
`define ADDR_UART_W   8	// port 2
`define ADDR_ETH_W    8	// port 3
`define ADDR_PS2_W    8	// port 4
`define ADDR_VGA_W    8	// port 5
`define ADDR_DCT_W    8	// port 6
`define ADDR_PARP_W   8	// port 7
`define ADDR_LEELA_W  8	// port 8
`define ADDR_LAB3_W   8	// port 9
//
// peripheral addresses
`define ADDR_MC	`ADDR_DEC_W'h93 // port 0
`define ADDR_BOOT	`ADDR_BOOT_W'h40 // port 1
`define ADDR_UART	`ADDR_UART_W'h90 // port 2
`define ADDR_ETH	`ADDR_ETH_W'h92 // port 3
`define ADDR_PS2	`ADDR_PS2_W'h94 // port 4
`define ADDR_VGA	`ADDR_VGA_W'h97 // port 5
`define ADDR_DCT	`ADDR_DCT_W'h96 // port 6
`define ADDR_PARP	`ADDR_PARP_W'h91 // port 7
`define ADDR_LEELA	`ADDR_LEELA_W'h98 // port 8
`define ADDR_LAB3	`ADDR_LAB3_W'h99 // port 9

`endif// Local Variables:
// verilog-library-directories:("." ".." "../or1200" "../jpeg" "../pkmc" "../dvga" "../uart" "../monitor" "../lab1" "../dafk_tb" "../eth" "../wb" "../leela")
// End:
