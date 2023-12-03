#include <emscripten/emscripten.h>
#include <emscripten/bind.h>
#include <emscripten/val.h>
#include "avif/avif.h"

using namespace emscripten;

thread_local const val Uint8Array = val::global("Uint8Array");
thread_local const val AvifFrame = val::global("AvifFrame");
thread_local const val AvifInfo = val::global("AvifInfo");

std::map<std::string, avifDecoder *> decoders;
std::map<std::string, std::string *> decoderDatas;

val decodeSingleFrameImage(std::string avifBytes)
{
    avifDecoder *decoder = avifDecoderCreate();
    avifResult setMemoryResult = avifDecoderSetIOMemory(decoder, (uint8_t *)avifBytes.c_str(), avifBytes.length());

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

    val result = AvifFrame.new_(Uint8Array.new_(typed_memory_view(rgb.rowBytes * rgb.height, rgb.pixels)), rgb.width, rgb.height, decoder->imageTiming.duration);

    avifRGBImageFreePixels(&rgb);
    avifDecoderDestroy(decoder);

    return result;
}

val initMemoryDecoder(std::string key, std::string avifBytes)
{
    if (decoders.count(key) != 0)
    {
        avifDecoder *decoder = decoders[key];
        return AvifInfo.new_(0, 0, decoder->imageCount, decoder->duration);
    }

    avifDecoder *decoder = avifDecoderCreate();

    std::string *bytes = new std::string(avifBytes);
    avifResult setMemoryResult = avifDecoderSetIOMemory(decoder, (uint8_t *)bytes->c_str(), bytes->length());

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

    decoders[key] = decoder;
    decoderDatas[key] = bytes;

    return AvifInfo.new_(0, 0, decoder->imageCount, decoder->duration);
}

val getNextFrame(std::string key)
{
    if (decoders.count(key) == 0)
    {
        return val::null();
    }
    avifDecoder *decoder = decoders[key];

    avifResult decodeResult = avifDecoderNextImage(decoder);
    if (decodeResult == AVIF_RESULT_NO_IMAGES_REMAINING)
    {
        avifDecoderReset(decoder);
        decodeResult = avifDecoderNextImage(decoder);
    }

    if (decodeResult != AVIF_RESULT_OK)
    {
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
        return val::null();
    }

    val result = AvifFrame.new_(Uint8Array.new_(typed_memory_view(rgb.rowBytes * rgb.height, rgb.pixels)), rgb.width, rgb.height, decoder->imageTiming.duration);

    avifRGBImageFreePixels(&rgb);

    return result;
}

val resetDecoder(std::string key)
{
    if (decoders.count(key) == 0)
    {
        return val::null();
    }
    avifDecoder *decoder = decoders[key];

    avifDecoderReset(decoder);
    return val::null();
}

val disposeDecoder(std::string key)
{
    if (decoders.count(key) == 0)
    {
        return val::null();
    }
    avifDecoder *decoder = decoders[key];
    std::string *decoderData = decoderDatas[key];
    avifDecoderDestroy(decoder);
    delete decoderData;
    decoders.erase(key);
    decoderDatas.erase(key);
    return val::null();
}

EMSCRIPTEN_BINDINGS(my_module)
{
    function("decodeSingleFrameImage", &decodeSingleFrameImage);
    function("initMemoryDecoder", &initMemoryDecoder);
    function("getNextFrame", &getNextFrame);
    function("resetDecoder", &resetDecoder);
    function("disposeDecoder", &disposeDecoder);
}
