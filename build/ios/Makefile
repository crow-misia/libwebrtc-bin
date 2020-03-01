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
	zip -9 -r $(PACKAGE_DIR)/libwebrtc-ios.zip WebRTC.framework/*

.PHONY: patch
patch: common-patch

.PHONY: build
build: patch
	cd $(SRC_DIR)/tools_webrtc/ios && \
	./build_ios_libs.py --arch x64 arm64 -e -o $(BUILD_DIR)

