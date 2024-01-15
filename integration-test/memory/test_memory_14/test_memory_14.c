#include "test_memory_14.h"
#include "../../integration_utils.h"
#include <stdlib.h>

void test_memory_14(inout_int_t a[N], in_int_t b[N]) {
  for (unsigned i = 0; i < N; i++) {
    int x = a[i];
    if (b[i] > 5) {
      x = x + 1;
      b[i] = 0;
    }
    a[i] = x;
  }
}

int main(void) {
  inout_int_t a[N];
  in_int_t b[N];

  srand(13);
  for (unsigned j = 0; j < N; ++j) {
    a[j] = (rand() % 100) - 50;
    b[j] = (rand() % 100) - 50;
  }

  CALL_KERNEL(test_memory_14, a, b);
  return 0;
}
