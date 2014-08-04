#include <stdio.h>
#include <stdbool.h>

void getbool(bool * Pbool) {
  *Pbool = true;
}

void getint(int * Pint) {
  *Pint = 42;
}

int main(void) {
  while(1) {
    char c1, nl;
    c1 = getchar();
    nl = getchar();
    switch(c1) {
      case 'q': return 0;
      case 'e': {
	bool b;
	int i;
	getbool(&b);
	getint(&i);
	printf("%i\n%i\n", b, i);
      }
    }
  }
}
