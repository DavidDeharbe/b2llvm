static inline int exp(int a, int b)
{
  int r = 1;
  while (b != 0) {
    r *= a;
    --b;
  }
  return r;
}

int f (a, b)
{
  int r;
  r = exp(a, 0);
  r = exp(a, r);
  return r;
}
