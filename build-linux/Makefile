# Content of this library
TARGET = libPEPTransport
OBJECTS = $(call find-objects,../src)
DEPFILES = $(call find-deps,../src)
HEADERS = $(call find-headers,../PublicHeaders/)

# Dependencies *within* this repo (other headers should be installed and found in $PREFIX).
INCLUDES = \
  $(call find-includes,..) \
	-I$(PEP_INCLUDE) \

# Only for making .so libs. Libs for static linking are defined with the final binary.
LIBS =

# Load the shared pEp ObjC Makefile.
MAKEFILE_COMMON ?= ../../../../pepgnustephelper/
include $(MAKEFILE_COMMON)/Makefile.common

# This enables proper header-dependencies based on .d files made by the compiler.
include $(DEPFILES)
