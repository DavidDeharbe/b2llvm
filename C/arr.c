int a[128][32];
int coef[] = {4, 5, 6};
int m3(int n1, int n2, int n3)
{
  int num;
  int den;
  int n[3];
  n[0] = n1;
  n[1] = n2;
  n[2] = n3;
  num = 0;
  num += n[0]*10 * coef[0];
  num += n[1]*10 * coef[1];
  num += n[2]*10 * coef[2];
  return num;
}
