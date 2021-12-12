BASE_DIR := $(realpath ../..)

empty :=
space:= $(empty) $(empty)

ifeq ($(USE_CCACHE),1)
CC_WRAPPER := cc_wrapper="$(THIRD_PARTY_DIR)/ccache"
else
CC_WRAPPER :=
endif

PACKAGE_NAME := libwebrtc

ifneq (x$(TARGET_OS),x)
PACKAGE_NAME += -$(TARGET_OS)
endif
ifneq (x$(TARGET_CPU),x)
PACKAGE_NAME += -$(TARGET_CPU)
endif

ifeq ($(USE_H264),1)
RTC_USE_H264 := rtc_use_h264=true
PACKAGE_NAME += -h264
else
RTC_USE_H264 := rtc_use_h264=false
endif

ifeq ($(USE_X11),1)
RTC_USE_X11 := rtc_use_x11=true
PACKAGE_NAME += -x11
else
RTC_USE_X11 := rtc_use_x11=false
endif

.PHONY: common-clean
clean:
	rm -rf $(PACKAGE_DIR)/*
	rm -rf $(BUILD_DIR)

.PHONY: download
download:
ifneq (x$(TARGET_CPU),x)
	$(WEBRTC_DIR)/src/build/linux/sysroot_scripts/install-sysroot.py --arch=$(TARGET_CPU)
endif

.PHONY: common-patch
common-patch:
	echo "apply patches ..." \
	&& cd $(SRC_DIR) \
	&& patch -p1 < $(PATCH_DIR)/nacl_armv6_2.patch \
	&& patch -p2 < $(PATCH_DIR)/4k.patch \
	&& patch -p2 < $(PATCH_DIR)/macos_h264_encoder.patch \
	&& patch -p2 < $(PATCH_DIR)/disable_use_hermetic_xcode_on_linux.patch \
	&& patch -p2 < $(PATCH_DIR)/add_licenses.patch

.PHONY: common-package
common-package: copy
	cd $(PACKAGE_DIR) && \
	tar -Jcf $(subst $(space),,$(PACKAGE_NAME)).tar.xz include lib NOTICE VERSION

.PHONY: generate-licenses
generate-licenses:
	python3 $(SRC_DIR)/tools_webrtc/libs/generate_licenses.py --target :webrtc $(BUILD_DIR) $(BUILD_DIR)

.PHONY: common-copy
common-copy: generate-licenses
	rm -rf $(PACKAGE_DIR)/{lib,include,NOTICE,VERSION}
	mkdir -p $(PACKAGE_DIR)/lib
	mkdir -p $(PACKAGE_DIR)/include
	cp $(BUILD_DIR)/obj/libwebrtc.a $(PACKAGE_DIR)/lib/libwebrtc.a
	cp $(BUILD_DIR)/obj/third_party/boringssl/libboringssl.a $(PACKAGE_DIR)/lib/libboringssl.a

	rsync -amv '--include=*/' '--include=*.h' '--include=*.hpp' '--exclude=*' $(SRC_DIR)/. $(PACKAGE_DIR)/include/.

	cp -f $(BUILD_DIR)/LICENSE.md $(PACKAGE_DIR)/NOTICE
	echo '$(WEBRTC_VERSION)' > $(PACKAGE_DIR)/VERSION
