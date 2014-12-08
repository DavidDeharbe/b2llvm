theory b2llvm_2
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
variables. Although it is defined as the \textit{string} type, it could be any
type inhabited by a countable number of values. *}

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

text {* Values can only be integer and Boolean values.  *}
datatype LValue = LInt int | LBool bool   

text {* Expressions in LLVM can only be constants or temporaries. They are formalized as
follows: *}

datatype LExpr = Val LValue |  Var LTemp

text {* Next, (a few) LLVM statements are formalized in the following type. Note that the typing 
annotation found in the concrete syntax of LLVM is omitted (the formalization currently avoids 
considering typing issues anyway). *}

datatype LStm =
  Load LTemp LAddr |         -- "Loads contents from address to temporary"                      
  Store LExpr LAddr |        -- "Store temporary value at address"
  Add LTemp LExpr LExpr |    -- "Adds two values to temporary"
  ICmpEq LTemp LExpr LExpr | -- "Compares to values and stores result into temporary"
  BrU LTemp |                -- "Unconditional branch" 
  BrC LExpr LTemp LTemp |    -- "Conditional branch"
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

fun b2llvm_expr :: "BExpr \<Rightarrow> (BVariable \<Rightarrow> LAddr) \<Rightarrow> LTemp \<Rightarrow> (LStm list * LExpr * LTemp)"
where
  "b2llvm_expr BTrue loc tmp = ([], Val(LBool True), tmp)" |
  "b2llvm_expr BFalse loc tmp = ([], Val(LBool False), tmp)" |    
  "b2llvm_expr (BVar v) loc tmp = ( [ Load tmp (loc v) ], Var tmp, tmp+1)" |    
  "b2llvm_expr (BConst (BInt i)) loc tmp = ([], Val (LInt i), tmp)" |
  "b2llvm_expr (BConst (BBool b)) loc tmp = ([], Val (LBool b), tmp)" |
  "b2llvm_expr (BSum e1 e2) loc tmp = 
    (case (b2llvm_expr e1 loc tmp) of
      (p1, v1, tmp1) \<Rightarrow>
        (case (b2llvm_expr e2 loc tmp1) of
          (p2, v2, tmp2) \<Rightarrow> ( p1 @ p2 @ [ Add tmp2 v1 v2 ], Var tmp2, tmp2+1)))"

value "(let (v0, v1, v2) = (0, 1, 2) in 
          (b2llvm_expr (BConst (BInt 0)) (\<lambda> x . x) 0))"
value "(let (v0, v1, v2) = (0, 1, 2) in 
          (b2llvm_expr (BSum (BSum (BConst (BInt 1)) (BConst (BInt 2))) (BConst (BInt 3))) (\<lambda> x . x) 0))"
value "(let (v0, v1, v2) = (0, 1, 2) in 
          (b2llvm_expr (BSum (BSum (BVar 0) (BConst (BInt 1))) (BVar 1)) (\<lambda> x . x) 0))"
          
