
theory LlvmDataLayout
imports Main
begin

section {* Data Layout *}

text {* LLVM has a set of default settings to lay out data in memory. These settings may be 
overriden in a module by an explicit statement. The data layout settings are formalized hereafter. *}

text {* Endianness specifies whether least significant bits have highest address (big-endian) or 
lowest address (little-endian). The type @{text "EndianType"} enumerates the possible values
for endianness.*}

datatype EndianType =
  BigEndian     -- "most significant bits have lowest address"
| LittleEndian  -- "least significant bits have lowest address"

text {* Alignment settings are defined on a per-type basis; they are composed of the ABI and
        preferred alignment. *}
record TypeAlignment =
  ABI :: nat
  Pref :: "nat option"
  
text {* The record type @{text "DataLayout"} has one field per aspect of the layout:
\begin{itemize}
\item @{text "EndianNess"} indicates if the architecture is big-endian or little-endian.
\item @{text "StackAlignment"} is the natural alignment of the stack (in bits), i.e. it
constrains the alignment of stack variables. If specified, it must be a multiple of 8.
\item @{text "PointerAlignment"} specifies the size of pointers and the corresponding
alignment.
\item @{text "IntegerAlignment"} specifies the alignment of integer types. For each supported
bit width one alignment is specified.
\end{itemize}
*}
record DataLayout =
  EndianNess :: EndianType
  StackAlignment :: "nat option" -- "defaults to unspecified"
  PointerAlignment :: "nat * nat * (nat option)"
  IntegerAlignment :: "nat \<Rightarrow> TypeAlignment option"         --"isize:abi:pref"
  VectorAlignment :: "nat \<Rightarrow> TypeAlignment option"         -- "vsize:abi:pref"
  FloatAlignment :: "nat \<Rightarrow> TypeAlignment option"           -- "fsize:abi:pref"
  AggregateAlignment :: "nat \<Rightarrow> TypeAlignment option"       -- "asize:abi:pref"
  StackObjectAlignment :: "nat \<Rightarrow> TypeAlignment option" -- "ssize:abi:pref"
  NativeIntegers :: "nat set" -- "native integer widths for the target CPU in bits"

fun DefaultIntegerAlignment :: "nat \<Rightarrow> (TypeAlignment option)"
where
  "DefaultIntegerAlignment w =
  (if w = 1 then Some\<lparr> ABI = 8, Pref = Some 8 \<rparr>
   else if w = 8 then Some\<lparr> ABI = 8, Pref = Some 8 \<rparr>
   else if w = 16 then Some\<lparr> ABI = 16, Pref = Some 16 \<rparr>
   else if w = 32 then Some\<lparr> ABI = 32, Pref = Some 32 \<rparr>
   else if w = 64 then Some\<lparr> ABI = 64, Pref = Some 64 \<rparr>
   else None)"

fun DefaultVectorAlignment :: "nat \<Rightarrow> (TypeAlignment option)"
where
  "DefaultVectorAlignment w =
  (if w = 64 then Some\<lparr> ABI = 64, Pref = Some 64 \<rparr>
   else if w = 128 then Some\<lparr> ABI = 128, Pref = Some 128 \<rparr>
   else None)"

fun DefaultFloatAlignment :: "nat \<Rightarrow> (TypeAlignment option)"
where
  "DefaultFloatAlignment w =
  (if w = 32 then Some\<lparr> ABI = 32, Pref = Some 32 \<rparr>
   else if w = 64 then Some\<lparr> ABI = 64, Pref = Some 64 \<rparr>
   else None)"

fun DefaultAggregateAlignment :: "nat \<Rightarrow> (TypeAlignment option)"
where
  "DefaultAggregateAlignment w =
  (if w = 0 then Some\<lparr> ABI = 0, Pref = Some 1 \<rparr> else None )"

fun DefaultStackAlignment :: "nat \<Rightarrow> (TypeAlignment option)"
where
  "DefaultStackAlignment w =
  (if w = 0 then Some\<lparr> ABI = 64, Pref = Some 64 \<rparr> else None )"

definition DefaultDataLayout :: DataLayout where
  "DefaultDataLayout = 
    \<lparr> EndianNess = BigEndian,
      StackAlignment = None,
      PointerAlignment = (64, 64, Some 64),
      IntegerAlignment = DefaultIntegerAlignment,
      VectorAlignment = DefaultVectorAlignment,
      FloatAlignment = DefaultFloatAlignment,
      AggregateAlignment = DefaultAggregateAlignment,
      StackObjectAlignment = DefaultStackAlignment,
      NativeIntegers = {8, 16, 32, 64} \<rparr> "
  
end

