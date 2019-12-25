BASE_DIR := $(CURDIR)/../..

ifeq ($(USE_CCACHE),1)
CC_WRAPPER := cc_wrapper="$(THIRD_PARTY_DIR)/ccache"
else
CC_WRAPPER :=
endif

PACKAGE_SUFFIX :=

ifeq ($(USE_H264),1)
RTC_USE_H264 := rtc_use_h264=true
PACKAGE_SUFFIX += -h264
else
RTC_USE_H264 := rtc_use_h264=false
endif

ifeq ($(USE_X11),1)
RTC_USE_X11 := rtc_use_x11=true
PACKAGE_SUFFIX += -x11
else
RTC_USE_X11 := rtc_use_x11=false
endif

.PHONY: clean
clean:
	rm -rf $(PACKAGE_DIR)
	rm -rf $(BUILD_DIR)

.PHONY: download
download:
	$(WEBRTC_DIR)/src/build/linux/sysroot_scripts/install-sysroot.py --arch=$(TARGET_CPU)

.PHONY: package
package: copy
	cd $(PACKAGE_DIR) && \
	tar -Jcf libwebrtc-$(TARGET_OS)-$(TARGET_CPU)$(strip $(PACKAGE_SUFFIX)).tar.xz include lib NOTICE VERSION

.PHONY: copy
copy:
	rm -rf $(PACKAGE_DIR)
	mkdir -p $(PACKAGE_DIR)/lib
	mkdir -p $(PACKAGE_DIR)/include
	cp $(BUILD_DIR)/obj/libwebrtc.a $(PACKAGE_DIR)/lib/libwebrtc.a
	cp $(BUILD_DIR)/obj/third_party/boringssl/libboringssl.a $(PACKAGE_DIR)/lib/libboringssl.a

	rsync -amv '--include=*/' '--include=*.h' '--include=*.hpp' '--exclude=*' $(SRC_DIR)/. $(PACKAGE_DIR)/include/.

	cp -f $(BASE_DIR)/NOTICE $(PACKAGE_DIR)/
	echo '$(WEBRTC_VERSION)' > $(PACKAGE_DIR)/VERSION
