YML2PROC?=yml2proc
PREFIX?=$(HOME)

TARGET=transport_status_code.h transport_status_code.c PEPTransportStatusCode.h TransportStatusCode.kt transport_status_code.cs

TSC=$(wildcard *.tsc)

all: $(TARGET)

transport_status_code.h: gen_c.ysl2 transport_status_code.yml2 $(TSC)
	yml2proc -y $< -o $@ transport_status_code.yml2

transport_status_code.c: gen_strings.ysl2 transport_status_code.yml2 $(TSC)
	yml2proc -y $< -o $@ transport_status_code.yml2

PEPTransportStatusCode.h: gen_objc.ysl2 transport_status_code.yml2 $(TSC)
	yml2proc -y $< -o $@ transport_status_code.yml2

TransportStatusCode.kt: gen_kotlin.ysl2 transport_status_code.yml2 $(TSC)
	yml2proc -y $< -o $@ transport_status_code.yml2

transport_status_code.cs: gen_cs.ysl2 transport_status_code.yml2 $(TSC)
	yml2proc -y $< -o $@ transport_status_code.yml2

.PHONY: clean install

clean:
	rm -f $(TARGET)

install:
	mkdir -p $(PREFIX)/include/pEp
	cp -f transport_status_code.h $(PREFIX)/include/pEp/
