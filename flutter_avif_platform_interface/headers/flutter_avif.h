#include <stdarg.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdlib.h>

typedef struct DartData {
  uint8_t *ptr;
  int32_t len;
} DartData;

struct DartData decode_single_frame_image(const unsigned char *ptr, uintptr_t len);

struct DartData init_memory_decoder(const unsigned char *ptr, uintptr_t len);

bool reset_decoder(const unsigned char *ptr, uintptr_t len);

bool dispose_decoder(const unsigned char *ptr, uintptr_t len);

struct DartData get_next_frame(const unsigned char *ptr, uintptr_t len);

struct DartData encode_avif(const unsigned char *ptr, uintptr_t len);

void free_dart_data(struct DartData data);
