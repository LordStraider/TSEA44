# The name of the program we want to compile
PROGRAM  = dct_sw

# The directory containing the open risc supportdir
LIBDIR=../lib
INCLUDEDIR=../include

CFLAGS += -I$(INCLUDEDIR) -Wall -Wstrict-prototypes -Werror-implicit-function-declaration 
CFLAGS += -Os -g -fno-builtin -fomit-frame-pointer -nostdlib -mhard-mul

# Toolchain configuration
AS = or32-uclinux-as
CC = or32-uclinux-gcc
LD = or32-uclinux-ld
DUMP = or32-uclinux-objdump -S -D -EB
COPY = or32-uclinux-objcopy 
SIM =  or32-uclinux-sim


# Flags to LD, need to include a link script here
LDFLAGS = -Tram.ld


OBJFILES=$(PROGRAM).o

HEXFILE=$(PROGRAM).hex

SIMPROGRAM=$(PROGRAM)sim


all: $(PROGRAM) $(HEXFILE)  $(SIMPROGRAM)

# The minimal supportlib containing printf/sleep/etc
openrisclib: $(LIBDIR)/openrisclib.a $(LIBDIR)/crt.o $(LIBDIR)/reset.o

# Commands to make the open risc support lib
$(LIBDIR)/openrisclib.a:
	cd $(LIBDIR) && $(MAKE)

$(LIBDIR)/crt.o:
	cd $(LIBDIR) && $(MAKE)

$(LIBDIR)/reset.o:
	cd $(LIBDIR) && $(MAKE)

.S.o:
	$(CC) $(CFLAGS) -c $<

.c.o:
	$(CC) -c $(CFLAGS) -o $@ $<


# Link the program together with the supportlib
# (And create a text file with the disassembled contents of the program)
$(PROGRAM): $(OBJFILES) ram.ld openrisclib
	$(LD)  -Bstatic $(LIBDIR)/crt.o $(OBJFILES) $(LIBDIR)/openrisclib.a $(LDFLAGS) -o $(PROGRAM)
	$(DUMP) $(PROGRAM) > $(PROGRAM).txt

# Create an intel hex dump of the program
$(HEXFILE): $(PROGRAM)
	$(COPY) -O ihex $(PROGRAM) $(HEXFILE)

# Create a binary we can simulate with the openrisc simulator
$(SIMPROGRAM): $(PROGRAM) ram.ld openrisclib
	$(LD)  -Bstatic $(LIBDIR)/reset.o $(PROGRAM) $(LDFLAGS) -o $(SIMPROGRAM)
	$(DUMP) $(SIMPROGRAM) > $(SIMPROGRAM).txt

# Run the simulator on the program
sim: $(SIMPROGRAM)
	$(SIM) -i -f sim.cfg $(SIMPROGRAM)


clean:
	rm -f *.o *~ sim.profile $(PROGRAM) $(SIMPROGRAM) $(HEXFILE) *.txt  uart0.tx uart0.rx



