
#include "Rec.h"

/* Clause CONCRETE_CONSTANTS */
/* Basic constants */

/* Array and record constants */
/* Clause CONCRETE_VARIABLES */

static struct R_1 { int32_t number;int32_t balance; } Rec__account;
/* Clause INITIALISATION */
void Rec__INITIALISATION(void)
{
    
    Rec__account.number = 0;
    Rec__account.balance = 10;
}

/* Clause OPERATIONS */

void Rec__positive(bool *res)
{
    if((Rec__account.balance) > (0))
    {
        (*res) = true;
    }
    else
    {
        (*res) = false;
    }
}

void Rec__withrdaw(int32_t amt)
{
    if((((amt) >= (0)) &&
        ((amt) <= (2147483647))) &&
    (((Rec__account.balance) >= (amt))))
    {
        Rec__account.number = Rec__account.number;
        Rec__account.balance = (Rec__account.balance-amt);
    }
}

void Rec__unsafe_dec(void)
{
    Rec__account.balance = Rec__account.balance-1;
}

