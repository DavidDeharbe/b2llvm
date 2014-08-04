struct point {
  float x;
  float y;
};


void middle (struct point p1, struct point p2, struct point * m)
{
  m->x = (p1.x + p2.x) / 2;
  m->y = (p1.y + p2.y) / 2;
}
