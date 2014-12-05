header {* b2llvm - level 1 *}

theory b2llvm_1
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
  Sum BExpr BExpr (infix "+\<^sub>B" 65)

text {* The following definition gives an (operational) semantics of expressions. The evaluation of 
an expression in a state yields a value. *}

inductive BEvalExpr :: "BExpr \<times> BState \<Rightarrow>  BValue \<Rightarrow> bool" (infix "\<leadsto>\<^sub>B\<^sup>E" 55) where
  "(Const v, _) \<leadsto>\<^sub>B\<^sup>E v" |
  "(BVar v, \<sigma>) \<leadsto>\<^sub>B\<^sup>E store \<sigma> v" |
  "\<lbrakk> (e1, \<sigma>) \<leadsto>\<^sub>B\<^sup>E BInt i1; (e2, \<sigma>) \<leadsto>\<^sub>B\<^sup>E BInt i2 \<rbrakk> \<Longrightarrow> (e1 +\<^sub>B e2, \<sigma>) \<leadsto>\<^sub>B\<^sup>E BInt (i1 + i2)"

text {* A type for B instructions. Needs to be extended to match the actual language. *}
datatype BInst =
  Asg BVariable BExpr (infix "\<leftarrow>" 60) |
  Blk "BInst list"

text {* The "Concrete Semantics" textbook instead used predicates to specify big-step
semantics. *}
inductive
  Bbig_step :: "BInst \<times> BState \<Rightarrow> BState \<Rightarrow> bool" (infix "\<leadsto>\<^sub>B" 55) and
  Bbig_step_l :: "BInst list \<times> BState \<Rightarrow> BState \<Rightarrow> bool" (infix "\<leadsto>\<^sub>B\<^sup>*" 55)
where
  "\<lbrakk> (e, \<sigma>) \<leadsto>\<^sub>B\<^sup>E x \<rbrakk> \<Longrightarrow> (v \<leftarrow> e, \<sigma>) \<leadsto>\<^sub>B \<lparr> alpha = alpha \<sigma>, store = (store \<sigma>) (v := x) \<rparr>" |
  "\<lbrakk> (il, \<sigma>) \<leadsto>\<^sub>B\<^sup>* \<sigma>' \<rbrakk> \<Longrightarrow> (Blk il, \<sigma>) \<leadsto>\<^sub>B \<sigma>'" |
  
  "( [], \<sigma>) \<leadsto>\<^sub>B\<^sup>* \<sigma>" |
  "\<lbrakk> (i, \<sigma>) \<leadsto>\<^sub>B \<sigma>'; (il, \<sigma>') \<leadsto>\<^sub>B\<^sup>* \<sigma>'' \<rbrakk> \<Longrightarrow> (i # il, \<sigma>) \<leadsto>\<^sub>B\<^sup>* \<sigma>''"
  
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
  Val LValue |                -- "literals"
  Var LTemp                   -- "temporaries"

inductive LEvalExpr :: "LExpr \<times> LState \<Rightarrow> LValue \<Rightarrow> bool" (infix "\<leadsto>\<^sub>L\<^sup>E" 55) where
  "(Val v, _) \<leadsto>\<^sub>L\<^sup>E v" |
  "(Var v, \<sigma>) \<leadsto>\<^sub>L\<^sup>E (mem \<sigma>) v"
  
text {* Next, (a few) LLVM statements are formalized in the following type. Note that the typing 
annotation found in the concrete syntax of LLVM is omitted (the formalization currently avoids 
considering typing issues anyway). *}

datatype LStm =
  Load LTemp LAddr |
  Store LExpr LAddr |
  Add LTemp LExpr LExpr

text {* Follows the specification of the semantics for the selected LLVM statements. As with a
B instruction, the semantics of a LLVM statement is a state transformer. *}

inductive
  Lbig_step :: "LStm \<times> LState \<Rightarrow> LState \<Rightarrow> bool" (infix "\<leadsto>\<^sub>L" 55) and
  Lbig_step_star :: "LStm list \<times> LState \<Rightarrow> LState \<Rightarrow> bool" (infix "\<leadsto>\<^sub>L\<^sup>*" 55)
