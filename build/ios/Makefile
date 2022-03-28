include ../../VERSION

BASE_DIR := $(CURDIR)/../..

include ../env.mk

TARGET_OS ?= ios
TARGET_CPU =

include ../common.mk

EXTRA_GN_ARGS := \
	use_rtti=true \
	rtc_libvpx_build_vp9=true \
	rtc_include_tests=false \
	rtc_build_tools=false \
	rtc_build_examples=false \
	rtc_use_h264=false

.PHONY: all
all: clean build package

.PHONY: package
package:
	mkdir -p $(PACKAGE_DIR) && \
	cd $(BUILD_DIR) && \
	zip -9 -r $(PACKAGE_DIR)/$(subst $(space),,$(PACKAGE_NAME)).zip WebRTC.xcframework/*

.PHONY: patch
patch: common-patch
	echo "apply iOS patches ..." \
	&& cd $(SRC_DIR) \
	&& patch -p1 < $(PATCH_DIR)/ios_disable_mllvm.patch

.PHONY: build
build: patch
	cd $(SRC_DIR)/tools_webrtc/ios && \
	python3 build_ios_libs.py -o $(BUILD_DIR) --build_config release --bitcode --extra-gn-args '$(EXTRA_GN_ARGS) $(CC_WRAPPER)'

