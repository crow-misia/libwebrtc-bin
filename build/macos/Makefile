include ../../VERSION

BASE_DIR=$(CURDIR)/../..

ifeq ($(USE_CCACHE),1)
CC_WRAPPER=cc_wrapper="${THIRD_PARTY_DIR}/ccache"
else
CC_WRAPPER=
endif

.PHONY: all
all: clean build compress

.PHONY: build
build:
	export PATH="${DEPOT_TOOLS_DIR}:$(PATH)" && \
	cd ${WEBRTC_DIR}/src && \
	gn gen ${WEBRTC_DIR}/out --args='${CC_WRAPPER} target_os="mac" is_debug=false treat_warnings_as_errors=false rtc_use_h264=false rtc_include_tests=false rtc_build_examples=false is_component_build=false use_rtti=true strip_debug_info=true symbol_level=0 libcxx_abi_unstable=false' && \
	ninja -C ${WEBRTC_DIR}/out && \
	ninja -C ${WEBRTC_DIR}/out \
	  builtin_audio_decoder_factory \
	  default_task_queue_factory \
	  native_api \
	  default_codec_factory_objc \
	  peerconnection \
	  videocapture_objc

.PHONY: clean
clean:
	rm -rf ${RELEASE_DIR}
	rm -rf ${WEBRTC_DIR}/out

.PHONY: compress
compress: copy
	cd ${RELEASE_DIR} && \
	tar -Jcf libwebrtc-macos-x64.tar.xz include lib NOTICE VERSION

.PHONY: copy
copy:
	install -d ${RELEASE_DIR}/lib
	install -m 0644 ${WEBRTC_DIR}/out/obj/libwebrtc.a ${RELEASE_DIR}/lib/libwebrtc.a
	install -m 0644 ${WEBRTC_DIR}/out/obj/third_party/boringssl/libboringssl.a ${RELEASE_DIR}/lib/libboringssl.a

	cd ${WEBRTC_DIR}/src &&	\
	for h in $$(find api audio base call common_audio common_video logging media modules p2p pc rtc_base rtc_tools system_wrappers video -type f -name '*.h'); do \
	  install -d `dirname ${RELEASE_DIR}/include/$$h`; \
	  install -m 0644 $$h ${RELEASE_DIR}/include/$$h; \
	done
	cd ${WEBRTC_DIR}/src/third_party/abseil-cpp && \
	for h in $$(find . -type f -name '*.h'); do \
	  install -d `dirname ${RELEASE_DIR}/include/$$h`; \
	  install -m 0644 $$h ${RELEASE_DIR}/include/$$h; \
	done
	cd ${WEBRTC_DIR}/src/third_party/boringssl/src/include && \
	for h in $$(find . -type f -name '*.h'); do \
	  install -d `dirname ${RELEASE_DIR}/include/$$h`; \
	  install -m 0644 $$h ${RELEASE_DIR}/include/$$h; \
	done
	cd ${WEBRTC_DIR}/src/third_party/jsoncpp/source/include && \
	for h in $$(find . -type f -name '*.h'); do \
	  install -d `dirname ${RELEASE_DIR}/include/$$h`; \
	  install -m 0644 $$h ${RELEASE_DIR}/include/$$h; \
	done
	cd ${WEBRTC_DIR}/src/third_party/libyuv/include && \
	for h in $$(find . -type f -name '*.h'); do \
	  install -d `dirname ${RELEASE_DIR}/include/$$h`; \
	  install -m 0644 $$h ${RELEASE_DIR}/include/$$h; \
	done
	cp -f ${WEBRTC_DIR}/src/*.h ${RELEASE_DIR}/include
	cp -f ${BASE_DIR}/NOTICE ${RELEASE_DIR}/
	echo "${WEBRTC_VERSION}" > ${RELEASE_DIR}/VERSION
