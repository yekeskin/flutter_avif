#include "include/flutter_avif_linker.h"
#include <stdint.h>
#include <stddef.h>
#include <stdbool.h>

typedef int64_t (*AvifFunction)(int64_t, const unsigned char *, uintptr_t);
extern int64_t decode_single_frame_image(int64_t, const unsigned char *, uintptr_t);
extern int64_t init_memory_decoder(int64_t, const unsigned char *, uintptr_t);
extern int64_t reset_decoder(int64_t, const unsigned char *, uintptr_t);
extern int64_t dispose_decoder(int64_t, const unsigned char *, uintptr_t);
extern int64_t get_next_frame(int64_t, const unsigned char *, uintptr_t);
extern int64_t encode_avif(int64_t, const unsigned char *, uintptr_t);

typedef bool (*DartPostCObject)(int64_t, void *);
extern void store_dart_post_cobject(DartPostCObject);
static void (*volatile store_post_cobject)(DartPostCObject) = store_dart_post_cobject;

// Dart looks these functions up by name. Volatile reads retain their link
// references even in optimized builds without calling the codec at registration.
static AvifFunction volatile functions[] = {
    decode_single_frame_image, init_memory_decoder, reset_decoder,
    dispose_decoder, get_next_frame, encode_avif,
};

void flutter_avif_force_link(void) {
    (void)store_post_cobject;
    for (size_t i = 0; i < sizeof(functions) / sizeof(functions[0]); ++i) {
        (void)functions[i];
    }
}
