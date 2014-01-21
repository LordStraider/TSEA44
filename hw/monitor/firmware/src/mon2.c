#include "uart.h"
#include "board.h"
#include "spr_defs.h"
#include "text.h"
#include "uartfun.h"
#include "graphics.h"
#include "system.h"
#include "mon2.h"
#include "flash.h"
#include "printf.h"
#include "dct2.h"
#include "jpegtest.h"

/* NOTE This program assumes sizeof(int) == 4
 * NOTE This program cannot have anything located in the .data section.
 *      We cannot use any initialized global variables here */

unsigned char buf[70];

int main(void) {
  unsigned long len, src, dst, i;
  int *adr = 0, dat;
  int sadr = 0;
  int c;
  int debug = 0;
  int code;
  int size;
  unsigned char *bufptr;
  int (*pf)(void);
  int tmp;
  char *hwtype;

  // The first thing we do is to set the leds so that we can get some
  // feedback that the design is working.
  REG32(PAR_BASE_ADDR) = 1;

  timer_init();
  uart_init();

  REG32(PAR_BASE_ADDR) = 2;

  // You may use these functions instead while simulating if you think
  // that the cache flush takes too much time. Never use this in a real
  // design that you are downloading to the FPGA though!
  //ic_enable(NO_FLUSH);    
  //dc_enable(NO_FLUSH);

  ic_enable(FLUSH);
  dc_enable(FLUSH);

  REG32(PAR_BASE_ADDR) = 3;
  exception_init();

  /******** Test programs ********/
  REG32(PAR_BASE_ADDR) = 4;
  // dct_sw();
  // dma_dct_hw();
  // jpegtest();
  size = 16;
  code = 0x55ff;
  asm volatile("l.sd 0x0(%0),%1" : : "r"(code), "r"(size));
  size = 16;
  code = 0xff55;
  asm volatile("l.sd 0x0(%0),%1" : : "r"(code), "r"(size));

  size = 8;
  code = 0xff;
  asm volatile("l.sd 0x0(%0),%1" : : "r"(code), "r"(size));

  size = 8;
  code = 0x22;
  asm volatile("l.sd 0x0(%0),%1" : : "r"(code), "r"(size));

  size = 2;
  code = 0x3;
  asm volatile("l.sd 0x0(%0),%1" : : "r"(code), "r"(size));
  size = 2;
  code = 0x3;
  asm volatile("l.sd 0x0(%0),%1" : : "r"(code), "r"(size));
  size = 2;
  code = 0x3;
  asm volatile("l.sd 0x0(%0),%1" : : "r"(code), "r"(size));
  size = 2;
  code = 0x3;
  asm volatile("l.sd 0x0(%0),%1" : : "r"(code), "r"(size));

  size = 8;
  code = 0x33;
  asm volatile("l.sd 0x0(%0),%1" : : "r"(code), "r"(size));

  size = 16;
  code = 0xffff;
  asm volatile("l.sd 0x0(%0),%1" : : "r"(code), "r"(size));


/*
  size = 3;
  code = 0x5;
  asm volatile("l.sd 0x0(%0),%1" : : "r"(code), "r"(size));

  size = 11;
  code = 0x25;
  asm volatile("l.sd 0x0(%0),%1" : : "r"(code), "r"(size));

  size = 1;
  code = 0x1;
  asm volatile("l.sd 0x0(%0),%1" : : "r"(code), "r"(size));

  size = 9;
  code = 0x6;
  asm volatile("l.sd 0x0(%0),%1" : : "r"(code), "r"(size));

  size = 17;
  code = 0x31;
  asm volatile("l.sd 0x0(%0),%1" : : "r"(code), "r"(size));

*/

  REG32(PAR_BASE_ADDR) = 5;

  tmp = REG32(PAR_BASE_ADDR);
  if ((tmp & 0xff000000) == 0xc0000000) {
    hwtype = "dafk";
  } else if((tmp & 0xff000000) == 0x80000000) {
    hwtype = "lab1";
  } else {
    hwtype = "<unknown>";
  }

  tmp = (tmp & 0x00ffff00) >> 8; // Get the build number

  printf("\nmonitor " BUILDTIME " HW: type %s, build #%d\n\n",hwtype,tmp);

  REG32(PAR_BASE_ADDR) = 6;

  while (1) {
    printf("> ");
		
    readline(buf,68);
    bufptr = buf;

    /* Skip whitespace in beginning */
    bufptr = skip_ws(bufptr);

    /* Extract the command */
    c = *bufptr;
    bufptr++;
		
    if(checksyntax(bufptr,c,debug))
    {
      if(c == 'd')
      {
	getnumber(bufptr,(unsigned long *) &adr);
	display(adr);
	adr += 0x80 / sizeof(int); 
      }
      else if(c == 'g')
      {
	getnumber(bufptr,(unsigned long *) &pf);
	dat = (*pf)();
	/* Print return value */
	printf("\n %d\n", dat);
      }else if(c == 'l'){
	pf = (int (*)(void)) loadhex();
	printf("\nStart address: %x\n", (int) pf);
      }else if(c == 'm'){
	bufptr = getnumber(bufptr,(unsigned long *) &adr);
	getnumber(bufptr,(unsigned long *) &dat);
	*adr = dat; 
      }else if(c == 'c'){
	bufptr = getnumber(bufptr, &src);
	bufptr = getnumber(bufptr, &dst);
	getnumber(bufptr, &len);
	memcpy((void *)dst, (void *)src,len);
      }else if(c == 'f'){
	bufptr = getnumber(bufptr, &src);
	bufptr = getnumber(bufptr, &dst);
	getnumber(bufptr, &len);
	fl_program(src, dst, len);
      }else if(c == 'b'){
	boot(0x0, 0x10000); /* never returns */
      }else if(c == 't'){
        size = 3;
        code = 0x0004;
        asm volatile("l.sd 0x0(%0),%1" : : "r"(code), "r"(size));
        
        size = 16;
        code = 0x1235;
        asm volatile("l.sd 0x0(%0),%1" : : "r"(code), "r"(size));

        size = 5;
        code = 0x0007;
        asm volatile("l.sd 0x0(%0),%1" : : "r"(code), "r"(size));
        
        size = 8;
        code = 0xff;
        asm volatile("l.sd 0x0(%0),%1" : : "r"(code), "r"(size));
        printf("done sending stuff\n");
      }else if(c == 'u'){
	boot(0x100000, 0x300000);  /* never returns */
      }else if(c == 'x'){
	/* For extra credits, device a way to send arguments to Linux :) */
	boot(0x800000, 0x500000);  /* never returns */
      }else if(c == 's'){
	getnumber(bufptr,(unsigned long *) &sadr);
	mfspr(sadr);
	sadr += 0x20;
      }else if(c == 'R'){
	bufptr = getnumber(bufptr,(unsigned long *) &adr);
	getnumber(bufptr,(unsigned long *) &dat);
	mtspr((int)adr, dat);
      }else if(c == 'C'){
	caminit();
      }else if(c == 'V'){
	vgainit();
      }else if(c == 'P'){
	palinit();
      }else if(c == '1'){
	ic_enable(FLUSH);
	printf("ICache enabled\n");
      }else if(c == '2'){
	ic_disable();
	printf("ICache disabled\n");
      }else if(c == '3'){
	dc_enable(FLUSH);
	printf("DCache enabled\n");
      }else if(c == '4'){
	dc_disable();
	printf("DCache disabled\n");
      }else if(c == 'w'){
	dct_sw();
      }else if(c == 'a'){
	dma_dct_hw();
      }else if(c == 'j'){
	jpegtest();
      }else if(c == 'D'){
	debug = 1;
      }else if((c == 'h') || (c == '?')){
	printf("Memory manipulation:\n"
		 "  d <addr> [display mem]\n"
		 "  m <addr> <dat> [modify mem]\n"
		 "  c <src> <dst> <len> [copy]\n"
		 "  l [load intel hex file]\n"
		 "Execution:\n"
		 "  g <addr> [go]\n"
		 "  u Boot uClinux from flash\n"
		 "Special Purpose Register manipulation:\n"
		 "  s <addr> [show SPR]\n"
		 "  R <adr> <dat> [modify SPR]\n"
		 "Peripherials:\n"
		 "  V Vga Init\n"
		 "  C Camera Init\n"
		 "Cache commands:\n"
		 "  1 Enable ICache\n"
		 "  2 Disable ICache\n"
		 "  3 Enable DCache\n"
		 "  4 Disable DCache\n"
		 );
				
	if(debug == 1){
	  printf("Debug commands:\n"
		 "  D Enable Debug commands\n"
		 "  P Palette init\n"
		 "  b Run the Bender Monitor\n"
		 "  x Boot linux from flash\n"
		 "  f <src> <dst> <len> [flash]\n"
		 "  w Run dct_sw\n"
		 "  a Run dma_dct_hw\n"
		 "  j Run jpegtest\n"
		 );
	}
      }
    }else{
      printf("Error\n");
    }
  }
  return(0);
}

	
int checksyntax(unsigned char *buf,char cmd,int debug)
{
  /* The number of values accepted by each command */
  static const char syntax[] = { 
    'd',1, /* Display */
    'd',0, /* Magic to let display take one default argument */
    'g',1, /* go */
    'g',0, /* go */
    't',0, /* test lab4 */
    'l',0, /* load intel hex file*/
    'm',2, /* modify mem*/
    'c',3, /* copy */
    's',1, /* show special register */
    's',0, /* show special register / Magic: see 'd' above */
    'R',2, /* modify special register */
    'h',0, /* help */
    '?',0, /* help */
    'V',0, /* vga init */
    'C',0, /* camera init */
    '1',0, /* Enable ICache */
    '2',0, /* Disable ICache */
    '3',0, /* Enable DCache */
    '4',0, /* Disable DCache */
    'D',0, /* Enter debug mode */
    'u',0, /* boot uClinux */
    '\0',0 /* no command */
  };

  static const char syntaxdebug[] = {
    'P',0, /* pal init */
    'b',0, /* boot bender*/
    'x',0, /* boot Linux*/
    'f',3, /* flash */
    'w',0, /* dct_sw */
    'a',0, /* dma_dct_hw */
    'j',0, /* jpegtest */
  };

  int i;
  for(i=0;i<sizeof(syntax);i+=2){
    if(syntax[i] == cmd){
      if(checkvalues(buf,syntax[i+1])){
	return 1;
      }
    }
  }
  if(!debug){
    return 0;
  }

  for(i=0;i<sizeof(syntaxdebug);i+=2){
    if(syntaxdebug[i] == cmd){
      if(checkvalues(buf,syntaxdebug[i+1])){
	return 1;
      }
    }
  }
  return 0;
	
}

