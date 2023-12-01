#include "if_loop_1.h"
#include "../integration_utils.h"
#include <stdlib.h>

int if_loop_1(in_int_t a[N], in_int_t n) {
  int sum = 0;
  for (int i = 0; i < n; i++) {
    int tmp = a[i] * 5;
    if (tmp > 10)
      sum += tmp;
  }
  return sum;
}

int main(void) {
  in_int_t a[N];
  for (int j = 0; j < N; ++j)
    a[j] = rand() % N;

  CALL_KERNEL(if_loop_1, a, N);
  return 0;
}