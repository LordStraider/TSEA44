#include "jchuff.h"
#include "jdct.h"
#include "jpegtest.h"
#include "mon2.h"
#include "board.h"

/* The image we are encoding (loaded by drawimage()) */
// static char theimage[WIDTH*HEIGHT];

const unsigned char chess[] = 
  {0, 255, 0, 255, 0, 255, 0, 255, 0, 0, 255, 255, 0, 0, 255, 255, 0, 0, 0, 0, 255, 255, 255, 255, 0, 0, 0, 0, 0, 0, 0, 0,
   255, 0, 255, 0, 255, 0, 255, 0, 0, 0, 255, 255, 0, 0, 255, 255, 0, 0, 0, 0, 255, 255, 255, 255, 0, 0, 0, 0, 0, 0, 0, 0,
   0, 255, 0, 255, 0, 255, 0, 255, 255, 255, 0, 0, 255, 255, 0, 0, 0, 0, 0, 0, 255, 255, 255, 255, 0, 0, 0, 0, 0, 0, 0, 0,
   255, 0, 255, 0, 255, 0, 255, 0, 255, 255, 0, 0, 255, 255, 0, 0, 0, 0, 0, 0, 255, 255, 255, 255, 0, 0, 0, 0, 0, 0, 0, 0,
   0, 255, 0, 255, 0, 255, 0, 255, 0, 0, 255, 255, 0, 0, 255, 255, 255, 255, 255, 255, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
   255, 0, 255, 0, 255, 0, 255, 0, 0, 0, 255, 255, 0, 0, 255, 255, 255, 255, 255, 255, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
   0, 255, 0, 255, 0, 255, 0, 255, 255, 255, 0, 0, 255, 255, 0, 0, 255, 255, 255, 255, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
   255, 0, 255, 0, 255, 0, 255, 0, 255, 255, 0, 0, 255, 255, 0, 0, 255, 255, 255, 255, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};

void drawimage(void)
{

  /* Draw a default image */
  memcpy(MEM_ADDR, chess, sizeof(chess));
}

void jpegtest(void)
{
  int i;
  short MCU_block[DCTSIZE2];

  drawimage(); // Create the image we are going to encode 

  init_huffman();
  init_image(WIDTH, HEIGHT);

#ifdef HW_DMA
  /* Initialize the DMA */
  //REG32(JPG_BASE_ADDR + ...) = ...
  //   ...
#endif

  for(i = 0; i < MCU_COUNT; i++) {
    REG32(PAR_BASE_ADDR) = i;
    forward_DCT(MCU_block);
    REG32(PAR_BASE_ADDR) = 255;
    encode_mcu_huff(MCU_block);
  }

  finish_pass_huff();

  return 0;
}



