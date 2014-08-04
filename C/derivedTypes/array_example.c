#include <stdio.h> 
	//int arr[99];
        struct tstruct { int arr[99]; int anyVar1; int anyVar2;  } ref;
	const int start_arr =1  ;

void set();
void get();	

int main (){
	set();

	printf("%d",ref.arr[4]);
}

void set(){
	int ind = 7;
	int tmp = 4 - start_arr;
	ref.arr[tmp]=5;
}

void get(){
	int a= ref.arr[4];
}
