#include "jpegtest.h"
#include "jchuff.h"
#include "jdct.h"
#include "mon2.h"
#include "board.h"
#include "printf.h"

//#ifdef HW_INST
//#include "setbitinclude.h"
//#endif


/*
 * jpeg_natural_order[i] is the natural-order position of the i'th element
 * of zigzag order.
 *
 * When reading corrupted data, the Huffman decoders could attempt
 * to reference an entry beyond the end of this array (if the decoded
 * zero run length reaches past the end of the block).  To prevent
 * wild stores without adding an inner-loop test, we put some extra
 * "63"s after the real entries.  This will cause the extra coefficient
 * to be stored in location 63 of the block, not somewhere random.
 * The worst case would be a run-length of 15, which means we need 16
 * fake entries.
 */

const int jpeg_natural_orders[DCTSIZE2+16] = {
  0,  1,  8, 16,  9,  2,  3, 10,
  17, 24, 32, 25, 18, 11,  4,  5,
  12, 19, 26, 33, 40, 48, 41, 34,
  27, 20, 13,  6,  7, 14, 21, 28,
  35, 42, 49, 56, 57, 50, 43, 36,
  29, 22, 15, 23, 30, 37, 44, 51,
  58, 59, 52, 45, 38, 31, 39, 46,
  53, 60, 61, 54, 47, 55, 62, 63,
  63, 63, 63, 63, 63, 63, 63, 63, /* extra entries for safety in decoder */
  63, 63, 63, 63, 63, 63, 63, 63
};


const unsigned char header[] = {
  0xff,0xd8,0xff,0xe0,0x00,0x10,0x4a,0x46,0x49,0x46,0x00,0x01,0x01,0x00,0x00,0x01,
  0x00,0x01,0x00,0x00,0xff,0xdb,0x00,0x43,0x00,0x08,0x06,0x06,0x07,0x06,0x05,0x08,
  0x07,0x07,0x07,0x09,0x09,0x08,0x0a,0x0c,0x14,0x0d,0x0c,0x0b,0x0b,0x0c,0x19,0x12,
  0x13,0x0f,0x14,0x1d,0x1a,0x1f,0x1e,0x1d,0x1a,0x1c,0x1c,0x20,0x24,0x2e,0x27,0x20,
  0x22,0x2c,0x23,0x1c,0x1c,0x28,0x37,0x29,0x2c,0x30,0x31,0x34,0x34,0x34,0x1f,0x27,
  0x39,0x3d,0x38,0x32,0x3c,0x2e,0x33,0x34,0x32,0xff,0xc0,0x00,0x0b,0x08,
  WHI,WLO,//height
  HHI,HLO,//width
  0x01,0x01,0x11,0x00,0xff,0xc4,0x00,0x1f,0x00,0x00,0x01,0x05,0x01,0x01,
  0x01,0x01,0x01,0x01,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x01,0x02,0x03,0x04,
  0x05,0x06,0x07,0x08,0x09,0x0a,0x0b,0xff,0xc4,0x00,0xb5,0x10,0x00,0x02,0x01,0x03,
  0x03,0x02,0x04,0x03,0x05,0x05,0x04,0x04,0x00,0x00,0x01,0x7d,0x01,0x02,0x03,0x00,
  0x04,0x11,0x05,0x12,0x21,0x31,0x41,0x06,0x13,0x51,0x61,0x07,0x22,0x71,0x14,0x32,
  0x81,0x91,0xa1,0x08,0x23,0x42,0xb1,0xc1,0x15,0x52,0xd1,0xf0,0x24,0x33,0x62,0x72,
  0x82,0x09,0x0a,0x16,0x17,0x18,0x19,0x1a,0x25,0x26,0x27,0x28,0x29,0x2a,0x34,0x35,
  0x36,0x37,0x38,0x39,0x3a,0x43,0x44,0x45,0x46,0x47,0x48,0x49,0x4a,0x53,0x54,0x55,
  0x56,0x57,0x58,0x59,0x5a,0x63,0x64,0x65,0x66,0x67,0x68,0x69,0x6a,0x73,0x74,0x75,
  0x76,0x77,0x78,0x79,0x7a,0x83,0x84,0x85,0x86,0x87,0x88,0x89,0x8a,0x92,0x93,0x94,
  0x95,0x96,0x97,0x98,0x99,0x9a,0xa2,0xa3,0xa4,0xa5,0xa6,0xa7,0xa8,0xa9,0xaa,0xb2,
  0xb3,0xb4,0xb5,0xb6,0xb7,0xb8,0xb9,0xba,0xc2,0xc3,0xc4,0xc5,0xc6,0xc7,0xc8,0xc9,
  0xca,0xd2,0xd3,0xd4,0xd5,0xd6,0xd7,0xd8,0xd9,0xda,0xe1,0xe2,0xe3,0xe4,0xe5,0xe6,
  0xe7,0xe8,0xe9,0xea,0xf1,0xf2,0xf3,0xf4,0xf5,0xf6,0xf7,0xf8,0xf9,0xfa,0xff,0xda,
  0x00,0x08,0x01,0x01,0x00,0x00,0x3f,0x00
};

