#include "common.h"

void vgainit(void)
{
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

void vgasetbase(int offset)
{
	REG32(VGABASE+0x4) = offset;
}

/* Set the camera to continuously send frames to the VGA memory */
void camview(void) {
	REG32(LEELA_CTRL) = 0x00800100;
}

void camdisable(void) {
	REG32(LEELA_CTRL) = 0x00800000;
}

/* Get one frame from the camera to the address specified by addr with
 * the threshold set appropriately */
void camgetfilteredframe(unsigned char *addr,int threshold)
{
        REG32(LEELA_VBASE) = 0;
	REG32(LEELA_FBASE0) = (int)addr;
	REG32(LEELA_FBASE1) = (int)addr;
	REG32(LEELA_CTRL) = 0x00001700 | ((threshold & 0xff) << 16);

	/* Busy wait for frame end */
	while(REG32(LEELA_CTRL) & 0x200);
}


void showsprite(int sprite)
{
	unsigned int x;

	x = REG32(VGA_CTRL);
	if(sprite == 0){
		x |= 0x80000000; /* Sprite 0 enable */
	}else if(sprite == 1){
		x |= 0x40000000; /* Sprite 1 enable */
	}

	REG32(VGA_CTRL) = x; 
}

void hidesprite(int sprite)
{
	unsigned int x;

	x = REG32(VGA_CTRL);
	if(sprite == 0){
		x &= ~0x80000000; /* Sprite 0 enable */
	}else if(sprite == 1){
		x &= ~0x40000000; /* Sprite 1 enable */
	}

	REG32(VGA_CTRL) = x; 
}

void initsprites(void)
{
	unsigned int x;

	x = REG32(VGA_CTRL);
	x &= 0x3ffff88f; /* Mask away sprite control bits */
	x |= 0x00000400; /* Enable sprites, invert sprite 0 */

	REG32(VGA_CTRL) = x;
	REG32(VGA_SPROFFS) = 0x0f0f0f0f;
}

void movesprite(int sprite,int x,int y)
{
	unsigned int spritecoords;
	if(sprite == 0){
		spritecoords = VGA_SPRX0;
	}else if(sprite == 1){
		spritecoords = VGA_SPRX1;
	}else{
		return;
	}
	REG32(spritecoords) = x;
	REG32(spritecoords + 4) = y;
}
