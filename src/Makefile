YML2PROC?=yml2proc

TARGET=transport_status_code.h transport_status_code.c PEPTransportStatusCode.h

TSC=$(wildcard *.tsc)

all: $(TARGET)

transport_status_code.h: gen_c.ysl2 transport_status_code.yml2 $(TSC)
	yml2proc -y $< -o $@ transport_status_code.yml2

transport_status_code.c: gen_strings.ysl2 transport_status_code.yml2 $(TSC)
	yml2proc -y $< -o $@ transport_status_code.yml2

PEPTransportStatusCode.h: gen_objc.ysl2 transport_status_code.yml2 $(TSC)
	yml2proc -y $< -o $@ transport_status_code.yml2

.PHONY: clean

clean:
	rm -f $(TARGET)
