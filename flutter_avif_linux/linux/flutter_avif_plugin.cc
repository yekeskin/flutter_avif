#include "include/flutter_avif/flutter_avif_plugin.h"

#include <flutter_linux/flutter_linux.h>
#include <gtk/gtk.h>

#define FLUTTER_AVIF_PLUGIN(obj) \
  (G_TYPE_CHECK_INSTANCE_CAST((obj), flutter_avif_plugin_get_type(), \
                              FlutterAvifPlugin))

struct _FlutterAvifPlugin {
  GObject parent_instance;
};

G_DEFINE_TYPE(FlutterAvifPlugin, flutter_avif_plugin, g_object_get_type())


static void flutter_avif_plugin_dispose(GObject* object) {
  G_OBJECT_CLASS(flutter_avif_plugin_parent_class)->dispose(object);
}

static void flutter_avif_plugin_class_init(FlutterAvifPluginClass* klass) {
  G_OBJECT_CLASS(klass)->dispose = flutter_avif_plugin_dispose;
}

static void flutter_avif_plugin_init(FlutterAvifPlugin* self) {}

void flutter_avif_plugin_register_with_registrar(FlPluginRegistrar* registrar) {
  FlutterAvifPlugin* plugin = FLUTTER_AVIF_PLUGIN(
      g_object_new(flutter_avif_plugin_get_type(), nullptr));

  g_object_unref(plugin);
}