where
  "\<lbrakk> m = mem \<sigma> \<rbrakk> \<Longrightarrow> (Load t a, \<sigma>) \<leadsto>\<^sub>L \<lparr> mem = m, local = (local \<sigma>)(t := m a) \<rparr>" |
  "\<lbrakk> (v, \<sigma>) \<leadsto>\<^sub>L\<^sup>E x \<rbrakk> \<Longrightarrow> (Store v a, \<sigma>) \<leadsto>\<^sub>L \<lparr> mem = (mem \<sigma>) (a := x), local = local \<sigma> \<rparr>" |
  "\<lbrakk> (v1, \<sigma>) \<leadsto>\<^sub>L\<^sup>E (LInt i1); (v2, \<sigma>) \<leadsto>\<^sub>L\<^sup>E (LInt i2) \<rbrakk> \<Longrightarrow> 
    (Add t v1 v2, \<sigma>) \<leadsto>\<^sub>L \<lparr> mem = (mem \<sigma>), local = (local \<sigma>)( t := LInt (i1 + i2) ) \<rparr>" |
  "([], \<sigma>) \<leadsto>\<^sub>L\<^sup>* \<sigma>" |
  "\<lbrakk> (s, \<sigma>) \<leadsto>\<^sub>L \<sigma>'; (sl, \<sigma>') \<leadsto>\<^sub>L\<^sup>* \<sigma>'' \<rbrakk> \<Longrightarrow> (s # sl, \<sigma>) \<leadsto>\<^sub>L\<^sup>* \<sigma>''"

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
  
definition StateMap :: "BState \<Rightarrow> DataMap \<Rightarrow> LState \<Rightarrow> bool" where
  "StateMap st\<^sub>B m st\<^sub>L \<equiv> \<forall> b v . b \<in> alpha st\<^sub>B \<longrightarrow> v = m b \<longrightarrow> b2llvm_data (store st\<^sub>B b) = mem st\<^sub>L v"

text
{*
The first function formalizes the code generation for expressions:
 *}
inductive 
  b2llvm_expr :: "BExpr \<Rightarrow> DataMap \<Rightarrow> LTemp \<Rightarrow> (LStm list \<times> LExpr \<times> LTemp) \<Rightarrow> bool" (infix "\<Turnstile>\<^bsup>Expr\<^esup>" 50) 
where
  "b2llvm_expr (Const (BInt i)) loc tmp ([], (Val (LInt i)), tmp)" |
  "b2llvm_expr (BVar v) loc tmp ( [ Load tmp (loc v) ], Var tmp, tmp+1)" |
  "\<lbrakk> b2llvm_expr e1 loc tmp (il1, v1, tmp1); 
     b2llvm_expr e2 loc tmp1 (il2, v2, tmp2) \<rbrakk> \<Longrightarrow>
      b2llvm_expr (e1 +\<^sub>B e2) loc tmp ( il1 @ il2 @ [ Add tmp2 v1 v2 ], Var tmp2, tmp2+1)"

text
{*
  First, we want to express some properties about the translation of expressions.
*}
lemma b2llvm_exp_temporary_increase:
  "b2llvm_expr e m tmp (sl, t, tmp') \<Longrightarrow> tmp \<le> tmp'"
sorry

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
and "(expB, m, tmp) \<Turnstile>\<^bsup>Expr\<^esup> (prog, expL, tmp')"
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
and "(expB, m, tmp) \<Turnstile>\<^bsup>Expr\<^esup> (prog, expL, tmp')"
and "(prog, \<sigma>\<^sub>L) \<leadsto>\<^sub>L\<^sup>* \<sigma>\<^sub>L'"
and "(expB, \<sigma>\<^sub>B) \<leadsto>\<^sub>B\<^sup>E valB"
and "(expL, \<sigma>\<^sub>L') \<leadsto>\<^sub>L\<^sup>E valL"
shows
  "b2llvm_data valB = valL"
sorry

text {* The following function formalizes the LLVM code generation from B instructions. *}

inductive
  b2llvm_stm :: "BInst \<times> DataMap \<times> LTemp \<Rightarrow> (LStm list \<times> LTemp) \<Rightarrow> bool" and
  b2llvm_stm_list :: "BInst list \<times> DataMap \<times> LTemp \<Rightarrow> (LStm list \<times> LTemp) \<Rightarrow> bool"
where
  "\<lbrakk> (e, m, tmp) \<Turnstile>\<^bsup>Expr\<^esup> (sl, e', t') \<rbrakk> \<Longrightarrow>
    b2llvm_stm (Asg v e, m, tmp) (sl @ [ Store e' (m v) ], t')" |
  "\<lbrakk> b2llvm_stm_list (l, m, tmp) (sl, tmp') \<rbrakk> \<Longrightarrow>
    b2llvm_stm (Blk l, m, tmp) (sl, tmp' )" |

  "b2llvm_stm_list ([], m, tmp) ([], tmp)" |
  "\<lbrakk> b2llvm_stm (i, m, tmp) (sl, tmp') ; 
     b2llvm_stm_list(il, m, tmp') (sl', tmp'') \<rbrakk> \<Longrightarrow>
   b2llvm_stm_list(i # il, m, tmp) (sl @ sl', tmp'')"
   
end

