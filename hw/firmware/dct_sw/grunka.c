#include "printf.h"
#include <common.h>
#include <time.h>

int main() {
    
    int mem[192];
    int transpose[8][8];
	  int d = 0x81828384;
	  int result, i, j, k;
	  int tmp1, tmp2, tmp3;
    
    for (i=0; i<48; i++) {
		    mem[i] = d;
		    d += 0x04040404;
    }

    REG32(0x96001800) = mem;
    REG32(0x96001804) = 24;
    REG32(0x96001808) = 2;
    REG32(0x9600180c) = 0;
    
//    printf("Starting the Grunka...\n");
   /* result = REG32(0x96001800);
    printf(" %08X, ", result);
    result = REG32(0x96001804);
    printf(" %08X, ", result);
    result = REG32(0x96001808);
    printf(" %08X, ", result);
    result = REG32(0x9600180c);
    printf(" %08X\n", result);
    
    int i1, i2, i3;*/
    sleep(1);
    for (k=0; k < 2; k++) {
      printf("run %d\n", k);
      REG32(0x96001810) = 1; // start
      
      
      /*
      printf("Waiting until finished\n");
      result = REG32(0x96001810);
      printf("%08X\n", result);
      */
      int csr = REG32(0x96001810);
      //while (csr != 128) { csr = REG32(0x96001000); printf("%08X\n", csr); }
      //printf("done\n");
      //sleep(2);
      while ((csr & 0x00000002 ) != 0x00000002) { 
          csr = REG32(0x96001810);
          tmp1 = REG32(0x96001800);
          tmp2 = REG32(0x96001804);
          tmp3 = REG32(0x96001808);
          printf("csr: %08X, ptr: %08X, pitch: %08X, width: %08X\n", csr, tmp1, tmp2, tmp3);
          //sleep(1);
      }

      printf("Begin reading result\n");

      int trans = 0;
      for (j=0; j<8; j++) {
          trans = 0;
          for (i=0; i<4; i++) {
              result = REG32(0x96000800 + 4*i + j*16);
              transpose[trans++][j] = result >> 16;
              transpose[trans++][j] = (result << 16) >> 16;
          }
      }
      
      printf("-----------inmem---------\n");
    	for (i=0; i<16; i++) {
		      result = REG32(0x96000000 + 4*i);
		      printf("%08X = %08X\n", 0x96000000 + 4*i, result);
      }
      
      printf("-----------transposed---------\n");
      for (j=0; j<8; j++) {
          for (i=0; i<8; i++) {
              printf("%5d", transpose[j][i]);
              
	        }
	        printf("\n");
      }

      REG32(0x96001810) = 2;
    }
    
    /*
	//int d = 0x81828384;
	int d = 0x807f807f;
	int result, i, j;
    int pc[8][8];
    printf("starting, trying to write\n");
	for (i=0; i<16; i++) {
		if ((i % 4) < 2)
			d = 0x807f807f;
		else
			d = 0x7f807f80;

		if(i % 2)
			d = 0x80808080;

		REG32(0x96000000 + 4*i) = d;
		// d += 0x04040404;		

    }
	for (i=0; i<16; i++) {
		result = REG32(0x96000000 + 4*i);
		printf("%08X = %08X \n", 0x96000000 + i, result);
    }

    printf("has written to inmem, pressing start\n");
    //REG32(0x96001000) = 0x01000000; //start
    REG32(0x96001000) = 1; //start
    //printf("Waiting... \n");

    int csr = REG32(0x96001000);
    while (csr != 128) { csr = REG32(0x96001000); }
	REG32(0x96001000) = 0;
	//printf("we waited %d\n", k);

    printf("---------- Finished ----------\n");
    int trans = 0;
    for (j=0; j<8; j++) {
        trans = 0;
		for (i=0; i<4; i++) {
			result = REG32(0x96000800 + 4*i + j*16);
			pc[trans++][j] = result >> 16;
			pc[trans++][j] = (result << 16) >> 16;
			
            printf("%5d ", result >> 16);
            printf("%5d ", (result << 16) >>16);
			
		}
	 	printf("\n");
    }

    printf("---------- transposed ----------\n");
    for (j=0; j<8; j++) {
		for (i=0; i<8; i++) {
    		printf("%5d ", pc[j][i]);
    	}
    	printf("\n");
    }

    printf("---------- Finished ----------\n");

	// for (i=0; i<16; i++) {
	// 	result = REG32(0x96000000 + 4*i);
	// 	printf("%08X = %08X \n", 0x96000000 + 4*i, result);
 //    } //*/
    return 0;
}
