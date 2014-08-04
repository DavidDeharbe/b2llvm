'''
This module provides string templates to form lines of LLVM source code.

The templates are properly indented.
'''

_TB = "  "
_NL = "\n"

ALLOC = _TB + "%{0} = alloca {1}" + _NL
APPLY = _TB + "{0} = {1} {2} {3}, {4}" + _NL
CALL  = _TB + "call void {0}({1})" + _NL
CGOTO = _TB + "br i1 {0}, label %{1}, label %{2}" + _NL
COMM  = ";; {0}" + _NL
FNDEC = "declare void {0}({1})" + _NL
FNDEF = "define void {0}({1}) {{" + _NL
FNEND = "}}" + _NL
GLOBL = "{0} = common global {1} zeroinitializer" + _NL
GOTO  = _TB + "br label %{0}" + _NL
ICOMP = _TB + "{0} = icmp {1} {2}, {3}" + _NL
LABEL = "{0}:" + _NL
LOADD = _TB + "{0} = load {1}* {2}" + _NL
LOADI = _TB + "{0} = getelementptr {1} {2}, i32 0, i32 {3}" + _NL
GETPT = _TB + "{0} = getelementptr {1}* {2}, i32 0" + _NL
OTYPE = "{0} = type opaque" + _NL
RET   = _TB + "ret void" + _NL
STORE = _TB + "store {0} {1}, {0}* {2}" + _NL
SWEND = _TB + "]" + _NL
SWEXP = _TB + "switch {0} {1}, label %{2} [" + _NL
SWVAL = 2*_TB + "{0} {1}, label %{3}" + _NL
TYPE = "{0} = type {1}" + _NL
