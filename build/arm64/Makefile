include ../../VERSION

BASE_DIR=$(CURDIR)/../..

ifeq ($(USE_CCACHE),1)
CC_WRAPPER=cc_wrapper="${THIRD_PARTY_DIR}/ccache"
else
CC_WRAPPER=
endif

ifeq ($(USE_H264),1)
RTC_USE_H264=rtc_use_h264=true
PACKAGE_SUFFIX=-h264
else
RTC_USE_H264=rtc_use_h264=false
PACKAGE_SUFFIX=
endif

TARGET_OS=linux
TARGET_CPU=arm64

.PHONY: all
all: clean build compress

.PHONY: build
build: download
	export PATH="${DEPOT_TOOLS_DIR}:$(PATH)" && \
	cd ${WEBRTC_DIR}/src && \
	gn gen ${WEBRTC_DIR}/out --args='${CC_WRAPPER} target_os="${TARGET_OS}" target_cpu="${TARGET_CPU}" is_debug=false treat_warnings_as_errors=false ${RTC_USE_H264} rtc_include_tests=false rtc_build_examples=false is_desktop_linux=false rtc_build_json=true use_rtti=true strip_debug_info=true symbol_level=0 use_custom_libcxx=false use_custom_libcxx_for_host=false' && \
	ninja -C ${WEBRTC_DIR}/out

.PHONY: clean
clean:
	rm -rf ${RELEASE_DIR}
	rm -rf ${WEBRTC_DIR}/out

.PHONY: download
download:
	${WEBRTC_DIR}/src/build/linux/sysroot_scripts/install-sysroot.py --arch=${TARGET_CPU}

.PHONY: compress
compress: copy
	cd ${RELEASE_DIR} && \
	tar -cf - include lib NOTICE VERSION | xz -6e -c - > libwebrtc-linux-${TARGET_OS}-${TARGET_CPU}${PACKAGE_SUFFIX}.tar.xz

.PHONY: copy
copy:
	install -m 0644 -D ${WEBRTC_DIR}/out/obj/libwebrtc.a ${RELEASE_DIR}/lib/libwebrtc.a

	cd ${WEBRTC_DIR}/src &&	\
	for h in $$(find api audio base call common_audio common_video logging media modules p2p pc rtc_base rtc_tools system_wrappers video -type f -name '*.h'); do \
	  install -m 0644 -D $$h ${RELEASE_DIR}/include/$$h; \
	done
	cd ${WEBRTC_DIR}/src/third_party/abseil-cpp && \
	for h in $$(find . -type f -name '*.h'); do \
	  install -m 0644 -D $$h ${RELEASE_DIR}/include/$$h; \
	done
	cd ${WEBRTC_DIR}/src/third_party/jsoncpp/source/include && \
	for h in $$(find . -type f -name '*.h'); do \
	  install -m 0644 -D $$h ${RELEASE_DIR}/include/$$h; \
	done
	cp -f ${WEBRTC_DIR}/src/*.h ${RELEASE_DIR}/include
	cp -f ${BASE_DIR}/NOTICE ${RELEASE_DIR}/
	echo "${WEBRTC_VERSION}" > ${RELEASE_DIR}/VERSION
