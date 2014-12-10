This directory contains the files related to a formal expression of the rules
defining the code generation of LLVM code units from B implementations.

This formalisation is incremental. Starting from a very small subset of the
source B language, and gradually introducing more elements, we shall get as
close as possible to the definition of the full system of rules. The different
steps are the following:

- Step 1:

| Constructions| supported        |
|--------------|------------------|
| Type system  | integers         |
| Expression  | integer literals, variables, sum              |
| Instruction | assignment, block            |

Specification of LLVM does not include typing annotations.

- Step 2:

| Constructions| supported        |
|--------------|------------------|
| Type system  | integers, *Booleans*	        |
| Expression  | integer literals, *Boolean literals*, variables, sum          |
| *Predicate* | *equalities*, *conjunctions*, *negations*        |
| Instruction | assignment, block, *if*, *skip*              |

Specification of LLVM does not include typing annotations.

- Step 3:

| Constructions| supported        |
|--------------|------------------|
| Type system  | integers, Booleans	      |
| Expression  | integer literals, Boolean literals, variables, sum              |
| Predicate   | equality, conjunction, negations        |
| Instruction | assignment, block            |

*Specification of LLVM does include typing annotations*.

- Step 4:

| Constructions| supported        |
|--------------|------------------|
| Type system  | integers, Booleans, *enumerations*	      |
| Expression  | integer literals, Boolean literals, variables, sum              |
| Predicate   | equality, conjunction, negations        |
| Instruction | assignment, block            |
