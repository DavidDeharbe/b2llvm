#include <limits.h>
#include <stdio.h>

int main (void) {
  signed char c, d;
  for (c = SCHAR_MIN; c < SCHAR_MAX; ++c)
    fprintf(stdout, "%hhi %hhu\n", c, c);
  fprintf(stdout, "%hhi %hhu\n", c, c);
  return 0;
}
