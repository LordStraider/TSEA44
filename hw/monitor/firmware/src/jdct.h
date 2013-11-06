extern void jpeg_fdct_islow (int * data);
void init_image(unsigned int image_width, unsigned int image_height);
void forward_DCT(short coef_block[]);

#define DCTSIZE		    8	/* The basic DCT block is 8x8 samples */
#define DCTSIZE2	    64	/* DCTSIZE squared; # of elements in a block */

/* Precalculated constants */
#define CONST_BITS  13

#if CONST_BITS == 13
#define FIX_0_298631336  (  2446)	// 0.298631336 * 8192
#define FIX_0_390180644  (  3196)	// 0.390180644 * 8192
#define FIX_0_541196100  (  4433)	// 0.541196100 * 8192
#define FIX_0_765366865  (  6270)	// 0.765366865 * 8192
#define FIX_0_899976223  (  7373)	// 0.899976223 * 8192
#define FIX_1_175875602  (  9633)	// 1.175875602 * 8192
#define FIX_1_501321110  (  12299)	// 1.501321110 * 8192
#define FIX_1_847759065  (  15137)	// 1.847759065 * 8192
#define FIX_1_961570560  (  16069)	// 1.961570560 * 8192
#define FIX_2_053119869  (  16819)	// 2.053119869 * 8192
#define FIX_2_562915447  (  20995)	// 2.562915447 * 8192
#define FIX_3_072711026  (  25172)	// 3.072711026 * 8192
#define FIX_C6           (  4433)        // sqrt(2) * (c6) * 8192
#define FIX_S6           (  10703)       // sqrt(2) * (s6) * 8192
#else
#error Not implemented
#endif

#define MULTIPLY(var,const)  (((short) (var)) * ((short) (const)))
#define DESCALE(x,n)  ((x) >> (n)) /* no rounding in our HW */





