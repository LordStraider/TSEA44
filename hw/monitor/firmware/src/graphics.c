#include "mon2.h"
#include "graphics.h"

void vgainit(void) {
	unsigned char *vga = (unsigned char *)VGABASE + 0x1C;

	/* Doing the initialization in this way saves a couple of instructions because
	 * we don't need two instructions to load an address. We load it once
	 * and use only one instruction to change the address */
	REG32(vga) = 0x00000000;
	vga -= 4;
	REG32(vga) = 0x00000000;
	vga -= 4;
	REG32(vga) = 0x00000000;
	vga -= 4;
	REG32(vga) = 0x00000000;
	vga -= 4;
	REG32(vga) = 0x00000000;
	vga -= 4;
	REG32(vga) = 0x00080000;
	vga -= 4;
	REG32(vga) = 0x00000000;
	vga -= 4;
	REG32(vga) = 0x20000001;
}

void palinit(void) {
	int i;
	unsigned char *pal = (unsigned char *)(VGABASE + 0x800);
	for(i=0; i<256; i++) {
		REG32(pal) = i;
		pal += 4;
	}
}

void caminit(void) {
	REG32(LEELABASE+0x08) = 0x20020000;
	REG32(LEELABASE+0x04) = 0x20010000;
	REG32(LEELABASE+0x00) = 0x00800100;
	
}
