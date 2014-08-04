/* enumeration
 * Author: 
 * Creation date: 3/28/14
 */
MACHINE
    enumeration
SETS
    PARITY = { even, odd }
VARIABLES
    count
INVARIANT
    count : INT & count : 0..1
INITIALISATION
    count := 0
OPERATIONS
    tick = count := 1-count;
    res <-- read = IF count = 0 THEN res := even ELSE res := odd END
END
