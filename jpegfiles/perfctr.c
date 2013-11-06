#include <stdio.h>
#include "perfctr.h"


/* Global variables for clock cycles spent on various parts of the
 * code. */

unsigned int perf_mainprogram;
unsigned int perf_init;
unsigned int perf_dct;
unsigned int perf_copy;
unsigned int perf_dctkernel;
unsigned int perf_huff;
unsigned int perf_emitbits;

void print_performance(void){
  /* Print performance statistics in a tree like view */
  printf("Performance statistics:\n");
  printf("Cycles spent in main program:             %8u\n", perf_mainprogram);
  printf("+-- Cycles spent in init:                 %8u\n", perf_init);
  printf("+-- Cycles spent in encode_image:         %8u\n", perf_mainprogram - perf_init);
  printf("    +-- Cycles spent in forward_DCT:      %8u\n", perf_dct);
  printf("    |   +-- Cycles spent in copy:         %8u\n", perf_copy);
  printf("    |   +-- Cycles spent in DCT kernel:   %8u\n", perf_dctkernel);
  printf("    |   +-- Cycles spent in quantization: %8u\n", perf_dct - perf_copy - perf_dctkernel);
  printf("    +-- Cycles spent in Huffman encoding: %8u\n", perf_huff);
  printf("        +-- Cycles spent in emit_bits:    %8u\n", perf_emitbits);
}
