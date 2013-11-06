#include "common.h"


/* Expand a packed bitmap with 1 bit per pixel into the 8 bit per pixel
 * format used in the frame buffer */
void expandbitmap(volatile unsigned int *src,unsigned int *dst)
{
	unsigned int val;
	int i,j;

	static const unsigned int vals[16] = {
		0x00000000,
		0x000000ff,
		0x0000ff00,
		0x0000ffff,
		0x00ff0000,
		0x00ff00ff,
		0x00ffff00,
		0x00ffffff,
		0xff000000,
		0xff0000ff,
		0xff00ff00,
		0xff00ffff,
		0xffff0000,
		0xffff00ff,
		0xffffff00,
		0xffffffff
	};
#if 0
	dst +=7;

	/* We tried to make this as optimized as 
	 * possible */
	for(i=0;i<IMAGESIZE/32;i++){
		val = *src;

		for(j=0;j<8;j++){
			*dst = vals[val & 0xf];
			val >>=4;
			dst--;
		}

		dst+=16;
		src++;
	}
#else
	for(i=0;i<IMAGESIZE/32;i++){
		val = *src;
		if(val) {

			dst[7] = vals[val & 0xf];
			val >>=4;
			dst[6] = vals[val & 0xf];
			val >>=4;
			dst[5] = vals[val & 0xf];
			val >>=4;
			dst[4] = vals[val & 0xf];
			val >>=4;
			dst[3] = vals[val & 0xf];
			val >>=4;
			dst[2] = vals[val & 0xf];
			val >>=4;
			dst[1] = vals[val & 0xf];
			val >>=4;
			dst[0] = vals[val & 0xf];
		} else {
			dst[0] = dst[1] = dst[2] = dst[3] = 0;
			dst[4] = dst[5] = dst[6] = dst[7] = 0;
		}
		dst+=8;
		src++;
	}
#endif
}


void smallcircle(int x,int y,volatile unsigned int *img,int draw)
{
	volatile unsigned int *startcircle;
	unsigned int startx;
	unsigned int starty;
	unsigned int shiftcount;

	unsigned int leftpart;
	unsigned int rightpart;
	int i;

	static unsigned int smallcircle[] = {
		0x00010000,
		0x000FE000,
		0x003FF800,
		0x007FFC00,
		0x007FFC00,
		0x00FFFE00,
		0x00FFFE00,
		0x00FFFE00,
		0x01FFFF00,
		0x00FFFE00,
		0x00FFFE00,
		0x00FFFE00,
		0x007FFC00,
		0x007FFC00,
		0x003FF800,
		0x000FE000,
		0x00010000
	};

	starty = y-8;
	startx = x-16;

	startcircle = img + starty * (640/32) + startx/32;

	shiftcount = startx % 32;
	if(!draw){
		for(i=0;i<17;i++){
			leftpart = smallcircle[i] >> shiftcount;

			if(shiftcount){
				rightpart = smallcircle[i] << (32 - shiftcount);
			}else{
				rightpart = 0; /* Can't shift 32 steps in C */
			}

			*startcircle &= ~leftpart;
			*(startcircle+1) &= ~rightpart;
			startcircle += (640/32);
		}
	}else{
		for(i=0;i<17;i++){
			leftpart = smallcircle[i] >> shiftcount;

			if(shiftcount){
				rightpart = smallcircle[i] << (32 - shiftcount);
			}else{
				rightpart = 0; /* Can't shift 32 steps in C */
			}

			*startcircle |= leftpart;
			*(startcircle+1) |= rightpart;
			startcircle += (640/32);
		}
	}
	
}


void largecircle(int x,int y,volatile unsigned int *img,int draw)
{
	volatile unsigned int *startcircle;
	unsigned int startx;
	unsigned int starty;
	unsigned int shiftcount;

	unsigned int leftpart;
	unsigned int rightpart;
	int i;

	static unsigned int largecircle[] = {
		0x00010000,
		0x003FF800,
		0x00FFFE00,
		0x01FFFF00,
		0x07FFFFC0,
		0x0FFFFFE0,
		0x0FFFFFE0,
		0x1FFFFFF0,
		0x3FFFFFF8,
		0x3FFFFFF8,
		0x7FFFFFFC,
		0x7FFFFFFC,
		0x7FFFFFFC,
		0x7FFFFFFC,
		0x7FFFFFFC,
		0xFFFFFFFE,
		0x7FFFFFFC,
		0x7FFFFFFC,
		0x7FFFFFFC,
		0x7FFFFFFC,
		0x7FFFFFFC,
		0x3FFFFFF8,
		0x3FFFFFF8,
		0x1FFFFFF0,
		0x0FFFFFE0,
		0x0FFFFFE0,
		0x07FFFFC0,
		0x01FFFF00,
		0x00FFFE00,
		0x003FF800,
		0x00010000
	};

	starty = y-15;
	startx = x-16;

	startcircle = img + starty * (640/32) + startx/32;
	
	shiftcount = startx % 32;

	if(!draw){
		for(i=0;i<31;i++){
			leftpart = largecircle[i] >> shiftcount;

			if(shiftcount){
				rightpart = largecircle[i] << (32 - shiftcount);
			}else{
				rightpart = 0;
			}

			*startcircle &= ~leftpart;
			*(startcircle+1) &= ~rightpart;
			startcircle += (640/32);
		}

	}else{
		for(i=0;i<31;i++){
			leftpart = largecircle[i] >> shiftcount;

			if(shiftcount){
				rightpart = largecircle[i] << (32 - shiftcount);
			}else{
				rightpart = 0;
			}

			*startcircle |= leftpart;
			*(startcircle+1) |= rightpart;
			startcircle += (640/32);
		}
	}
	
}
