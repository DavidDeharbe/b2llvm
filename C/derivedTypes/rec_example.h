#ifndef _rec_example_h
#define _rec_example_h

#include <stdint.h>
#include <stdbool.h>
#ifdef __cplusplus
extern "C" {
#endif /* __cplusplus */


/* Clause SETS */
typedef enum
{
    rec_example__aa,
    rec_example__bb
    
} rec_example__ID;

/* Clause CONCRETE_VARIABLES */


/* Clause CONCRETE_CONSTANTS */
/* Basic constants */
/* Array and record constants */
extern void rec_example__INITIALISATION(void);

/* Clause OPERATIONS */

extern void rec_example__positive_checking_account(bool *res);
extern void rec_example__withdraw(int32_t amt);
extern void rec_example__deposit(int32_t amt);
extern void rec_example__swap(void);
extern void rec_example__unsafe_dec(void);

#ifdef __cplusplus
}
#endif /* __cplusplus */


#endif /* _rec_example_h */
