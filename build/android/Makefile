include ../../VERSION

BASE_DIR := $(CURDIR)/../..

include ../env.mk

TARGET_OS ?= android
TARGET_CPU =

include ../common.mk

.PHONY: all
all: clean build package

.PHONY: package
package:
	mkdir -p $(PACKAGE_DIR) && \
	cd $(PACKAGE_DIR) && \
	tar -Jcf $(subst $(space),,$(PACKAGE_NAME)).tar.xz libwebrtc.aar LICENSE.md

.PHONY: build
build:
	cd $(SRC_DIR) && \
	./tools_webrtc/android/build_aar.py --build-dir $(BUILD_DIR) --output $(BUILD_DIR)/libwebrtc.aar
