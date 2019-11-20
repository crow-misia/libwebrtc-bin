BASE_DIR=$(CURDIR)/../..

ifeq ($(USE_CCACHE),1)
CC_WRAPPER=cc_wrapper="$(THIRD_PARTY_DIR)/ccache"
else
CC_WRAPPER=
endif

PACKAGE_SUFFIX=

ifeq ($(USE_H264),1)
RTC_USE_H264=rtc_use_h264=true
PACKAGE_SUFFIX+=-h264
else
RTC_USE_H264=rtc_use_h264=false
endif

ifeq ($(USE_X11),1)
RTC_USE_X11=rtc_use_x11=true
PACKAGE_SUFFIX+=-x11
else
RTC_USE_X11=rtc_use_x11=false
endif

.PHONY: clean
clean:
	rm -rf $(RELEASE_DIR)
	rm -rf $(WEBRTC_DIR)/out

.PHONY: download
download:
	$(WEBRTC_DIR)/src/build/linux/sysroot_scripts/install-sysroot.py --arch=$(TARGET_CPU)

.PHONY: compress
compress: copy
	cd $(RELEASE_DIR) && \
	tar -Jcf libwebrtc-$(TARGET_OS)-$(TARGET_CPU)$(strip $(PACKAGE_SUFFIX)).tar.xz include lib NOTICE VERSION

.PHONY: copy
copy:
	install -m 0755 -d $(RELEASE_DIR)/lib
	install -m 0644 $(WEBRTC_DIR)/out/obj/libwebrtc.a $(RELEASE_DIR)/lib/libwebrtc.a
	install -m 0644 $(WEBRTC_DIR)/out/obj/third_party/boringssl/libboringssl.a $(RELEASE_DIR)/lib/libboringssl.a

	cd $(WEBRTC_DIR)/src && \
	for h in $$(find api audio base call common_audio common_video logging media modules p2p pc rtc_base rtc_tools system_wrappers video -type f -name '*.h'); do \
	  install -m 0755 -d `dirname $(RELEASE_DIR)/include/$$h`; \
	  install -m 0644 $$h $(RELEASE_DIR)/include/$$h; \
	done
	cd $(WEBRTC_DIR)/src/third_party/abseil-cpp && \
	for h in $$(find . -type f -name '*.h'); do \
	  install -m 0755 -d `dirname $(RELEASE_DIR)/include/$$h`; \
	  install -m 0644 $$h $(RELEASE_DIR)/include/$$h; \
	done
	cd $(WEBRTC_DIR)/src/third_party/boringssl/src/include && \
	for h in $$(find . -type f -name '*.h'); do \
	  install -m 0755 -d `dirname $(RELEASE_DIR)/include/$$h`; \
	  install -m 0644 $$h $(RELEASE_DIR)/include/$$h; \
	done
	cd $(WEBRTC_DIR)/src/third_party/jsoncpp/source/include && \
	for h in $$(find . -type f -name '*.h'); do \
	  install -m 0755 -d `dirname $(RELEASE_DIR)/include/$$h`; \
	  install -m 0644 $$h $(RELEASE_DIR)/include/$$h; \
	done
	cd $(WEBRTC_DIR)/src/third_party/libyuv/include && \
	for h in $$(find . -type f -name '*.h'); do \
	  install -m 0755 -d `dirname $(RELEASE_DIR)/include/$$h`; \
	  install -m 0644 $$h $(RELEASE_DIR)/include/$$h; \
	done
	cp -f $(WEBRTC_DIR)/src/*.h $(RELEASE_DIR)/include
	cp -f $(BASE_DIR)/NOTICE $(RELEASE_DIR)/
	echo '$(WEBRTC_VERSION)' > $(RELEASE_DIR)/VERSION
