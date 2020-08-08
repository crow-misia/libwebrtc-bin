include ../../VERSION

BASE_DIR := $(realpath ../..)

include ../env.mk

TARGET_OS ?= android
TARGET_CPU =

include ../common.mk

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
	mkdir -p $(PACKAGE_DIR)/include
	cp -f $(BUILD_DIR)/armeabi-v7a/libwebrtc.a $(PACKAGE_DIR)/lib/armeabi-v7a/
	cp -f $(BUILD_DIR)/arm64-v8a/libwebrtc.a $(PACKAGE_DIR)/lib/arm64-v8a/
	cp -f $(BUILD_DIR)/libwebrtc.jar $(PACKAGE_DIR)/jar/
	cp -f $(BUILD_DIR)/libwebrtc.aar $(PACKAGE_DIR)/aar/
	rsync -amv '--include=*/' '--include=*.h' '--include=*.hpp' '--exclude=*' $(SRC_DIR)/. $(PACKAGE_DIR)/include/.
	cp -f $(BUILD_DIR)/LICENSE.md $(PACKAGE_DIR)/NOTICE
	echo '$(WEBRTC_VERSION)' > $(PACKAGE_DIR)/VERSION

.PHONY: patch
patch: common-patch
	cd $(SRC_DIR) \
	&& patch -p2 < $(PATCH_DIR)/android_version.patch \
	&& $(SCRIPTS_DIR)/generate_android_version.sh $(SRC_DIR) $(WEBRTC_COMMIT) $(WEBRTC_SEMANTIC_VERSION)

.PHONY: build
build: patch
	cd $(SRC_DIR) && \
	vpython $(SRC_DIR)/tools_webrtc/android/build_aar.py \
	  --build-dir $(BUILD_DIR) \
	  --output $(BUILD_DIR)/libwebrtc.aar \
	  --arch armeabi-v7a arm64-v8a \
	  --extra-gn-args '$(CC_WRAPPER) is_debug=false rtc_use_h264=false rtc_include_tests=false is_clang=true rtc_build_json=true use_custom_libcxx=false use_rtti=true'

	ln -sf $(DEPOT_TOOLS_DIR)/vpython $(DEPOT_TOOLS_DIR)/python
	cd $(SRC_DIR) && \
	vpython $(DEPOT_TOOLS_DIR)/gn.py gen $(BUILD_DIR)/armeabi-v7a-static --args='$(CC_WRAPPER) target_os="android" target_cpu="arm" arm_version=7 is_debug=false rtc_build_examples=false rtc_use_h264=false rtc_include_tests=false is_clang=true rtc_build_json=true use_custom_libcxx=false use_rtti=true' && \
	ninja -C $(BUILD_DIR)/armeabi-v7a-static && \
	ninja -C $(BUILD_DIR)/armeabi-v7a-static native_api

	cd $(BUILD_DIR)/armeabi-v7a-static/obj && \
	$(SRC_DIR)/third_party/llvm-build/Release+Asserts/bin/llvm-ar -rc $(BUILD_DIR)/armeabi-v7a/libwebrtc.a `find . -name '*.o'`

	cd $(SRC_DIR) && \
	vpython $(DEPOT_TOOLS_DIR)/gn.py gen $(BUILD_DIR)/arm64-v8a-static --args='$(CC_WRAPPER) target_os="android" target_cpu="arm64" is_debug=false rtc_build_examples=false rtc_use_h264=false rtc_include_tests=false is_clang=true rtc_build_json=true use_custom_libcxx=false use_rtti=true' && \
	ninja -C $(BUILD_DIR)/arm64-v8a-static && \
	ninja -C $(BUILD_DIR)/arm64-v8a-static native_api

	cd $(BUILD_DIR)/arm64-v8a-static/obj && \
	$(SRC_DIR)/third_party/llvm-build/Release+Asserts/bin/llvm-ar -rc $(BUILD_DIR)/arm64-v8a/libwebrtc.a `find . -name '*.o'`

	cd $(BUILD_DIR) && \
	unzip libwebrtc.aar
	rm -rf $(BUILD_DIR)/jni
	rm -f $(BUILD_DIR)/AndroidManifest.xml
	mv $(BUILD_DIR)/classes.jar $(BUILD_DIR)/libwebrtc.jar

