/* ioint
* Author: 
* Creation date: 9/19/13
*/
MACHINE
    ioint
OPERATIONS
    print_int(num) =
    PRE
        num : INT
    THEN
        skip
    END;
    res <-- read_int =
    BEGIN
        res :∈ INT
    END
END
