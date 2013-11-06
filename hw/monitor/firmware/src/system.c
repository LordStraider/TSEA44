#include "board.h"
#include "spr_defs.h"

#include "mon2.h"
#include "text.h"
#include "system.h"
#include "flash.h"
#include "printf.h"

/* Initialize timer */
void timer_init(void)
{

  // Free running timer, no interrupt
  mtspr(SPR_TTMR, 0xc0000000);
}

/* Cache enable/disable stuff from bender */
/* Enable instruction cache */
void ic_enable (int par)
{
  unsigned long addr;
  unsigned long sr;
	
  /* Invalidate IC */
  if (par == FLUSH) {
    for (addr = 0; addr < 8192; addr += 16*8){
      asm("l.mtspr r0,%0,%1": : "r" (addr+16*0), "i" (SPR_ICBIR));  
      asm("l.mtspr r0,%0,%1": : "r" (addr+16*1), "i" (SPR_ICBIR));  
      asm("l.mtspr r0,%0,%1": : "r" (addr+16*2), "i" (SPR_ICBIR));  
      asm("l.mtspr r0,%0,%1": : "r" (addr+16*3), "i" (SPR_ICBIR));  
      asm("l.mtspr r0,%0,%1": : "r" (addr+16*4), "i" (SPR_ICBIR));  
      asm("l.mtspr r0,%0,%1": : "r" (addr+16*5), "i" (SPR_ICBIR));  
      asm("l.mtspr r0,%0,%1": : "r" (addr+16*6), "i" (SPR_ICBIR));  
      asm("l.mtspr r0,%0,%1": : "r" (addr+16*7), "i" (SPR_ICBIR));  
    }
  }
	
  /* Enable IC */
  asm("l.mfspr %0,r0,%1": "=r" (sr) : "i" (SPR_SR));
  sr |= SPR_SR_ICE;
  asm("l.mtspr r0,%0,%1": : "r" (sr), "i" (SPR_SR));  
  asm("l.nop");
  asm("l.nop");
  asm("l.nop");
  asm("l.nop");
}

/* Disable instruction cache */
void ic_disable (void)
{
  unsigned long sr;
	
  /* Disable IC */
  asm("l.mfspr %0,r0,%1": "=r" (sr) : "i" (SPR_SR));
  sr &= ~SPR_SR_ICE;
  asm("l.mtspr r0,%0,%1": : "r" (sr), "i" (SPR_SR));  
  asm("l.nop");
  asm("l.nop");
  asm("l.nop");
  asm("l.nop");
}

/* Enable data cache */
void dc_enable (int par)
{
  unsigned long addr;
  unsigned long sr;
	
  /* Invalidate DC */
  if (par == FLUSH) {
    for (addr = 0; addr < 8192; addr += 16*8){
      asm("l.mtspr r0,%0,%1": : "r" (addr+16*0), "i" (SPR_DCBIR));  
      asm("l.mtspr r0,%0,%1": : "r" (addr+16*1), "i" (SPR_DCBIR));  
      asm("l.mtspr r0,%0,%1": : "r" (addr+16*2), "i" (SPR_DCBIR));  
      asm("l.mtspr r0,%0,%1": : "r" (addr+16*3), "i" (SPR_DCBIR));  
      asm("l.mtspr r0,%0,%1": : "r" (addr+16*4), "i" (SPR_DCBIR));  
      asm("l.mtspr r0,%0,%1": : "r" (addr+16*5), "i" (SPR_DCBIR));  
      asm("l.mtspr r0,%0,%1": : "r" (addr+16*6), "i" (SPR_DCBIR));  
      asm("l.mtspr r0,%0,%1": : "r" (addr+16*7), "i" (SPR_DCBIR));  
    }
  }
	
  /* Enable DC */
  asm("l.mfspr %0,r0,%1": "=r" (sr) : "i" (SPR_SR));
  sr |= SPR_SR_DCE;
  asm("l.mtspr r0,%0,%1": : "r" (sr), "i" (SPR_SR));  
  asm("l.nop");
  asm("l.nop");
  asm("l.nop");
  asm("l.nop");
}

/* Disable data cache */
void dc_disable (void)
{
  unsigned long sr;
	
  /* Disable DC */
  asm("l.mfspr %0,r0,%1": "=r" (sr) : "i" (SPR_SR));
  sr &= ~SPR_SR_DCE;
  asm("l.mtspr r0,%0,%1": : "r" (sr), "i" (SPR_SR));  
  asm("l.nop");
  asm("l.nop");
  asm("l.nop");
  asm("l.nop");
}

/* Show a special register */
void mfspr(int adr)
{

  int i,j;
  int val;

  printf("\nSPRs\n");
  for(j=0;j<8;j++){
    printf("0x%08x: ", adr);
    for(i=0;i<4;i++){
      asm("l.mfspr %0,%1,0": "=r" (val) : "r" (adr));
      printf("0x%08x ", val);
      adr++;
    }
    printf("\n");
  }
}

/* Get a special register */
void mtspr(int adr, int val)
{
  asm("l.mtspr %0,%1,0": : "r" (adr), "r" (val));
}

/* Load from Flash to SDRAM and boot */
int boot(int offset, int size)
{
  int i;
  int (*pf)(void) = (int (*)(void)) 0x100;

  printf("\nCopying from FLASH to 0 ...");
  memcpy((char *)0x0, (char *) (FLASH_BASE_ADDR + offset), size);

  printf(" done\n");
  mtspr(0x11, 0x8001);

  i = (*pf)();

  return(i);
}

