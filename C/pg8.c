typedef struct {
  float x;
  float y;
} * Tpoint;


void dx (Tpoint m, float d)
{
  m->x += d;
}

typedef struct {
  Tpoint p1;
  Tpoint p2;
} * Tsegment;

void segment_dx(Tsegment s, float d)
{
  dx(s->p1, d);
  dx(s->p2, d);
}
