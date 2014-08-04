"""A Python representation for AST of B machines and implementations.

1. Design

- AST nodes are coded as dict() objects. It would be nicer to have proper
classes, I suppose.

2. Shortcomings

- The full B language is not yet represented. You need to read the code
to know what is supported.
- The AST nodes are somehow incomplete in some cases. Their design is
oriented towards the implementation of the translation to LLVM.
"""

### TYPES ###

# We are only concerned with representing concrete data.
# The following types of concrete data are supported
# - INTEGERS
# - BOOL
# - Enumerations
# The following types of concrete data are partially supported 
# and are being handled by Valerio, the corresponding code is
# present elsewhere and shall eventually be merged in this section:
# - Arrays (=> Valerio)
# - Intervals (=> Valerio)
#

INTEGER = { "kind": "Integer", "id" : "INTEGER" }
BOOL = { "kind": "Bool", "id": "BOOL" }

def make_enumerated(name):
    """Creates an AST node for an element of an enumerated set.
    The created node does not have the type attribute set."""
    return { "kind": "Enumerated", "id": name }

def make_enumeration(name, elements):
    """Creates an AST node for an enumerated set. Sets the
    type nodes for all the elements to the created node."""
    assert type(elements) is list
    n = { "kind": "Enumeration", "id": name, "elements": elements }
    for e in elements:
        e["type"] = n
    return n

### TERMINALS ###

def make_const(name, typedef, value):
    """Creates an AST node for a B constant."""
    return { "kind": "Cons", "id": name, "type": typedef, "value" : value }


def make_var(name, typedef, scope):
    """Creates an AST node for a B variable."""
    return { "kind": "Vari", "id": name, "type": typedef, "scope": scope }

def make_imp_var(name, typedef):
    """Creates an AST node for a B concrete variable."""
    return make_var(name, typedef, "Impl")

def make_loc_var(name, typedef):
    """Creates an AST node for a B local variable."""
    return make_var(name, typedef, "Local")

def make_arg_var(name, typedef):
    """Creates an AST node for a B operation argument."""
    return make_var(name, typedef, "Oper")

def make_intlit(value):
    '''
    Creates an AST node for a B integer literal.

    - Input: an integer value

    '''
    return { "kind": "IntegerLit",
             "value": str(value)}

def make_boollit(value):
    '''
    Creates an AST node for a Boolean literal.

    - Input: "FALSE" or "TRUE"

    '''
    return { "kind": "BooleanLit",
             "value": value}

FALSE = make_boollit("FALSE")
TRUE = make_boollit("TRUE")

ZERO = make_intlit(0)
ONE = make_intlit(1)
MAXINT = make_intlit(2147483647)

#VGM - TODO: move this functions ?
def make_sset(node):
    """Creates an AST node for a B simple set."""
    if (node.get("operator") == ".."):
        res = make_interval(node[0].get("value"),node[1].get("value"))
    elif (node.get("operator") == "*"):
        res = become_list(make_sset(node[0]))
        res += become_list(make_sset(node[1]))
    assert res != None
    return res

def become_list(elem):
    """Creates a list and avoid to create sublist in list."""
    if (type( elem ) == list ): 
        return elem
    else: return  [elem]

def make_interval(start,end):
    """Creates an AST node for a B simple interval set."""
    return { "kind" : "set_interval" , "start" : start, "end" : end }

def make_arrayType(domxml, ranxml):
    """Creates an AST node for a B arrayType."""
    #TODO: create support to INT type and NAT
    #TODO: support a list of indices in domain
    dom = become_list(make_sset(domxml))
    ran = make_sset(ranxml)
    assert dom != None and ran != None
    return { "kind" : "arrayType", "dom": dom, "ran" : ran}

def make_arrayItem(base,index):
    """Creates an AST node for a B arrayType."""
    return { "base": base, "index": index, 
            "kind":"arrayItem", "type": INTEGER} #TODO: change it support other typer different of INTEGER 

### COMPOSED EXPRESSIONS ###

def make_term(operator, args):
    """Creates an AST node for a B term."""
    return { "kind": "Term", "op": operator, "args" : args }

def make_succ(term):
    """Creates an AST node for a B succ (successor) expression."""
    return make_term("succ", [term])

def make_pred(term):
    """Creates an AST node for a B pred (predecessor) expression."""
    return make_term("pred", [term])

def make_sum(term1, term2):
    """Creates an AST node for a B sum expression."""
    return make_term("+", [term1, term2])

def make_diff(term1, term2):
    """Creates an AST node for a B subtraction expression."""
    return make_term("-", [term1, term2])

def make_prod(term1, term2):
    """Creates an AST node for a B product expression."""
    return make_term("*", [term1, term2])

def make_comp(operator, arg1, arg2):
    """Creates an AST node for a B comparison."""
    return { "kind": "Comp", "op": operator, "arg1": arg1, "arg2": arg2 }

def make_le(term1, term2):
    """Creates an AST node for a B "lower or equal" expression."""
    return make_comp("<=", term1, term2)

def make_lt(term1, term2):
    """Creates an AST node for a B "lower than" expression."""
    return make_comp("<", term1, term2)

