CODEC_URL = https://github.com/AOMediaCodec/libavif/archive/b7c5de33d2e4ee2c4b1caf123ebd041c9907eb4b.tar.gz
CODEC_PACKAGE = deps/libavif.tar.gz

LIBAOM_URL = https://aomedia.googlesource.com/aom/+archive/v3.7.1.tar.gz
LIBAOM_PACKAGE = deps/libaom.tar.gz

export CODEC_DIR = deps/libavif
export BUILD_DIR = deps/build
export LIBAOM_DIR = deps/libaom

override CFLAGS += "-Wno-unused-macros"
export

OUT_DEC_JS = build/avif_decoder.js
OUT_DEC_CPP = src/avif_decoder.cpp
ENVIRONMENT = web,worker

HELPER_MAKEFLAGS := -f helper.Makefile

.PHONY: all clean

all: $(OUT_DEC_JS)

$(OUT_DEC_JS): $(OUT_DEC_CPP) $(CODEC_DIR)/CMakeLists.txt $(LIBAOM_DIR)/CMakeLists.txt
	$(MAKE) \
		$(HELPER_MAKEFLAGS) \
		OUT_JS=$@ \
		OUT_CPP=$< \
		LIBAOM_FLAGS="\
			-DCONFIG_AV1_ENCODER=0 \
			-DCONFIG_MULTITHREAD=0 \
		" \
		ENVIRONMENT=$(ENVIRONMENT) \
		LIBAVIF_FLAGS="-DAVIF_CODEC_AOM_ENCODE=0"

$(CODEC_PACKAGE):
	mkdir -p $(@D)
	curl -sL $(CODEC_URL) -o $@

$(LIBAOM_PACKAGE):
	mkdir -p $(@D)
	curl -sL $(LIBAOM_URL) -o $@

$(CODEC_DIR)/CMakeLists.txt: $(CODEC_PACKAGE)
	mkdir -p $(@D)
	tar xzm --strip 1 -C $(@D) -f $(CODEC_PACKAGE)

$(LIBAOM_DIR)/CMakeLists.txt: $(LIBAOM_PACKAGE)
	mkdir -p $(@D)
	tar xzm -C $(@D) -f $(LIBAOM_PACKAGE)

clean:
	$(MAKE) $(HELPER_MAKEFLAGS) OUT_JS=$(OUT_DEC_JS) clean
