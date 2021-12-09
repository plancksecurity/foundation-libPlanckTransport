root = ../../..

# Content of this library
TARGET_EXE = TestMirrorRPCServer
OBJECTS := $(patsubst %.m,%.o,$(wildcard ../*.m))
DEPFILES := $(wildcard ../*.d)
HEADERS :=


# Dependencies *within* this repo (other headers should be installed and found in $PREFIX).
# TODO: add more as needed.
INCLUDES = \
  -I$(root)/pEpIPsecTypes/C/ \
  -I$(root)/pEpRPCObjCAdapter/PublicHeaders/ \

# Since we link an excecutable here, these options matter a lot. We also need
# to list all transitive dependincies if we want to link statically.
# ObjC stuff needs to be linked with --whole-archive to mae Extensions work.
# Otherwise, we link "our" dependencies with -Bstatic to perfer static linking,
# but allow dynamic linking in the end for system stuff.
# TODO: this is a very rough guess for now.
LIBS = \
  -Wl,-Bstatic \
    -Wl,--whole-archive \
      -lpEpObjCAdapter \
      -lPEPObjCTypes \
      -lPEPObjCTypeUtils \
      -lPEPObjCAdapterProtocols \
      -lPEPIPsecObjCTypes \
      -lpEpIPsecObjCTypeUtils \
      -lpEpRPCObjCAdapter \
    -Wl,--no-whole-archive \
    -lpEpEngine -lasn1 -lsqlite3 -letpan -liconv -luuid \
    -lsequoia_openpgp_ffi -lhogweed -lnettle -lgmp -lbz2 \
    -lpEpRPC -lcapnp-rpc -lcapnp -lkj-async -lkj \
  -Wl,-Bdynamic \
  -ldl # dlsym is needed by some rust thing in sequoia.

# Default rule, to build the executable instead of libraries.
all: $(TARGET_EXE)

# Load the shared pEp ObjC Makefile.
MAKEFILE_COMMON ?= ../../../../pepgnustephelper/
include $(MAKEFILE_COMMON)/Makefile.common

# This enables proper header-dependencies based on .d files made by the compiler.
include $(DEPFILES)

