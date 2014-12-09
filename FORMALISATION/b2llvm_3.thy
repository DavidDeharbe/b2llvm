theory b2llvm_3
imports Main
begin

section {* Syntax *}

subsection {* Formalization of syntax of some B constructs. *}

text {* This formalization only considers two kinds of data: integers and Booleans: *}
datatype BType = BIntType | BBoolType

text {* Accordingly to this simple type system, the possible values are defined as
follows: *}

datatype BValue = BInt int | BBool bool

text {* Values are related to their type by the following function: *}

fun BValueType :: "BValue \<Rightarrow> BType" where
  "BValueType (BInt _) = BIntType" |
  "BValueType (BBool _) = BBoolType"

text {* A B component has a set of variables, and the valuations of such variables 
form the possible states of that component. The following introduces a type for
variables. Although it is defined as the \textit{nat} type, it could be any
type inhabited by a countable number of values. Using @{term nat} makes it more convenient
                   to write \verb'value' Isabelle commands to evaluate terms. *}

type_synonym BVariable = nat

text {* Definition of a (record) type for the typing context in which some B constructs are
  written. *}
  
record BContext =
  \<alpha> :: "BVariable set"       -- "alphabet for the state"         
  \<tau> :: "BVariable \<Rightarrow> BType" -- "type for each variable"       

text {* B has two distinct syntactic categories for expressions and predicates, i.e. one
  must distinguish between Boolean expressions (that can be assigned to variables) and
  predicates (used for control flow and assertions). It is possible to convert a
  predicate to a Boolean expression (with the \verb'bool' operator), and vice-versa 
  (by comparing the expression to \verb'TRUE').
 
  The following types correspond to B expressions and predicates, respectively. *}

datatype 
  BExpr =
    BTrue | BFalse |
    BVar BVariable | BConst BValue | BSum BExpr BExpr
and 
  BPredicate = 
    BEq BExpr BExpr | 
    BConj BPredicate BPredicate | BNeg BPredicate

text {* A B expression has a type. Predicates are always Boolean valued. The following function formalizes this relation: *}
fun BExprType :: "BExpr \<Rightarrow> BContext \<Rightarrow> BType option" where
  "BExprType BTrue _ = Some BBoolType" |               
  "BExprType BFalse _ = Some BBoolType" |                                     
  "BExprType (BVar v) \<gamma> = (if v \<in> \<alpha> \<gamma> then Some (\<tau> \<gamma> v) else None)" |                                 
  "BExprType (BConst k) _ = Some (BValueType k)" |
  "BExprType (BSum e1 e2) \<gamma> = 
    (case (BExprType e1 \<gamma>, BExprType e2 \<gamma>) of
       (Some BIntType, Some BIntType) \<Rightarrow> Some BIntType | _ => None)"

text {* A type for B instructions. Needs to be extended to match the actual language. *}
datatype BInst =
  Asg BVariable BExpr |      
  Blk "BInst list" |
  If BPredicate BInst BInst |
  Skip

subsection {* Syntax of the target LLVM language. *}

text {* We next turn our attention to LLVM. First two types are introduced: they respectively 
represent memory addresses and temporary variables.*}

type_synonym LAddr = nat
type_synonym LTemp = int

text {* LLVM data types are integer types and pointer types. *}
datatype LType = LIntType int | LPtrType LType

text {* Conversion of B types to LLVM data types. *}
fun b2llvm_type :: "BType \<Rightarrow> LType" where
  "b2llvm_type BBoolType = LIntType 1" |
  "b2llvm_type BIntType = LIntType 32"
  
text {* In principle, LLVM values can only be of any LLVM type. The code generator
  only produces integer values (from integer and Booleans). *}
datatype LValue = LInt int

text {* Expressions in LLVM can only be constants or temporaries. They are formalized as
follows: *}

datatype LExpr = Val LValue |  Var LTemp

text {* Next, (a few) LLVM statements are formalized in the following type. Note that the typing 
annotation found in the concrete syntax of LLVM is omitted (the formalization currently avoids 
considering typing issues anyway). *}

datatype LStm =
  Load LTemp LType LAddr |         -- "Loads contents from address to temporary"                      
  Store LType LExpr LType LAddr |        -- "Store temporary value at address"
  Add LTemp LType LExpr LExpr |    -- "Adds two values to temporary"
  ICmpEq LTemp LType LExpr LExpr | -- "Compares to values and stores result into temporary"
  BrU LTemp |                -- "Unconditional branch" 
  BrC LType LExpr LTemp LTemp |    -- "Conditional branch"
  Label LTemp

