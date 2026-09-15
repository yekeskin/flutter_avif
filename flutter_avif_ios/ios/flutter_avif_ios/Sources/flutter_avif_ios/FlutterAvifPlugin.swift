import Flutter
import UIKit
#if SWIFT_PACKAGE
import flutter_avif_linker
#endif

public class FlutterAvifPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    flutter_avif_force_link()
    let channel = FlutterMethodChannel(name: "flutter_avif", binaryMessenger: registrar.messenger())
    let instance = FlutterAvifPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard call.method == "getPlatformVersion" else {
      result(FlutterMethodNotImplemented)
      return
    }
    result("iOS " + UIDevice.current.systemVersion)
  }
}
