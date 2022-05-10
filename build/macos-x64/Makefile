include ../../VERSION

BASE_DIR := $(CURDIR)/../..

include ../env.mk

TARGET_OS ?= macos
TARGET_CPU ?= x64

include ../common.mk

EXTRA_GN_ARGS := \
	target_os="mac" \
	target_cpu="$(TARGET_CPU)" \
	enable_stripping=true \
	enable_dsyms=true \
	is_debug=false \
	treat_warnings_as_errors=false \
	$(RTC_USE_H264) \
	rtc_include_tests=false \
	rtc_build_tools=false \
	rtc_build_examples=false \
	rtc_libvpx_build_vp9=true \
	rtc_enable_symbol_export=true \
	rtc_enable_objc_symbol_export=true \
	is_component_build=false \
	use_rtti=true

.PHONY: all
all: clean build package

.PHONY: package
package: copy
	cd $(PACKAGE_DIR) && \
	tar -Jcf $(subst $(space),,$(PACKAGE_NAME)).tar.xz include lib NOTICE VERSION Frameworks

.PHONY: copy
copy: common-copy
	rm -f $(PACKAGE_DIR)/lib/libboringssl.a
	rm -rf $(PACKAGE_DIR)/Frameworks/WebRTC.xcframework
	xcodebuild \
	  -create-xcframework \
	  -framework $(BUILD_DIR)/WebRTC.framework \
	  -debug-symbols $(BUILD_DIR)/WebRTC.dSYM \
	  -output $(PACKAGE_DIR)/Frameworks/WebRTC.xcframework

.PHONY: patch
patch: common-patch

.PHONY: build
build: patch
	cd $(SRC_DIR) && \
	gn gen $(BUILD_DIR) --args='$(EXTRA_GN_ARGS) $(CC_WRAPPER)' && \
	ninja -C $(BUILD_DIR) && \
	ninja -C $(BUILD_DIR) \
	  api/audio_codecs:builtin_audio_decoder_factory \
	  api/task_queue:default_task_queue_factory \
	  sdk:native_api \
	  sdk:default_codec_factory_objc \
	  pc:peerconnection \
	  sdk:videocapture_objc \
	  sdk:mac_framework_objc

	cd $(BUILD_DIR)/obj && \
	/usr/bin/ar -rc $(BUILD_DIR)/obj/libwebrtc.a `find . -name '*.o'`

