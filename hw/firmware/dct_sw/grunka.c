#include "printf.h"
#include <common.h>

int main() {
	int d = 0x81828384;
	int result;
	int i, j;

	for (i=0; i<16; i++) {
		REG32(0x96000000 + 4*i) = d;
		//printf("%8X\n", d);
		d += 0x04040404;
    }

    //printf("Waiting... \n");

    int csr = REG32(0x96001000);
    int k = 0;
    while (csr != 128) { csr = REG32(0x96001000); k++; }
	REG32(0x96001000) = 0;
	printf("we waited %d\n", k);

    printf("---------- Finished ----------\n");

    for (j=0; j<8; j++) {
		for (i=0; i<4; i++) {
			result = REG32(0x96000800 + 4*i + j*16);
			printf("%5d ", result >> 16);
			printf("%5d ", (result << 16) >> 16);
		}
		printf("\n");
    }

    return 0;
}
