#import "FlutterAvifPlugin.h"

@implementation FlutterAvifPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"flutter_avif"
            binaryMessenger:[registrar messenger]];
  FlutterAvifPlugin* instance = [[FlutterAvifPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

@end
