#include "uartfun.h"
#include "mon2.h"
#include "text.h"
#include "printf.h"

/* Extract a hexadecimal number from the buffer */
unsigned char *getnumber(unsigned char *buf, unsigned long *number)
{
  int c;
  unsigned long nr = 0;
  unsigned int initialized = 0;

  /* Skip whitespace */
  buf = skip_ws(buf);

  
  while ((c = *buf)){
    if ((c >= '0') && (c <= '9')){
      initialized = 1;
      nr = 16*nr + c - '0'; /* Luckily we don't do EBCDIC :) */
    } else if (( c >= 'a') && (c <= 'f')){
      initialized = 1;
      nr = 16*nr + c - 'a' + 10;
    } else if (( c >= 'A') && (c <= 'F')){
      initialized = 1;
      nr = 16*nr + c - 'A' + 10;
    } else if (c == ' '){
      break; /* The number has finished */
    } else {
      /* Syntax error */
      return 0;
    }
    buf++;
  }

  if (initialized){
    if (number) { /* Allow a NULL to be passed as number for syntax checking purposes */
      *number = nr;
    }
    return buf;

  }else{

    return 0;
  }
}

/* Read one line from the serial port */
void readline(unsigned char *buf,int len)
{
  int index;
  int c;

  index = 0;
  buf[index] = 0;

  while(1) {
    c = (int) readch();
    if (c == CTRL_C){
      reset();
    } else if ((c == BACKSPACE) || (c == DELETE)) {

      if(index == 0){
	/* At start of line, ignore */
	printf("\007");
      }else{
	printf("\010 \010");
	index--;
	buf[index] = 0; /* NUL terminate the string */
      }

    } else if (c == '\r'){
      /* Newline, print the newline character and return */
      printf("\r\n");
      return;
    } else {
      if(index <= len){
	putch(c);
	buf[index] = c;
	index = index + 1;
	buf[index] = 0; /* NUL terminate the string */
      }else{
	printf("\007");
      }
    }
  }
}

/* Return a pointer to the first non space character in a string */
unsigned char *skip_ws(unsigned char *b)
{
  while(*b == ' '){
    b++;
  }
  return b;
}

/* Calculate the Intel Hex checksum function */
int checksumint(unsigned int x)
{
  int chk;
  chk = x & 0xff;
  x = x >> 8;
  chk += x & 0xff;
  x = x >> 8;
  chk += x & 0xff;
  x = x >> 8;
  chk += x & 0xff;
  return chk;
}

/* Load an intel hex file from input. */
int loadhex(void)
{
  char *pbyte;
  int nr=0, adr, type, chk, i, *pword;
  int ext = 0, sum=0, start;
  int quit = 0;
  int lastbyte = 0;

  printf("Please send an intel hex file... (ctrl c to abort)\n");

  while(1) {
    while (readch() != ':');
  
    nr = readnr(2);
    chk = nr;

    nr = nr<<1;			/* nr of chars */
    adr = readnr(4);
    chk += checksumint(adr);

    type = readnr(2);
    chk += type & 0xff;

    if (type==0) {		/* data */
      adr += ext;
      if ((nr & 0x7)==0) {
	int val;
	pword = (int *)adr;
	for (i=0; i<(nr>>3); i++){
	  val = readnr(8);
	  *(pword+i) = val;
	  chk += checksumint(val);
	}
      } else {
	pbyte = (char *)adr;
	for (i=0; i<(nr>>1); i++){
	  int val;
	  val = readnr(2);
	  *(pbyte+i) = val;
	  chk += val;
	}
      }
    } else if (type==1) {	        /* end of file */
      quit=1;
    } else if (type==2){		/* Intel extended segment address */
      ext = readnr(nr);
      chk += checksumint(ext);
      ext = ext<<4;
    } else if (type==3){		/* Intel start segment address */
      start = readnr(nr);
      chk += checksumint(start);
    } else if (type==4) {		/* extended linear address */
      ext = readnr(nr);
      chk += checksumint(ext);
      ext = ext<<16;
    } else if (type==5) {		/* start linear address */
      start = readnr(nr);
      chk += checksumint(start);
    }

    lastbyte = readnr(2);

    if((lastbyte + chk) & 0xff) {
      printf("\nChecksum error in intel hex file (0x%02x+0x%02x!=0)\n", chk & 0xff, lastbyte & 0xff);
    }

    sum += nr;
   
    if (quit==1)
      break;

    if(type == 0){
      //      printf("\r 0x%x", adr);       // Don't print anything here since there is no FIFO in the  student based  UART!
    }
  }
  return(start);
}

/* Read a (hex) number from the input */
int readnr(int n)
{
  int i, c, nr=0;

  for (i=0; i<n; i++) {
    c = (int) readch();	      

    if ((c == ' ') || (c == '\r'))
      break;
      
    if (c < 58)
      c = c - 48;
    else {
      c = c & 0x5f;
      c = c - 55; 
    }
    nr = c + 16*nr;
  }
  
  return(nr);
}


