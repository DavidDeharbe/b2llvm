/* storemax
* Author:  David
* Creation date: 10/30/13
*/
MACHINE
    storemax
VARIABLES
    numbers
INVARIANT
    numbers : POW(INT)
INITIALISATION
    numbers := {}
OPERATIONS
    generate =
    ANY val WHERE val : INT THEN
        numbers := numbers \/ { val }
    END;
    res <-- upper =
    PRE numbers /= {} THEN
        res := max(numbers)
    END;
    res <-- lower =
    PRE numbers /= {} THEN
        res := min(numbers)
    END
END
