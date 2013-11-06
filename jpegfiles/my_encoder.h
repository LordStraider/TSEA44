#ifndef _MY_ENCODER_H
#define _MY_ENCODER_H

#define DCTSIZE		    8	/* The basic DCT block is 8x8 samples */
#define DCTSIZE2	    64	/* DCTSIZE squared; # of elements in a block */

void encode_mcu_huff (short MCU_data[DCTSIZE2]);
void encode_image(void);
void init_huffman (FILE *fp,int width,int height);
void init_encoder(int width,int height,unsigned char *image, FILE *fp);
void init_image(unsigned char *t, unsigned int image_width, unsigned int image_height);
void forward_DCT(short coef_block[]);

#endif
