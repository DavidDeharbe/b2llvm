
void acc (int * a, int v)
{
  * a = * a + v;
}

void test (void)
{
  int a;
  int b[2];
  a = 42;
  b[0] = 2;
  b[1] = 3;
  acc(&a, b[0]);
  acc(&b[1], b[0]);
}