const unsigned char correct_result[] = {
  0x4f,0xf5,0x3f,0xf4,0xcb,0xcb,0xff,0x00,0x80,0x6c,0xdb,0xff,0x00,0x7e,0xf6,0xed,
  0xf2,0x7f,0xe9,0x9e,0xdf,0x27,0xfe,0x58,0xf9,0x3f,0xf1,0x2e,0x3f,0xe4,0x0f,0xff,
  0x00,0x52,0xe7,0xf6,0x07,0xfd,0xbd,0xff,0x00,0xc2,0x2b,0xe7,0xfe,0x7f,0x6d,0xfb, 
  0x4e,0x7d,0xfc,0xad,0xdd,0xb1,0x47,0xfc,0x9b,0x9f,0xfd,0x4c,0x7f,0xdb,0xff,0x00, 
  0xf6,0xe9,0xe4,0x79,0x1f,0xf7,0xf3,0x76,0xef,0x3b,0xdb,0x1b,0x7b,0xe7,0x8f,0x00, 
  0xaf,0xff,0xd9 
};

/* The buffer and relevant info
 */
static unsigned char *buffer;
// static unsigned char buffer[2048]; // The buffer containing the info that should be written to file.

static unsigned int old_put_buffer; // Saved bits waiting to be written to buffer[]
static unsigned int new_put_buffer; // New bits to be written to buffer[]
static unsigned int next_buffer; // The position of the next char in buffer[]
static unsigned int current_buffer_bit; // Number of bits currently in old_put_buffer

/* Encoding parameters */
static int last_dc_val; // DC value of the last MCU

const c_derived_tbl actbl =
  { // code for each symbol
    {10, 0, 1, 4, 11, 26, 120, 248, 1014, 65410, 65411, 0, 0, 0, 0, 0, 0, 
     12, 27, 121, 502, 2038, 65412, 65413, 65414, 65415, 65416, 0, 0, 0, 0, 0, 0, 
     28, 249, 1015, 4084, 65417, 65418, 65419, 65420, 65421, 65422, 0, 0, 0, 0, 0, 0, 
     58, 503, 4085, 65423, 65424, 65425, 65426, 65427, 65428, 65429, 0, 0, 0, 0, 0, 0, 
     59, 1016, 65430, 65431, 65432, 65433, 65434, 65435, 65436, 65437, 0, 0, 0, 0, 0, 0, 
     122, 2039, 65438, 65439, 65440, 65441, 65442, 65443, 65444, 65445, 0, 0, 0, 0, 0, 0, 
     123, 4086, 65446, 65447, 65448, 65449, 65450, 65451, 65452, 65453, 0, 0, 0, 0, 0, 0, 
     250, 4087, 65454, 65455, 65456, 65457, 65458, 65459, 65460, 65461, 0, 0, 0, 0, 0, 0, 
     504, 32704, 65462, 65463, 65464, 65465, 65466, 65467, 65468, 65469, 0, 0, 0, 0, 0, 0, 
     505, 65470, 65471, 65472, 65473, 65474, 65475, 65476, 65477, 65478, 0, 0, 0, 0, 0, 0, 
     506, 65479, 65480, 65481, 65482, 65483, 65484, 65485, 65486, 65487, 0, 0, 0, 0, 0, 0, 
     1017, 65488, 65489, 65490, 65491, 65492, 65493, 65494, 65495, 65496, 0, 0, 0, 0, 0, 0, 
     1018, 65497, 65498, 65499, 65500, 65501, 65502, 65503, 65504, 65505, 0, 0, 0, 0, 0, 0, 
     2040, 65506, 65507, 65508, 65509, 65510, 65511, 65512, 65513, 65514, 0, 0, 0, 0, 0, 0, 
     65515, 65516, 65517, 65518, 65519, 65520, 65521, 65522, 65523, 65524, 0, 0, 0, 0, 0, 
     2041, 65525, 65526, 65527, 65528, 65529, 65530, 65531, 65532, 65533, 65534, 0, 0, 0, 0, 0},
    // length of code for each symbol
    {4, 2, 2, 3, 4, 5, 7, 8, 10, 16, 16, 0, 0, 0, 0, 0, 0, 
     4, 5, 7, 9, 11, 16, 16, 16, 16, 16, 0, 0, 0, 0, 0, 0, 
     5, 8, 10, 12, 16, 16, 16, 16, 16, 16, 0, 0, 0, 0, 0, 0, 
     6, 9, 12, 16, 16, 16, 16, 16, 16, 16, 0, 0, 0, 0, 0, 0, 
     6, 10, 16, 16, 16, 16, 16, 16, 16, 16, 0, 0, 0, 0, 0, 0, 
     7, 11, 16, 16, 16, 16, 16, 16, 16, 16, 0, 0, 0, 0, 0, 0, 
     7, 12, 16, 16, 16, 16, 16, 16, 16, 16, 0, 0, 0, 0, 0, 0, 
     8, 12, 16, 16, 16, 16, 16, 16, 16, 16, 0, 0, 0, 0, 0, 0, 
     9, 15, 16, 16, 16, 16, 16, 16, 16, 16, 0, 0, 0, 0, 0, 0, 
     9, 16, 16, 16, 16, 16, 16, 16, 16, 16, 0, 0, 0, 0, 0, 0, 
     9, 16, 16, 16, 16, 16, 16, 16, 16, 16, 0, 0, 0, 0, 0, 0, 
     10, 16, 16, 16, 16, 16, 16, 16, 16, 16, 0, 0, 0, 0, 0, 0, 
     10, 16, 16, 16, 16, 16, 16, 16, 16, 16, 0, 0, 0, 0, 0, 0, 
     11, 16, 16, 16, 16, 16, 16, 16, 16, 16, 0, 0, 0, 0, 0, 0, 
     16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 0, 0, 0, 0, 0, 
     11, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 0, 0, 0, 0, 0}
  };

