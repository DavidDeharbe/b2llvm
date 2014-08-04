class point {
 private:
  float x;
  float y;
 public:
  point(const point & p)
    {
      x = p.x;
      y = p.y;
    }
  point()
    {
      x = y = 0.0f;
    }
  void dx(float d)
    {
      x += d;
    }
};

point p;
