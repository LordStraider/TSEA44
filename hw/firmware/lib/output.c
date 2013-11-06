#include "common.h"

int putchar(int c)
{
	UART volatile *pu = (UART *) UART_BASE;
	while (!(pu->lsr & 0x60)); 	/* wait for Tx FIFO empty */
	pu->txrx = c; /* Output the character */

	return 0;
}

void puts(const char *str)
{
	while(*str){
		if(*str == '\n'){
			putchar('\r');
		}
		putchar(*str);
		str++;
	}
}

void led(int x)
{
  unsigned long *pp = (unsigned long *) PAR_BASE;

  *pp = x;
}
