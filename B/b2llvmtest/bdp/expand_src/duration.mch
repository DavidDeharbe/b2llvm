/* duration
 * Author: 
 * Creation date: 06/11/14
 */
MACHINE
    duration
ABSTRACT_CONSTANTS
    DURATION ,
    duration_cs
PROPERTIES
    DURATION = struct ( mi : 0 .. 59 , se : 0 .. 59 , hu : 0 .. 99 ) &
    duration_cs : struct ( mi : 0 .. 59 , se : 0 .. 59 , hu : 0 .. 99 ) --> INT &
    duration_cs = % dd . ( dd : DURATION | dd ' hu + 100 * dd ' se + 60 * 100 * dd ' mi )
END
