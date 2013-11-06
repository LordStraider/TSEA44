#include "uart.h"
#include "board.h"
#include "spr_defs.h"

#include "mon2.h"
#include "uartfun.h"

/* Print one character to UART */
void putch(int c)
{
    UART volatile *pu = (UART *) UART_BASE;

    while (!(pu->lsr & 0x60)); /* wait for Tx FIFO empty */
    pu->txrx = c; /* Output the character */

    if (c == NEWLINE) {
      while (!(pu->lsr & 0x60)); 
      pu->txrx = RETURN; 

    }
}

/* read char from UART */
int readch(void)
{
    UART volatile *pu = (UART *) UART_BASE;
    int c;

    while (!(pu->lsr & 0x1)); /* wait for char in Rx FIFO */

    c = (int) pu->txrx;

    /* Restart monitor if ctrl c is pressed */
    if(c == CTRL_C) {
	reset();
    }
    return(c);
}

/* UART startup */
void uart_init(void)
{
    UART volatile *pu = (UART *) UART_BASE;

    // hardcoded at reset. Olle
    // uart/uart_regs.v
    // pu->lcr = 0x83; 	/* 8 bits, 1 stop bit, no parity */
    // pu->ier = 0;		/* write divisor latches */
    // pu->txrx = 14;		/* 115200 */
    // pu->lcr = 0x3;		/* access regs again */
}

