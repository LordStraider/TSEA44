#include <stdio.h>
#include <stdlib.h>

#include "jchuff.h"
#include "my_encoder.h"
#include "perfctr.h"

#define WIDTH 640
#define HEIGHT 480

unsigned char *vgabase = (unsigned char *)  0x98200000;

#define REG32(add) *((volatile unsigned long *)(add))


/* Somewhat ugly code to get only one picture from the camera
 * Need to fix the hardware in the camera for next year to make
 * this easier. */
static void  init_picture(void)
{
  volatile unsigned char *leelabase = (volatile unsigned char *) 0x98000000;

  REG32(leelabase+0x0) = 0x100; /* Enable the camera */

  REG32(0x91000000) = 0x1;
  /* This is very ugly! But the camera controller has no good way to do this */
  if((REG32(leelabase+0x1c) & 0x1ff) == 0) { /* Frame has not started yet */
    REG32(0x91000000) = 0x2;
    while((REG32(leelabase+0x1c) & 0x1ff) == 0); /* Wait for frame to start */
    REG32(0x91000000) = 0x4;
    while((REG32(leelabase+0x1c) & 0x1ff) != 0); /* Wait for frame to finish */
  }else{
    while((REG32(leelabase+0x1c) & 0x1ff) != 0); /* Wait for previous frame to finish */
    REG32(0x91000000) = 0x8;
    while((REG32(leelabase+0x1c) & 0x1ff) == 0); /* Wait for frame to start */
    REG32(0x91000000) = 0x10;
    while((REG32(leelabase+0x1c) & 0x1ff) != 0); /* Wait for frame to finish */
  }
    REG32(0x91000000) = 0x20;

    REG32(leelabase+0x0) = 0x000; /* Disable the camera */
    REG32(0x91000000) = 0xf0;

}


int main(int argc,char **argv)
{
  fprintf(stdout,"Content-type: image/jpeg\n\n");
  
  
  init_picture(); // Capture the image from the camera
  
  init_encoder(WIDTH,HEIGHT,vgabase,stdout); // Init the encoder
  
#ifdef HW_DMA
  /* REG32(...) = ... */
#endif
  
  
  encode_image();
  finish_pass_huff();  // flush buffer to file

  return 0;
}
