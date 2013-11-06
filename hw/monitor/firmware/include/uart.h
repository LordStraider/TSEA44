#define UART struct uart
UART
{
    unsigned char txrx;		/* 0. transmit(W), receive(R) */
    unsigned char ier;		/* 1. interrupt enable (RW) */
    unsigned char iir;		/* 2. interrupt flags (R), FIFO control(W) */
    unsigned char lcr;		/* 3. line control (RW) */
    unsigned char mcr;		/* 4. modem control (W) */
    unsigned char lsr;		/* 5. line status (R) */
    unsigned char msr;		/* 6. modem status (R) */
};


