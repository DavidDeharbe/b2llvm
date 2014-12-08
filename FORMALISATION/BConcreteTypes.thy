theory BConcreteTypes
imports Main
begin

section {* Concrete data types in B *}

text {* B has a number of predefined types and type constructors for concrete data. The
predefined types are integers and booleans, and the type constructors are arrays,
records, integer intervals and enumerations. Arrays may be multi-dimensional.*}

type_synonym BIdentifier = nat

datatype BConcreteType =
  Integer
| Boolean
| Array "BConcreteType list * BConcreteType" -- "indices, elements"
| Record "(BIdentifier * BConcreteType) list"
| Interval "int * int" -- "lower bound, upper bound"
| Enumeration "BIdentifier list"

fun "isBSimpleConcreteType" :: "BConcreteType \<Rightarrow> bool"
where
  "isBSimpleConcreteType Boolean = True"
| "isBSimpleConcreteType (Enumeration _) = True"
| "isBSimpleConcreteType (Interval _) = True"
| "isBSimpleConcreteType _ = False"

end

