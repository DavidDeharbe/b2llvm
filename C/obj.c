#include <stdbool.h>
struct impl1 {
  int v1;
  int v2;
  bool v3;
} instance, * impl1_anonymous;

void op1(struct impl1 * a)
{
  a->v1 = a->v1 + 1;
}

void op2(struct impl1 * a, int * r)
{
  * r = a->v1;
}

struct impl2 {
  int w1;
  struct impl1 * w2;
  struct impl1 * w3;
} * impl2_anonymous;

void op3(struct impl2 * a)
{
  op1(a->w2);
  op1(a->w3);
}
