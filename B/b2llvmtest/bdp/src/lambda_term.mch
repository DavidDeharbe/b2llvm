/* lambda_term
 * Author: 
 * Creation date: 11/08/14
 */
MACHINE
    lambda_term
ABSTRACT_VARIABLES
    val
INVARIANT
    val : INT
INITIALISATION
    val := 0
OPERATIONS
    reset = val := 0
    ;
    inc =
    PRE val < MAXINT THEN
        val := val + 1
    END
    ;
    dec =
    PRE 0 < val THEN
        val := val - 1
    END
    ;
    res <-- get = res := val
END
