#include "printf.h"
#include <common.h>
#include <time.h>

int main() {
    
    int mem[64];
    int transpose[8][8];
	  int d = 0x81828384;
	  int result, i, j;
    
    for (i=0; i<16; i++) {
		    mem[i] = d;
		    d += 0x04040404;		
    }
    REG32(0x96001800) = mem;
    REG32(0x96001804) = 16;
    REG32(0x96001808) = 1;
    REG32(0x9600180c) = 1;
    printf("Starting the Grunka...\n");
    REG32(0x96001810) = 1;
    
    printf("Waiting until finished\n");

    int csr = REG32(0x96001810);
    while ((csr & 0x00000010 ) != 0x00000010) { 
        csr = REG32(0x96001810); 
        //result = REG32(0x96000000);
        //printf("%08X, %08X\n", (csr & 0x00000010 ), result);
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
		    printf("%08X = %08X should be: %08X\n", 0x96000000 + i, result, mem[i]);
    }
    
    printf("-----------transposed---------\n");
    for (j=0; j<8; j++) {
        for (i=0; i<8; i++) {
            printf("%5d", transpose[j][i]);
	      }
	      printf("\n");
    }

    REG32(0x96001810) = 2;
    
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
