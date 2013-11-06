#ifndef _COMMON_H
#define _COMMON_H
#include <stddef.h>

/* Most of these library functions are taken from orpmon */

/* Output functions (To the serial port) */
int printf(const char *format, ...);
int sprintf(char *out, const char *format, ...);
int putchar(int c);
void puts(const char *str);

/* Set the leds on the board */
void led(int x);

/* Input functions (From the serial port) */
int availch(void); /* Check if a character is available */
int readch(void); /* Read one character */
void readline(unsigned char *buf,int len);  /* Read a line to buf */




/* Timer functions */
unsigned long get_timer (unsigned long base);
void set_timer (unsigned long t);
unsigned long get_tick (unsigned long base);
void set_tick (unsigned long t);
void sleep(unsigned long sleep_secs);
void tick_init(void);

/* Set special purpose register */
void mtspr(unsigned long spr, unsigned long value);
/* Read special purpose register */
unsigned long mfspr(unsigned long spr);

/* Enable/disable caches */
void dc_disable (void);
void ic_disable (void);
void dc_enable (void);
void ic_enable (void);


/* String functions */
unsigned long strtoul (const char *str, char **endptr, int base);
size_t strlen(const char *s);
char *strcpy(char *dest, const char *src);
char *strncpy(char *dest, const char *src, size_t n);
char *strcat(char *dest, const char *src);
char *strncat(char *dest, const char *src, size_t n);
int strcmp(const char *s1, const char *s2);
int strncmp(const char *s1, const char *s2, size_t n);
char *strchr(const char *s, int c);
char *strrchr(const char *s, int c);
void *memcpy(void *dest, const void *src, size_t n);
void *memmove(void *dest, void *src, size_t n);
int memcmp(const void *s1, const void *s2, size_t n);
void *memchr(const void *s, int c, size_t n);
void *memset(void *s, int c, size_t n);


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

/* Graphics functions */
/* Draw a large circle */
void largecircle(int x,int y,volatile unsigned int *img,int draw);
/* Draw a small circle */
void smallcircle(int x,int y,volatile unsigned int *img,int draw);
/* Expand a packed bitmap with 1 bpp into a 8 bit per pixel bitmap */
void expandbitmap(volatile unsigned int *src,unsigned int *dst);

#define IMAGESIZE (640*480)


/* Init the vga controller */
void vgainit(void);
/* Set the location (in the vga memory) of the VGA framebuffer */
void vgasetbase(int offset);
/* Hide a sprite. (sprite can be 0 or 1) */
void hidesprite(int sprite);
/* Show a sprite. (sprite can be 0 or 1) */
void showsprite(int sprite);
/* Init the sprite register to reasonable values */
void initsprites(void);
/* Move the specified sprite to location (x,y)  (sprite can be 0 or 1) */
void movesprite(int sprite,int x,int y);

/* View the camera on the VGA screen */
void camview(void);
/* Disable the camera */
void camdisable(void);
/* Get one filtered frame from the camera to the specified address */
void camgetfilteredframe(unsigned char *addr,int threshold);



#define REG8(add) *((volatile unsigned char *)(add))
#define REG16(add) *((volatile unsigned short *)(add))
#define REG32(add) *((volatile unsigned long *)(add))

/* Architecture definitions */
#define UART_BASE       0x90000000
#define UART_IRQ        2

#define PAR_BASE        0x91000000

#define IN_CLK          25000000

#define VGABASE		0x97000000
#define VGA_CTRL	0x97000000
#define VGA_BASE0	0x97000004
#define VGA_BASE1	0x97000008
#define VGA_SPROFFS	0x9700000c
#define VGA_SPRX0	0x97000010
#define VGA_SPRY0	0x97000014
#define VGA_SPRX1	0x97000018
#define VGA_SPRY1	0x9700001c

#define VGAPALBASE	0x97000800

#define VGASPRITEMEM0	0x97001000
#define VGASPRITEMEM1	0x97001800

#define VGAMEM		0x98200000

#define LEELABASE	0x98000000
#define LEELA_CTRL	0x98000000
#define LEELA_FBASE0	0x98000004
#define LEELA_FBASE1	0x98000008
#define LEELA_VBASE	0x9800000c


#endif
