SOBJS	= crt.o or32.o
COBJS	= printf.o uartfun.o text.o graphics.o system.o mon2.o dct2.o jpegtest.o jdct.o jchuff.o

SIMOBJS = reset.o

D2MDIR	= ../d2m
MEMMAP	= memorymap.bmm
MONV 	= mon_prog_bram_contents.v

SEDCMD	= 's/^000/@40000/g;s/^001/@40001/g;s/^002/@40002/g;s/^003/@40003/g;s/^004/@40004/g;s/^005/@40005/g'
SIMCFG  = or1ksim.cfg

include ../Makefile.conf

all: mon_prog_bram_contents.v

$(TARGET): $(SOBJS) $(COBJS)
	$(LD) $(SOBJS) $(COBJS) $(LFLAGS) -o $(TARGET)

$(SOBJS): %.o: %.S
	$(CC) $(CFLAGS) -c -o $@ $*.S

$(COBJS): %.o: %.c %.h
	$(CC) $(CFLAGS) -c -o $@ $*.c

# Creates a list file (text dump) of the boot monitor
txt: $(TARGET)
	$(DUMP) $(DUMPFLAGS) $(TARGET) > $(TARGET).txt

# Creates a binary dump of the boot monitor
$(TARGET).raw: $(TARGET)
	$(COPY) $(COPYFLAGS) $(TARGET) $(TARGET).raw

# Creates a file usable by the data2mem utility from Xilinx
$(TARGET).mem: $(TARGET).raw
	od -Ax -w4 -tx1 -v $(TARGET).raw | sed $(SEDCMD) > $(TARGET).mem

$(MONV): $(TARGET).mem
	$(XILINX_INIT) $(DATA2MEM) -bm $(D2MDIR)/$(MEMMAP) -bd $(TARGET).mem -o v $(MONV)

# Creates a file for the simulator
reset.o: reset.S
	$(CC) $(CFLAGS) -c reset.S

sim: $(SIMOBJS) $(SOBJS) $(COBJS) 
	$(LD)  $(SIMOBJS) $(SOBJS) $(COBJS) $(LFLAGS) -o $(TARGET)sim
	$(DUMP) $(DUMPFLAGS) $(TARGET)sim > $(TARGET)sim.txt
	$(SIM) -f $(SIMCFG) $(TARGET)sim

clean:
	rm -f $(TARGET) $(TARGET)sim txt2v $(TARGET).txt 
	rm -f *.hex *.o *~ $(TARGET).mem $(TARGET).raw $(TARGET)sim.txt $(MONV)
	rm -f *.tx *.rx *.bit sim.profile

install: mon_prog_bram_contents.v
	cp mon_prog_bram_contents.v ../..

