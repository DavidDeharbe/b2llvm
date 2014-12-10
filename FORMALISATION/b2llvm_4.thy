theory b2llvm_4
imports Main
begin

section {* Syntax *}

subsection {* Formalization of syntax of some B constructs. *}

text {* This formalization considers the following data:
\begin{itemize}
\item Booleans;
\item integers;
\item enumerations: the constructor takes as input an natural number that identifies the enumeration.
\end{itemize}
: *}
datatype BType = BIntType | BBoolType | BEnumeration nat

text {* Accordingly to this simple type system, the possible values are:
\begin{itemize}
\item integers, represented with Isabelle's integers;
\item Booleans, represented with Isabelle's Booleans;
\item enumerated value, represented as a pair of non-negative numbers: the identifier of the
enumeration containing this value, and the position of the value in the enumeration.
\end{itemize}
defined as
follows: *}

datatype BValue = BInt int | BBool bool | BEnum nat nat

text {* Definition of a (record) type for the typing context in which some B constructs are
  written. *}
  
text {* A B component has a set of variables, and the valuations of such variables 
form the possible states of that component. The following introduces a type for
variables. Although it is defined as the \textit{nat} type, it could be any
type inhabited by a countable number of values. Using @{term nat} makes it more convenient
                   to write \verb'value' Isabelle commands to evaluate terms. *}

type_synonym BVariable = nat   

record BContext =
  \<alpha> :: "BVariable set"       -- "alphabet for the state"         
  \<tau> :: "BVariable \<Rightarrow> BType" -- "type for each variable"
  enum_size :: "nat \<Rightarrow> nat" -- "number of values for each enumeration"
  
text {* Values are related to their type by the following function: *}

fun BValueType :: "BContext \<Rightarrow> BValue \<Rightarrow> BType" where
  "BValueType \<Gamma> v =
    (case v of
      BInt _ \<Rightarrow> BIntType |
      BBool _ \<Rightarrow> BBoolType |
      BEnum i _ \<Rightarrow> BEnumeration i)" 

text {* B has two distinct syntactic categories for expressions and predicates, i.e. one
  must distinguish between Boolean expressions (that can be assigned to variables) and
  predicates (used for control flow and assertions). It is possible to convert a
  predicate to a Boolean expression (with the \verb'bool' operator), and vice-versa 
  (by comparing the expression to \verb'TRUE').
 
  The following types correspond to B expressions and predicates, respectively. *}

datatype 
  BExpr =
    BVar BVariable | BConst BValue | BSum BExpr BExpr
and 
  BPredicate = 
    BEq BExpr BExpr | 
    BConj BPredicate BPredicate | BNeg BPredicate

text {* A B expression has a type. Predicates are always Boolean valued. The following function formalizes this relation: *}
fun BExprType :: "BContext \<Rightarrow> BExpr \<Rightarrow> BType option" where
  "BExprType \<Gamma> \<epsilon> =
    (case \<epsilon> of
      BVar v \<Rightarrow> (if v \<in> \<alpha> \<Gamma> then Some (\<tau> \<Gamma> v) else None) |                                 
      BConst k \<Rightarrow> Some (BValueType \<Gamma> k) |
      BSum e1 e2 \<Rightarrow> 
        (case (BExprType \<Gamma> e1, BExprType \<Gamma> e2) of
           (Some BIntType, Some BIntType) \<Rightarrow> Some BIntType | 
           _ => None))"

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
datatype LType = LIntType nat | LPtrType LType

text {* Conversion of B types to LLVM data types. *}

text {* The encoding of enumerations demands a function to compute the minimum bit width to
encode a given number of values. *}

fun min_bit_width :: "nat \<Rightarrow> nat" where
  "min_bit_width n =
    (if n = 0 \<or>  n = 1 then 0
     else if n = 2 then 1
     else Suc (min_bit_width (n div 2)))"


fun b2llvm_type :: "BContext \<Rightarrow> BType \<Rightarrow> LType" where
  "b2llvm_type \<Gamma> t =
    (case t of
      BBoolType \<Rightarrow> LIntType 1 |
      BIntType \<Rightarrow> LIntType 32 |
      BEnumeration n \<Rightarrow> 
        LIntType (let w = min_bit_width (enum_size \<Gamma> n) in (if n = 0 then (Suc 0) else n)))" 
  
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

type_synonym VarLayout = "BVariable \<Rightarrow> LAddr"

text {* The functions formalizing the generation of LLVM code from B
expressions and instructions take as parameters:
\begin{itemize}
\item an element of B language to B translated;
\item a function mapping B variables to LLVM memory addresses;
\item the next LLVM temporary name to be used (each temporary may be assigned exactly once).
\end{itemize}
                              
The first function formalizes the code generation for expressions:
 *}                    

fun b2llvm_expr :: "BContext \<Rightarrow> VarLayout \<Rightarrow> BExpr \<Rightarrow> LTemp \<Rightarrow> (LStm list * LExpr * LType * LTemp)"
where
  "b2llvm_expr \<Gamma> \<L> \<epsilon> tmp = 
    (case \<epsilon> of 
      BVar v \<Rightarrow> (let t = b2llvm_type \<Gamma> (\<tau> \<Gamma> v) in
        ( [ Load tmp (LPtrType t) (\<L> v) ], Var tmp, t, tmp+1)) |    
      BConst(BInt i) \<Rightarrow> ([], Val (LInt i), LIntType 32, tmp) |
      BConst(BBool b) \<Rightarrow> ([], Val (LInt (if b then 1 else 0)), LIntType 1, tmp) |
      BConst(BEnum t e) \<Rightarrow> (case b2llvm_type \<Gamma> (BEnumeration t) of
        (LIntType w) => ([], Val (LInt (int e)), LIntType w, tmp)) |
      BSum e1 e2 \<Rightarrow> 
        (case (b2llvm_expr \<Gamma> \<L> e1 tmp) of
          (p1, v1, t1, tmp1) \<Rightarrow>
            (case (b2llvm_expr \<Gamma> \<L> e2 tmp1) of
              (p2, v2, t2, tmp2) \<Rightarrow> ( p1 @ p2 @ [ Add tmp2 t1 v1 v2 ], Var tmp2, t1, tmp2+1))))"

