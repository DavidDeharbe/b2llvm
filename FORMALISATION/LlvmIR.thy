header {* Formalization of parts of LLVM IR *}
theory LlvmIR
imports Main
begin

text {* 

  missing instructions:
  switch,
  getelementptr, extractvalue,
  alloca, load, store,
  call

  missing concepts:
  block of instructions
  function
  global variable

  missing definition:
  what is a well-formed LLVM program
  prove that b2llvm only generates well-formed LLVM programs
*}

type_synonym LlId = string
type_synonym LlValue = int
type_synonym LlState = "LlId \<Rightarrow> LlValue"

datatype LlComp =
  Eq | Ne | SGt | SGe | SLt | SLe

datatype LlExpr =
  Lit int
| Id LlId

datatype LlInst =
  Ret LlExpr
| BrCond LlExpr "LlInst list" "LlInst list"
| BrUncond "LlInst list"
| Add LlId LlExpr LlExpr
| Sub LlId LlExpr LlExpr
| Mul LlId LlExpr LlExpr
| SDiv LlId LlExpr LlExpr
| SRem LlId LlExpr LlExpr
| ICmp LlId LlComp LlExpr LlExpr

end
