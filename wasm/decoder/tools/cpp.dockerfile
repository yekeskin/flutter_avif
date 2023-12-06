FROM emscripten/emsdk:3.1.30
RUN apt-get update && apt-get install -qqy autoconf libtool pkg-config
ENV CFLAGS "-O3 -flto"
ENV CXXFLAGS "${CFLAGS} -std=c++17"
ENV LDFLAGS "${CFLAGS} \
-s FILESYSTEM=0 \
-s ALLOW_MEMORY_GROWTH=1 \
-s TEXTDECODER=0 \
-s EXPORTED_FUNCTIONS=_malloc \
-s EXPORT_NAME=avif_decoder_wasm \
"

# Build and cache standard libraries with these flags + Embind.
RUN emcc ${CXXFLAGS} ${LDFLAGS} --bind -xc++ /dev/null -o /dev/null

WORKDIR /src
CMD ["sh", "-c", "emmake make -j`nproc`"]