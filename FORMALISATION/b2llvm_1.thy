header {* b2llvm - level 1 *}

theory b2llvm_1
imports Main
begin

section {* Syntax *}

subsection {* Syntax for source B implementation *}

text {* Definition of a type for B variables.*}

type_synonym BVariable = string

text {* Define the possible values taken by B variables. We make here the simplifying assumption 
that such variables are integers. *}
datatype BValue = BInt int

text {* A type for B expressions. *}
datatype BExpr =
  Const BValue |
  BVar BVariable |
  Sum BExpr BExpr (infix "+\<^sub>B" 65)

text {* A type for B instructions. Needs to be extended to match the actual language. *}
datatype BInst =
  Asg BVariable BExpr (infix "\<leftarrow>" 60) |
  Blk "BInst list"

subsection {* Syntax for target LLVM code *}

text {* This completes the skeleton of a formal semantics of the B implementation language. 
We next turn our attention to LLVM. First two types are introduced: they respectively 
represent memory addresses and temporary variables.*}

type_synonym LAddr = nat
type_synonym LTemp = nat

text {* Again, we consider that values can only be integer values. *}
datatype LValue = LInt int

text {* Expressions in LLVM statements can only be constants or temporaries. They are
formalized as follows: *}
datatype LExpr =
  Val LValue |                -- "literals"
  Var LTemp                   -- "temporaries"

datatype LStm =
  Load LTemp LAddr |
  Store LExpr LAddr |
  Add LTemp LExpr LExpr

text {* A LLVM program is a list of LLVM statements. *}
type_synonym LProg = "LStm list"

text {* I want to specify what is a well-formed LLVM program. Some properties that may be 
expressed and proved are the following:
\begin{itemize}
\item the temporary names must form an increasing sequence of numbers, starting from 0;
\item the program is well-typed;
\item the program is in SSA form.
\end{itemize}

Proving each such property will require developing auxiliary definitions before addressing
the corresponding proofs.
*}

(*
type_synonym nat_list = "nat list"

inductive is_nat_interval :: "nat \<Rightarrow> nat list \<Rightarrow> bool"
where
  "is_nat_interval n []" |
  "\<lbrakk> is_nat_interval n (x # xl); x < n \<rbrakk> \<Longrightarrow> is_nat_interval n xl"

fun upto :: "nat \<Rightarrow> nat list" where
  "upto 0 = []" |
  "upto (Suc n) = (upto n) @ [n]"

lemma "is_nat_interval n (upto n)"
sorry *)

(*
primrec LStm_temp :: "LStm \<Rightarrow> LTemp option" where
  "LStm_temp (Load t a) = Some t" |
  "LStm_temp (Store e a) = None" |
  "LStm_temp (Add t e e') = Some t"

primrec LProg_temp_first :: "LProg \<Rightarrow> LTemp option" where
  "LProg_temp_first [] = None" |
  "LProg_temp_first (i #il) = (if LStm_temp i = None then LProg_temp_first il else LStm_temp i)"

primrec WF_LProg :: "LProg \<Rightarrow> bool" where
  "WF_LProg [] = True" |
  "WF_LProg (i # il) = ((WF_LProg il) \<and>
                        (case (LStm_temp i, LProg_temp_first il) of
                           (None, _) \<Rightarrow> True |
                           (_, None) \<Rightarrow> True |
                           (Some t1, Some t2) \<Rightarrow> t1 < t2))"
                        
*)

subsection {* Generation of LLVM from B *}

text {* The third part of the formalization deals with the generation of LLVM code from B
expressions and instructions. All functions take as
\begin{itemize}
\item an element of B language to B translated;
\item a function mapping B variables to LLVM memory addresses;
\item the next LLVM temporary name to be used (each temporary may be assigned exactly once).
\end{itemize}
*}

text {* The function mapping B variables to LLVM memory addresses has the following type: *}
type_synonym DataMap = "BVariable \<Rightarrow> LAddr"

text {* The well-formed condition for such functions is that two different variables are
mapped to different addresses, that is, they must be injective. *}

definition WF_DataMap :: "DataMap \<Rightarrow> bool" where
  "WF_DataMap m \<equiv> inj m"

text {* The following function formalizes the encoding of B data into LLVM data. *}
fun b2llvm_data :: "BValue \<Rightarrow> LValue" where
  "b2llvm_data (BInt i) = (LInt i)"

text
{*
The first function formalizes the code generation for expressions:
 *}
fun
  b2llvm_expr :: "BExpr \<Rightarrow> DataMap \<Rightarrow> LTemp \<Rightarrow> (LStm list \<times> LExpr \<times> LTemp)" 
