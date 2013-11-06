#include "common.h"
#include "spr_defs.h"

/* Cache enable/disable stuff from orpmon */
void ic_enable (void)
{
	unsigned long addr;
	unsigned long sr;
	
	/* Invalidate IC */
	for (addr = 0; addr < 8192; addr += 16){
		asm("l.mtspr r0,%0,%1": : "r" (addr), "i" (SPR_ICBIR));  
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

void dc_enable (void)
{
	unsigned long addr;
	unsigned long sr;
	
	/* Invalidate DC */
	for (addr = 0; addr < 8192; addr += 16){
		asm("l.mtspr r0,%0,%1": : "r" (addr), "i" (SPR_DCBIR));  
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
