typedef struct ModuloName_internalState{
	unsigned char x;
	unsigned int y;
} * Tpoint;


void d00 (Tpoint pointerMVars)
{
	return;
	
}
void d000(Tpoint pointerMVars,Tpoint pointerVars2teste)
{
	return;
	
}

void d0 (Tpoint pointerMVars)
{
	int a = 99;
	
}


void da (Tpoint pointerMVars)
{
	pointerMVars->x=50;
	
}

void db (Tpoint pointerMVars, unsigned char d)
{
	int a = d;
}

void de (Tpoint pointerMVars, unsigned char d)
{
	pointerMVars->x = d;
}

void df (Tpoint pointerMVars, unsigned char d)
{
	pointerMVars->x = d;
	pointerMVars->y = d;
}

void dg (Tpoint pointerMVars, unsigned char d)
{
	pointerMVars->x = d + pointerMVars->x;
	pointerMVars->y = d + pointerMVars->y;
}