(*          
value "(let (v0, v1, v2) = (0, 1, 2) in 
          (b2llvm_expr (BConst (BInt 0)) (\<lambda> x . x) 0))"
value "(let (v0, v1, v2) = (0, 1, 2) in 
          (b2llvm_expr (BSum (BSum (BConst (BInt 1)) (BConst (BInt 2))) (BConst (BInt 3))) (\<lambda> x . x) 0))"
value "(let (v0, v1, v2) = (0, 1, 2) in 
          (b2llvm_expr (BSum (BSum (BVar 0) (BConst (BInt 1))) (BVar 1)) (\<lambda> x . x) 0))"
*)          
fun b2llvm_pred :: "BContext \<Rightarrow> VarLayout \<Rightarrow> BPredicate \<Rightarrow> LTemp \<Rightarrow> LTemp \<Rightarrow> LTemp \<Rightarrow> (LStm list * LExpr * LTemp)"
where
  "b2llvm_pred \<Gamma> \<L> \<phi> label_true label_false tmp =
    (case \<phi> of
    
      (BEq e1 e2) \<Rightarrow> 
        (case (b2llvm_expr \<Gamma> \<L> e1 tmp) of
          (il1, v1, ty1, tmp1) \<Rightarrow>
            (case (b2llvm_expr \<Gamma> \<L> e2 tmp1) of
              (il2, v2, ty2, tmp2) \<Rightarrow> 
                ( il1 @ il2 @ 
                  [ ICmpEq tmp2 ty1 v1 v2 ,
                    BrC (LIntType 1) (Var tmp2) label_true label_false], 
                  Var tmp2, tmp2 + 1))) |
                  
      (BConj p1 p2) \<Rightarrow>
        (case (b2llvm_pred \<Gamma> \<L> p1 tmp label_false (tmp + 1)) of
          (il1, v1, tmp1) \<Rightarrow>
            (case (b2llvm_pred \<Gamma> \<L> p2 label_true label_false (tmp1 + 1)) of
              (il2, v2, tmp2) \<Rightarrow> 
                (il1 @ 
                 [ BrC (LIntType 1) v1 tmp1 label_false, Label tmp ] @ 
                 il2, 
                 Var tmp2, tmp2))) |

      (BNeg p) \<Rightarrow>
        (case (b2llvm_pred \<Gamma> \<L> p label_false label_true tmp) of
          (il, v, tmp') \<Rightarrow> (il, Var tmp', tmp'+1)))"

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

fun b2llvm_stm :: "BContext \<Rightarrow> VarLayout \<Rightarrow> BInst \<Rightarrow> LTemp \<Rightarrow> (LStm list * LTemp)" 
where
  "b2llvm_stm \<Gamma> \<L> s counter =
    (case s of
      Skip \<Rightarrow> ([], counter) |
      Asg v e \<Rightarrow> 
        (let (sl, e', ty_e, counter') = (b2llvm_expr \<Gamma> \<L> e counter) in
          (let ty_v = b2llvm_type \<Gamma> (\<tau> \<Gamma> v) in
           (sl @ [ Store ty_e e' ty_v (\<L>  v) ], counter'))) |
      _ \<Rightarrow> ([], counter))" (* actually should be undefined *)

fun b2llvm_stm_label :: "BContext \<Rightarrow> VarLayout \<Rightarrow> BInst \<Rightarrow> LTemp \<Rightarrow> LTemp \<Rightarrow> (LStm list * LTemp)" 
where
  "b2llvm_stm_label \<Gamma> \<L> s exit counter = 
    (case s of
      Skip \<Rightarrow>
        (let (sl, counter') = b2llvm_stm \<Gamma> \<L> Skip counter in
          (sl @ [BrU exit], counter')) |
      (Asg v e) \<Rightarrow>
        (let (sl, counter') = b2llvm_stm \<Gamma> \<L> (Asg v e) counter in
          (sl @ [BrU exit], counter')) |
      (Blk []) \<Rightarrow>
        ( [BrU exit], counter ) |
      (Blk (x # xs)) \<Rightarrow>
        (let (sl, counter') = 
          (case x of
            (If _ _ _) \<Rightarrow> 
              (let (sli, tempi) = b2llvm_stm_label \<Gamma> \<L> x counter (counter + 1) in
                (sli @ [ Label counter ], counter + 1)) |
            _ \<Rightarrow> 
               b2llvm_stm \<Gamma> \<L> x counter) 
         in    
           (let (sl', counter'') = b2llvm_stm_label \<Gamma> \<L> (Blk xs) exit counter' in
             (sl @ sl', counter''))) |
      (If c i1 i2) \<Rightarrow>
        (let (bk_then, bk_else) = (counter, counter + 1) in
          (let (ilc, e1, tmp1) = b2llvm_pred \<Gamma> \<L> c bk_then bk_else (counter + 2) in
            (let (ilt, tmp2) = b2llvm_stm_label \<Gamma> \<L> i1 exit tmp1 in
              (let (ile, tmp3) = b2llvm_stm_label \<Gamma> \<L> i2 exit tmp2 in
                 (ilc @
                  [Label bk_then] @
                  ilt @
                  [Label bk_else] @
                  ile,
                  tmp3))))))"
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

