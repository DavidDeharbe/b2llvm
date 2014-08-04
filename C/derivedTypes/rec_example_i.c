
#include "rec_example.h"

/* Clause CONCRETE_CONSTANTS */
/* Basic constants */

/* Array and record constants */
/* Clause CONCRETE_VARIABLES */

static struct R_2 { rec_example__ID name;struct R_1 { int32_t balance_checking_account;int32_t balance_savings_account; } accounts; } rec_example__client;
static struct R_3 { rec_example__ID name; } rec_example__bank;
/* Clause INITIALISATION */
void rec_example__INITIALISATION(void)
{
    
    rec_example__bank.name = rec_example__bb;
    rec_example__client.name = rec_example__aa;
    rec_example__client.accounts.balance_checking_account = 0;
    rec_example__client.accounts.balance_savings_account = 0;
}

/* Clause OPERATIONS */

void rec_example__positive_checking_account(bool *res)
{
    if((rec_example__client.accounts.balance_savings_account) > (0))
    {
        (*res) = true;
    }
    else
    {
        (*res) = false;
    }
}

void rec_example__withdraw(int32_t amt)
{
    int32_t new_balance;
    
    new_balance = rec_example__client.accounts.balance_checking_account-amt;
    if(((new_balance) >= (-2147483647)))
    {
        rec_example__client.accounts.balance_checking_account = new_balance;
    }
}

void rec_example__deposit(int32_t amt)
{
    int32_t new_balance;
    
    new_balance = rec_example__client.accounts.balance_checking_account+amt;
    if((((new_balance)) <= (2147483647)))
    {
        rec_example__client.accounts.balance_checking_account = new_balance;
    }
}

void rec_example__swap(void)
{
    if((((rec_example__client.accounts.balance_checking_account)) >= (0)) &&
    (((rec_example__client.accounts.balance_checking_account)) <= (2147483647)))
    {
        rec_example__client.name = rec_example__client.name;
        rec_example__client.accounts.balance_checking_account = rec_example__client.accounts.balance_savings_account;
        rec_example__client.accounts.balance_savings_account = rec_example__client.accounts.balance_checking_account;
    }
}

void rec_example__unsafe_dec(void)
{
    rec_example__client.accounts.balance_savings_account = rec_example__client.accounts.balance_savings_account-1;
}

