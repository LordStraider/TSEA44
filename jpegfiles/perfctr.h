#ifndef _PERFCTR_H
#define _PERFCTR_H

#define JPG_BASE_ADDR 0x96000000

// Direct memory access macros
#define REG8(add) *((volatile unsigned char *)(add))
#define REG16(add) *((volatile unsigned short *)(add))
#define REG32(add) *((volatile unsigned long *)(add))

#ifdef IA32
static inline unsigned int gettimer(void)
{
        /* No accurate timing implemented on X86 (could 
           use rdtsc instruction here but we don't bother about that */

	return 0;
}
#else
static inline unsigned int gettimer(void)
{
        unsigned long spr = 0x5002;
	unsigned int clockcycles;
	asm volatile ("l.mfspr\t\t%0,%1,0" : "=r" (clockcycles) : "r" (spr));
	return clockcycles;
}
#endif

void print_performance(void);

extern unsigned int perf_mainprogram;
extern unsigned int perf_init;
extern unsigned int perf_dct;
extern unsigned int perf_copy;
extern unsigned int perf_dctkernel;
extern unsigned int perf_huff;
extern unsigned int perf_emitbits;
#endif
