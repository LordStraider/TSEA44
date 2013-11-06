
#include "spr_defs.h"
#include "common.h"

/* read char from UART */
int readch(void)
{
	UART volatile *pu = (UART *) UART_BASE;
	int c;

	while (!(pu->lsr & 0x1)); 	/* wait for char in Rx FIFO */

	c = (int) pu->txrx;

	return(c);
}

int availch(void)
{
	UART volatile *pu = (UART *) UART_BASE;

	return pu->lsr & 0x1;
}

#define BACKSPACE 8
/* Read one line from the serial port */
void readline(unsigned char *buf,int len)
{
	int index;
	int c;

	index = 0;
	buf[index] = 0;

	while(1){
		c = (int) readch();
		if (c == BACKSPACE) {

			if(index == 0){
				/* At start of line, ignore */
				printf("\007");
			}else{
				printf("\010 \010");
				index--;
				buf[index] = 0; /* NUL terminate the string */
			}

		}else if(c == '\r'){
			/* Newline, print the newline character and return */
			printf("\n");
			return;
		}else{
			if(index <= len){
				putchar(c);
				buf[index] = c;
				index = index + 1;
				buf[index] = 0; /* NUL terminate the string */
			}else{
				printf("\007");
			}
      
		}

	}

}
