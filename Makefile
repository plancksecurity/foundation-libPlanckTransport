.PHONY: src test install uninstall clean

all: src

src:
	$(MAKE) -C src

#test: src
#	$(MAKE) -C test

clean:
	$(MAKE) -C src clean
#	$(MAKE) -C test clean

install:
	$(MAKE) -C src install

uninstall:
	$(MAKE) -C src uninstall