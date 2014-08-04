/* wd
 * Author: David
 * Creation date: 8/29/13
 */
MACHINE
    wd
CONSTANTS
    timeout
PROPERTIES
    timeout : INT &
    timeout > 0
VARIABLES
    ticker
INVARIANT
    ticker : INT &
    ticker >= 0 & timeout >= ticker
INITIALISATION
    ticker := 0
OPERATIONS
    start = ticker := timeout;
    tick = 
    IF ticker > 0 THEN
        ticker := ticker - 1
    END;
    res <-- expired = 
    IF ticker = 0 THEN
        res := TRUE
    ELSE
        res := FALSE
    END
END