const c_derived_tbl dctbl =
  {
    // code for each symbol
    {0, 2, 3, 4, 5, 6, 14, 30, 62, 126, 254, 510, 0, 0, 0, 0, 
     0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
     0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
     0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
     0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
     0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
     0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
     0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
     0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
     0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
     0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
     0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
     0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
     0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
     0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
     0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
    // length of code for each symbol
    {2, 3, 3, 3, 3, 3, 4, 5, 6, 7, 8, 9, 0, 0, 0, 0, 
     0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
     0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
     0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
     0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
     0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
     0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
     0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
     0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
     0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
     0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
     0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
     0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
     0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
     0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
     0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
  };


/* Forward declarations */
void encode_mcu_huff (short MCU_data[DCTSIZE2]);
static void write_header(void);
void finish_pass_huff(void);

// Our own initilize
void init_huffman (void)
{
  buffer = (unsigned char *) MEM_ADDR2;
  new_put_buffer = 0;
  old_put_buffer = 0;
  current_buffer_bit = 0;

  write_header(); 
#ifdef HW_INST
   /* Initialize the vlx unit (Phase 1)*/
#endif
}
  

static void write_header (void)
{

  // Creates a hardcoded header in buffer[] that is later written to file.
  memcpy(buffer, header, sizeof(header));
  next_buffer = sizeof(header);
}


static void write_data(void)
{
  // Writes the buffer to the file given to jpegtest.c
  int i;
  unsigned char *pb = buffer;
  /*
  printf("\nHeader:\n");
  for (i=0; i<sizeof(header); i++) {
    printf("%2x ", *pb++);
    if (i%16 == 15)
      printf("\n");
  }
  printf("\n");
  */
  pb += sizeof(header);
  printf("\nBlocks:\n");
  for (i=0; i<next_buffer-sizeof(header); i++) {
    printf("%02x ", *pb++);
    if (i%16 == 15)
      printf("\n");
  }
  printf("\n");
}

/* Outputting bits to the buffer */

/* Only the right 24 bits of put_buffer are used; the valid bits are
 * left-justified in this part.  At most 16 bits can be passed to emit_bits
 * in one call, and we never retain more than 7 bits in put_buffer
 * between calls, so 24 bits are sufficient.
 */
// Här skriver vi ut bitar till minnesbuffern!

static void emit_bits (unsigned int code, int size)
{
#ifdef HW_INST
/* Emit bits using the vlx unit (Phase 2)*/   
#else
  new_put_buffer = (int) code;
   
  // Add new bits to old bits. If at least 8 bits then write a char to buffer, save the rest until we get more bits.
   
  new_put_buffer &= (1<<size) - 1; /* mask off any extra bits in code */
   
  current_buffer_bit += size;		/* new number of bits in buffer */
   
  new_put_buffer = new_put_buffer << (24 - current_buffer_bit); /* align incoming bits */
   
  new_put_buffer = new_put_buffer | old_put_buffer; /* and merge with old buffer contents */

  while (current_buffer_bit >= 8) {
    int c = ((new_put_buffer >> 16) & 0xFF); // Mask out the 8 bits we want
    
    buffer[next_buffer] = (char) c;
    next_buffer++;
    if (c == 0xFF) { // 0xFF is a reserved code for tags, if we get image date with an FF value it has to be followed by 0x00.
      {
	buffer[next_buffer] = 0x00;
	next_buffer++;
      }
    }
    new_put_buffer <<= 8;
    current_buffer_bit -= 8;
  }
  old_put_buffer = new_put_buffer; /* update state variables */
#endif
}


static void flush_bits (void)
{
#ifdef HW_INST
  /* Flush bits remaining in the vlx buffer (Phase 3) */
#else
  emit_bits(0x7F, 7);  /* fill any partial byte with ones */
  old_put_buffer = 0; /* and reset bit-buffer to empty */
#endif
}


/* Encode a single block's worth of coefficients */

/*
 * Encode and output one MCU's worth of Huffman-compressed coefficients.
 */

void encode_mcu_huff (short MCU_data[DCTSIZE2])
{
  int ci = 0;

  //**************************************************************
  /* Encode the MCU data blocks */

  register int temp, temp2;
  register int nbits;
  register int k, r, i;

  /* Encode the DC coefficient difference per section F.1.2.1 */
  
  temp = temp2 = MCU_data[0] - last_dc_val;
  if (temp < 0) {
    temp = -temp;		/* temp is abs value of input */
    /* For a negative input, want temp2 = bitwise complement of abs(input) */
    /* This code assumes we are on a two's complement machine */
    temp2--;
  }
  
  /* Find the number of bits needed for the magnitude of the coefficient */
  nbits = 0;
  while (temp) {
    nbits++;
    temp >>= 1;
  }
  /* There is actually an OR1200 instruction that does almost all of
   * the above. However, it does it from the wrong end
   * unfortunately. No one would complain if it was changed to do it
   * from the correct end however... */


  /* Emit the Huffman-coded symbol for the number of bits */
  emit_bits(dctbl.ehufco[nbits], dctbl.ehufsi[nbits]);

  
  /* Emit that number of bits of the value, if positive, */
  /* or the complement of its magnitude, if negative. */
  if (nbits)			/* emit_bits rejects calls with size 0 */
    emit_bits((unsigned int) temp2, nbits);

  /* Encode the AC coefficients per section F.1.2.2 */
  
  r = 0;			/* r = run length of zeros */

  for (k = 1; k < DCTSIZE2; k++) {
    /* The interested tsea02 student might want to take a shot at removing
     * the zigzag addressing and moving it to a place where it could be
     * run without any performance impact... */
    if ((temp = MCU_data[jpeg_natural_orders[k]]) == 0) {
      r++;
    } else {
      /* if run length > 15, must emit special run-length-16 codes (0xF0) */
      while (r > 15) {
	emit_bits(actbl.ehufco[0xF0], actbl.ehufsi[0xF0]);
	r -= 16;
      }

      temp2 = temp;
      if (temp < 0) {
	temp = -temp;		/* temp is abs value of input */
	/* This code assumes we are on a two's complement machine */
	temp2--;
      }
      
      /* Find the number of bits needed for the magnitude of the coefficient */
      nbits = 1;		/* there must be at least one 1 bit */
      while ((temp >>= 1))
	nbits++;

      /* Emit Huffman symbol for run length / number of bits */
      i = (r << 4) + nbits;
      emit_bits(actbl.ehufco[i], actbl.ehufsi[i]);

      /* Emit that number of bits of the value, if positive, */
      /* or the complement of its magnitude, if negative. */
      emit_bits((unsigned int) temp2, nbits);
	      
      r = 0;
    }
  }

  /* If the last coef(s) were zero, emit an end-of-block code */
  if (r > 0)
    emit_bits(actbl.ehufco[0], actbl.ehufsi[0]);
  
  /* Update last_dc_val */
  last_dc_val = MCU_data[0];

  /* Completed MCU, so update state */
}


/*
 * Finish up at the end of a Huffman-compressed scan.
 */

void finish_pass_huff (void)
{
  /* Flush out the last data */
  flush_bits();
   
  /* End of file flag */
  buffer[next_buffer++] = (char) 0xff;
  buffer[next_buffer++] = (char) 0xd9;

  write_data();
}
