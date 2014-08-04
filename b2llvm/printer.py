# This file provides an ASCII printer for Python representations of B0 implementations.
#
# 1. Design
#
# Printing is performed by recursive traversal of the tree representation. There is one
# function for each syntactic category. If the category is the union of several categories
# then the function dispatches control to the corresponding handler.
#
# 2. Shortcomings
#
# - Although the output is decently indented, no provision is taken to limit text width.
# - Some elements of the B representation are not present in the Python representation and
# are therefore not output.
#
from b2llvm.strutils import commas, SP, TB, NL

def term(n):
    '''
    term
    '''
    global SP
    kind = n["kind"]
    if kind == "BooleanLit":
        return n["value"]
    elif kind == "IntegerLit":
        return n["value"]
    elif kind == "Cons":
        return n["id"]
    elif kind == "arrayItem":
        return (SP + term(n["base"])+"("+ term(n["index"])+ ")")
    elif kind == "Vari":
        return n["id"]
    elif kind == "Enumerated":
        return n["id"]
    elif n["op"] in { "succ", "pred" }:
        return n["op"] + "(" + term(n["args"][0]) + ")"
    elif n["op"] in { "+", "*", "-" }:
        return (SP + n["op"] + SP).join(term(e) for e in n["args"])
    else:
        return "<< UNRECOGNIZED >>"

def comp(n):
    '''
    comparison
    '''
    return term(n["arg1"])+SP+n["op"]+SP+term(n["arg2"])

def form(n):
    '''
    formula
    '''
    global SP
    op, args = n["op"], n["args"]
    if op == "not":
        return "(" + op + SP + condition(args[0]) + ")"
    else:
        return (SP + op + SP).join([condition(e) for e in args])

def condition(n):
    '''
    condition
    '''
    kind = n["kind"]
    if kind == "Comp":
        return comp(n)
    elif kind == "Form":
        return form(n)
    else:
        return "<<UNRECOGNIZED >>"

def type(n):
    return n["id"]

def imports(n):
    result = ""
    if n["pre"] != None:
        result += n["pre"] + "."
    result += n["mach"]["id"]
    return result

def sets(n):
    result = ""
    return (n["id"] + " = " + 
            "{" + commas([e["name"] for e in n["elements"]]) + "}")

def value(n):
    return n["id"] + " = " + term(n["value"])

def invar(n):
    '''
    (typing) invariant
    '''
    return n["id"] + " : " + type(n["type"])

def skip(indent, n):
    global TB
    return (indent*TB) + "SKIP"

def beq(indent, n):
    '''
    Becomes equal
    '''
    global TB
    return (indent*TB) + term(n["lhs"]) + " := " + term(n["rhs"])

def bin(indent, n):
    '''
    Becomes equal
    '''
    global TB
    return ((indent*TB) +
            commas([ term(x) for x in n["lhs"]]) + " :: " +
            commas([ type(x["type"]) for x in n["lhs"]]))

def blk(indent, n):
    '''
    Block
    '''
    global TB, NL
    result = ""
    result += (indent*TB) + "BEGIN" + NL
    result += subst_l(indent+1, n["body"]) + NL
    result += (indent*TB) + "END"
    return result

def var_decl(indent, n):
    '''
    Variable declaration
    '''
    global NL, TB
    result = ""
    result += (indent*TB) + "VAR" + NL
    result += ((indent+1)*TB) + (","+SP).join([term(e) for e in n["vars"]]) + NL
    result += (indent*TB) + "IN" + NL
    result += subst_l(indent+1, n["body"]) + NL
    result += (indent*TB) + "END"
    return result

def if_br(indent, position, branch):
    '''
    If branch
    '''
    global NL
    cond = branch["cond"]
    body = branch["body"]
    if cond == None:
        kw = "ELSE"
    elif position == 0:
        kw = "IF"
    else:
        kw = "ELSIF"
    result = (indent*TB)+kw
    if cond != None:
        result += SP + condition(cond) + SP + "THEN"
    result += NL
    result += subst(indent+1, body)
    if cond == None:
        result += SP+NL+(indent*TB)+"END"
    return result

