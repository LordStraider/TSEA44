#include "jdct.h"
#include "jpegtest.h"
#include "board.h"
#include "mon2.h"
#include "printf.h"

static const int reciprocals[] = {2048, 2979, 3277, 2048, 1365, 819, 643, 537,
				  2731, 2731, 2341, 1725, 1260, 565, 546, 596,
				  2341, 2521, 2048, 1365,  819, 575, 475, 585,
				  2341, 1928, 1489, 1130,  643, 377, 410, 529,
				  1820, 1489,  886,  585,  482, 301, 318, 426,
				  1365,  936,  596,  512,  405, 315, 290, 356,
				  669,   512,  420,  377,  318, 271, 273, 324,
				  455,   356,  345,  334,  293, 328, 318, 331};


int workspace[DCTSIZE2];	/* work area for FDCT subroutine */

/* Private subobject for this module */
static int row; // The row of the first bit in the current MCU
static int col; // The column of the first bit the current MCU
static unsigned int width; // Image width
static unsigned int height; // Image Height
static unsigned char  *theimage; // The raw image

void init_image(unsigned int image_width, unsigned int image_height)
{
  int i=0,x,y;

  theimage = (unsigned char *) MEM_ADDR;
  row = 0;
  col = 0;
  width = image_width;
  height = image_height;

#endif
}

/*
 * Perform forward DCT on one or more blocks of a component.
 *
 * The input samples are taken from the theimage[] array starting at
 * position row/col, and moving to the right for any additional
 * blocks. The quantized coefficients are returned in coef_block[].
 */

/* This version is used for integer DCT implementations. */
void forward_DCT (short coef_block[DCTSIZE2])
{
  int *pw = workspace;
  unsigned char *pb = theimage + row*width + col;
  int *pim = (int *) pb;
  int *pr=reciprocals;
  short *pc=coef_block;
  int y,x; // The current position within the MCU
  int temp, i,rval;

#ifdef HW_DMA
  #ifdef HW_DCT
  // 1) Wait for DMA_DCT_Q to complete a block
  // 2) Read out data, transpose, convert from 16 to 32 bit
  // 3) Continue with the next block
  #endif
#else
  #ifdef HW_DCT
  // 1) copy values from image to block RAM instead
  // 2) subtract 128 in SW
  // 3) start DCT_Q
  // 4) wait for it to finish
  // 5) read out, transpose, convert from 16 to 32 bit 
  #else
  // 1) Load data into workspace, applying unsigned->signed conversion
  // 2) subtract 128 (JPEG)
  for (y = 0; y < DCTSIZE; y++, pb += (width - DCTSIZE)) {
    for (x = 0; x < DCTSIZE; x++) {
      *pw++ = (int) *pb++ - 128;
    }
  }
  col += DCTSIZE;
  if (col >= width){
    col = 0;
    row += DCTSIZE;
  }
  // 3) Perform the DCT       
  jpeg_fdct_islow (workspace);

  REG32(PAR_BASE_ADDR) = 254;

  // 4) Quantize/descale the coefficients, and store into coef_blocks[]
  int rnd,pos,bits;
  for (i=0, pw=workspace; i < DCTSIZE2; i++) {
    rval = *pr++;
    temp = *pw++;
      
    temp = temp*rval;
      
    rnd = (temp & 0x10000) != 0 ; 
    bits = (temp & 0xffff) != 0; 
    pos = (temp & 0x80000000) == 0; 
    temp = temp >> 17; 
    temp += rnd && (pos || bits); 

    *pc++ = (short) temp;
  }
  #endif
#endif

}


