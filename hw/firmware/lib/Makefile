AS = or32-uclinux-as
AS = or32-uclinux-ar
CC = or32-uclinux-gcc
LD = or32-uclinux-ld
DUMP = or32-uclinux-objdump -S -D -EB
COPY = or32-uclinux-objcopy 
SIM =  or32-uclinux-sim
CFLAGS += -I../include -DOR1K -Wall -Wstrict-prototypes -Werror-implicit-function-declaration -Os -g -fno-builtin -fomit-frame-pointer -nostdlib

OBJFILES = printf.o or32.o spr.o timer.o misc.o input.o output.o leela.o cache.o graphics.o


all: openrisclib.a crt.o reset.o


.S.o:
	$(CC) $(CFLAGS) -c $<

.c.o:
	$(CC) -c $(CFLAGS) -o $@ $<


openrisclib.a: $(OBJFILES)
	$(AR) r openrisclib.a $(OBJFILES)

clean:
	rm -f *~ *.o *.a
