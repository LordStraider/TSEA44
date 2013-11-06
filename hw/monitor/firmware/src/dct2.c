#include "mon2.h"
#include "board.h"
#include "spr_defs.h"
#include "printf.h"

/* Precalculated constants */
#define FIX_0_298631336  ((int)  2446)	/* FIX(0.298631336) */
#define FIX_0_390180644  ((int)  3196)	/* FIX(0.390180644) */
#define FIX_0_541196100  ((int)  4433)	/* FIX(0.541196100) */
#define FIX_0_765366865  ((int)  6270)	/* FIX(0.765366865) */
#define FIX_0_899976223  ((int)  7373)	/* FIX(0.899976223) */
#define FIX_1_175875602  ((int)  9633)	/* FIX(1.175875602) */
#define FIX_1_501321110  ((int)  12299)	/* FIX(1.501321110) */
#define FIX_1_847759065  ((int)  15137)	/* FIX(1.847759065) */
#define FIX_1_961570560  ((int)  16069)	/* FIX(1.961570560) */
#define FIX_2_053119869  ((int)  16819)	/* FIX(2.053119869) */
#define FIX_2_562915447  ((int)  20995)	/* FIX(2.562915447) */
#define FIX_3_072711026  ((int)  25172)	/* FIX(3.072711026) */
#define FIX_C6           ((int)  4433)        /* sqrt(2) * (c6) */
#define FIX_S6           ((int)  10703)       /* sqrt(2) * (s6) */


#define MULTIPLY(var,const)  (((short) (var)) * ((short) (const)))
#define DESCALE(x,n)  ((x) >> (n)) /* no rounding in our HW */
#define CONST_BITS  13

void dct2(int *data, int *tmp);
void dct1(int *a, int *p);

int image[64], tmp[64];

/* Quantization matrix, Matlab notation
Q = [16 11 10 16 24 40 51 61;
     12 12 14 19 26 58 60 55; 
     14 13 16 24 40 57 69 56;
     14 17 22 29 51 87 80 62;
     18 22 37 56 68 109 103 77;
     24 35 55 64 81 104 113 92;
     49 64 78 87 103 121 120 101; 
     72 92 95 98 112 100 103 99];

reciprocals = round(2^15 ./ Q);
*/

static const int reciprocals[] = {2048, 2979, 3277, 2048, 1365, 819, 643, 537,
				  2731, 2731, 2341, 1725, 1260, 565, 546, 596,
				  2341, 2521, 2048, 1365,  819, 575, 475, 585,
				  2341, 1928, 1489, 1130,  643, 377, 410, 529,
				  1820, 1489,  886,  585,  482, 301, 318, 426,
				  1365,  936,  596,  512,  405, 315, 290, 356,
				  669,   512,  420,  377,  318, 271, 273, 324,
				  455,   356,  345,  334,  293, 328, 318, 331};

void dct_sw(void)
{
  int i, j, rval, temp, rnd;

  printf("\na=\n");
  for (i=0; i<8; i++) {
    for (j=0; j<8; j++)
      printf("%5d ", image[j+8*i]=j+8*i+1);
    printf("\n");
  }

  // Transform
  dct2(image, tmp);

  image[0] -= 8192;

  printf("\n8xDCT[a-128]=\n");
  for (i=0; i<8; i++) {
    for (j=0; j<8; j++)
      printf("%5d ", image[j+8*i]);
    printf("\n");
  }

  // Quantization
  printf("\nRND(8xDCT[a-128]/(8xQx1/2))=\n");
  for (i=0; i<8; i++) {
    for (j=0; j<8; j++) { 
      temp = image[j+8*i];
      rval = reciprocals[j+8*i];

      temp = temp*rval;
      rnd = (temp & 0x10000) && ((temp > 0) || (temp&0x1ffff) != 0x10000);
      temp = temp >> 17; 
      temp += rnd;

      printf("%5d ", temp);

    }
    printf("\n");
  }

}

void dct2(int *data, int *tmp)
{

  dct1(data, tmp);
  dct1(tmp, data);
}

/*
 * Perform the forward DCT on one block of samples.
 */

