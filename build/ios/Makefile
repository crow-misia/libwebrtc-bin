include ../../VERSION

BASE_DIR := $(CURDIR)/../..

include ../env.mk

TARGET_OS ?= ios
TARGET_CPU =

include ../common.mk

EXTRA_GN_ARGS := \
	is_debug=false \
	$(RTC_USE_H264) \
	rtc_libvpx_build_vp9=true \
	rtc_include_tests=false \
	rtc_build_examples=false \
	rtc_build_tools=false \
	rtc_use_perfetto=false \
	use_rtti=true \
	libyuv_include_tests=false

.PHONY: all
all: clean build package

.PHONY: package
package:
	mkdir -p $(PACKAGE_DIR) && \
	cd $(BUILD_DIR) && \
	zip -9 -r $(PACKAGE_DIR)/$(subst $(space),,$(PACKAGE_NAME)).zip WebRTC.xcframework/*

.PHONY: patch
patch: common-patch

.PHONY: build
build: patch
	cd $(SRC_DIR)/tools_webrtc/ios && \
	vpython3 build_ios_libs.py -o $(BUILD_DIR) --build_config release --extra-gn-args '$(EXTRA_GN_ARGS) $(CC_WRAPPER)'
