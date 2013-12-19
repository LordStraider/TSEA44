# Modified for the TSEA44 course. The original file was automatically
# generated.


# The name of your C compiler. You can change this to plain gcc if
# you don't want to cross compile your application
#
# Uncomment this for or32  
CC = or32-uclibc-gcc

# You may need to adjust these cc options:
#CFLAGS=  -I. -r -d  -O2 -Wall  -DHW_DCT -DHW_DMA -DHW_INST 
CFLAGS=  -I. -r -d  -O2 -Wall  -DHW_DCT -DHW_DMA
#CFLAGS=  -I. -r -d  -O2 -Wall
LDFLAGS= -r -d

# Use these values if you are not cross compiling to the OR1200
#CC = gcc
#CFLAGS=  -I. -g -O2 -DIA32
#LDFLAGS= -g

# linker
LN= $(CC)
# file deletion command
RM= rm -f

# compression library object files
CLIBOBJECTS= jchuff.o jcdctmgr.o jdct.o perfctr.o

# files included by source files
INCLUDES= jchuff.h my_encoder.h perfctr.h jdct.h

all:  jpegtest 

# sample programs:

jpegtest: jpegtest.o $(CLIBOBJECTS) $(INCLUDES)
	$(LN) $(LDFLAGS) jpegtest.o $(CLIBOBJECTS) -o j 

webcam.cgi: webcam.o $(CLIBOBJECTS) $(COMOBJECTS) 
	$(LN) $(LDFLAGS) webcam.o $(CLIBOBJECTS) $(COMOBJECTS) -o webcam.cgi

# Installation rules:
install: jpegtest
	echo No install yet

clean:
	$(RM) *.o cjpeg djpeg jpegtest core webcam.cgi


# GNU Make likes to know which target names are not really files to be made:
.PHONY: all install install-lib install-headers clean distclean test check

# Dependencies
jcdctmgr.o: jcdctmgr.c jdct.h  perfctr.h my_encoder.h
jchuff.o: jchuff.c jchuff.h my_encoder.h perfctr.h
jdct.o: jdct.c jdct.h my_encoder.h perfctr.h
jpegtest.o: jpegtest.c jchuff.h my_encoder.h perfctr.h
perfctr.o: perfctr.c perfctr.h
