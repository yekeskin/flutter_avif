#include <emscripten/emscripten.h>
#include <emscripten/bind.h>
#include <emscripten/val.h>
#include "avif/avif.h"

using namespace emscripten;

thread_local const val Uint8Array = val::global("Uint8Array");
thread_local const val DecodeData = val::global("DecodeData");

val decodeSingleFrameImage(std::string avif_bytes)
{
    avifDecoder *decoder = avifDecoderCreate();
    avifResult setMemoryResult = avifDecoderSetIOMemory(decoder, (uint8_t *)avif_bytes.c_str(), avif_bytes.length());

    if (setMemoryResult != AVIF_RESULT_OK)
    {
        avifDecoderDestroy(decoder);
        return val::null();
    }

    avifResult parseResult = avifDecoderParse(decoder);
    if (!(parseResult == AVIF_RESULT_OK || parseResult == AVIF_RESULT_BMFF_PARSE_FAILED))
    {
        avifDecoderDestroy(decoder);
        return val::null();
    }

    avifResult decodeResult = avifDecoderNextImage(decoder);
    if (decodeResult == AVIF_RESULT_NO_IMAGES_REMAINING)
    {
        avifDecoderReset(decoder);
        decodeResult = avifDecoderNextImage(decoder);
    }

    if (decodeResult != AVIF_RESULT_OK)
    {
        avifDecoderDestroy(decoder);
        return val::null();
    }

    avifRGBImage rgb;
    avifRGBImageSetDefaults(&rgb, decoder->image);
    rgb.format = AVIF_RGB_FORMAT_RGBA;
    rgb.depth = 8;
    rgb.alphaPremultiplied = AVIF_TRUE;

    avifRGBImageAllocatePixels(&rgb);
    avifResult conversionResult = avifImageYUVToRGB(decoder->image, &rgb);
    if (conversionResult != AVIF_RESULT_OK)
    {
        avifDecoderDestroy(decoder);
        return val::null();
    }

    val result = DecodeData.new_(Uint8Array.new_(typed_memory_view(rgb.rowBytes * rgb.height, rgb.pixels)), rgb.width, rgb.height);

    avifRGBImageFreePixels(&rgb);
    avifDecoderDestroy(decoder);

    return result;
}

EMSCRIPTEN_BINDINGS(my_module)
{
    function("decodeSingleFrameImage", &decodeSingleFrameImage);
}
