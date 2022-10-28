#ifndef FLUTTER_PLUGIN_FLUTTER_AVIF_PLUGIN_H_
#define FLUTTER_PLUGIN_FLUTTER_AVIF_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter_plugin_registrar.h>

#include <memory>

namespace flutter_avif {

class FlutterAvifPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  FlutterAvifPlugin();

  virtual ~FlutterAvifPlugin();

  // Disallow copy and assign.
  FlutterAvifPlugin(const FlutterAvifPlugin&) = delete;
  FlutterAvifPlugin& operator=(const FlutterAvifPlugin&) = delete;

 private:
  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace flutter_avif

#ifdef FLUTTER_PLUGIN_IMPL
#define FLUTTER_PLUGIN_EXPORT __declspec(dllexport)
#else
#define FLUTTER_PLUGIN_EXPORT __declspec(dllimport)
#endif

#if defined(__cplusplus)
extern "C" {
#endif

    FLUTTER_PLUGIN_EXPORT void FlutterAvifPluginRegisterWithRegistrar(
        FlutterDesktopPluginRegistrarRef registrar);

#if defined(__cplusplus)
}  // extern "C"
#endif

#endif  // FLUTTER_PLUGIN_FLUTTER_AVIF_PLUGIN_H_
