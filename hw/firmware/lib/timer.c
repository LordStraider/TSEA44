#include "spr_defs.h"
#include "common.h"

/***********************************************************************/ 
/* returns time in seconds */
unsigned long get_timer (unsigned long base)
{

  return (mfspr(SPR_TTCR)/IN_CLK - base);
}

/***********************************************************************/  
void set_timer (unsigned long t)
{
  mtspr(SPR_TTCR,t*IN_CLK);
}

/***********************************************************************/ 
/* returns time in ticks */
unsigned long get_tick (unsigned long base)
{

  return (mfspr(SPR_TTCR) - base);
}

/***********************************************************************/  
void set_tick (unsigned long t)
{
  mtspr(SPR_TTCR,t);
}


void tick_init(void)
{
  // Free running timer, no interrupt
  mtspr(SPR_TTMR, 0xc0000000);
}

/* 
  sleep for n timer-ticks
*/

void sleep(unsigned long sleep_secs)
{
  int sleep_clocks = (int) sleep_secs*IN_CLK;
  int start_clock = (int) mfspr(SPR_TTCR);
  
  while ( (mfspr(SPR_TTCR) - start_clock) < sleep_clocks); /* do nothing */
}