void dct1(int *a, int *b)
{
  int tmp0, tmp1, tmp2, tmp3, tmp4, tmp5, tmp6, tmp7;
  int tmp10, tmp11, tmp12, tmp13;
  int z1, z2, z3, z4, z5;
  int *pa, *pb;
  int row;
    
  /* process rows. */
  /* Note results are scaled up by sqrt(8) compared to a true DCT; */

  pa = a;
  pb = b;

  for (row = 7; row >= 0; row--) {
    tmp0 = pa[0] + pa[7];
    tmp7 = pa[0] - pa[7];
    tmp1 = pa[1] + pa[6];
    tmp6 = pa[1] - pa[6];
    tmp2 = pa[2] + pa[5];
    tmp5 = pa[2] - pa[5];
    tmp3 = pa[3] + pa[4];
    tmp4 = pa[3] - pa[4];
    
    /* Even part */
    
    tmp10 = tmp0 + tmp3;
    tmp13 = tmp0 - tmp3;
    tmp11 = tmp1 + tmp2;
    tmp12 = tmp1 - tmp2;
    
    pb[0] = tmp10 + tmp11;	/* 0 */
    pb[32] = tmp10 - tmp11;	/* 4 */
    pb[16] = DESCALE(MULTIPLY(tmp12,FIX_C6) + MULTIPLY(tmp13,FIX_S6), CONST_BITS); /* 2 */
    pb[48] = DESCALE(-MULTIPLY(tmp12,FIX_S6) + MULTIPLY(tmp13,FIX_C6), CONST_BITS); /* 6 */

    /* Odd part */
    
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
    
    pb[56] = DESCALE(tmp4 + z1 + z3, CONST_BITS); /* 7 */
    pb[40] = DESCALE(tmp5 + z2 + z4, CONST_BITS); /* 5 */
    pb[24] = DESCALE(tmp6 + z2 + z3, CONST_BITS); /* 3 */
    pb[8] = DESCALE(tmp7 + z1 + z4, CONST_BITS);  /* 1 */
    
    pa += 8;		/* advance in pointer to next row */
    pb++;		/* advance out pointer to next column */
  }
}

/* Correct result of the transform and quantization (transponated) */ 
const unsigned short correcttransform[64] = {
  0xffa0, 0xffe8, 0x0000, 0xfffe, 0x0000, 0x0000, 0x0000, 0x0000,
  0xfffd, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
  0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
  0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
  0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
  0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
  0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
  0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000 };

/* For a first try you might want to reduce the width and height since
 * you have to simulate for quite a long time with 15x13 macroblocks */ 
#define WIDTH 2
#define HEIGHT 3
#define PITCH (WIDTH*8) 
#define DMA_ADDR 0x01000000

void dma_dct_hw(void) {
  unsigned int blockx, blocky;
  unsigned int x,y;
  int i, j;
  volatile int sum;
  unsigned char byte;

  volatile unsigned char *dma_address = (volatile unsigned char *) DMA_ADDR; /* Somewhere in the SDRAM */


  // A test image
  j = 0;
  for(blocky = 0; blocky < HEIGHT; blocky++){
    for(blockx = 0; blockx < WIDTH; blockx++){
      i=1;
      for(y = 0; y < 8; y++){
	for(x = 0; x < 8; x++){
	  dma_address[blockx*8+x+(blocky*8+y)*PITCH] = i++;
	}
      }
    }
  }

  REG32(PAR_BASE_ADDR) = 0xa0; /* We are writing status information to the parport so that it is
				* easy to see what we are doing in the wave window */

  /* Here you must initialize the DMA engine (Hint: DMA_ADDR, PITCH, WIDTH - 1, HEIGHT - 1) */


  REG32(PAR_BASE_ADDR) = 0xa1;

  j = 0;
  for(blocky = 0; blocky < HEIGHT; blocky++){
    short temp;
    for(blockx = 0; blockx < WIDTH; blockx++){

      REG32(PAR_BASE_ADDR) = 0xa5;

      /* Wait here for the DMA accelerator to finish one block */

      /* Wait for DCTDMA to fill the DCT accelerator */

      REG32(PAR_BASE_ADDR) = 0xa6;

      temp = REG16(JPG_BASE_ADDR + 0x800);
      REG32(PAR_BASE_ADDR) = 0xb1;

      for(i=0; i < 64; i++) {
	if(REG16(JPG_BASE_ADDR + 0x800 + i*2) != correcttransform[i]){
	  REG32(PAR_BASE_ADDR) = REG16(JPG_BASE_ADDR + 0x800 + i*2);
	  while(1){
	    REG32(PAR_BASE_ADDR) = 0xff; // We did not get the correct result, crash here so the user knows this
	  }
	}
      }

      /* Here you must tell the DMA accelerator to continue with the next block */
    }
  }

  REG32(PAR_BASE_ADDR) = 0xaf; /* All is well */
  printf("DCT passed\n");
}

