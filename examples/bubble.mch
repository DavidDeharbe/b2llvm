/* Bubble
 * Author: valerio
 */
MACHINE
   Bubble
VARIABLES
   vec,sort
INVARIANT
   vec : 0..99 --> 0..99 & sort : 0..1 &
   ( sort = 1 =>  !ii.(ii : 0..98 => vec(ii)<=vec(ii+1)))
INITIALISATION
   vec :: 0..99 --> 0..99 || sort := 0
OPERATIONS
   op_sort =
   ANY sorted_vector WHERE
    sorted_vector : 0..99 --> 0..99 &
    !ii.(ii : 0..98 => sorted_vector(ii)<=sorted_vector(ii+1))
   THEN
    vec := sorted_vector|| sort := 1
   END

END