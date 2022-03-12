include ../../VERSION

BASE_DIR := $(realpath ../..)

include ../env.mk

TARGET_OS ?= android
TARGET_CPU =

include ../common.mk

EXTRA_GN_ARGS := \
	is_debug=false \
	is_java_debug=false \
	$(RTC_USE_H264) \
	rtc_build_tools=false \
	rtc_build_examples=false \
	rtc_include_tests=false \
	is_clang=true \
	is_component_build=false \
	rtc_enable_protobuf=false \
	rtc_build_json=true \
	use_rtti=true

.PHONY: all
all: clean build package

.PHONY: package
package: copy
	cd $(PACKAGE_DIR) && \
	tar -Jcf $(subst $(space),,$(PACKAGE_NAME)).tar.xz aar jar include lib NOTICE VERSION

.PHONY: copy
copy:
	rm -rf $(PACKAGE_DIR)/aar
	rm -rf $(PACKAGE_DIR)/jar
	rm -rf $(PACKAGE_DIR)/include
	rm -rf $(PACKAGE_DIR)/lib
	rm -f $(PACKAGE_DIR)/NOTICE
	rm -f $(PACKAGE_DIR)/VERSION
	mkdir -p $(PACKAGE_DIR)/aar
	mkdir -p $(PACKAGE_DIR)/jar
	mkdir -p $(PACKAGE_DIR)/lib/armeabi-v7a
	mkdir -p $(PACKAGE_DIR)/lib/arm64-v8a
	mkdir -p $(PACKAGE_DIR)/lib/x86_64
	mkdir -p $(PACKAGE_DIR)/include
	cp -f $(BUILD_DIR)/static/armeabi-v7a/libwebrtc.a $(PACKAGE_DIR)/lib/armeabi-v7a/
	cp -f $(BUILD_DIR)/static/arm64-v8a/libwebrtc.a $(PACKAGE_DIR)/lib/arm64-v8a/
	cp -f $(BUILD_DIR)/static/x86_64/libwebrtc.a $(PACKAGE_DIR)/lib/x86_64/
	cp -f $(BUILD_DIR)/libwebrtc.jar $(PACKAGE_DIR)/jar/
	cp -f $(BUILD_DIR)/libwebrtc.aar $(PACKAGE_DIR)/aar/
	rsync -amv '--include=*/' '--include=*.h' '--include=*.hpp' '--exclude=*' $(SRC_DIR)/. $(PACKAGE_DIR)/include/.
	rm -rf $(PACKAGE_DIR)/include/rtc_tools
	cp -f $(BUILD_DIR)/LICENSE.md $(PACKAGE_DIR)/NOTICE
	echo '$(WEBRTC_VERSION)' > $(PACKAGE_DIR)/VERSION

.PHONY: patch
patch: common-patch
	cd $(SRC_DIR) \
	&& patch -p2 < $(PATCH_DIR)/android_version.patch \
	&& $(SCRIPTS_DIR)/generate_android_version.sh $(SRC_DIR) $(WEBRTC_COMMIT) $(WEBRTC_SEMANTIC_VERSION)


define build-android
	cd $(SRC_DIR) && \
	gn gen $(BUILD_DIR)/static/$1 --args='$(EXTRA_GN_ARGS) $(CC_WRAPPER) target_os="android" target_cpu="$2" $3' && \
	ninja -C $(BUILD_DIR)/static/$1 && \
	ninja -C $(BUILD_DIR)/static/$1 native_api

	cd $(BUILD_DIR)/static/$1/obj && \
	rm -f sdk/android/libjingle_peerconnection_so/jni_onload.o && \
	$(SRC_DIR)/third_party/llvm-build/Release+Asserts/bin/llvm-ar -rc $(BUILD_DIR)/static/$1/libwebrtc.a `find . -name '*.o'`
endef

.PHONY: build
build: patch
	cd $(SRC_DIR) && \
	python3 $(SRC_DIR)/tools_webrtc/android/build_aar.py \
	  --build-dir $(BUILD_DIR)/aar \
	  --output $(BUILD_DIR)/libwebrtc.aar \
	  --arch armeabi-v7a arm64-v8a x86_64 \
	  --extra-gn-args '$(EXTRA_GN_ARGS) $(CC_WRAPPER)'

	$(call build-android,armeabi-v7a,arm,arm_version=7)
	$(call build-android,arm64-v8a,arm64)
	$(call build-android,x86_64,x64)

	cd $(BUILD_DIR) && \
	unzip -q libwebrtc.aar && \
	rm -rf jni && \
	rm -f AndroidManifest.xml && \
	mv classes.jar libwebrtc.jar

