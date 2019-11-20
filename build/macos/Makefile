include ../../VERSION

TARGET_OS=macos
TARGET_CPU=x64

include ../common.mk

.PHONY: all
all: clean build compress

.PHONY: build
build:
	export PATH="$(DEPOT_TOOLS_DIR):$(PATH)" && \
	cd $(WEBRTC_DIR)/src && \
	gn gen $(WEBRTC_DIR)/out --args='$(CC_WRAPPER) target_os="mac" is_debug=false treat_warnings_as_errors=false $(RTC_USE_H264) rtc_include_tests=false rtc_build_examples=false is_component_build=false use_rtti=true strip_debug_info=true symbol_level=0 libcxx_abi_unstable=false' && \
	ninja -C $(WEBRTC_DIR)/out && \
	ninja -C $(WEBRTC_DIR)/out \
	  builtin_audio_decoder_factory \
	  default_task_queue_factory \
	  native_api \
	  default_codec_factory_objc \
	  peerconnection \
	  videocapture_objc
