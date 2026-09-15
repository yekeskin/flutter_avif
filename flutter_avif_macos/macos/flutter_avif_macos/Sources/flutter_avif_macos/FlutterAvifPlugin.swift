import FlutterMacOS
#if SWIFT_PACKAGE
import flutter_avif_macos_linker
#endif

public class FlutterAvifPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    flutter_avif_macos_force_link()
    let channel = FlutterMethodChannel(name: "flutter_avif", binaryMessenger: registrar.messenger)
    let instance = FlutterAvifPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }
}
