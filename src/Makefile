include ../Makefile.conf

TARGET=transport_status_code.h transport_status_code.c PEPTransportStatusCode.h TransportStatusCode.kt
HEADERS=$(wildcard *.hh *.hxx *.h)
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

uninstall:
	cd $(PREFIX)/include/pEp && rm -vf $(HEADERS)
	cd $(PREFIX)/lib && rm -vf $(TARGET)

clean:
	rm -f $(TARGET)
