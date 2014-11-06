/* chronometer
* Author: 
* Creation date: 05/11/14
*/
MACHINE
    chronometer
SETS
    STATE = { STOPPED , RUNNING , PAUSED , LAP_RUNNING , LAP_PAUSED }
CONCRETE_CONSTANTS
    CAPACITY
PROPERTIES
    CAPACITY : INT &
    CAPACITY = 60 * 60 * 100
ABSTRACT_VARIABLES
    state ,
    elapsed /* centiseconds elapsed*/ ,
    display /* time showed on display */
INVARIANT
    state : STATE &
    elapsed : INT & elapsed : 0 .. ( CAPACITY - 1 ) &
    display : INT & display : 0 .. ( CAPACITY - 1 ) &
    ( state = STOPPED => ( elapsed = 0 & display = 0 ) )
ASSERTIONS
    CAPACITY = 360000
INITIALISATION
    state := STOPPED || elapsed := 0 || display := 0
OPERATIONS
    tick =
    ANY vv WHERE
        vv : INT &
        ( elapsed + 1 < CAPACITY => vv = elapsed + 1 ) &
        ( elapsed + 1 = CAPACITY => vv = 0 )
    THEN
        SELECT state = RUNNING THEN
            elapsed , display := vv , vv
            WHEN state = LAP_RUNNING THEN
                elapsed := vv
        END
    END
    ;
    button1 =
    SELECT state = STOPPED THEN state := RUNNING
    WHEN state = RUNNING THEN state := PAUSED
    WHEN state = PAUSED THEN state := RUNNING
    WHEN state = LAP_RUNNING THEN state := LAP_PAUSED
    WHEN state = LAP_PAUSED THEN state := LAP_RUNNING
    END
    ;
    button2 =
    SELECT state = RUNNING THEN state := LAP_RUNNING
    WHEN state = PAUSED THEN state , elapsed , display := STOPPED , 0 , 0
    WHEN state = LAP_RUNNING THEN state := RUNNING
    WHEN state = LAP_PAUSED THEN state := PAUSED
    END
    ;
    d1 , d2 , d3 , d4 , d5 , d6 <-- digits =
    BEGIN
        ANY v1 , v2 , v3 , v4 , v5 , v6 WHERE
            v1 : 0 .. 5 & v2 : 0 .. 9 & v3 : 0 .. 5 & v4 : 0 .. 9 & v5 : 0 .. 9 & v6 : 0 .. 9 &
            display = ( ( ( ( ( v1 * 10 + v2 ) * 6 + v3 ) * 10 + v4 ) * 10 ) + v5 ) * 10 + v6
        THEN
            d1 , d2 , d3 , d4 , d5 , d6 := v1 , v2 , v3 , v4 , v5 , v6
        END
    END
END
