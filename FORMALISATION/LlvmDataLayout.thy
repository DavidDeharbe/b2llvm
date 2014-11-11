
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
  VectorAlignmnent :: "nat \<Rightarrow> (nat * nat)"         -- "vsize:abi:pref"
  FloatAlignment :: "nat \<Rightarrow> (nat * nat)"           -- "fsize:abi:pref"
  AggregateAlignment :: "nat \<Rightarrow> (nat * nat)"       -- "asize:abi:pref"
  StackObjectAlignment :: "nat \<Rightarrow> (nat * nat)" -- "ssize:abi:pref"
  NativeIntegers :: "nat set" -- "native integer widths for the target CPU in bits"

definition DefaultDataLayout :: DataLayout where
  "DefaultDataLayout = 
    \<lparr> EndianNess = BigEndian,
      StackAlignment = None,
      PointerAlignment = (64, 64, Some 64),
      IntegerAlignment = {1 |-> Some (8,8), 8 |-> Some(8, 8) \<rparr>, 16 |-> Some(16, 16),
                          32 |-> Some(32, 32), "
  
end

