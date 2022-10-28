#include "include/flutter_avif_linux/flutter_avif_linux_plugin.h"

#include <flutter_linux/flutter_linux.h>
#include <gtk/gtk.h>

#define FLUTTER_AVIF_LINUX_PLUGIN(obj) \
  (G_TYPE_CHECK_INSTANCE_CAST((obj), flutter_avif_linux_plugin_get_type(), \
                              FlutterAvifLinuxPlugin))

struct _FlutterAvifLinuxPlugin {
  GObject parent_instance;
};

G_DEFINE_TYPE(FlutterAvifLinuxPlugin, flutter_avif_linux_plugin, g_object_get_type())


static void flutter_avif_linux_plugin_dispose(GObject* object) {
  G_OBJECT_CLASS(flutter_avif_linux_plugin_parent_class)->dispose(object);
}

static void flutter_avif_linux_plugin_class_init(FlutterAvifLinuxPluginClass* klass) {
  G_OBJECT_CLASS(klass)->dispose = flutter_avif_linux_plugin_dispose;
}

static void flutter_avif_linux_plugin_init(FlutterAvifLinuxPlugin* self) {}

void flutter_avif_linux_plugin_register_with_registrar(FlPluginRegistrar* registrar) {
  FlutterAvifLinuxPlugin* plugin = FLUTTER_AVIF_LINUX_PLUGIN(
      g_object_new(flutter_avif_linux_plugin_get_type(), nullptr));

  g_object_unref(plugin);
}
