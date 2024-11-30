#include <stdarg.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdlib.h>

int64_t decode_single_frame_image(int64_t port, const unsigned char *ptr, uintptr_t len);

int64_t init_memory_decoder(int64_t port, const unsigned char *ptr, uintptr_t len);

int64_t reset_decoder(int64_t port, const unsigned char *ptr, uintptr_t len);

int64_t dispose_decoder(int64_t port, const unsigned char *ptr, uintptr_t len);

int64_t get_next_frame(int64_t port, const unsigned char *ptr, uintptr_t len);

int64_t encode_avif(int64_t port, const unsigned char *ptr, uintptr_t len);
