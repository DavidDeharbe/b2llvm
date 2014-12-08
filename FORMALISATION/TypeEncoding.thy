theory TypeEncoding
imports Main BConcreteTypes LlvmTypeSystem
begin

fun "LlvmOfBType" :: "DataLayout \<Rightarrow> BConcreteType \<Rightarrow> LlvmType"
where
  "LlvmOfBType _ Boolean = (Integer 1)"
| "LlvmOfBType _ (Enumeration e) = (let l = length e in (Integer l))"
| "LlvmOfBType _ (Interval _) = (Integer 32)"
| "LlvmOfBType _ _ = Void"

end

