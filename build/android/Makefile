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
	cd $(BUILD_DIR) && \
	tar -Jcf $(PACKAGE_DIR)/$(subst $(space),,$(PACKAGE_NAME)).tar.xz libwebrtc.aar LICENSE.md

.PHONY: patch
patch: common-patch
	cd $(SRC_DIR) \
	&& patch -p2 < $(PATCH_DIR)/android_version.patch \
	&& $(SCRIPTS_DIR)/generate_android_version.sh $(SRC_DIR) $(WEBRTC_COMMIT) $(WEBRTC_SEMANTIC_VERSION)

.PHONY: build
build: patch
	cd $(SRC_DIR) && \
	./tools_webrtc/android/build_aar.py \
	  --build-dir $(BUILD_DIR) \
	  --output $(BUILD_DIR)/libwebrtc.aar \
	  --arch armeabi-v7a arm64-v8a \
	  --extra-gn-args ' \
	    is_debug=false \
	    rtc_use_h264=false \
	    rtc_include_tests=false \
	    rtc_build_json=true \
	    use_rtti=true \
	  '
