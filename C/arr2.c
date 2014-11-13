#include <stdio.h>

void f(int v[4], int m[5][5])
{
  int a;
  int b;
  a = v[0];
  v[1] = a;
  a = a+v[1];
  b = m[0][0];
  b += m[0][1];
  b += m[1][0];
  printf("%i %i\n", a, b);
}