section {* Formalization of the code generation rules*}

text {* The functions formalizing the generation of LLVM code from B
expressions and instructions take as parameters:
\begin{itemize}
\item an element of B language to B translated;
\item a function mapping B variables to LLVM memory addresses;
\item the next LLVM temporary name to be used (each temporary may be assigned exactly once).
\end{itemize}
                              
The first function formalizes the code generation for expressions:
 *}                    

fun b2llvm_expr :: "BContext \<Rightarrow> BExpr \<Rightarrow> (BVariable \<Rightarrow> LAddr) \<Rightarrow> LTemp \<Rightarrow> (LStm list * LExpr * LType * LTemp)"
where
  "b2llvm_expr \<Gamma> BTrue loc tmp = ([], Val(LInt 1), LIntType 1, tmp)" |
  "b2llvm_expr \<Gamma> BFalse loc tmp = ([], Val(LInt 0), LIntType 1, tmp)" |    
  "b2llvm_expr \<Gamma> (BVar v) loc tmp = (let t = b2llvm_type (\<tau> \<Gamma> v) in
    ( [ Load tmp (LPtrType t) (loc v) ], Var tmp, t, tmp+1))" |    
  "b2llvm_expr \<Gamma> (BConst (BInt i)) loc tmp = ([], Val (LInt i), LIntType 32, tmp)" |
  "b2llvm_expr \<Gamma> (BConst (BBool b)) loc tmp = ([], Val (LInt (if b then 1 else 0)), LIntType 1, tmp)" |
  "b2llvm_expr \<Gamma> (BSum e1 e2) loc tmp = 
    (case (b2llvm_expr \<Gamma> e1 loc tmp) of
      (p1, v1, t1, tmp1) \<Rightarrow>
        (case (b2llvm_expr \<Gamma> e2 loc tmp1) of
          (p2, v2, t2, tmp2) \<Rightarrow> ( p1 @ p2 @ [ Add tmp2 t1 v1 v2 ], Var tmp2, t1, tmp2+1)))"

(*          
value "(let (v0, v1, v2) = (0, 1, 2) in 
          (b2llvm_expr (BConst (BInt 0)) (\<lambda> x . x) 0))"
value "(let (v0, v1, v2) = (0, 1, 2) in 
          (b2llvm_expr (BSum (BSum (BConst (BInt 1)) (BConst (BInt 2))) (BConst (BInt 3))) (\<lambda> x . x) 0))"
value "(let (v0, v1, v2) = (0, 1, 2) in 
          (b2llvm_expr (BSum (BSum (BVar 0) (BConst (BInt 1))) (BVar 1)) (\<lambda> x . x) 0))"
