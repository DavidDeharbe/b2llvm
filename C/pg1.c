static int a;

int f1 (void) {
  int c1, c2, c3, c4;
  c1 = 96 + a;
  c2 = 128;
  if (c1 < c2) {
    c3 = c1;
    c1 = c2;
    c2 = c3;
  }
  c4 = c4 + c2;
  while (c1 /= c2) {
    c3 = c1 - c2;
    c1 = c2;
    c2 = c3;
    c4 = c4 + 1;
  }
  return c4;
}
