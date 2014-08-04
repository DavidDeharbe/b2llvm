#ifndef _Array_h
#define _Array_h

#include <stdint.h>
#include <stdbool.h>
#include <string.h>
#ifdef __cplusplus
extern "C" {
#endif /* __cplusplus */


/* Clause SETS */

/* Clause CONCRETE_VARIABLES */


/* Clause CONCRETE_CONSTANTS */
/* Basic constants */
/* Array and record constants */
extern void Array__INITIALISATION(void);

/* Clause OPERATIONS */

extern void Array__set(int32_t ix, int32_t tt);
extern void Array__read(int32_t ix, int32_t *tt);
extern void Array__swap(int32_t ix, int32_t jx);

#ifdef __cplusplus
}
#endif /* __cplusplus */


#endif /* _Array_h */
