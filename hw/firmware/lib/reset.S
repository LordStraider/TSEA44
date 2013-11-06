	.section .vectors,"ax"
	
	.org 0x100		// reset
_reset:		
	l.movhi	r1, 0x4000	// set stack pointer
	l.ori	r1, r1, 0x1800  // (Use romram)

	// Init the UART

	l.movhi	r3,0x9000    // UART_BASE
	l.ori	r3,r3,0x0

	// 8 bits, 1 stop bit, no parity
	l.addi	r4,r0,0xffffff83	
	l.sb	0x3(r3),r4

	// Write divisor latches
	l.sb	0x1(r3),r0

	// 115200
	l.addi	r4,r0,14
	l.sb	0x0(r3),r4

	// access regs again
	l.addi	r4,r0,0x3
	l.sb	0x3(r3),r4


	// Init the timer register
	l.movhi	r4,0xc000
	l.ori	r4,r4,0x0
	l.addi	r3,r0,0x5000
	l.mtspr	r3,r4,0x0
	
	

	// Call the run time initialization
	l.movhi r3, hi(_crt)
 	l.ori r3,r3,lo(_crt)
 	l.jr r3
 	l.nop 0x0