where
  "b2llvm_expr (Const (BInt i)) loc tmp = ([], (Val (LInt i)), tmp)" |
  "b2llvm_expr (BVar v) loc tmp = ( [ Load tmp (loc v) ], Var tmp, tmp+1)" |
  "b2llvm_expr (e1 +\<^sub>B e2) loc tmp =
    (let (il1, v1, tmp1) = (b2llvm_expr e1 loc tmp) in
       (let (il2, v2, tmp2) = (b2llvm_expr e2 loc tmp1) in
         (il1 @ il2 @ [ Add tmp2 v1 v2 ], Var tmp2, tmp2+1)))"

text {* The following function formalizes the LLVM code generation from B instructions. *}

inductive
  b2llvm_stm :: "BInst \<times> DataMap \<times> LTemp \<Rightarrow> (LStm list \<times> LTemp) \<Rightarrow> bool" and
  b2llvm_stm_list :: "BInst list \<times> DataMap \<times> LTemp \<Rightarrow> (LStm list \<times> LTemp) \<Rightarrow> bool"
where
  "\<lbrakk> b2llvm_expr e m tmp = (sl, e', t') \<rbrakk> \<Longrightarrow>
  b2llvm_stm (v \<leftarrow> e, m, tmp) (sl @ [ Store e' (m v) ], t')" |
  "\<lbrakk> b2llvm_stm_list (l, m, tmp) (sl, tmp') \<rbrakk> \<Longrightarrow>
    b2llvm_stm (Blk l, m, tmp) (sl, tmp' )" |

  "b2llvm_stm_list ([], m, tmp) ([], tmp)" |
  "\<lbrakk> b2llvm_stm (i, m, tmp) (sl, tmp') ; 
     b2llvm_stm_list(il, m, tmp') (sl', tmp'') \<rbrakk> \<Longrightarrow>
   b2llvm_stm_list(i # il, m, tmp) (sl @ sl', tmp'')"

section {* Semantics *}

subsection {* Semantics for source B implementations *}

text {* Definition of a (record) type for the state of the B component. The state is specified by
a valuation of some variables, that we call the alphabet of the state. *}
record BState =
  alpha :: "BVariable set"         -- "alphabet for the state"
  store :: "BVariable \<Rightarrow> BValue"   -- "valuation of the variables"

text {* The following definition gives an (operational) semantics of expressions. The evaluation of 
an expression in a state yields a value. *}

fun BEvalExpr :: "BExpr \<times> BState \<Rightarrow>  BValue" where
  "BEvalExpr (Const v, _) = v" |
  "BEvalExpr (BVar v, \<sigma>) = store \<sigma> v" |
  "BEvalExpr (e1 +\<^sub>B e2, \<sigma>) = (case (BEvalExpr (e1, \<sigma>), BEvalExpr(e2, \<sigma>)) of
    (BInt i1, BInt i2) \<Rightarrow> BInt (i1 + i2))"

text {* The "Concrete Semantics" textbook instead used predicates to specify big-step
semantics. *}
inductive
  Bbig_step :: "BInst \<times> BState \<Rightarrow> BState \<Rightarrow> bool" (infix "\<leadsto>\<^sub>B" 55) and
  Bbig_step_l :: "BInst list \<times> BState \<Rightarrow> BState \<Rightarrow> bool" (infix "\<leadsto>\<^sub>B\<^sup>*" 55)
where
  "(v \<leftarrow> e, \<sigma>) \<leadsto>\<^sub>B \<lparr> alpha = alpha \<sigma>, store = (store \<sigma>) (v := BEvalExpr(e, \<sigma>)) \<rparr>" |
  "\<lbrakk> (il, \<sigma>) \<leadsto>\<^sub>B\<^sup>* \<sigma>' \<rbrakk> \<Longrightarrow> (Blk il, \<sigma>) \<leadsto>\<^sub>B \<sigma>'" |
  
  "( [], \<sigma>) \<leadsto>\<^sub>B\<^sup>* \<sigma>" |
  "\<lbrakk> (i, \<sigma>) \<leadsto>\<^sub>B \<sigma>'; (il, \<sigma>') \<leadsto>\<^sub>B\<^sup>* \<sigma>'' \<rbrakk> \<Longrightarrow> (i # il, \<sigma>) \<leadsto>\<^sub>B\<^sup>* \<sigma>''"

subsection {* Semantics for target LLVM code *}

record LState =
  mem :: "LAddr \<Rightarrow> LValue"    -- "models the global store"
  local :: "LTemp \<Rightarrow> LValue"  -- "models the temporaries within LLVM functions"

fun LEvalExpr :: "LExpr \<times> LState \<Rightarrow> LValue" where
  "LEvalExpr (Val v, _) = v" |
  "LEvalExpr (Var v, \<sigma>) = (mem \<sigma>) v"
  
text {* Next, (a few) LLVM statements are formalized in the following type. Note that the typing 
annotation found in the concrete syntax of LLVM is omitted (the formalization currently avoids 
considering typing issues anyway). *}

text {* Follows the specification of the semantics for the selected LLVM statements. As with a
B instruction, the semantics of a LLVM statement is a state transformer. *}

inductive
  Lbig_step :: "LStm \<times> LState \<Rightarrow> LState \<Rightarrow> bool" (infix "\<leadsto>\<^sub>L" 55) and
  Lbig_step_star :: "LStm list \<times> LState \<Rightarrow> LState \<Rightarrow> bool" (infix "\<leadsto>\<^sub>L\<^sup>*" 55)
where
  "\<lbrakk> m = mem \<sigma> \<rbrakk> \<Longrightarrow> (Load t a, \<sigma>) \<leadsto>\<^sub>L \<lparr> mem = m, local = (local \<sigma>)(t := m a) \<rparr>" |
  "(Store v a, \<sigma>) \<leadsto>\<^sub>L \<lparr> mem = (mem \<sigma>) (a := LEvalExpr(v, \<sigma>)), local = local \<sigma> \<rparr>" |
  "\<lbrakk> LEvalExpr(v1, \<sigma>) = LInt i1; LEvalExpr (v2, \<sigma>) = LInt i2 \<rbrakk> \<Longrightarrow> 
    (Add t v1 v2, \<sigma>) \<leadsto>\<^sub>L \<lparr> mem = (mem \<sigma>), local = (local \<sigma>)( t := LInt (i1 + i2) ) \<rparr>" |
  "([], \<sigma>) \<leadsto>\<^sub>L\<^sup>* \<sigma>" |
  "\<lbrakk> (s, \<sigma>) \<leadsto>\<^sub>L \<sigma>'; (sl, \<sigma>') \<leadsto>\<^sub>L\<^sup>* \<sigma>'' \<rbrakk> \<Longrightarrow> (s # sl, \<sigma>) \<leadsto>\<^sub>L\<^sup>* \<sigma>''"

subsection {* Semantic aspects of code generation *}

definition StateMap :: "BState \<Rightarrow> DataMap \<Rightarrow> LState \<Rightarrow> bool" where
  "StateMap st\<^sub>B m st\<^sub>L \<equiv> \<forall> b v . b \<in> alpha st\<^sub>B \<longrightarrow> v = m b \<longrightarrow> b2llvm_data (store st\<^sub>B b) = mem st\<^sub>L v"

text {*
  The following lemma states that executing the LLVM code corresponding to the evaluation of
  a B expression does not change the memory dedicated to the representation of B variables.
  
  We suppose that
  \begin{itemize}
  \item @{term m} maps a B state {@term \<sigma>\<^sub>B} to a LLVM state {@term \<sigma>\<^sub>L};
  \item {@term m} is a well-formed state map;.
  \item the code generation for the expression @{term expB} produces a sequence
  of LLVM statements @{text prog}; and
  \item executing @{text prog} on {@term \<sigma>\<^sub>L} results in a new state @{term \<sigma>\<^sub>L'}.
  \end{itemize}
  Then we conclude that @{term m} also maps {@term \<sigma>\<^sub>B} to {@term \<sigma>\<^sub>L'}.
*}
lemma b2llvm_expr_sound_mem: 
assumes "StateMap \<sigma>\<^sub>B m \<sigma>\<^sub>L" and "WF_DataMap m" 
and "b2llv_expr(expB, m, tmp) = (prog, expL, tmp')"
and "(prog, \<sigma>\<^sub>L) \<leadsto>\<^sub>L\<^sup>* \<sigma>\<^sub>L'"
shows
  "StateMap \<sigma>\<^sub>B m \<sigma>\<^sub>L'"
sorry

text {*

  Next lemma states that the code generated from B expressions evaluates the correct value.
  
  We suppose that
  \begin{itemize}
  \item @{term m} maps a B state {@term \<sigma>\<^sub>B} to a LLVM state {@term \<sigma>\<^sub>L};
  \item @{term m} is a well-formed state map;.
  \item the code generation for the expression @{term expB} produces a sequence
  of LLVM statements @{text prog} and an LLVM expression @{text expL};
  \item executing @{text prog} on {@term \<sigma>\<^sub>L} results in a new state @{term \<sigma>\<^sub>L'};
  \item evaluation of @{term expB} in the B state @{term \<sigma>\<^sub>B} yields a value @{term valB}; and
  \item evaluation of @{term expL} in the LLVM state @{term \<sigma>\<^sub>L'} yields a value @{term valL}.
  \end{itemize}
  Then we conclude that the LLVM encoding of value @{term valB} is precisely @{term valL}.
*}
lemma b2llvm_expr_sound_val: 
assumes "StateMap \<sigma>\<^sub>B m \<sigma>\<^sub>L" and "WF_DataMap m" 
and "b2llvm_expr expB m tmp = (prog, expL, tmp')"
and "(prog, \<sigma>\<^sub>L) \<leadsto>\<^sub>L\<^sup>* \<sigma>\<^sub>L'"
and "BEvalExpr (expB, \<sigma>\<^sub>B) =  valB"
and "BEvalInst (expL, \<sigma>\<^sub>L') = valL"
shows
  "b2llvm_data valB = valL"
sorry

end