def subst_if(indent, n):
    '''
    If substitution (if is a Python keyword)
    '''
    global NL
    bits = []
    branches = n["branches"]
    for i in range(len(branches)):
        branch = branches[i]
        bits.append(if_br(indent, i, branch))
    return NL.join(bits)

def case_br(indent, position, values, body):
    '''
    case branch
    '''
    global SP, NL
    default = values == [] or values == None
    if default:
        kw = "ELSE"
    elif position == 0:
        kw = "EITHER"
    else:
        kw = "OR"
    result = (indent*TB)+kw
    if not default:
        result += SP + ", ".join([term(e) for e in values])
        result += " THEN"
    result += NL
    result += subst(indent+1, body)
    if default:
        result += NL+ (indent*TB)+"END"
    return result

def case(indent, n):
    global TB, SP, NL
    result = ""
    result += (indent*TB)+ "CASE" + SP + term(n["expr"]) + SP + "THEN" + NL
    bits = []
    branches = n["branches"]
    for i in range(len(branches)):
        branch = branches[i]
        bits.append(case_br(indent+1, i, branch["val"], branch["body"]))
    result += NL.join(bits) + NL
    result += (indent*TB)+"END"
    return result

def subst_while(indent, n):
    global TB, SP, NL
    result = ""
    result += (indent*TB)+ "WHILE" + SP + condition(n["cond"]) + SP + "DO" + NL
    result += subst_l(indent+1, n["body"]) + NL
    result += (indent*TB)+"END"
    return result

def call(indent, n):
    '''
    operation call
    '''
    global TB
    op, inp, out, inst = n["op"], n["inp"], n["out"], n["inst"]
    result = ""
    result += indent*TB
    if out != []:
        result += ", ".join([term(e) for e in out])
        result += SP + "<-" + SP
    if inst != None:
        if inst["pre"] != None:
            result += inst["pre"] + "."
    result += op["id"]
    if inp != []:
        result += "(" + ", ".join([term(e) for e in inp]) + ")"
    return result

def subst_l(indent, l):
    '''
    Substitution list
    '''
    global NL
    return (";"+NL).join([subst(indent, e) for e in l])

def subst(indent, n):
    '''
    substitution
    '''
    kind = n["kind"]
    table = dict({"Skip":skip, "Beq":beq, "Blk":blk, "VarD":var_decl,
                  "If":subst_if, "Case":case, "While":subst_while, "Call":call})
    if kind in table.keys():
        return table[kind](indent, n)
    else:
        return (indent * TB) + "<< UNRECOGNIZED >>"

def oper(n):
    result = ""
    inp = n["inp"]
    out = n["out"]
    if out != []:
        result += ",".join([term(e) for e in out]) + " <-- "
    result += n["id"]
    if inp != []:
        result += "(" + ",".join([term(e) for e in inp]) + ")"
    result += SP+"="+NL
    result += subst(1, n["body"])
    return result

def implementation(n):
    global SP, TB, NL
    imp, sets = n["imports"], n["sets"]
    consts, vars = n["concrete_constants"], n["variables"]
    init, ops = n["initialisation"], n["operations"]
    result = ""
    result += "IMPLEMENTATION" + SP + n["id"] + NL
    if imp != []:
        result += "IMPORTS" + NL
        result += TB + commas([imports(e) for e in imp]) + NL
    if sets != []:
        result += "SETS" + NL
        result += TB + commas([sets(e) for e in sets]) + NL        
    if consts != []:
        result += "VALUES" + NL
        result += TB + commas([value(e) for e in consts]) + NL
    if vars != []:
        result += "VARIABLES" + NL
        result += TB + commas([e["id"] for e in vars]) + NL
        result += "INVARIANT" + NL
        result += TB + (SP+"&"+NL+TB).join([invar(e) for e in vars]) + NL
    if init != []:
        result += "INITIALISATION" + NL
        result += subst_l(1, init) + NL
    if ops != []:
        result += "OPERATIONS" + NL
        result += (TB+";"+NL).join([oper(e) for e in ops]) + NL
    result += "END" + NL
    return result
