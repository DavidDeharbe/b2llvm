unsigned char c1, c2 = 0;
unsigned char w[] = {0, 1, 2};
signed char w2[] = {0, -1, -128, 1, 127};
void f2 (void) {
  ++c1;
}

void f3 (unsigned char v[5]) {
  w[0]++;
  c2 = v[3];
}

