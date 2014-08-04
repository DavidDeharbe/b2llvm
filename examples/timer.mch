/* timer
* Author: David
* Creation date: 6/7/13
*/
MACHINE
    timer
SETS
    STATE = { running, stopped }
CONSTANTS
    capacity
PROPERTIES
    capacity: INT &
    capacity > 0
VARIABLES
    state, count, overflow
INVARIANT
    state : STATE & count : INT & overflow : BOOL &
    0 <= count & count <= capacity
INITIALISATION
    state := stopped || count := 0 || overflow := FALSE
OPERATIONS
    tick = 
    IF (state = running) & (overflow = FALSE) THEN
        IF (count = capacity) THEN
            overflow := TRUE
        ELSE
            count := count + 1
        END
    END
    ;
    reset =
    PRE state = stopped THEN
        count := 0 || overflow := FALSE
    END
    ;
    stop =
    PRE state = running THEN
        state := stopped
    END
    ;
    start =
    PRE state = stopped THEN
        state := running
    END
    ;
    hours, minutes, seconds <-- elapsed =
    BEGIN
        IF (overflow = TRUE) THEN
            hours, minutes, seconds :(hours: INT & minutes: INT & seconds : INT)
        ELSE
            hours, minutes, seconds :(hours: INT & minutes: INT & seconds : INT & 
                hours >= 0 & minutes >= 0 & seconds >= 0 & 
                count = 3600*hours + 60*minutes + seconds )
        END
    END
    ;
    answer <-- has_overflown =
    IF overflow = TRUE THEN
        answer := TRUE
    ELSE
        answer := FALSE
    END
END
