$(warning ==== LIBPEPTRANSPORT android.mk START)
LOCAL_PATH := $(call my-dir)


include $(CLEAR_VARS)

LOCAL_MODULE    := pEpTransport


#LOCAL_CPP_FEATURES += exceptions
LOCAL_CPPFLAGS += -std=c99

#FIXME: WORKAROUND
STUB = $(shell sh $(LOCAL_PATH)/../takeOutHeaderFiles.sh $(LOCAL_PATH)/../../../planckCoreV3/ $(LOCAL_PATH)/../../)
$(info $(STUB))

LIB_PEP_TRANSPORT_INCLUDE_FILES := $(wildcard $(LOCAL_PATH)/../../src/*.h*)

LOCAL_C_INCLUDES += $(LOCAL_PATH)/../../../planckCoreV3/build-android/include \
				$(LIB_PEP_TRANSPORT_INCLUDE_FILES:%=%)

LOCAL_EXPORT_C_INCLUDES += $(LOCAL_PATH)../include

LOCAL_SRC_FILES += $(wildcard $(LOCAL_PATH)/../../src/*.c)


include $(BUILD_STATIC_LIBRARY)

