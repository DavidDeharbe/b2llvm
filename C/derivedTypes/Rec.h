#ifndef _Rec_h
#define _Rec_h

#include <stdint.h>
#include <stdbool.h>
#ifdef __cplusplus
extern "C" {
#endif /* __cplusplus */


/* Clause SETS */

/* Clause CONCRETE_VARIABLES */


/* Clause CONCRETE_CONSTANTS */
/* Basic constants */
/* Array and record constants */
extern void Rec__INITIALISATION(void);

/* Clause OPERATIONS */

extern void Rec__positive(bool *res);
extern void Rec__withrdaw(int32_t amt);
extern void Rec__unsafe_dec(void);

#ifdef __cplusplus
}
#endif /* __cplusplus */


#endif /* _Rec_h */
