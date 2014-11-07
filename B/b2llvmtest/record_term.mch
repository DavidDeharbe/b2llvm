/* record_term
 * Author: 
 * Creation date: 11/08/14
 */
MACHINE
    record_term
VARIABLES
    minutes, seconds
INVARIANT
    minutes : INT & minutes: 0..59 &
    seconds : INT & seconds: 0..59
INITIALISATION
    minutes, seconds := 0, 0
OPERATIONS
    reset = minutes, seconds := 0, 0
    ;
    tick = PRE minutes < 60 THEN
        IF seconds = 59 THEN
            BEGIN
                IF minutes = 59 THEN
                    minutes, seconds := 0, 0
                ELSE
                    BEGIN
                        minutes := minutes + 1 ||
                        seconds := 0
                    END
                END
            END
       ELSE
           seconds := seconds + 1
       END
   END
   ;
   res <-- display_minutes = res := minutes
   ;
   res <-- display_seconds = res := seconds
END
