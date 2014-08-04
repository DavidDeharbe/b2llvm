/*
 * =====================================================================================
 *
 *       Filename:  extcons.c
 *
 *    Description:  
 *
 *        Version:  1.0
 *        Created:  07/03/12 14:08:50
 *       Revision:  none
 *       Compiler:  gcc
 *
 *         Author:  YOUR NAME (), 
 *        Company:  
 *
 * =====================================================================================
 */

extern int f(int, int, int *);

int g (int a)
{
  int b;
  b = f(a, a, &a);
  return b;
}
