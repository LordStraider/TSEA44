int check_error (unsigned long sr, unsigned long addr)
{
  if ((sr & (FL_SR_ERASE_ERR << 16)) || (sr & FL_SR_ERASE_ERR)) {
    printstr("erase error \n");
    /* Clear status register */
    REG32(FLASH_BASE_ADDR) = 0x05D00050;
    return 1;
  } else if ((sr & (FL_SR_PROG_ERR << 16)) || (sr & FL_SR_PROG_ERR)) {
    printstr("program error \n");
    /* Clear status register */
    REG32(FLASH_BASE_ADDR) = 0x05D00050;
    return 1;
  } else if ((sr & (FL_SR_PROG_LV << 16)) || (sr & FL_SR_PROG_LV)) {
    printstr("low voltage error\n");
    /* Clear status register */
    REG32(FLASH_BASE_ADDR) = 0x05D00050;
    return 1;
  } else if ((sr & (FL_SR_LOCK << 16)) || (sr & FL_SR_LOCK)) {
    printstr("lock bit error\n");
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
  
  printstr("Clearing all lock bits... ");
  REG32(FLASH_BASE_ADDR) = 0x00600060; /* Clear Block lock bits 1 */
  REG32(FLASH_BASE_ADDR) = 0x00d000d0; /* Clear Block lock bits 2 */

  do {
    REG32(FLASH_BASE_ADDR) = 0x00700070; /* Read SR 1 */
    sr = REG32(FLASH_BASE_ADDR);         /* Read SR 2 */
  } while (!(sr & (FL_SR_WSM_READY << 16)) || !(sr & FL_SR_WSM_READY));
  printstr("done\n");
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

int fl_program (unsigned long src_addr, unsigned long dst_addr)
{
  unsigned long tmp, taddr, tlen;
  unsigned long i;

  // FIXME - are we sure that you are allowed to run fl_init
  // several times?
  fl_init();

  fl_unlock_blocks ();
    
  taddr = dst_addr & ~(FLASH_BLOCK_SIZE - 1);
  tlen = (dst_addr + len - taddr + FLASH_BLOCK_SIZE - 1) / FLASH_BLOCK_SIZE;
  
  printf ("Erasing flash... ");
  for (i = 0, tmp = taddr; i < tlen; i++, tmp += FLASH_BLOCK_SIZE) {
    if (fl_block_erase (tmp)){
      // printf("failed on block 0x%08x\n", tmp);
      return 1;
    }
  }
  printf ("done\n");
  
  REG32(FLASH_BASE_ADDR) = 0x00ff00ff; /* Read array */
  /* printf ("Copying from 0x%08x-0x%08x to 0x%08x-0x%08x\n", 
     src_addr, src_addr + len - 1, dst_addr, dst_addr + len - 1); */

  tlen = len / 10;
  tmp = 0;
  printf ("Programming ");
  for (i = 0; i < len; i += 4) {
    if (fl_word_program (dst_addr + i, REG32(src_addr + i))){
      // printf("failed on location 0x%08x\n", dst_addr+i);
      return 1;
    }
    if (i > tmp) {
      printstr(".");
      tmp += tlen;
    }
  }
  printstr(" done\n");

  REG32(FLASH_BASE_ADDR) = 0x00ff00ff; /* Read array */
  printstr("Verifying   ");
  tmp = 0;
  for (i = 0; i < len; i += 4) {
    if (REG32(src_addr + i) != REG32(dst_addr + i)) {
      /* printf ("error at 0x%08x: 0x%08x != 0x%08x\n", 
	 src_addr + i, REG32(src_addr + i), REG32(dst_addr + i)); */
      return 1;
    }
    if (i > tmp) {
      printstr(".");
      tmp += tlen;
    }
  }
  
  printstr(" done\n");
  return 0;
}

