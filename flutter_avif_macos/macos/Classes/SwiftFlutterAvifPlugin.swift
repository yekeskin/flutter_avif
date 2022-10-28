import FlutterMacOS

public class SwiftFlutterAvifPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "flutter_avif", binaryMessenger: registrar.messenger)
    let instance = SwiftFlutterAvifPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }
}
