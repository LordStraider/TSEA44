#ifndef _FLASH_H
#define _FLASH_H

#define FL_SR_WSM_READY   0x80
#define FL_SR_ERASE_ERR   0x20
#define FL_SR_PROG_ERR    0x40
#define FL_SR_PROG_LV     0x08
#define FL_SR_LOCK        0x02

void fl_init (void);
int fl_unlock_blocks (void);
int fl_word_program (unsigned long addr, unsigned long val);
int fl_block_erase (unsigned long addr);

/* erase = 1 (whole chip), erase = 2 (required only) */
int fl_program (unsigned long src_addr, unsigned long dst_addr, unsigned long len);


#endif /* _FLASH_H */