void jpeg_fdct_islow (int * data)
{
  int tmp0, tmp1, tmp2, tmp3, tmp4, tmp5, tmp6, tmp7;
  int tmp10, tmp11, tmp12, tmp13;
  int z1, z2, z3, z4, z5;
  int *dataptr;
  int ctr;
  int i;
  short val;

  /* Pass 1: process rows. */
  /* Note results are scaled up by sqrt(8) compared to a true DCT; */

  dataptr = data;
  for (ctr = DCTSIZE-1; ctr >= 0; ctr--) {
    tmp0 = dataptr[0] + dataptr[7];
    tmp7 = dataptr[0] - dataptr[7];
    tmp1 = dataptr[1] + dataptr[6];
    tmp6 = dataptr[1] - dataptr[6];
    tmp2 = dataptr[2] + dataptr[5];
    tmp5 = dataptr[2] - dataptr[5];
    tmp3 = dataptr[3] + dataptr[4];
    tmp4 = dataptr[3] - dataptr[4];
    
    /* Even part per LL&M figure 1 --- note that published figure is faulty;
     * rotator "sqrt(2)*c1" should be "sqrt(2)*c6".
     */
    
    tmp10 = tmp0 + tmp3;
    tmp13 = tmp0 - tmp3;
    tmp11 = tmp1 + tmp2;
    tmp12 = tmp1 - tmp2;
    
    dataptr[0] = (int) (tmp10 + tmp11);
    dataptr[4] = (int) (tmp10 - tmp11);
    
    dataptr[2] = (int) DESCALE(MULTIPLY(tmp12,FIX_C6) + MULTIPLY(tmp13,FIX_S6), CONST_BITS);
    dataptr[6] = (int) DESCALE(-MULTIPLY(tmp12,FIX_S6) + MULTIPLY(tmp13,FIX_C6), CONST_BITS);

    /* Odd part per figure 8 --- note paper omits factor of sqrt(2).
     * cK represents cos(K*pi/16).
     * i0..i3 in the paper are tmp4..tmp7 here.
     */
    
    z1 = tmp4 + tmp7;
    z2 = tmp5 + tmp6;
    z3 = tmp4 + tmp6;
    z4 = tmp5 + tmp7;
    z5 = MULTIPLY(z3 + z4, FIX_1_175875602); /* sqrt(2) * c3 */
    
    tmp4 = MULTIPLY(tmp4, FIX_0_298631336); /* sqrt(2) * (-c1+c3+c5-c7) */
    tmp5 = MULTIPLY(tmp5, FIX_2_053119869); /* sqrt(2) * ( c1+c3-c5+c7) */
    tmp6 = MULTIPLY(tmp6, FIX_3_072711026); /* sqrt(2) * ( c1+c3+c5-c7) */
    tmp7 = MULTIPLY(tmp7, FIX_1_501321110); /* sqrt(2) * ( c1+c3-c5-c7) */
    z1 = MULTIPLY(z1, - FIX_0_899976223); /* sqrt(2) * (c7-c3) */
    z2 = MULTIPLY(z2, - FIX_2_562915447); /* sqrt(2) * (-c1-c3) */
    z3 = MULTIPLY(z3, - FIX_1_961570560); /* sqrt(2) * (-c3-c5) */
    z4 = MULTIPLY(z4, - FIX_0_390180644); /* sqrt(2) * (c5-c3) */
    
    z3 += z5;
    z4 += z5;
    
    dataptr[7] = (int) DESCALE(tmp4 + z1 + z3, CONST_BITS);
    dataptr[5] = (int) DESCALE(tmp5 + z2 + z4, CONST_BITS);
    dataptr[3] = (int) DESCALE(tmp6 + z2 + z3, CONST_BITS);
    dataptr[1] = (int) DESCALE(tmp7 + z1 + z4, CONST_BITS);
    
    dataptr += DCTSIZE;		/* advance pointer to next row */
  }

  /* Pass 2: process columns.
   * We remove the PASS1_BITS scaling, but leave the results scaled up
   * by an overall factor of 8.
   */

  dataptr = data;
  for (ctr = DCTSIZE-1; ctr >= 0; ctr--) {
    tmp0 = dataptr[DCTSIZE*0] + dataptr[DCTSIZE*7];
    tmp7 = dataptr[DCTSIZE*0] - dataptr[DCTSIZE*7];
    tmp1 = dataptr[DCTSIZE*1] + dataptr[DCTSIZE*6];
    tmp6 = dataptr[DCTSIZE*1] - dataptr[DCTSIZE*6];
    tmp2 = dataptr[DCTSIZE*2] + dataptr[DCTSIZE*5];
    tmp5 = dataptr[DCTSIZE*2] - dataptr[DCTSIZE*5];
    tmp3 = dataptr[DCTSIZE*3] + dataptr[DCTSIZE*4];
    tmp4 = dataptr[DCTSIZE*3] - dataptr[DCTSIZE*4];
    
    /* Even part per LL&M figure 1 --- note that published figure is faulty;
     * rotator "sqrt(2)*c1" should be "sqrt(2)*c6".
     */
    
    tmp10 = tmp0 + tmp3;
    tmp13 = tmp0 - tmp3;
    tmp11 = tmp1 + tmp2;
    tmp12 = tmp1 - tmp2;

    dataptr[DCTSIZE*0] = (int) tmp10+tmp11;
    dataptr[DCTSIZE*4] = (int) tmp10-tmp11;

    dataptr[DCTSIZE*2] = (int) DESCALE(MULTIPLY(tmp12,FIX_C6) + MULTIPLY(tmp13,FIX_S6), CONST_BITS); 
    dataptr[DCTSIZE*6] = (int) DESCALE(-MULTIPLY(tmp12,FIX_S6) + MULTIPLY(tmp13,FIX_C6), CONST_BITS);
    
    /* Odd part per figure 8 --- note paper omits factor of sqrt(2).
     * cK represents cos(K*pi/16).
     * i0..i3 in the paper are tmp4..tmp7 here.
     */
    
    z1 = tmp4 + tmp7;
    z2 = tmp5 + tmp6;
    z3 = tmp4 + tmp6;
    z4 = tmp5 + tmp7;
    z5 = MULTIPLY(z3 + z4, FIX_1_175875602); /* sqrt(2) * c3 */
    
    tmp4 = MULTIPLY(tmp4, FIX_0_298631336); /* sqrt(2) * (-c1+c3+c5-c7) */
    tmp5 = MULTIPLY(tmp5, FIX_2_053119869); /* sqrt(2) * ( c1+c3-c5+c7) */
    tmp6 = MULTIPLY(tmp6, FIX_3_072711026); /* sqrt(2) * ( c1+c3+c5-c7) */
    tmp7 = MULTIPLY(tmp7, FIX_1_501321110); /* sqrt(2) * ( c1+c3-c5-c7) */
    z1 = MULTIPLY(z1, - FIX_0_899976223); /* sqrt(2) * (c7-c3) */
    z2 = MULTIPLY(z2, - FIX_2_562915447); /* sqrt(2) * (-c1-c3) */
    z3 = MULTIPLY(z3, - FIX_1_961570560); /* sqrt(2) * (-c3-c5) */
    z4 = MULTIPLY(z4, - FIX_0_390180644); /* sqrt(2) * (c5-c3) */
    
    z3 += z5;
    z4 += z5;
    
    dataptr[DCTSIZE*7] = (int) DESCALE(tmp4 + z1 + z3, CONST_BITS);
    dataptr[DCTSIZE*5] = (int) DESCALE(tmp5 + z2 + z4, CONST_BITS);
    dataptr[DCTSIZE*3] = (int) DESCALE(tmp6 + z2 + z3, CONST_BITS);
    dataptr[DCTSIZE*1] = (int) DESCALE(tmp7 + z1 + z4, CONST_BITS);
    
    dataptr++;			/* advance pointer to next column */
  }

}

