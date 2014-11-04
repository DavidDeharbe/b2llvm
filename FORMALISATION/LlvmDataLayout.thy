theory LlvmDataLayout
imports Main
begin

datatype EndianType =
BigEndian | LittleEndian

record DataLayout =
  EndianNess :: EndianType
  StackAlignment :: "nat option" -- "defaults to unspecified"
  PointerAlignment :: "nat * nat * (nat option)"
  IntegerAlignment :: "nat \<Rightarrow> (nat * nat) option"  --"isize:abi:pref"
  VectorAlignmnent :: "nat \<Rightarrow> (nat * nat)"         -- "vsize:abi:pref"
  FloatAlignment :: "nat \<Rightarrow> (nat * nat)"           -- "fsize:abi:pref"
  AggregateAlignment :: "nat \<Rightarrow> (nat * nat)"       -- "asize:abi:pref"
  StackObjectAlignment :: "nat \<Rightarrow> (nat * nat)" -- "ssize:abi:pref"
  NativeIntegers :: "nat set" -- "native integer widths for the target CPU in bits"
  
end

