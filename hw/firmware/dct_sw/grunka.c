#include "printf.h"
#include <common.h>

int main() {
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
 //    }
    return 0;
}
