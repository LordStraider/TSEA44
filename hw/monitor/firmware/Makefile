SUBDIRS = sim src 

include Makefile.conf

all: $(TARGET)

$(TARGET):
	$(MAKE) -C src all

install:
	$(MAKE) -C src install

bit:
	$(MAKE) -C src bit

clean:
	for dir in $(SUBDIRS); do \
	  $(MAKE) -C $$dir clean; \
	done
	rm -f *~
