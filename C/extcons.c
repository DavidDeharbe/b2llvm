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

extern char const k1;
extern int k2;
typedef enum {a, b, c, d} e;
void f (int * pi)
{
  e v;
  if (v == a)
    v = b;
  else
    *pi += *pi + k1 + k2;
}