int checkvalues(unsigned char *buf,int num_values)
{
  while(num_values > 0){
    /* Go through the buffer and find all numbers in it */
    buf = getnumber(buf,0);
    if(!buf){
      return 0;
    }
    num_values--;
  }

  buf = skip_ws(buf);
  /* Only the NUL character should be left in this case! */
  if(*buf){
    return 0;
  }else{
    return 1;
  }
}

/* Basic mem functions */
/***********************************************************************/ 
void memcpy(void *dest, const void *src, unsigned long n)
{
  /* check if 'src' and 'dest' are on LONG boundaries */
  if ( (sizeof(unsigned long) -1) & ((unsigned long)dest | (unsigned long)src) )
  {
      /* no, do a byte-wide copy */
    char *cs = (char *) src;
    char *cd = (char *) dest;

    while (n--)
      *cd++ = *cs++;
  }
  else
  {
    /* yes, speed up copy process */
    /* copy as many LONGs as possible */
    long *ls = (long *)src;
    long *ld = (long *)dest;

    unsigned long cnt = n >> 2;
    while (cnt--)
      *ld++ = *ls++;

    /* finally copy the remaining bytes */
    char *cs = (char *) (src + (n & ~0x03));
    char *cd = (char *) (dest + (n & ~0x03));

    cnt = n & 0x3;
    while (cnt--)
      *cd++ = *cs++;
  }
}

/* Display address: data */
void display(int *adr)
{
  int i,j;
  unsigned char *str;

  for(j=0;j<8;j++){
    printf("0x%08x: ", (int) adr);
    str = (unsigned char *) adr;
    for(i=0;i<4;i++){
      printf("0x%08x ", *adr);
      adr++;
    }
    printf("  ");
    for(i=0;i<16;i++){
      if((*str > ' ') && (*str < '~')){
	putch(*str);
      }else{
	putch('.');
      }
      str++;
    }
    printf("\n");
  }
}

// Jump to the start of the monitor
void reset(void)
{
  // Jump to runtime system start
  crt();
}

void buserr(int instr_addr, int berr_addr)
{
  printf("\nBus error at 0x%08x EA=0x%08x, restarting ...\n", instr_addr, berr_addr);
  reset();
}

void exception_init(void)
{
  memcpy((void *) 0x200, (void *) 0x40000010,32);		/* copy bus error code */
}
