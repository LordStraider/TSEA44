#include "printf.h"
#include <common.h>
#include <time.h>

#include "perfctr.h"

int main() {
  unsigned int code, i, size, startcycle, perf;

  startcycle = gettimer();
  for (i = 0; i < 100; ++i) {
    asm volatile("l.sd 0x0(%0),%1" : : "r"(0x2), "r"(2));
  }

  perf = gettimer() - startcycle;
  printf("100x size 2 = %d\n", perf);
  startcycle = gettimer();

  for (i = 0; i < 100; ++i) {
    asm volatile("l.sd 0x0(%0),%1" : : "r"(0x33), "r"(8));
  }

  perf = gettimer() - startcycle;
  printf("100x size 8 = %d\n", perf);
  startcycle = gettimer();

  for (i = 0; i < 100; ++i) {
    asm volatile("l.sd 0x0(%0),%1" : : "r"(0x33), "r"(16));
  }

  perf = gettimer() - startcycle;
  printf("100x size 16 = %d\n", perf);
  startcycle = gettimer();

  for (i = 0; i < 100; ++i) {
    asm volatile("l.sd 0x0(%0),%1" : : "r"(0xFF), "r"(8));
  }

  perf = gettimer() - startcycle;
  printf("100x FF size 8 = %d\n", perf);

  return 0;
}
