#include "stdio.h"
#include "Array.h"

/* Clause CONCRETE_CONSTANTS */
/* Basic constants */

/* Array and record constants */
/* Clause CONCRETE_VARIABLES */

static int Array3[10][20][30];
static int32_t Array__arr[100];
static int32_t Array__arr_n[100][100];
static int32_t Array__tmp[100];

void Array__setZero(void);

void Array__setZeroSimp(void);

void Array__setInitializing(void);

int main(void){
   Array__setZero();
   printf("%d\n", Array3[2][3][4]);
  return 0;
}

/* Clause INITIALISATION */
void Array__INITIALISATION(void)
{
    Array__arr[1] = 100;
    Array__arr_n[0][0] = 10;
    memmove(Array__tmp,Array__arr,100 * sizeof(int32_t));
    Array__setZero();
    Array__setInitializing();

}

/* Clause OPERATIONS */
void Array__setZero(void)
{   int x=2; int y=3 ; int z=4 ;
    Array3[x][y][z]=7;
}

void Array__setInitializing(void)
{
    //Array3={{{1},{2}} {{3},{4}}};
    int values [2] [2] [4] = { { { 1, 2, 3, 4}, { 1, 2, 3, 4 }}
                              ,{ { 1, 2, 3, 4}, { 1, 2, 3, 4 }} };
    values[0][0][0] = 1;
    values[0][0][1] = 2;
    values[0][0][2] = 3;
    values[0][0][2] = 4;
    
    values[0][1][0] = 1;
    values[0][1][1] = 2;
    values[0][1][2] = 3;
    values[0][1][2] = 4;
    
    values[1][0][0] = 1;
    values[1][0][1] = 2;
    values[1][0][2] = 3;
    values[1][0][2] = 4;
    
    values[1][1][0] = 1;
    values[1][1][1] = 2;
    values[1][1][2] = 3;
    values[1][1][2] = 4;

}



void Array__setZeroSuggestedByDavid(void)
{  /* David gives a similar sugestion wit intermediate steps */   

	Array__arr_n[2][5]=4;
    	printf("%d\n",Array__arr_n[2][5]);     
	int * mid = Array__arr_n[2];
	printf("%d\n",mid[5]);
}




void Array__set(int32_t ix, int32_t tt)
{
    if(((((ix) >= (0)) &&
            ((ix) <= (99))) &&
        ((tt) >= (0))) &&
    ((tt) <= (1000)))
    {
        Array__arr[ix] = tt;
    }
}

void Array__read(int32_t ix, int32_t *tt)
{
    if(((ix) >= (0)) &&
    ((ix) <= (99)))
    {
        (*tt) = Array__arr[ix];
    }
    else
    {
        (*tt) = 0;
    }
}

void Array__swap(int32_t ix, int32_t jx)
{
    if(((((ix) >= (0)) &&
            ((ix) <= (99))) &&
        ((jx) >= (0))) &&
    ((jx) <= (99)))
    {
        {
            int32_t temp;
            
            temp = Array__arr[jx];
            Array__arr[jx] = Array__arr[ix];
            Array__arr[ix] = temp;
        }
    }
}

