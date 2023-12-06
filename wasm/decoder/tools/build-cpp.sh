#!/bin/sh -e
BUILD_DIR=$(pwd)
SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
echo "BUILD_DIR: $BUILD_DIR"
echo "SCRIPTDIR: $SCRIPTDIR"
docker build -t cpp-build - < $SCRIPTDIR/cpp.Dockerfile
docker run --rm -v $BUILD_DIR:/src cpp-build "$@"

cp $BUILD_DIR/build/avif_decoder.js $BUILD_DIR/../../flutter_avif_web/web/avif_decoder.js
cp $BUILD_DIR/build/avif_decoder.wasm $BUILD_DIR/../../flutter_avif_web/web/avif_decoder.wasm
#cp $BUILD_DIR/build/avif_decoder.worker.js $BUILD_DIR/../../flutter_avif_web/web/avif_decoder.worker.js