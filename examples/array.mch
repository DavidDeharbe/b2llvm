/* Author: ??? */
MACHINE
   array
VARIABLES arr

INVARIANT 
    arr : ((0..99) --> 0..1000)

INITIALISATION arr := {1|->100}

OPERATIONS 

set(ix,tt)=
        PRE ix : (0..99) & tt : (0..1000)
        THEN arr := arr <+ {ix |-> tt}
        END ;

tt <-- read(ix) =
        PRE ix : (0..99)
        THEN tt := arr(ix)
        END;

swap(ix, jx)=
        PRE ix : (0..99) & jx : (0..99)
        THEN arr := arr <+ {ix |-> arr(jx), jx|-> arr(ix)}
        END

END
