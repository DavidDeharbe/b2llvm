#include <stdbool.h>

typedef int t1;
static const t1 v1 = 42;

typedef enum { red, green, blue } t2;
static t2 v2 = green;

const bool v3 = true;

const int v4[2][2] = { { 0, 1}, {1, 0} };

int f(void)
{
  if (v2 == blue)
    return v1;
  else if (v2 == red)
    return 1;
  else
    return 0;
}
