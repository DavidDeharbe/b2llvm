/* switch
 * Author: David
 * Creation date: 8/29/13
 */
MACHINE
    switch
VARIABLES
    v1, v2
INVARIANT
    v1: INT & v2: INT &
    v1: 0..4 & v2: 0..1 &
    ((v1 = 0 & v2 = 0) or
        (v1 = 1 & v2 = 0) or
        (v1 = 1 & v2 = 1) or
        (v1 = 2 & v2 = 1) or
        (v1 = 4 & v2 = 1))
INITIALISATION
    v1 := 0 || v2 := 0
OPERATIONS
    step = 
    CHOICE
        v1, v2 := 0, 0
    OR
        v1, v2 := 1, 0
    OR
        v1, v2 := 1, 1
    OR
        v1, v2 := 2, 1
    OR
        v1, v2 := 4, 1
    END
END
