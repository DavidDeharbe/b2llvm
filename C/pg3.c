unsigned char c1, c2;
unsigned char f1 (void) {
  unsigned char c3, c4;
  c1 = 48;
  c2 = 76;
  if (c1 < c2) {
    unsigned char c3;
    c3 = c1;
    c1 = c2;
    c2 = c3;
  }
  c4 = 0;
  while (c1 /= c2) {
    c3 = c1 - c2;
    c1 = c2;
    c2 = c3;
    c4 = c4 + 1;
  }
  return c4;
}
