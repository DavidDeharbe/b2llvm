/*
 * =====================================================================================
 *
 *       Filename:  exttype.c
 *
 *    Description:  i
 *
 *        Version:  1.0
 *        Created:  07/03/12 14:17:02
 *       Revision:  none
 *       Compiler:  gcc
 *
 *         Author:  YOUR NAME (), 
 *        Company:  
 *
 * =====================================================================================
 */
class t1;
extern t1 c1;
extern bool operator==(t1&, t1&);

typedef enum e1 { V1, V2 } e1;

e1 t2_of_t1(t1 & v, e1 * p1)
{
  *p1 = V1;
  if (v == c1)
    return V1;
  else
    return V2;

}

