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
  
  printf("Preparing to encode\n");

  drawimage(); // Create the image we are going to encode 
  
  printf("Init encoder\n");

  init_encoder(WIDTH,HEIGHT,theimage,fp); // Init the encoder
  
  printf("Perf init\n");

  perf_init += gettimer() - startcycle;
  
  printf("Perf init done\n");

#ifdef HW_DMA
    printf("Initializing DMA...");

    /*REG32(0x96001800) = theimage;
    REG32(0x96001804) = WIDTH;
    REG32(0x96001808) = (WIDTH / DCTSIZE) - 1;
    REG32(0x9600180c) = (HEIGHT / DCTSIZE) - 1;*/
  
    printf("done\n");
#endif

  //printf("Encoding stuffz\n");
  
  encode_image();
  
  perf_mainprogram += gettimer() - startcycle;

  finish_pass_huff();  // write to file
  fclose(fp);

  print_performance(); // Print performance data 

  return 0;
}
