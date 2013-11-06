#include <stdio.h>
#include <stdlib.h>

#include "jchuff.h"
#include "my_encoder.h"
#include "perfctr.h"

#define WIDTH 400
#define HEIGHT 512

/* The image we are encoding (loaded by drawimage()) */
static char theimage[WIDTH*HEIGHT];

static void drawimage(void)
{
  FILE *fp;
  int i;


  /* Draw a default image */
  for(i=0;i< WIDTH*HEIGHT; i++){
    theimage[i] = i & 0xff;
  }

  for(i=0; i < 255; i++){
    theimage[i+i*WIDTH] = i;
  }


  /* Load the raw testimage from a file */
  fp = fopen("testbild.raw","rb");
  if(!fp){
    fprintf(stderr,"Warning: Could not open testbild.raw, using default test pattern\n");
    return;
  }
  if(fread(theimage,WIDTH*HEIGHT,1,fp) != 1){
    fprintf(stderr,"ERROR: Could not load entire testbild.raw\n");
    exit(0);
  }
  fclose(fp);
}

int main(int argc,char **argv)
{
  unsigned int startcycle;
  FILE *fp;
  
  startcycle = gettimer();

  if(argc != 2){
    fprintf(stderr,"Usage: jpegtest <outfilename>\n");
    exit(1);
  }
        
  fp = fopen(argv[1],"w");
  if(!fp){
    fprintf(stderr,"Could not open output file\n");
    exit(1);
  }

  drawimage(); // Create the image we are going to encode 

  init_encoder(WIDTH,HEIGHT,theimage,fp); // Init the encoder

  perf_init += gettimer() - startcycle;

#ifdef HW_DMA
  /* Initialize the DMA */
  //REG32(JPG_BASE_ADDR + ...) = ...
  //   ...
#endif
  
  encode_image();
  
  perf_mainprogram += gettimer() - startcycle;

  finish_pass_huff();  // write to file
  fclose(fp);

  print_performance(); // Print performance data 

  return 0;
}
