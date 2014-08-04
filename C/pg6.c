#include <stdlib.h>
unsigned fib (unsigned n)
{
  unsigned * tab = malloc((n+1) * sizeof(unsigned));
  unsigned res;
  int i;
  tab[0] = 0;
  tab[1] = 1;
  for (i = 2; i <= n; ++i)
    tab[i] = tab[i-1]+tab[i-2];
  res = tab[n];
  return res;
}
