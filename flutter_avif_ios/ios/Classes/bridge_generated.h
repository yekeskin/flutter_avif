#include <stdbool.h>
#include <stdint.h>
#include <stdlib.h>
typedef struct _Dart_Handle* Dart_Handle;

typedef struct DartCObject DartCObject;

typedef int64_t DartPort;

typedef bool (*DartPostCObjectFnType)(DartPort port_id, void *message);

typedef struct wire_uint_8_list {
  uint8_t *ptr;
  int32_t len;
} wire_uint_8_list;

typedef struct wire_EncodeFrame {
  struct wire_uint_8_list *data;
  uint64_t duration_in_timescale;
} wire_EncodeFrame;

typedef struct wire_list_encode_frame {
  struct wire_EncodeFrame *ptr;
  int32_t len;
} wire_list_encode_frame;

typedef struct DartCObject *WireSyncReturn;

void store_dart_post_cobject(DartPostCObjectFnType ptr);

Dart_Handle get_dart_object(uintptr_t ptr);

void drop_dart_object(uintptr_t ptr);

uintptr_t new_dart_opaque(Dart_Handle handle);

intptr_t init_frb_dart_api_dl(void *obj);

void wire_init_memory_decoder(int64_t port_,
                              struct wire_uint_8_list *key,
                              struct wire_uint_8_list *avif_bytes);

void wire_reset_decoder(int64_t port_, struct wire_uint_8_list *key);

void wire_dispose_decoder(int64_t port_, struct wire_uint_8_list *key);

void wire_get_next_frame(int64_t port_, struct wire_uint_8_list *key);

void wire_encode_avif(int64_t port_,
                      int32_t width,
                      int32_t height,
                      int32_t speed,
                      int32_t max_threads,
                      uint64_t timescale,
                      int32_t max_quantizer,
                      int32_t min_quantizer,
                      int32_t max_quantizer_alpha,
                      int32_t min_quantizer_alpha,
                      struct wire_list_encode_frame *image_sequence);

struct wire_list_encode_frame *new_list_encode_frame_0(int32_t len);

struct wire_uint_8_list *new_uint_8_list_0(int32_t len);

void free_WireSyncReturn(WireSyncReturn ptr);

static int64_t dummy_method_to_enforce_bundling(void) {
    int64_t dummy_var = 0;
    dummy_var ^= ((int64_t) (void*) wire_init_memory_decoder);
    dummy_var ^= ((int64_t) (void*) wire_reset_decoder);
    dummy_var ^= ((int64_t) (void*) wire_dispose_decoder);
    dummy_var ^= ((int64_t) (void*) wire_get_next_frame);
    dummy_var ^= ((int64_t) (void*) wire_encode_avif);
    dummy_var ^= ((int64_t) (void*) new_list_encode_frame_0);
    dummy_var ^= ((int64_t) (void*) new_uint_8_list_0);
    dummy_var ^= ((int64_t) (void*) free_WireSyncReturn);
    dummy_var ^= ((int64_t) (void*) store_dart_post_cobject);
    dummy_var ^= ((int64_t) (void*) get_dart_object);
    dummy_var ^= ((int64_t) (void*) drop_dart_object);
    dummy_var ^= ((int64_t) (void*) new_dart_opaque);
    return dummy_var;
}
