include ../VERSION

LC_ALL = C
export LC_ALL

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
	&& mkdir build \
	&& cd build \
	&& cmake -DZSTD_FROM_INTERNET=ON -DHIREDIS_FROM_INTERNET=ON -DCMAKE_BUILD_TYPE=Release .. \
	&& make \
	&& mv ccache $(CCACHE) \
	&& ln -sf $(CCACHE) $(THIRD_PARTY_DIR)/ccache \
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

$(1).fetch: depot_tools
	$(SCRIPTS_DIR)/fetch_webrtc.sh $(WEBRTC_DIR) $(DEPOT_TOOLS_DIR) $(WEBRTC_COMMIT) $(CONFIG_DIR)/$(1)

.PHONY: $(1).build
$(1).build: prepare $(CCACHE) $(1).fetch sync
	make $(SUB_DIR_OPTS) -C $(1) build

.PHONY: $(1).build-nofetch
$(1).build-nofetch: $(CCACHE) sync
	rm -rf $(BUILD_DIR)
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

.PHONY: depot_tools
depot_tools: prepare
	if [ -d $(DEPOT_TOOLS_DIR) ]; then \
	  echo "Syncing depot_tools ..."; \
	  cd $(DEPOT_TOOLS_DIR); \
	  git reset --hard; \
	  git fetch; \
	  git checkout -f origin/HEAD; \
	else \
	  echo "Getting depot_tools ..."; \
	  git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git $(DEPOT_TOOLS_DIR); \
	fi

.PHONY: sync
sync:

.PHONY: clean
clean:
	rm -rf $(WEBRTC_DIR)
	rm -rf $(BUILD_DIR)
	rm -rf $(PACKAGE_DIR)
