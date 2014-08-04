/* thr
 * Author:  David
 * Creation date: 8/29/13
 */
MACHINE
    thr
INCLUDES
    thrdef
VARIABLES
    count
INVARIANT
    count : INT &
    count : 0..maxval
INITIALISATION
    count := 0
OPERATIONS
    ok <-- inc =
    IF count < maxval THEN
        count := succ(count) ||
        ok := TRUE
    ELSE
        ok := FALSE
    END
    
END
