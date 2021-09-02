include Makefile.conf

ifneq ($(wildcard local.conf),)
    $(info ================================================)
    $(info Overrides in `local.conf` are used.)
    $(info ================================================)
endif

TARGET=transport_status_code.h transport_status_code.c PEPTransportStatusCode.h TransportStatusCode.kt

TSC=$(wildcard *.tsc)

all: $(TARGET)

transport_status_code.h: gen_c.ysl2 transport_status_code.yml2 $(TSC)
	$(YML2_PROC) -y $< -o $@ transport_status_code.yml2

transport_status_code.c: gen_strings.ysl2 transport_status_code.yml2 $(TSC)
	$(YML2_PROC) -y $< -o $@ transport_status_code.yml2

PEPTransportStatusCode.h: gen_objc.ysl2 transport_status_code.yml2 $(TSC)
	$(YML2_PROC) -y $< -o $@ transport_status_code.yml2

TransportStatusCode.kt: gen_kotlin.ysl2 transport_status_code.yml2 $(TSC)
	$(YML2_PROC) -y $< -o $@ transport_status_code.yml2

.PHONY: clean

clean:
	rm -f $(TARGET)
