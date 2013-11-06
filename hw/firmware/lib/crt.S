	.global _crt

_crt:
	// Call main
	l.movhi	r3,hi(_main)
	l.ori	r3,r3,lo(_main)
	l.jr	r3
	l.nop
