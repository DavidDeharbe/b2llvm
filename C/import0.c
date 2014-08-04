typedef struct counter_ {
	int value;
} counter;

typedef struct wrap_ {
	counter c1;
	counter c2;
} wrap;

void inc(counter * c) {
  c->value += 1;
}
void get(counter * c, int * Pint) {
  *Pint = c->value;
}

void tick(wrap * w) {
  int elapsed;
  inc(&w->c1);
  get(&w->c1, &elapsed);
  inc(&w->c2);
}
