include ../../VERSION

TARGET_OS=linux
TARGET_CPU=arm

include ../common.mk

.PHONY: all
all: clean build compress

.PHONY: build
build: download
	export PATH="$(DEPOT_TOOLS_DIR):$(PATH)" && \
	cd $(WEBRTC_DIR)/src && \
	gn gen $(WEBRTC_DIR)/out --args='$(CC_WRAPPER) target_os="$(TARGET_OS)" target_cpu="$(TARGET_CPU)" is_debug=false treat_warnings_as_errors=false $(RTC_USE_H264) $(RTC_USE_X11) rtc_include_tests=false rtc_build_examples=false is_desktop_linux=false rtc_build_json=true use_rtti=true strip_debug_info=true symbol_level=0 use_custom_libcxx=false use_custom_libcxx_for_host=false' && \
	ninja -C $(WEBRTC_DIR)/out
