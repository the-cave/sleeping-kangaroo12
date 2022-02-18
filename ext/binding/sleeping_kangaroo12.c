#include <stdlib.h>
#include "libk12.a.headers/KangarooTwelve.h"

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
