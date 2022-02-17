#include <stdint.h>
#include <stdlib.h>
#include "blake3.h"

uint16_t UncleBlake3_KEY_LEN() {
  return (BLAKE3_KEY_LEN);
}

uint16_t UncleBlake3_OUT_LEN() {
  return (BLAKE3_OUT_LEN);
}

void * UncleBlake3_Init() {
  blake3_hasher *retVal = malloc(sizeof (blake3_hasher)); // TODO: check result
  blake3_hasher_init(retVal);
  return retVal;
}

void * UncleBlake3_InitWithKey(const uint8_t *key) {
  blake3_hasher *retVal = malloc(sizeof (blake3_hasher)); // TODO: check result
  blake3_hasher_init_keyed(retVal, key);
  return retVal;
}

void * UncleBlake3_InitWithKeySeed(const void *context, size_t context_len) {
  blake3_hasher *retVal = malloc(sizeof (blake3_hasher)); // TODO: check result
  blake3_hasher_init_derive_key_raw(retVal, context, context_len);
  return retVal;
}

void UncleBlake3_Update(void *instance, const void *input, size_t inputByteLen) {
  return blake3_hasher_update((blake3_hasher *)instance, input, inputByteLen);
}

void UncleBlake3_Final(void *instance, uint8_t *output, size_t outputByteLen) {
  return blake3_hasher_finalize((const blake3_hasher *)instance, output, outputByteLen);
}

void UncleBlake3_Destroy(void *instance) {
  free(instance);
}
