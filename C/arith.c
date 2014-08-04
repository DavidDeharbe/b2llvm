int f(int a, int b)
{
  int c;
  c = a + b;
  a = b - c;
  b = c * a;
  c = a / b;
  a = b % c;
  b = -a;
  return b;
}
