#ifndef JCHUFF_H
#define JCHUFF_H

#define MEM_ADDR2 0x01010000

/* Derived data constructed for each Huffman table */

/* If no code has been allocated for a symbol S, ehufsi[S] contains 0 */
typedef struct {
  unsigned int ehufco[256];	/* code for each symbol */
  char ehufsi[256];		/* length of code for each symbol */
} c_derived_tbl;

void init_huffman(void);
void encode_mcu_huff(short[]);
void finish_pass_huff (void);

#endif