fun b2llvm_pred :: "BPredicate \<Rightarrow> (BVariable \<Rightarrow> LAddr) \<Rightarrow> LTemp \<Rightarrow> LTemp \<Rightarrow> LTemp \<Rightarrow> (LStm list * LExpr * LTemp)"
where
  "b2llvm_pred (BEq e1 e2) loc label_true label_false tmp =
    (case (b2llvm_expr e1 loc tmp) of
      (il1, v1, tmp1) \<Rightarrow>
        (case (b2llvm_expr e2 loc tmp1) of
          (il2, v2, tmp2) \<Rightarrow> 
            ( il1 @ il2 @ 
              [ ICmpEq tmp2 v1 v2 ,
                BrC (Var tmp2) label_true label_false], 
              Var tmp2, tmp2+1)))" |      
  "b2llvm_pred (BConj p1 p2) loc label_true label_false tmp =                        
    (case (b2llvm_pred p1 loc tmp label_false (tmp + 1)) of
      (il1, v1, tmp1) \<Rightarrow>
        (case (b2llvm_pred p2 loc label_true label_false (tmp1 + 1)) of
          (il2, v2, tmp2) \<Rightarrow> 
            (il1 @ 
             [ BrC v1 tmp1 label_false, Label tmp ] @ 
             il2, 
             Var tmp2, tmp2)))" |
  "b2llvm_pred (BNeg p) loc label_true label_false tmp =                          
    (case (b2llvm_pred p loc label_false label_true tmp) of
      (il, v, tmp') \<Rightarrow> (il, Var tmp', tmp'+1))"

text {* Next, the following function formalizes the translation for B instructions. *}

fun b2llvm_stm :: "BInst \<Rightarrow> (BVariable \<Rightarrow> LAddr) \<Rightarrow> LTemp \<Rightarrow> (LStm list * LTemp)" where
  "b2llvm_stm (Asg v e) loc temp =
    (case (b2llvm_expr e loc temp) of
      (sl, e', t') \<Rightarrow> (sl @ [ (Store e' (loc v)) ], t'))" |
  "b2llvm_stm (Blk []) loc temp = ( [], temp )" |
  "b2llvm_stm (Blk (x # xs)) loc temp =
    (case (b2llvm_stm x loc temp) of
      (sl, t') \<Rightarrow> (case (b2llvm_stm (Blk xs) loc temp) of
                    (sl', t'') \<Rightarrow> (sl @ sl', t'')))" |
  "b2llvm_stm (If c i1 i2) loc temp =
    (let (bk_then, bk_else, bk_end) = (temp, temp + 1, temp + 2) in
      (let (ilc, e1, tmp1) = b2llvm_pred c loc bk_then bk_else (bk_end + 1) in
        (let (ilt, tmp2) = b2llvm_stm i1 loc tmp1 in
          (let (ile, tmp3) = b2llvm_stm i2 loc tmp2 in
            (ilc @
            [BrC e1 bk_then bk_else] @
            [Label bk_then] @
            ilt @
            [BrU bk_end] @
            [Label bk_else] @
            ile @
            [BrU bk_end] @
            [Label bk_end],
            tmp3)))))" |
  "b2llvm_stm Skip loc temp = ([], temp)"

value "let (v0, v1, v2) = (0, 1, 2) in 
          b2llvm_stm Skip (\<lambda> x . x) 0"
value "(let (v0, v1, v2) = (0, 1, 2) in 
          (b2llvm_stm (Asg 0 (BConst (BInt 0))) (\<lambda> x . x) 0))"
value "(let (v0, v1, v2) = (0, 1, 2) in 
          (b2llvm_stm (If (BEq (BVar 0) (BConst (BInt 0))) (Asg 0 (BConst (BInt 1))) Skip) (\<lambda> x . x) 0))"

section {* Semantics *}

text {* The following paragraphs are in draft-state, at best. *}

subsection {* Semantics for source B constructions *}

text {* We define a B expression as well-formed when we can derive its type in a context. *}
definition WF_BExpr :: "BExpr \<Rightarrow> BContext \<Rightarrow> bool" where
  "WF_BExpr e \<gamma> \<equiv> (case (BExprType e \<gamma>) of Some _ \<Rightarrow> True | None \<Rightarrow> False)"

text {* A predicate is well-formed when there is a derivation from the context that its type
  is Boolean. *}
fun WF_BPredicate :: "BPredicate \<Rightarrow> BContext \<Rightarrow> bool" where
  "WF_BPredicate (BEq e1 e2) \<gamma> =                                  
    (case (BExprType e1 \<gamma>, BExprType e2 \<gamma>) of (Some t1, Some t2) \<Rightarrow> t1 = t2 | _ => False)" |
  "WF_BPredicate (BConj p1 p2) \<gamma> = (WF_BPredicate p1 \<gamma> \<and> WF_BPredicate p2 \<gamma>)" |
  "WF_BPredicate (BNeg p) \<gamma> = WF_BPredicate p \<gamma>"


text {* Definition of a (record) type for the state of the B component. The state is specified by
a valuation of some variables. *}

record BState =
  \<Gamma> :: BContext
  \<V> :: "BVariable \<Rightarrow> BValue"   -- "valuation of the variables"

text {* A state is considered to be well-formed whenever each variable is valued according
to its typing information. *}

definition WF_BState :: "BState \<Rightarrow> bool" where
  "WF_BState s \<equiv> \<forall> v . (v \<in> \<alpha> (\<Gamma> s) \<longrightarrow> \<tau> (\<Gamma> s) v = BValueType (\<V> s v))"
      
text {* The following definition gives an (operational) semantics of expressions. 
The evaluation of an expression in a state yields a value. *}

text {* The following functions formalize well-formed instructions and instruction lists. 
An assignment is well-formed whenever the source expression is well-formed, the target
variable belongs to the context alphabet, and the type of the variable is the same as
that of the expression. *}        
fun WF_BInst :: "BInst \<Rightarrow> BContext \<Rightarrow> bool" and
    WF_BInstList :: "BInst list \<Rightarrow> BContext \<Rightarrow> bool"
where                                                                           
  "WF_BInst (Asg v e) \<gamma> = 
    (v \<in> \<alpha> \<gamma> \<and> WF_BExpr e \<gamma> \<and> Some ((\<tau> \<gamma>) v) = (BExprType e \<gamma>))" |
  "WF_BInst (Blk il) \<gamma> = WF_BInstList il \<gamma>" |

  "WF_BInstList [] _ = True" |
  "WF_BInstList (i # il) \<gamma> = ((WF_BInst i \<gamma>) \<and> (WF_BInstList il \<gamma>))"                       

primrec BEvalPredicate :: "BPredicate \<Rightarrow> BState \<Rightarrow> bool option" and
        BEvalExpr :: "BExpr \<Rightarrow> BState \<Rightarrow> BValue option" where
  "BEvalPredicate (BEq e1 e2) s =                        
    (case (BEvalExpr e1 s, BEvalExpr e2 s) of
       (Some (BInt i1), Some (BInt i2)) \<Rightarrow> Some (i1 = i2) |
       (Some (BBool b1), Some (BBool b2)) \<Rightarrow> Some (b1 = b2) |
       _ \<Rightarrow> None)" |
  "BEvalPredicate (BConj p1 p2) s =
    (case (BEvalPredicate p1 s, BEvalPredicate p2 s) of
      (Some b1, Some b2) \<Rightarrow> Some (b1 \<and> b2) |
       _ \<Rightarrow> None)" |                                                
  "BEvalPredicate (BNeg p) s =   
    (case (BEvalPredicate p s) of
      Some b \<Rightarrow> Some(\<not> b) |
     _ \<Rightarrow> None)" |

  "BEvalExpr BTrue s = Some (BBool True)" |       
  "BEvalExpr BFalse s = Some (BBool False)" |
  "BEvalExpr (BVar v) s = Some ((\<V> s) v)" |
  "BEvalExpr (BConst v) s = Some v" |
  "BEvalExpr (BSum e1 e2) s = 
    (case (BEvalExpr e1 s, BEvalExpr e2 s) of 
      (Some (BInt i1), Some (BInt i2)) \<Rightarrow> Some (BInt (i1 + i2)) | 
       _ \<Rightarrow> None)"

text {* TODO: prove that if an expression is well-formed, and a state is well formed, then
the evaluation of that expression in that state yields Some value. Similar property should hold
for predicates. *}

lemma B_eval_wf_expr: 
assumes
  "QF_BState \<sigma>"
  "WF_BExpr e (\<Gamma> \<sigma>)"
shows
  "\<exists> v . BEvalExpr e \<sigma> = Some v"
sorry                                                    

lemma B_eval_wf_pred: 
assumes
  "QF_BState \<sigma>"
  "WF_BPred p (\<Gamma> \<sigma>)"
shows
  "\<exists> b . BEvalPred p \<sigma> = Some b"
sorry
 
text {* Next, the semantics of statement is defined: a statement changes the state. *}
primrec BEvalInst :: "BInst \<Rightarrow> BState \<Rightarrow> BState option" and
  BEvalInstList :: "BInst list \<Rightarrow> BState \<Rightarrow> BState option"
where
  "BEvalInst (Asg v e) s = (case (BEvalExpr e s) of
     Some val \<Rightarrow> Some \<lparr>  \<Gamma> = \<Gamma> s, \<V> = (\<V> s) (v := val) \<rparr> |
     None \<Rightarrow> None)" |
  "BEvalInst (Blk l) s = BEvalInstList l s" |
                                                     
  "BEvalInstList [] s = Some s" |
  "BEvalInstList (x # xs) s = (case (BEvalInst x s) of
    Some s' \<Rightarrow> BEvalInstList xs s' |            
    _ \<Rightarrow> None)"
      
