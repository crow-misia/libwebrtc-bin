include ../../VERSION

BASE_DIR := $(CURDIR)/../..

include ../env.mk

TARGET_OS ?= ios
TARGET_CPU =

include ../common.mk

.PHONY: all
all: clean build package

.PHONY: package
package:
	mkdir -p $(PACKAGE_DIR) && \
	cd $(BUILD_DIR) && \
	zip -9 -r $(PACKAGE_DIR)/$(subst $(space),,$(PACKAGE_NAME)).zip WebRTC.xcframework/*

.PHONY: patch
patch: common-patch
	echo "apply ios patches ..." \
	&& cd $(SRC_DIR) \
	&& patch -p2 < $(PATCH_DIR)/ios_disable_dsym.patch

.PHONY: build
build: patch
	cd $(SRC_DIR)/tools_webrtc/ios && \
	./build_ios_libs.py -e -o $(BUILD_DIR) --bitcode --extra-gn-args 'use_xcode_clang=false enable_dsyms=true rtc_libvpx_build_vp9=true $(CC_WRAPPER)'

