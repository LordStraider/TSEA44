#include "spr_defs.h"
#include "board.h"

	.global _crt
	.global be

_crt:	l.movhi	r1, 0x4001	// set SP
	l.ori	r1, r1, 0x2000	// at end of boot_RAM
	l.j     _main
	l.nop

be:	l.mfspr	r3,r0,0x20	// instruction addr
	l.mfspr	r4,r0,0x30	// berr addr
	l.movhi	r5, hi(_buserr)	
	l.ori	r5, r5, lo(_buserr)
	l.jr	r5
	l.nop
	l.nop
	l.nop
