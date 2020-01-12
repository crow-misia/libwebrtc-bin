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
	zip -9 -r $(PACKAGE_DIR)/WebRTC.framework.zip WebRTC.framework/*

.PHONY: build
build:
	cd $(SRC_DIR)/tools_webrtc/ios && \
	./build_ios_libs.py --arch x64 arm64 -e -o $(BUILD_DIR)

