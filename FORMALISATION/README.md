This directory contains the files related to a formal expression of the rules
defining the code generation of LLVM code units from B implementations.

This formalisation is incremental. Starting from a very small subset of the
source B language, and gradually introducing more elements, we shall get as
close as possible to the definition of the full system of rules. The different
steps are the following:

- Step 1:

| Type system  | integers         |
|--------------|------------------|
| Expressions  | integer literals |
|              | variables        |
|              | sum              |
|--------------|------------------|
| Instructions | assignment       |
|              | block            |
|--------------|------------------|

Specification of LLVM does not include typing annotations.

- Step 2:

| Type system  | integers           |
|      	       | +Booleans	        |
|--------------|--------------------|
| Expressions  | integer literals   |
|              | + Boolean literals |
|              | variables          |
|              | sum                |
|--------------|--------------------|
| Predicates   | + equalities       |
|              | + conjunctions     |
|              | + negations        |
|--------------|--------------------|
| Instructions | assignment         |
|              | block              |
|--------------|--------------------|

Specification of LLVM does not include typing annotations.

- Step 3:

| Type system  | integers         |
|      	       | Booleans	      |
|--------------|------------------|
| Expressions  | integer literals |
|              | Boolean literals |
|              | variables        |
|              | sum              |
|--------------|------------------|
| Predicates   | equalities       |
|              | conjunctions     |
|              | negations        |
|--------------|------------------|
| Instructions | assignment       |
|              | block            |
|--------------|------------------|

+ Specification of LLVM does include typing annotations.