def make_ge(term1, term2):
    """Creates an AST node for a B "greater or equal" expression."""
    return make_comp(">=", term1, term2)

def make_gt(term1, term2):
    """Creates an AST node for a B "greater than" expression."""
    return make_comp(">", term1, term2)

def make_eq(term1, term2):
    """Creates an AST node for a B equality."""
    return make_comp("=", term1, term2)

def make_neq(term1, term2):
    """Creates an AST node for a B inequality."""
    return make_comp("!=", term1, term2)

def make_form(operator, args):
    """Creates an AST node for a B formula."""
    return { "kind": "Form", "op": operator, "args" : args }

def make_and(arg1, arg2):
    """Creates an AST node for a B conjunction."""
    return make_form("and", [arg1, arg2])

def make_or(arg1, arg2):
    """Creates an AST node for a B disjunction."""
    return make_form("or", [arg1, arg2])

def make_not(arg):
    """Creates an AST node for a B negation."""
    return make_form("not", [arg])

### INSTRUCTIONS ###

def make_skip():
    """Creates an AST node for a B skip instruction."""
    return { "kind": "Skip" }

def make_beq(lhs, rhs):
    """Creates an AST node for a B becomes equal instruction."""
    return { "kind": "Beq", "lhs": lhs, "rhs": rhs}

def make_bin(lhs):
    """Represents a becomes in susbtitution (but only the left hand side)."""
    return { "kind": "Bin", "lhs": lhs}

def make_blk(body):
    """Creates an AST node for a B block instruction."""
    assert type(body) is list
    return { "kind": "Blk", "body": body }

def make_var_decl(variables, body):
    """Creates an AST node for a B variable declaration instruction."""
    assert type(variables) is list
    assert type(body) is list
    return { "kind": "VarD", "vars": variables, "body": body }

def make_if_br(cond, body):
    """Creates an AST node for a B if branch."""
    assert type(body) is not list
    return { "kind": "IfBr", "cond": cond, "body": body}

def make_if(branches):
    """Creates an AST node for a B if instruction."""
    assert type(branches) is list
    return { "kind": "If", "branches": branches }

def make_case_br(values, body):
    """Creates an AST node for a B case branch."""
    assert type(values) is list
    assert type(body) is not list
    return { "kind": "CaseBr", "val": values, "body": body }

def make_case(expression, branches):
    """Creates an AST node for a B case instruction."""
    assert type(branches) is list
    return { "kind": "Case", "expr": expression, "branches": branches }

def make_while(cond, body):
    """Creates an AST node for a B while instruction."""
    assert type(body) is list
    return { "kind": "While", "cond": cond, "body": body }

def make_call(operator, inp, out, inst=None):
    '''
    Creates an AST node for a B operation call instruction.

    - Input:
    op: an operation
    inp: a sequence of inputs
    out: a sequence of outputs
    inst: an element of an imported clause (optional)

    '''
    return { "kind": "Call", "op": operator, "inp": inp, "out": out,
             "inst": inst }

### COMPONENT ###

def make_oper(name, inp, out, body):
    """Creates an AST node to represent a B operation."""
    assert type(inp) is list
    assert type(out) is list
    assert type(body) is not list
    return { "kind": "Oper", "id": name, "inp": inp, "out": out, "body": body }

def make_import(mach, prefix = None):
    '''
    Creates an AST node for a B import element.

    - Input:
    mach: a machine or a library machine
    prefix: a string prefix (optional).
    - Output:
    Creates an element of an import clause, i.e., a module.
    '''
    assert(mach["kind"] in { "Machine" })
    return { "kind": "Module", "mach": mach, "pre": prefix }

def make_implementation(name, imports, sets, consts, variables, init, ops):
    """Creates an AST node for a B implementation module."""
    assert type(imports) is list
    assert type(consts) is list
    assert type(sets) is list
    assert type(variables) is list
    assert type(init) is list
    assert type(ops) is list
    root = { "kind": "Impl",
             "id": name,
             "machine": None,
             "imports": imports,
             "sets": sets,
             "concrete_constants": consts,
             "variables": variables,
             "initialisation": init, "operations": ops,
             "stateful": None}
    for node in imports + variables + ops:
        node["root"] = root
    return root

def make_base_machine(name, sets, consts, variables, ops):
    '''
    Constructor for node that represent a machine interface, namely
    the elements of a machine that may be accessed by a module depending
    on that machine.
    '''
    assert type(sets) is list
    assert type(consts) is list
    assert type(variables) is list
    assert type(ops) is list
    root = { "kind": "Machine",
             "id": name,
             "base": True,
             "concrete_constants": consts,
             "variables": variables,
             "operations": ops,
             "implementation": None,
             "stateful": None,
             "comp_direct": None,
             "comp_indirect": None}
    for node in variables + ops:
        node["root"] = root
    return root

def make_developed_machine(name, sets, impl):
    '''
    Constructor for node that represents a developed machine.

    For now we are just interested in the implementation of that machine.
    '''
    assert type(sets) is list
    return { "kind": "Machine",
             "id": name,
             "base": False,
             "sets": sets,
             "concrete_constants": [],
             "variables": [],
             "implementation": impl,
             "stateful": None,
             "comp_direct": None,
             "comp_indirect": None
             }
