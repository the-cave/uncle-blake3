#include <stdlib.h>
#include <stdint.h>
#include "blake3.h"

void * UncleBlake3_Init() {
  blake3_hasher *retVal = malloc(sizeof (blake3_hasher)); // TODO: check result
  blake3_hasher_init(retVal); // TODO: check result
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
