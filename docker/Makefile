ifeq (,$(shell readlink --canonicalize-existing ../VERSION))

BASE_DIR := $(CURDIR)
USE_CCACHE ?= 0

include $(BASE_DIR)/VERSION

include $(BASE_DIR)/build/env.mk

define generateRules

.PHONY: $(1)
$(1):
	make $(SUB_DIR_OPTS) CACHE_DIR=/root/webrtc-cache -C build $(1)

.PHONY: $(1).clean
$(1).clean:
	make -C build $(1).clean

.PHONY: $(1).build
$(1).build:
	make $(SUB_DIR_OPTS) CACHE_DIR=/root/webrtc-cache -C build $(1).build-nofetch

.PHONY: $(1).package
$(1).package:
	make $(SUB_DIR_OPTS) CACHE_DIR=/root/webrtc-cache -C build $(1).package

endef

else

DOCKER ?= docker

BASE_DIR := $(CURDIR)/..

include $(BASE_DIR)/VERSION

include $(BASE_DIR)/build/env.mk

WEBRTC_COMMIT_SHORT := $(shell echo $(WEBRTC_COMMIT) | cut -b 1-8)
WEBRTC_VERSION_SHORT := $(shell echo '$(WEBRTC_VERSION)' | cut -b 1-3)
IMAGE_VERSION := $(WEBRTC_VERSION_SHORT)-$(WEBRTC_COMMIT_SHORT)

define generateRules

.PHONY: $(1).prepare
$(1).prepare:
	rm -rf VERSION NOTICE LICENSE patch build
	cp -a ../VERSION ../NOTICE ../LICENSE ../patch ../build .
	DOCKER_BUILDKIT=1 $(DOCKER) build -t libwebrtc:$(IMAGE_VERSION) -f ./Dockerfile
	rm -rf VERSION NOTICE LICENSE patch build

.PHONY: $(1).edit
$(1).edit: $(1).prepare
	mkdir -p $(CURDIR)/../release
	$(DOCKER) run -it --rm -v $(CURDIR)/../release:/root/release libwebrtc:$(IMAGE_VERSION) /bin/bash -c 'cd /root && exec /bin/bash'

.PHONY: $(1)
$(1): $(1).prepare
	mkdir -p $(CURDIR)/../release
	$($(DOCKER) run -it --rm -v $(CURDIR)/../release:/root/release libwebrtc:$(IMAGE_VERSION) /bin/bash -c 'cd /root && make $(1)'

endef

endif

$(foreach pkg, $(PACKAGE_NAMES), $(eval $(call generateRules,$(pkg))))

