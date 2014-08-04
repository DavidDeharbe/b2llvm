#include <stdbool.h>

bool f(bool a, bool b)
{
  int c;
  c = a == true ? b : false;
  a = !(true);
  b = false;
  return a && b || c;
}
