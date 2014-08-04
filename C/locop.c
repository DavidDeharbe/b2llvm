extern void promop1(void);

static void locop1(void)
{
  promop1();
}

static void locop3();
static void locop2(void)
{
  locop3();
}

static void locop3(void)
{
}

void op(void)
{
  locop1();
  locop2();
  locop3();
}
