#import "FlutterAvifPlugin.h"
#import "flutter_avif.h"

// Exported by the allo-isolate crate, so cbindgen leaves it out of flutter_avif.h.
void store_dart_post_cobject(void *post_cobject);

// Dart looks the Rust functions up by name, so nothing links against them. Referencing them from
// a `used` table keeps the linker from dropping them, also when the plugin is linked statically.
__attribute__((used)) static const void *const kFlutterAvifFunctions[] = {
  (const void *)decode_single_frame_image,
  (const void *)init_memory_decoder,
  (const void *)reset_decoder,
  (const void *)dispose_decoder,
  (const void *)get_next_frame,
  (const void *)encode_avif,
  (const void *)store_dart_post_cobject,
};

@implementation FlutterAvifPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"flutter_avif"
            binaryMessenger:[registrar messenger]];
  FlutterAvifPlugin* instance = [[FlutterAvifPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"getPlatformVersion" isEqualToString:call.method]) {
    result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
  } else {
    result(FlutterMethodNotImplemented);
  }
}

@end
