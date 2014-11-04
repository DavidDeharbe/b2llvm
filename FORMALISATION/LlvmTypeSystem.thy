theory LlvmTypeSystem
imports Main LlvmDataLayout
begin

datatype LlvmFloatingPointType =
  Half
| Float
| Double
| Fp128
| X86_fp80
| Ppc_fp128

datatype LlvmType =
  Integer nat -- "bit width"
| FloatingPoint LlvmFloatingPointType -- "one of several predefined floating point types"
| X86mmx
| Void
| Label
| Metadata
| Array "nat * LlvmType" -- "size and type of elements"
| Function "LlvmType * (LlvmType list) * (bool option)" -- "return type, list of parameter types, optionally ..."
| Structure "LlvmType list * bool option" -- "list of fields, optionally packed"
| Opaque
| Pointer "LlvmType  * (nat option)" -- "type of data pointed, optionally address space"
| Vector "nat * LlvmType" -- "size and type of elements"
  
fun IsPrimitiveType :: "LlvmType \<Rightarrow> bool" where
  "IsPrimitiveType (Integer x) = True"
| "IsPrimitiveType (FloatingPoint x) = True"
| "IsPrimitiveType X86mmx = True"
| "IsPrimitiveType Void = True"
| "IsPrimitiveType Label = True"
| "IsPrimitiveType Metadata = True"
| "IsPrimitiveType (Array x) = False"
| "IsPrimitiveType (Function x) = False"
| "IsPrimitiveType (Structure x) = False"
| "IsPrimitiveType Opaque = False"
| "IsPrimitiveType (Pointer x) = False"
| "IsPrimitiveType (Vector x) = False"

definition IsDerivedType :: "LlvmType \<Rightarrow> bool" where
  "IsDerivedType t = (\<not> IsPrimitiveType t)"

fun IsFirstClassType :: "LlvmType \<Rightarrow> bool" where
  "IsFirstClassType (Integer x) = True"
| "IsFirstClassType (FloatingPoint x) = True"
| "IsFirstClassType X86mmx = False"
| "IsFirstClassType Void = False"
| "IsFirstClassType Label = True"
| "IsFirstClassType Metadata = True"
| "IsFirstClassType (Array x) = True"
| "IsFirstClassType (Function x) = False"
| "IsFirstClassType (Structure x) = True"
| "IsFirstClassType Opaque = False"
| "IsFirstClassType (Pointer x) = True"
| "IsFirstClassType (Vector x) = True"

end