text {* TODO: prove that if an instruction is well-formed, and a state is well formed, then
the execution of that instruction in that state yields Some state. *}

lemma B_eval_wf_inst: 
assumes
  "QF_BState \<sigma>"
  "WF_BInst i (\<Gamma> \<sigma>)"
shows
  "\<exists> \<sigma>' . BEvalInst e \<sigma> = Some \<sigma>'"
sorry
                                        
subsection  {* Semantics for LLVM language elements. *}

type_synonym LMemory = "LAddr \<Rightarrow> LValue"

primrec LEvalExpr :: "LExpr \<Rightarrow> LMemory \<Rightarrow> LValue" where
  "LEvalExpr (Val v) s = v" |
  "LEvalExpr (Var v) s = s v"

record LCode =
  prog :: "LStm list"         -- "a sequence of instructions forming a program unit"
  blocks :: "LLabel \<Rightarrow> nat"   -- "position of each block label in the sequence"  

(* DD: The following is voodoo for me. In summary, it makes the record definition behave as a
datatype definition, which in turn makes it possible to have record patterns in function
definitions.

Source: https://lists.cam.ac.uk/pipermail/cl-isabelle-users/2011-June/msg00062.html 
*)
rep_datatype LCode_ext by (fact LCode.ext_induct) (fact LCode.ext_inject)

