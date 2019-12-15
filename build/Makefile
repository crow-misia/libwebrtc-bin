include ../VERSION

BASE_DIR := $(CURDIR)/..

include ./env.mk

.PHONY: help
help:
	@echo "Usage:"
	@echo "  make <option> <packageName>"
	@echo ""
	@echo "<option>:"
	@echo " - USE_CCACHE=1"
	@echo " - USE_H264=1"
	@echo " - USE_X11=1"
	@echo ""
	@echo "<packageName>:"
	@for pkg in $(PACKAGE_NAMES); do echo " - $$pkg"; done
	@echo ""

ifeq (x$(USE_CCACHE),x1)
$(CCACHE):
	@echo "Build CCache"
	cd $(THIRD_PARTY_DIR) \
	&& curl -L -o ccache.tar.gz https://github.com/ccache/ccache/releases/download/v$(CCACHE_VERSION)/ccache-$(CCACHE_VERSION).tar.gz \
	&& rm -rf ccache-$(CCACHE_VERSION) \
	&& tar xf ccache.tar.gz \
	&& cd $(THIRD_PARTY_DIR)/ccache-$(CCACHE_VERSION) \
	&& ./configure \
	&& make \
	&& mv ccache $(CCACHE) \
	&& cd $(THIRD_PARTY_DIR) \
	&& rm -rf ccache.tar.gz ccache-$(CCACHE_VERSION)
else
CCACHE :=
endif

define generateRules

.PHONY: $(1)
$(1): $(1).clean $(1).build $(1).package

.PHONY: $(1).clean
$(1).clean:
	make -C $(1) clean

.PHONY: $(1).build
$(1).build: prepare fetch sync patch
	make $(SUB_DIR_OPTS) -C $(1) build

.PHONY: $(1).build-nofetch
$(1).build-nofetch: sync patch
	make $(SUB_DIR_OPTS) -C $(1) build

.PHONY: $(1).copy
$(1).copy:
	make $(SUB_DIR_OPTS) -C $(1) copy

.PHONY: $(1).package
$(1).package:
	make $(SUB_DIR_OPTS) -C $(1) package

endef

$(foreach pkg, $(PACKAGE_NAMES), $(eval $(call generateRules,$(pkg))))


.PHONY: prepare
prepare:
	mkdir -p $(THIRD_PARTY_DIR)
ifneq (x$(CCACHE),x)
	make $(CCACHE)
endif

.PHONY: depot_tools
depot_tools: prepare
	if [ -d $(DEPOT_TOOLS_DIR) ]; then \
	  echo "Syncing depot_tools ..."; \
	  cd $(DEPOT_TOOLS_DIR); \
	  git reset --hard; \
	  git fetch; \
	  git checkout -f origin/HEAD; \
	  git clean -xfd; \
	else \
	  echo "Getting depot_tools ..."; \
	  git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git $(DEPOT_TOOLS_DIR); \
	  cd $(DEPOT_TOOLS_DIR); \
	  git checkout -f origin/HEAD; \
	fi;

.PHONY: fetch
fetch: depot_tools
	mkdir -p $(CACHE_DIR) \
	&& cd $(CACHE_DIR) \
	&& if [ -f $(CACHE_DIR)/.gclient ]; then \
	  echo "Syncing webrtc ..."; \
	  cd $(CACHE_DIR)/src; \
	  git checkout .; \
	  git clean -xdf; \
	  cd third_party; \
	  git checkout .; \
	  git clean -xdf; \
	else \
	  echo "Getting WEBRTC ..."; \
	  rm -f $(DEPOT_TOOLS_DIR)/metrics.cfg; \
	  rm -rf $(CACHE_DIR)/src; \
	  fetch --nohooks webrtc; \
	fi \
	&& cd $(CACHE_DIR)/src \
	&& git fetch \
	&& git checkout -f $(WEBRTC_COMMIT) \
	&& cd $(CACHE_DIR) \
	&& gclient sync -Rv

.PHONY: sync
sync:
ifneq ($(CACHE_DIR),$(WEBRTC_DIR))
	rm -rf $(WEBRTC_DIR)
	cp -r $(CACHE_DIR) $(WEBRTC_DIR)
else
	:
endif

.PHONY: patch
patch:
	echo "apply patches ..." \
	&& cd $(WEBRTC_DIR)/src \
	&& patch -p1 < $(PATCH_DIR)/nacl_armv6_2.patch \
	&& patch -p2 < $(PATCH_DIR)/4k.patch \
	&& patch -p2 < $(PATCH_DIR)/macos_h264_encoder.patch

.PHONY: clean
clean:
	rm -rf $(WEBRTC_DIR)
	rm -rf $(RELEASE_DIR)
