/* timetracer
 * Author:  David
 * Creation date: 11/5/13
 */
MACHINE
    timetracer
VARIABLES
    time_running, time_stopped, started, idle
INVARIANT
    time_running : NAT & time_stopped : NAT &
    started : BOOL & idle : BOOL
INITIALISATION
    time_running := 0 || time_stopped := 0 || started := FALSE || idle :: BOOL
OPERATIONS
    enable =
    PRE started = FALSE THEN
        started, idle := TRUE, TRUE ||  time_running, time_stopped := 0, 0
    END;
    run =
    PRE started = TRUE & idle = TRUE THEN
        idle := FALSE
    END;
    stop =
    PRE started = TRUE & idle = FALSE THEN
        idle := TRUE
    END;
    disable =
    PRE started = TRUE THEN
        started := FALSE
    END;
    tick =
    PRE started = TRUE THEN
        IF idle = TRUE THEN
            IF time_stopped < MAXINT THEN
                time_stopped := time_stopped + 1
            END
        ELSE
            IF time_running < MAXINT THEN
                time_running := time_running + 1
            END
        END
    END;
    ts, tr <-- peak =
    BEGIN
        ts, tr := time_stopped, time_running
    END
END
