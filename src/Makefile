<<<<<<< HEAD
YML2PROC?=yml2proc
PREFIX?=$(HOME)

TARGET=transport_status_code.h transport_status_code.c PEPTransportStatusCode.h TransportStatusCode.kt transport_status_code.cs

=======
include ../Makefile.conf

TARGET=transport_status_code.h transport_status_code.c PEPTransportStatusCode.h TransportStatusCode.kt
HEADERS=$(wildcard *.hh *.hxx *.h)
>>>>>>> 2bb9545f5ab821426612f4abad1ae202b0c9b6cb
TSC=$(wildcard *.tsc)

.PHONY: install uninstall clean

all: $(TARGET)

transport_status_code.h: gen_c.ysl2 transport_status_code.yml2 $(TSC)
	$(YML2_PROC) -y $< -o $@ transport_status_code.yml2

transport_status_code.c: gen_strings.ysl2 transport_status_code.yml2 $(TSC)
	$(YML2_PROC) -y $< -o $@ transport_status_code.yml2

PEPTransportStatusCode.h: gen_objc.ysl2 transport_status_code.yml2 $(TSC)
	$(YML2_PROC) -y $< -o $@ transport_status_code.yml2

TransportStatusCode.kt: gen_kotlin.ysl2 transport_status_code.yml2 $(TSC)
	$(YML2_PROC) -y $< -o $@ transport_status_code.yml2


install: $(TARGET)
	mkdir -p $(PREFIX)/include/pEp
	mkdir -p $(PREFIX)/lib
	cp -v $(HEADERS) $(PREFIX)/include/pEp/

<<<<<<< HEAD
transport_status_code.cs: gen_cs.ysl2 transport_status_code.yml2 $(TSC)
	yml2proc -y $< -o $@ transport_status_code.yml2

.PHONY: clean install
=======
uninstall:
	cd $(PREFIX)/include/pEp && rm -vf $(HEADERS)
	cd $(PREFIX)/lib && rm -vf $(TARGET)
>>>>>>> 2bb9545f5ab821426612f4abad1ae202b0c9b6cb

clean:
	rm -f $(TARGET)

install:
	mkdir -p $(PREFIX)/include/pEp
	cp -f transport_status_code.h $(PREFIX)/include/pEp/