*)          
fun b2llvm_pred :: "BContext \<Rightarrow> BPredicate \<Rightarrow> (BVariable \<Rightarrow> LAddr) \<Rightarrow> LTemp \<Rightarrow> LTemp \<Rightarrow> LTemp \<Rightarrow> (LStm list * LExpr * LTemp)"
where
  "b2llvm_pred \<Gamma> (BEq e1 e2) loc label_true label_false tmp =
    (case (b2llvm_expr \<Gamma> e1 loc tmp) of
      (il1, v1, ty1, tmp1) \<Rightarrow>
        (case (b2llvm_expr \<Gamma> e2 loc tmp1) of
          (il2, v2, ty2, tmp2) \<Rightarrow> 
            ( il1 @ il2 @ 
              [ ICmpEq tmp2 ty1 v1 v2 ,
                BrC (LIntType 1) (Var tmp2) label_true label_false], 
              Var tmp2, tmp2 + 1)))" |      
  "b2llvm_pred \<Gamma> (BConj p1 p2) loc label_true label_false tmp =                        
    (case (b2llvm_pred \<Gamma> p1 loc tmp label_false (tmp + 1)) of
      (il1, v1, tmp1) \<Rightarrow>
        (case (b2llvm_pred \<Gamma> p2 loc label_true label_false (tmp1 + 1)) of
          (il2, v2, tmp2) \<Rightarrow> 
            (il1 @ 
             [ BrC (LIntType 1) v1 tmp1 label_false, Label tmp ] @ 
             il2, 
             Var tmp2, tmp2)))" |
  "b2llvm_pred \<Gamma> (BNeg p) loc label_true label_false tmp =                          
    (case (b2llvm_pred \<Gamma> p loc label_false label_true tmp) of
      (il, v, tmp') \<Rightarrow> (il, Var tmp', tmp'+1))"

text {* Next, the following function formalizes the translation for B instructions. The
parameters are:
\begin{itemize}
\item A B instruction, of type @{type BInst};
\item @{term layout} is the layout of the representation of B variables in the LLVM memory, it is a function
from B variables to LLVM addresses;
\item @{term exit} is the label of the block of LLVM instructions that must be executed following the execution
of the code produced for the current B instruction;
\item @{term counter} is the next free identifier that can be used to create a new temporary.
\end{itemize}
*}

fun b2llvm_stm :: "BContext \<Rightarrow> BInst \<Rightarrow> (BVariable \<Rightarrow> LAddr) \<Rightarrow> LTemp \<Rightarrow> (LStm list * LTemp)" 
where
  "b2llvm_stm \<Gamma> Skip layout counter =  ([], counter)" |
  "b2llvm_stm \<Gamma> (Asg v e) layout counter =
    (let (sl, e', ty_e, counter') = (b2llvm_expr \<Gamma> e layout counter) in
      (let ty_v = b2llvm_type(\<tau> \<Gamma> v) in
       (sl @ [ Store ty_e e' ty_v (layout v) ], counter')))" |
  "b2llvm_stm _ _ _ counter = ([], counter)"

fun b2llvm_stm_label :: "BContext \<Rightarrow> BInst \<Rightarrow> (BVariable \<Rightarrow> LAddr) \<Rightarrow> LTemp \<Rightarrow> LTemp \<Rightarrow> (LStm list * LTemp)" 
where
  "b2llvm_stm_label \<Gamma> Skip layout exit counter = 
    (let (sl, counter') = b2llvm_stm \<Gamma> Skip layout counter in
      (sl @ [BrU exit], counter'))" |
  "b2llvm_stm_label \<Gamma> (Asg v e) layout exit counter = 
    (let (sl, counter') = b2llvm_stm \<Gamma> (Asg v e) layout counter in
      (sl @ [BrU exit], counter'))" |
  "b2llvm_stm_label \<Gamma> (Blk []) layout exit counter = 
    ( [BrU exit], counter )" |
  "b2llvm_stm_label \<Gamma> (Blk (x # xs)) layout exit counter =
    (let (sl, counter') = 
       (case x of
         (If _ _ _) \<Rightarrow> 
           (let (sli, tempi) = b2llvm_stm_label \<Gamma> x layout counter (counter + 1) in
             (sli @ [ Label counter ], counter + 1)) |
          _ \<Rightarrow> 
            b2llvm_stm \<Gamma> x layout counter) 
     in    
       (let (sl', counter'') = b2llvm_stm_label \<Gamma> (Blk xs) layout exit counter' in
          (sl @ sl', counter'')))" |
  "b2llvm_stm_label \<Gamma> (If c i1 i2) varmap exit counter =
    (let (bk_then, bk_else) = (counter, counter + 1) in
      (let (ilc, e1, tmp1) = b2llvm_pred \<Gamma> c varmap bk_then bk_else (counter + 2) in
        (let (ilt, tmp2) = b2llvm_stm_label \<Gamma> i1 varmap exit tmp1 in
          (let (ile, tmp3) = b2llvm_stm_label \<Gamma> i2 varmap exit tmp2 in
            (ilc @
            [Label bk_then] @
            ilt @
            [Label bk_else] @
            ile,
            tmp3)))))"
(*
value "let (v0, v1, v2) = (0, 1, 2) in 
          b2llvm_stm_label Skip (\<lambda> x . x) -1 0"

value "(let (v0, v1, v2) = (0, 1, 2) in 
          (b2llvm_stm_label (Asg 0 (BConst (BInt 0))) (\<lambda> x . x) -1 0))"

value "(let (v0, v1, v2) = (0, 1, 2) in 
          (b2llvm_stm_label (If (BEq (BVar 0) (BConst (BInt 0))) (Asg 0 (BConst (BInt 1))) Skip) (\<lambda> x . x) -1 0))"

value "(let (v0, v1, v2) = (0, 1, 2) in 
          (b2llvm_stm_label (Blk [Asg 0 (BConst (BInt 0)), Asg 0 (BConst (BInt 0))]) (\<lambda> x . x) -1 0))"
*)          
end

