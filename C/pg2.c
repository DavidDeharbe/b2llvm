unsigned short c1, c2, c3, c4;
unsigned short f1 (void) {
  c1 = 96;
  c2 = 128;
  if (c1 < c2) {
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
