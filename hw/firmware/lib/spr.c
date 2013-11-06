#include "spr_defs.h"
#include "common.h"

/************** For writing into SPR. ***********************/
void mtspr(unsigned long spr, unsigned long value)
{
  asm("l.mtspr\t\t%0,%1,0": : "r" (spr), "r" (value));
}

/************** For reading SPR. ***************************/
unsigned long mfspr(unsigned long spr)
{
  unsigned long value;
  asm("l.mfspr\t\t%0,%1,0" : "=r" (value) : "r" (spr));
  return value;
}
