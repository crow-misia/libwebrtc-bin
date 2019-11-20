include ../VERSION

BASE_DIR=$(CURDIR)/..

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

ifeq ($(USE_CCACHE),1)
CCACHE=${THIRD_PARTY_DIR}/ccache
${CCACHE}:
	@echo "Build CCache"
	curl -L -o ccache.tar.gz https://github.com/ccache/ccache/releases/download/v${CCACHE_VERSION}/ccache-${CCACHE_VERSION}.tar.gz
	rm -rf ccache-${CCACHE_VERSION}
	tar xf ccache.tar.gz
	mv ccache-${CCACHE_VERSION} ccache
	cd ccache && ./configure
	make -C ccache
	mv ccache/ccache ${CCACHE}
	rm -rf ccache.tar.gz ccache
else
CCACHE=
endif

SUB_DIR_OPTS=USE_CCACHE=$(USE_CCACHE) USE_H264=$(USE_H264) USE_X11=$(USE_X11)

define generateRules

.PHONY: $(1)
$(1): $(1).clean $(1).build $(1).compress

.PHONY: $(1).clean
$(1).clean:
	make -C $(1) clean

.PHONY: $(1).build
$(1).build: prepare ${CCACHE} depot_tools fetch
	make ${SUB_DIR_OPTS} -C $(1) build

.PHONY: $(1).copy
$(1).copy:
	make ${SUB_DIR_OPTS} -C $(1) copy

.PHONY: $(1).compress
$(1).compress:
	make ${SUB_DIR_OPTS} -C $(1) compress

endef

$(foreach pkg, $(PACKAGE_NAMES), $(eval $(call generateRules,$(pkg))))

${CCACHE}:
	@echo "Build CCache"
	curl -L -o ccache.tar.gz https://github.com/ccache/ccache/releases/download/v${CCACHE_VERSION}/ccache-${CCACHE_VERSION}.tar.gz
	rm -rf ccache-${CCACHE_VERSION}
	tar xf ccache.tar.gz
	mv ccache-${CCACHE_VERSION} ccache
	cd ccache && ./configure
	make -C ccache
	mv ccache/ccache ${CCACHE}
	rm -rf ccache.tar.gz ccache

.PHONY: prepare
prepare:
	mkdir -p ${BASE_DIR}/third_party

.PHONY: depot_tools
depot_tools:
	if [ -d ${DEPOT_TOOLS_DIR} ]; then \
	  echo "Syncing depot_tools ..."; \
	  git -C ${DEPOT_TOOLS_DIR} clean -fd; \
	  git -C ${DEPOT_TOOLS_DIR} pull -f origin master; \
	else \
	  echo "Getting depot_tools ..."; \
	  git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git ${DEPOT_TOOLS_DIR}; \
	fi;

.PHONY: fetch
fetch:
	export PATH="${DEPOT_TOOLS_DIR}:$(PATH)" && \
	if [ -f ${WEBRTC_DIR}/.gclient ]; then \
	  echo "Syncing webrtc ..."; \
	else \
	  echo "Getting WEBRTC ..."; \
	  mkdir -p ${WEBRTC_DIR}; \
	  rm -f ${DEPOT_TOOLS_DIR}/metrics.cfg; \
	  cd ${WEBRTC_DIR} && \
	  fetch --nohooks webrtc; \
	fi && \
	cd ${WEBRTC_DIR} && \
	gclient sync --with_branch_heads -r ${WEBRTC_COMMIT}

.PHONY: clean
clean:
	rm -rf ccache
	rm -rf ccache.tar.gz
	rm -rf ${THIRD_PARTY_DIR}
	rm -rf ${WEBRTC_DIR}
	rm -rf ${RELEASE_DIR}
