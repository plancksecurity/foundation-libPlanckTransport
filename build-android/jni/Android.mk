$(warning ==== LIBPEPTRANSPORT android.mk START)
LOCAL_PATH := $(call my-dir)


include $(CLEAR_VARS)

LOCAL_MODULE    := pEpTransport


LOCAL_CPP_FEATURES += exceptions
LOCAL_CPPFLAGS += -std=c++14 -DANDROID_STL=c++_shared

#FIXME: WORKAROUND
STUB = $(shell sh $(LOCAL_PATH)/../takeOutHeaderFiles.sh $(LOCAL_PATH)/../../../pEpEngine/ $(LOCAL_PATH)/../../)
$(info $(STUB))

LIB_PEP_TRANSPORT_INCLUDE_FILES := $(wildcard $(LOCAL_PATH)/../../src/*.h*)

LOCAL_C_INCLUDES += $(LIB_PEP_TRANSPORT_INCLUDE_FILES:%=%)

LOCAL_EXPORT_C_INCLUDES += $(LOCAL_PATH)../include

LOCAL_SRC_FILES += $(wildcard $(LOCAL_PATH)/../../src/*.c)


include $(BUILD_STATIC_LIBRARY)

