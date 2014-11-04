typedef struct TSpoint {
	char x;
	int y;
	int z;
} Tpoint;

Tpoint orig = { 'o', 0, 0 } ;

Tpoint dx(Tpoint p)
{
  Tpoint res;
  res = p;
  res.y = res.y+1;
  orig.x = p.x;
  return res;
}
