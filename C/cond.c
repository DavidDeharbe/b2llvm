int test(int a, int b, int c)
{
  if (a <= b && b <= c)
    return 1;
  else if (!(a > c))
    return 2;
  else if (a > b || a > 2 * c)
    return 3;
  return 4;
}
