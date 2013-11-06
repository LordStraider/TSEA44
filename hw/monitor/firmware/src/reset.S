	.section .vectors,"ax"
	
	.org 0x100		// reset
_reset:		
	l.movhi r3, hi(_crt)
 	l.ori r3,r3,lo(_crt)
 	l.jr r3
 	l.nop 0x0