record LState =
  pc :: nat                   -- "program counter"
  mem :: "LMemory"            -- "global store"
  local :: "LTemp \<Rightarrow> LValue"  -- "temporaries within LLVM functions"

rep_datatype LState_ext by (fact LState.ext_induct) (fact LState.ext_inject)

text {* Follows the specification of the semantics for the selected LLVM statements. As with a
B instruction, the semantics of a LLVM statement is a state transformer. *}

fun LStep :: "LCode \<Rightarrow> LState \<Rightarrow> LState option" where
  "LStep \<lparr> prog = \<Pi>, blocks = b \<rparr> \<lparr> pc = i, mem = M, local = L \<rparr> =
    (if (\<not> i < length \<Pi>) then
       None
     else                                                  
       (case \<Pi> ! i of                                                                
         Load t a \<Rightarrow> Some \<lparr> pc = i+1, mem = M, local = L (t := M a) \<rparr> |
         Store v a \<Rightarrow> Some \<lparr> pc = i+1, mem = M (a := LEvalExpr v M), local = L \<rparr> |
         Add t v v' \<Rightarrow>
            (case (LEvalExpr v M, LEvalExpr v' M) of
              (LInt i1, LInt i2) \<Rightarrow> 
                Some \<lparr> pc = i+1, mem = M, local = L( t:= LInt(i1 + i2)) \<rparr> |
              _ \<Rightarrow> None) |                                    
         ICmpEq t v v' \<Rightarrow>
            (case (LEvalExpr v M, LEvalExpr v' M) of
              (LInt w, LInt w') \<Rightarrow> 
                Some \<lparr> pc = i+1, mem = M, local = L( t:= LBool(w = w')) \<rparr> |
              (LBool w, LBool w') \<Rightarrow> 
                Some \<lparr> pc = i+1, mem = M, local = L( t:= LBool(w = w')) \<rparr> |
              _ \<Rightarrow> None) |
         BrU label \<Rightarrow>
         (if (\<not> b label < length \<Pi>) then 
           None 
         else 
           Some \<lparr> pc = b label, mem = M, local = L \<rparr> )))"


end

