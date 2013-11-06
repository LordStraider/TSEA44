# Makefile for the 
CROSS		:= or32-uclibc-

PROGS     = hello
OBJS      = hello.o

CC        = $(CROSS)gcc

CFLAGS	 += -r -d -Wall -Os

STRIP	  = $(CROSS)strip 


all: $(PROGS)

$(PROGS): $(OBJS)
	$(CC) $(LDFLAGS) -r -d $^ $(LDLIBS) -o $@
	$(STRIP) -g --strip-unneeded $@


.PHONY: clean
clean:
	rm -f $(PROGS) *.o core *~
