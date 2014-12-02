theory b2llvm
imports Main
begin

text {* Definition of a type for B variables.*}

type_synonym BVariable = string

text {* Define the possible values taken by B variables. We make here the simplifying assumption 
that such variables are integers. Needs to be extended to match the actual language. *}
datatype BValue = BInt int

text {* Definition of a (record) type for the state of the B component. The state is specified by
a valuation of some variables, that we call the alphabet of the state. *}
record BState =
  alpha :: "BVariable set"         -- "alphabet for the state"
  store :: "BVariable \<Rightarrow> BValue"   -- "valuation of the variables"

text {* A type for B expressions. Needs to be extended to match the actual language. *}
datatype BExpr =
  Const BValue |
  BVar BVariable |
  Sum BExpr BExpr

text {* The following definition gives an (operational) semantics of expressions. The evaluation of 
an expression in a state yields a value. *}

primrec BEvalExpr :: "BExpr \<Rightarrow> BState \<Rightarrow>  BValue" where
  "BEvalExpr (Const v) s = v" |
  "BEvalExpr (BVar v) s = (store s) v" |
  "BEvalExpr (Sum e1 e2) s = 
    (case (BEvalExpr e1 s, BEvalExpr e2 s) of (BInt i1, BInt i2) \<Rightarrow> BInt (i1 + i2))"

text {* A type for B instructions. Needs to be extended to match the actual language. *}
datatype BInst =
  Asg BVariable BExpr |
  Blk "BInst list"

text {* Next, the semantics of statement is defined: a statement changes the state. *}
primrec BEvalInst :: "BInst \<Rightarrow> BState \<Rightarrow> BState" and
  BEvalInstList :: "BInst list \<Rightarrow> BState \<Rightarrow> BState"
where
  "BEvalInst (Asg v e) s = \<lparr>  alpha = alpha s, store = (store s) (v := (BEvalExpr e s)) \<rparr> " |
  "BEvalInst (Blk l) s = BEvalInstList l s" |

  "BEvalInstList [] s = s" |
  "BEvalInstList (x # xs) s = BEvalInstList xs (BEvalInst x s)"

text {* This completes the skeleton of a formal semantics of the B implementation language. 
We next turn our attention to LLVM. First two types are introduced: they respectively 
represent memory addresses and temporary variables.*}

type_synonym LAddr = nat
type_synonym LTemp = nat

text {* Again, we consider that values can only be integer values. Again this is a simplification
so that we can initially focus on identifying an approach to model the translation from B to LLVM. *}
datatype LValue = LInt int

record LState =
  mem :: "LAddr \<Rightarrow> LValue"    -- "models the global store"
  local :: "LTemp \<Rightarrow> LValue"  -- "models the temporaries within LLVM functions"

text {* Expressions in LLVM statements can only be constants or temporaries. They are
formalized as follows: *}
datatype LExpr =
  Val LValue |
  Var LTemp

primrec LEvalExpr :: "LExpr \<Rightarrow> LState \<Rightarrow> LValue" where
  "LEvalExpr (Val v) s = v" |
  "LEvalExpr (Var v) s = (mem s) v"

text {* Next, (a few) LLVM statements are formalized in the following type. Note that the typing 
annotation found in the concrete syntax of LLVM is omitted (the formalization currently avoids 
considering typing issues anyway). *}

datatype LStm =
  Load LTemp LAddr |
  Store LExpr LAddr |
  Add LTemp LExpr LExpr

text {* Follows the specification of the semantics for the selected LLVM statements. As with a
B instruction, the semantics of a LLVM statement is a state transformer. *}

primrec LEvalStm :: "LStm \<Rightarrow> LState \<Rightarrow> LState" where
  "LEvalStm (Load t a) s = 
    (let m = mem s in \<lparr> mem = m, local = (local s) (t := (m a) ) \<rparr>)" |
  "LEvalStm (Store v a) s =
    \<lparr> mem = (mem s) (a := (LEvalExpr v s)),
      local = local s \<rparr> " |
  "LEvalStm (Add t v1 v2) s =
    (case (LEvalExpr v1 s, LEvalExpr v2 s) of
      (LInt i1, LInt i2) \<Rightarrow> \<lparr> mem = mem s, local = (local s)(t := LInt (i1 + i2)) \<rparr>)"

text {* The third part of the formalization deals with the generation of LLVM code from B
expressions and instructions. All functions take as
\begin{itemize}
\item an element of B language to B translated;
\item a function mapping B variables to LLVM memory addresses;
\item the next LLVM temporary name to be used (each temporary may be assigned exactly once).
\end{itemize}

The first function formalizes the code generation for expressions:
 *}
fun b2llvm_expr :: "BExpr \<Rightarrow> (BVariable \<Rightarrow> LAddr) \<Rightarrow> LTemp \<Rightarrow> (LStm list * LExpr * LTemp)" where
  "b2llvm_expr (Const (BInt i)) loc tmp = ([], (Val (LInt i)), tmp)" |
  "b2llvm_expr (BVar v) loc tmp = ( [ Load tmp (loc v) ], Var tmp, tmp+1)" |
  "b2llvm_expr (Sum e1 e2) loc tmp = 
    (case (b2llvm_expr e1 loc tmp) of
      (p1, v1, tmp1) \<Rightarrow>
        (case (b2llvm_expr e2 loc (tmp+1)) of
          (p2, v2, tmp2) \<Rightarrow> ( p1 @ p2 @ [ Add tmp2 v1 v2 ], Var tmp2, tmp2+1)))"

fun b2llvm_stm :: "BInst \<Rightarrow> (BVariable \<Rightarrow> LAddr) \<Rightarrow> LTemp \<Rightarrow> (LStm list * LTemp)" where
  "b2llvm_stm (Asg v e) loc temp =
    (case (b2llvm_expr e loc temp) of
      (sl, e', t') \<Rightarrow> (sl @ [ (Store e' (loc v)) ], t'))" |
  "b2llvm_stm (Blk []) loc temp = ( [], temp )" |
  "b2llvm_stm (Blk (x # xs)) loc temp =
    (case (b2llvm_stm x loc temp) of
      (sl, t') \<Rightarrow> (case (b2llvm_stm (Blk xs) loc temp) of
                    (sl', t'') \<Rightarrow> (sl @ sl', t'')))"
end

