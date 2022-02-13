#if defined(__AVX512F__) && defined(__AVX512VL__)
  #include "libK12-avx512.a.headers/KangarooTwelve.h"
#elif defined(__AVX2__) && defined(__SSSE3__)
  #include "libK12-avx2-ssse3.a.headers/KangarooTwelve.h"
#elif defined(__AVX2__)
  #include "libK12-avx2.a.headers/KangarooTwelve.h"
#elif defined(__LP64__) && defined(__SSSE3__)
  #include "libK12-ssse3-64.a.headers/KangarooTwelve.h"
#elif defined(__LP64__)
  #include "libK12-generic-64.a.headers/KangarooTwelve.h"
#elif defined(__SSSE3__)
  #include "libK12-ssse3.a.headers/KangarooTwelve.h"
#else
  #include "libK12-generic.a.headers/KangarooTwelve.h"
#endif

#include <stdlib.h>

void * SleepingKangaroo12_Init(int outputLength) {
  KangarooTwelve_Instance *retVal = malloc(sizeof (KangarooTwelve_Instance)); // TODO: check result
  KangarooTwelve_Initialize(retVal, outputLength); // TODO: check result
  return retVal;
}

int SleepingKangaroo12_Update(void *instance, const unsigned char *input, size_t inputByteLen) {
  return KangarooTwelve_Update((KangarooTwelve_Instance *)instance, input, inputByteLen);
}

int SleepingKangaroo12_Final(void *instance, unsigned char *output, const unsigned char *customization, size_t customByteLen) {
  return KangarooTwelve_Final((KangarooTwelve_Instance *)instance, output, customization, customByteLen);
}

int SleepingKangaroo12_Squeeze(void *instance, unsigned char *output, size_t customByteLen) {
  return KangarooTwelve_Squeeze((KangarooTwelve_Instance *)instance, output, customByteLen);
}

void SleepingKangaroo12_Destroy(void *instance) {
  free(instance);
}