/* Initialize flash memory */
void fl_init (void)
{
  unsigned long tmp;

  REG32(FLASH_BASE_ADDR) = 0x00ff00ff; /* Read array */
  REG32(FLASH_BASE_ADDR) = 0x00900090; /* Read ID Codes */
  tmp = REG32(FLASH_BASE_ADDR) << 8;
  REG32(FLASH_BASE_ADDR) = 0x00900090;
  tmp = tmp | REG32(FLASH_BASE_ADDR + 4);
  REG32(FLASH_BASE_ADDR) = 0x00ff00ff; /* Read array */

}

int check_error (unsigned long sr, unsigned long addr)
{
  if ((sr & (FL_SR_ERASE_ERR << 16)) || (sr & FL_SR_ERASE_ERR)) {
    printf("erase error \n");
    /* Clear status register */
    REG32(FLASH_BASE_ADDR) = 0x05D00050;
    return 1;
  } else if ((sr & (FL_SR_PROG_ERR << 16)) || (sr & FL_SR_PROG_ERR)) {
    printf("program error \n");
    /* Clear status register */
    REG32(FLASH_BASE_ADDR) = 0x05D00050;
    return 1;
  } else if ((sr & (FL_SR_PROG_LV << 16)) || (sr & FL_SR_PROG_LV)) {
    printf("low voltage error\n");
    /* Clear status register */
    REG32(FLASH_BASE_ADDR) = 0x05D00050;
    return 1;
  } else if ((sr & (FL_SR_LOCK << 16)) || (sr & FL_SR_LOCK)) {
    printf("lock bit error\n");
    /* Clear status register */
    REG32(FLASH_BASE_ADDR) = 0x05D00050;
    return 1;
  }
  return 0;
}

int fl_block_erase (unsigned long addr)
{
  unsigned long sr;

  REG32(addr & ~(FLASH_BLOCK_SIZE - 1)) = 0x00200020; /* Block erase 1 */
  REG32(addr & ~(FLASH_BLOCK_SIZE - 1)) = 0x00D000D0; /* Block erase 2 */

  do {
    REG32(FLASH_BASE_ADDR) = 0x00700070; /* Read SR 1 */
    sr = REG32(FLASH_BASE_ADDR);         /* Read SR 2 */
  } while (!(sr & (FL_SR_WSM_READY << 16)) || !(sr & FL_SR_WSM_READY));

  REG32(FLASH_BASE_ADDR) = 0x00ff00ff; /* Read array */
  return check_error (sr, addr);
}

int fl_unlock_blocks (void)
{
  unsigned long sr;
  
  printf("Clearing all lock bits... ");
  REG32(FLASH_BASE_ADDR) = 0x00600060; /* Clear Block lock bits 1 */
  REG32(FLASH_BASE_ADDR) = 0x00d000d0; /* Clear Block lock bits 2 */

  do {
    REG32(FLASH_BASE_ADDR) = 0x00700070; /* Read SR 1 */
    sr = REG32(FLASH_BASE_ADDR);         /* Read SR 2 */
  } while (!(sr & (FL_SR_WSM_READY << 16)) || !(sr & FL_SR_WSM_READY));
  printf("done\n");
  return check_error (sr, FLASH_BASE_ADDR);
}

int fl_word_program (unsigned long addr, unsigned long val)
{
  unsigned long sr;

  REG32(addr) = 0x00400040;	/* Word Program 1 */
  REG32(addr) = val;            /* Word Program 2 */

  do {
    REG32(FLASH_BASE_ADDR) = 0x00700070; /* Read SR 1 */
    sr = REG32(FLASH_BASE_ADDR);         /* Read SR 2 */
  } while (!(sr & (FL_SR_WSM_READY << 16)) || !(sr & FL_SR_WSM_READY));

  REG32(FLASH_BASE_ADDR) = 0x00ff00ff; /* Read Array */
  return check_error (sr, addr);
}

int fl_program (unsigned long src_addr, unsigned long dst_addr, unsigned long len)
{
  unsigned long taddr, tlen;
  unsigned long i, tmp;

  fl_unlock_blocks ();
    
  taddr = dst_addr & ~(FLASH_BLOCK_SIZE - 1);
  tlen = (dst_addr + len - taddr + FLASH_BLOCK_SIZE - 1) / FLASH_BLOCK_SIZE;
  
  printf ("Erasing flash... ");
  for (i = 0, tmp = taddr; i < tlen; i++, tmp += FLASH_BLOCK_SIZE) {
    if (fl_block_erase (tmp)){
      printf("failed on block 0x%08x\n", tmp);
      return 1;
    }
  }
  printf ("done\n");
  
  REG32(FLASH_BASE_ADDR) = 0x00ff00ff; /* Read array */
  printf ("Copying from 0x%08x-0x%08x to 0x%08x-0x%08x\n", 
	  src_addr, src_addr + len - 1, dst_addr, dst_addr + len - 1); 

  tlen = len / 8;
  tmp = 0;
  printf ("Programming ");
  for (i = 0; i < len; i += 4) {
    if (fl_word_program (dst_addr + i, REG32(src_addr + i))){
      printf("failed on location 0x%08x\n", dst_addr+i);
      return 1;
    }
    if (i > tmp) {
      printf(".");
      tmp += tlen;
    }
  }
  printf(" done\n");

  REG32(FLASH_BASE_ADDR) = 0x00ff00ff; /* Read array */
  printf("Verifying   ");
  tmp = 0;
  for (i = 0; i < len; i += 4) {
    if (REG32(src_addr + i) != REG32(dst_addr + i)) {
      printf ("error at 0x%08x: 0x%08x != 0x%08x\n", 
	      src_addr + i, REG32(src_addr + i), REG32(dst_addr + i)); 
      return 1;
    }
    if (i > tmp) {
      printf(".");
      tmp += tlen;
    }
  }
  
  printf(" done\n");
  return 0;
}

