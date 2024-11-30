#include <stdarg.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdlib.h>

typedef struct DartData
{
  uint8_t *ptr;
  int32_t len;
} DartData;

int64_t decode_single_frame_image(int64_t port, const unsigned char *ptr, uintptr_t len);

int64_t init_memory_decoder(int64_t port, const unsigned char *ptr, uintptr_t len);

int64_t reset_decoder(int64_t port, const unsigned char *ptr, uintptr_t len);

int64_t dispose_decoder(int64_t port, const unsigned char *ptr, uintptr_t len);

int64_t get_next_frame(int64_t port, const unsigned char *ptr, uintptr_t len);

int64_t encode_avif(int64_t port, const unsigned char *ptr, uintptr_t len);

static int64_t dummy_method_to_enforce_bundling(void)
{
  int64_t dummy_var = 0;
  dummy_var ^= ((int64_t)(void *)decode_single_frame_image);
  dummy_var ^= ((int64_t)(void *)init_memory_decoder);
  dummy_var ^= ((int64_t)(void *)reset_decoder);
  dummy_var ^= ((int64_t)(void *)dispose_decoder);
  dummy_var ^= ((int64_t)(void *)get_next_frame);
  dummy_var ^= ((int64_t)(void *)encode_avif);
  return dummy_var;
}