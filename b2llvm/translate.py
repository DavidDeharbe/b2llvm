###
#
# Prototype for a LLVM-IR generator for B
#
# Caveat: This is the first Python program of the author, and he is aware
# that an object oriented (or, rather, a class oriented) solution could be
# appropriate.
#
# Error handling: When an error is detected, the code generator emits a
# message to stdout, inserts an error in the generated LLVM code and
# tries to proceed processing the input.
#
###
import math

import b2llvm.ast as ast
import b2llvm.loadbxml as loadbxml
import b2llvm.names as names
import b2llvm.printer as printer
from b2llvm.strutils import commas, nconc, SP, NL, TB, TB2
from b2llvm.bproject import BProject
from b2llvm.opcode import *

#
# Main entry point for this module
#

def translate_bxml(bmodule, outfile, buf, mode='comp', dir='bxml', settings='project.xml', emit_printer=False):
    '''
    Main function for applying the code generator to a B module

    Keywords:
      - bmodule: the name of the B machine to have code generated for
      - outfile: the name of the file where code shall be output
      - buf: a CodeBuffer object where the generated code is stored
      - mode: the code generation mode
      - dir: the name of the directory where files shall be read (default is 'bxml')
      - settings: the name of the file in dir where the project settings
      are stored (default: project.xml)
    Result:
      None
    '''
    project = loadbxml.load_project(dirname=dir, filename=settings)
    ast = loadbxml.load_module(dir, project, bmodule)
    buf.code(COMM, "-*- mode: asm -*-") # emacs syntax highlight on
    buf.trace.outu("file generated with b2llvm")
    buf.trace.outu("B project settings: "+settings)
    buf.trace.outu("B module: "+bmodule)
    buf.trace.outu("B project directory: "+dir)
    buf.trace.outu("code generation mode: " + ("component" if mode == "comp" else "project"))
    buf.trace.outu("output file: "+outfile)
    if mode == 'comp':
        translate_mode_comp(buf, ast, emit_printer)
    else:
        translate_mode_proj(buf, ast, emit_printer)
    llvm = open(outfile, 'w')
    llvm.write(buf.contents())
    llvm.close()

#
# TOP-LEVEL FUNCTION FOR EACH TRANSLATION MODE
#

def translate_mode_comp(buf, m, emit_printer):
    '''
    Translation in component mode.

    Inputs:
      - buf: a CodeBuffer object where the generated code is stored
      - m: root AST node for a B machine in proj
      - emit_printer: flag indicating if printing functions shall be produced

    LLVM text corresponding to the implementation of n is stored into res
    '''
    check_kind(m, {"Machine"})
    buf.trace.outu("")
    buf.trace.outu("This file contains LLVM code that implements B machine \"" + m["id"]+"\".")
    if is_base(m):
        buf.trace.outu("This machine is registered as a base machine.")
        section_typedef(buf, m)
    else:
        assert is_developed(m)
        i = implementation(m)
        buf.trace.outu("It is registered as a developed machine.")
        buf.trace.outu("The produced LLVM code is based on B implementation \""+i["id"]+"\".")
        buf.trace.outu("")
        tmp = comp_indirect(m)
        if tmp != []:
            buf.trace.out("The type declarations for state encodings of all imported modules are:")
            buf.trace.tab()
            acc = set()
            # TODO see if one should not filter out types for stateless modules
            for q in comp_indirect(m):
                if q.mach["id"] not in acc:
                    state_opaque_typedef(buf, q.mach)
                    acc.add(q.mach["id"])
            acc.clear()
            buf.trace.untab()
            buf.trace.out("The type definitions for references to these state encodings are:")
            buf.trace.tab()
            #TODO: see if one should not filter out types for stateless modules
            for q in comp_indirect(m):
                if q.mach["id"] not in acc:
                    state_ref_typedef(buf, q.mach)
                    acc.add(q.mach["id"])
            acc.clear()
            buf.trace.untab()
        tmp = comp_direct(m)
        if tmp != []:
            buf.trace.out("The interfaces of the directly imported modules are:")
            buf.trace.tab()
            for q in tmp:
                if q.mach["id"] not in acc:
                    buf.trace.out("The interface of \""+q.mach["id"]+"\" is composed of:")
                    buf.trace.tab()
                    section_interface(buf, q.mach, emit_printer)
                    buf.trace.untab()
                    acc.add(q.mach["id"])
            acc.clear()
            buf.trace.untab()
        if is_stateful(m):
            section_typedef_impl(buf, i, m)
            state_ref_typedef(buf, m)
        section_implementation(buf, m, emit_printer)

def translate_mode_proj(buf, m, emit_printer):
    '''
    Translation in project mode.

    Inputs:
      - buf: a CodeBuffer object where the generated code is stored
      - m: root AST node for a B machine
      - emit_printer: flag indicating if printing functions shall be produced

    Appends to text the LLVM code corresponding to the LLVM code generation for m
    in project mode.
    '''
    check_kind(m, { "Machine" })
    assert is_developed(m)
    buf.trace.outu("Preamble")
    buf.trace.outu("")
    buf.trace.outu("This file instantiates B machine \"" + m["id"]+"\", and all its components,")
    buf.trace.outu("and a function to initialise this instantiation.")
    buf.trace.outu("")
    # identify all the module instances that need to be created
    root = Comp([], m)
    comps = [root] + comp_indirect(m)
    # emit the type definitions corresponding to the instantiated modules
    # forward references are disallowed: enumerate definitions bottom-up
    comps.reverse()
    acc = set()
    buf.trace.out("These are the types encoding the state of each module,")
    buf.trace.out("and the corresponding pointer types.")
    buf.trace.tab()
    for q in comps:
        if q.mach["id"] not in acc:
            if is_stateful(q.mach):
                section_typedef(buf, q.mach)
                state_ref_typedef(buf, q.mach)
            else:
                buf.trace.outu("Module "+q.mach["id"]+ " is stateless and has no associated encoding type.")
            acc.add(q.mach["id"])
    acc.clear()
    buf.trace.untab()
    # the instances are now declared, top down
    buf.trace.out("Variables representing instances of components forming \""+m["id"]+ "\".")
    buf.trace.tab()
    comps.reverse()
    for q in comps:
        if is_stateful(q.mach):
            buf.trace.out("Variable representing to "+q.bstr())
            buf.code(GLOBL, str(q), state_t_name(q.mach))
    buf.trace.untab()
    # emit the declarations for the operations offered by root module
    # only the initialisation is necessary actually
    section_interface(buf, m, emit_printer)
    # generate the code of the routine that initializes the system
    # by calling the initialization function for the root module.
    args = [state_r_name(root.mach) + SP + str(root)]
    args += [state_r_name(q.mach)+SP+str(q) for q in comp_stateful(m)]
    buf.trace.out("Definition of the function to initialise instance \""+str(comps[0])+"\" of \""+m["id"]+ "\".")
    buf.trace.tab()
    buf.code(FNDEF, "@$init$", "")
    buf.code(LABEL, "entry")
    buf.trace.out("Call to initialisation function of \""+m["id"]+"\".")
    buf.code(CALL, init_name(m), commas(args))
    buf.code(RET)
    buf.code(FNEND)
    buf.trace.untab()
    if emit_printer:
        buf.trace.out("Definition of a function to print the state of the system")
        buf.code(FNDEF, "@$print$", "")
        buf.code(LABEL, "entry")
        buf.trace.out("Call to printing function of \""+m["id"]+"\".")
        buf.code(CALL, print_name(m), args[0])
        buf.code(RET)
        buf.code(FNEND)

#
# SECTION-LEVEL CODE GENERATION FUNCTIONS
#

def section_interface(buf, m, emit_printer):
    '''
    Generates the declaration of all externally visible elements of machine n:
    reference type, initialisation function, operation function.

    Input:
      - buf: a CodeBuffer object where the generated code is stored
      - n: AST root node of a machine
      - emit_printer: flag indicating if printing functions shall be produced

    Extends res with text of LLVM declarations (see section interface in translation
    definition).
    '''
    check_kind(m, {"Machine"})
    section_interface_init(buf, m)
    for op in operations(m):
        section_interface_op(buf, m, op)
    if emit_printer:
        buf.trace.out("Declaration of function responsible for printing the state")
        buf.code(FNDEC, print_name(m), state_r_name(m))

def operations(m):
    '''
    Gets list of operations of machine m.

    TODO: currently, the AST of developed machines does not have operations
    and this query is forwarded to the corresponding implementation. I would
    prefer to load properly the full AST of such machines.
    '''
    check_kind(m, {"Machine"})
    if is_developed(m):
        return implementation(m)["operations"]
    else:
        return m["operations"]

def section_interface_init(buf, m):
    '''
    Generates the declaration of the initialisation function for n

    Inputs:
      - buf: a CodeBuffer object where the generated code is stored
      - res: bytearray to store output
      - m: a machine AST root node
    Output:
      res is extended with the text of a LLVM function declaration for
      the initalisation
    '''
    global NL
    check_kind(m, {"Machine"})
    comp = list()
    buf.trace.out("The declaration of the function implementing initialisation is:")
    if is_stateful(m):
        comp.append(m)
    comp.extend([x.mach for x in comp_indirect(m)])
    args = commas([state_r_name(x) for x in comp if is_stateful(x)])
    buf.code(FNDEC, init_name(m), args)

def section_interface_op(buf, m, op):
    '''
    Declaration of the function implementing operation op in m.

    Inputs:
      - buf: a CodeBuffer object where the generated code is stored
      - m: a machine AST root node
      - op: an operation AST node

    The declaration of A LLVM function implementing operation op from m is
    appended to text.
    '''
    global NL
    # compute in tl the list of arguments types
    buf.trace.out("The declaration of the function implementing operation \""+op["id"]+"\" is:")
    tl = list()
    if is_stateful(m):
        tl.append(state_r_name(m))
    tl.extend([ x_type(i["type"]) for i in op["inp"] ])
    tl.extend([ x_type(o["type"])+"*" for o in op["out"] ])
    buf.code(FNDEC, op_name(op), commas(tl))

def section_typedef(buf, m):
    '''
    Generates the definition of the state type machine m.

    Inputs:
      - buf: a CodeBuffer object where the generated code is stored
      - m: AST root node of a machine
      - trace: a Tracer object

    Text of LLVM definitions for the types associated with the state of machine
    m is appended to text. If the machine is stateful, one type is created: an
    aggregate type encoding the state of n (or its implementation if it is a
    developed machine). Otherwise, nothing is generated.
    '''
    global NL
    check_kind(m, {"Machine"})
    if is_developed(m):
        section_typedef_impl(buf, implementation(m), m)
    else:
        assert is_base(m)
        if is_stateful(m):
            variables = m["variables"]
            buf.trace.out(m["id"] + ": definition of type coding the state")
            buf.trace.tab()
            for i in range(len(variables)):
                buf.trace.out("Position \"" + str(i) + "\" represents \"" +
                              v["id"] + "\".")
            args = [x_type(v["type"]) for v in m["variables"]]
            buf.code(TYPE, state_t_name(m), "{" + commas(args) + "}")

def section_typedef_impl(buf, i, m):
    '''
    Generates the section implementation of the translation to LLVM.

    Inputs:
      - buf: a CodeBuffer object where the generated code is stored
      - i: AST node for a B implementation
      - m: AST node for the B machine corresponding to i

    Definition of the type representing the states of implementation i
    of machine m is appended to text.
    '''
    check_kind(i, {"Impl"})
    check_kind(m, {"Machine"})
    if is_stateful(i):
        buf.trace.out("The type encoding the state of \""+m["id"] + "\" is an aggregate and is defined as")
        buf.trace.outu("(using implementation \""+i["id"]+"\"):")
        buf.trace.tab()
        imports = [imp for imp in i["imports"] if is_stateful(imp["mach"])]
        variables = i["variables"]
        pos = 0
        for imp in imports:
            buf.trace.out("Position \"" + str(pos) + "\" represents \"" +
                          printer.imports(imp) + "\".")
            pos = pos + 1
        for var in variables:
            buf.trace.out("Position \"" + str(pos) + "\" represents \"" +
                          var["id"] + "\".")
            pos = pos + 1
        buf.trace.untab()
        imports = [state_r_name(imp["mach"]) for imp in i["imports"] 
                   if is_stateful(imp["mach"])]
        variables = [x_type(var["type"]) for var in i["variables"]]
        buf.code(TYPE, state_t_name(m), "{" + commas(imports + variables) +"}")

def section_implementation(buf, m, emit_printer):
    '''
    Generates the section implementation of the translation to LLVM.

    Inputs:
      - buf: a CodeBuffer object where the generated code is stored
      - m: AST node for a B machine
      - emit_printer: flag indicating if printing functions shall be produced

    The definitions of the LLVM functions implementing the initialisation and
    operations of the implementation of m are appended to text.
    '''
    check_kind(m, {"Machine"})
    if is_developed(m):
        i = implementation(m)
        x_init(buf, m, i)
        for op in i["operations"]:
            x_operation(buf, op)
        if emit_printer:
            x_printer(buf, m, i)

#
# TRANSLATION FUNCTIONS OF INDIVIDUAL ELEMENTS OF THE B AST
#

#
# From now on, use x_ as prefix as a shortcut for the prefix translate_
#

### TYPE TRANSLATION ###

def bit_width(n):
    """Returns the number of bits to represent n different values."""
    return str(max(1, math.log(n, 2)))
#
# This function is responsible for translation B0 type names to LLVM types
#
def x_type(t):
    """Returns the type for declaration."""
    check_kind(t, {"Integer", "Bool", "Enumeration", "arrayType"})
    if (t == ast.INTEGER):
        return "i32" 
    if (t == ast.BOOL):
        return "i1"
    if (t["kind"] == "Enumeration"):
        return "i"+str(bit_width(len(t["elements"])))
    if (t.get("kind")== "arrayType"):
        return x_arrayType(t)

def x_arrayType(t):
    """Returns the type for declaration of Array."""
    if (True) :
        ranType = "i32" #TODO: needs support new types of ran
    tl =""
    tr =""
    domain = t.get("dom")
    for elem in domain:
        size =int(elem.get("end")) - int(elem.get("start"))+1
        tl += "[ "+str(size)+ " x "
        tr += "]"
    return tl + ranType + tr
    

### TRANSLATION FOR INITIALISATION

def x_init(buf, m, i):
    '''
    Input:
      - buf: a CodeBuffer object where the generated code is stored
      - m: root AST node of a B machine
      - i: root AST node of the implementation of m

    LLVM implementation of the initialisation clause of i (a LLVM function) is
    appended to text.
    '''
    global TB, NL, SP
    check_kind(m, {"Machine"})
    check_kind(i, {"Impl"})
    tm = state_r_name(m) # LLVM type name: pointer to structure storing m data
    names.reset()
    # 1. generate function signature: one parameter for the implementation
    # instance, one parameter for each transitively imported module instance.
    # 1.1 generate argument names for the imported instances, store in lexicon
    lexicon = dict()
    count = 0 # to generate fresh names
    for q in comp_indirect(m):
        if is_stateful(q.mach):
            lexicon[q] = "%arg"+str(count)+"$"
            count += 1
    # 1.2 generate parameter type, name list
    arg_list = [ tm+SP+"%self$" ]
    for q in comp_indirect(m):
        if is_stateful(q.mach):
            arg_list.append(state_r_name(q.mach)+SP+lexicon[q])
    # 1.3 the signature
    buf.trace.out("The function implementing initialisation for \""+m["id"]+"\" is \""+init_name(i)+"\"")
    buf.trace.outu("and has the following parameters:")
    buf.trace.tab()
    buf.trace.out("\"%self$\": address of LLVM aggregate storing state of \""+m["id"]+"\";")
    for q in comp_indirect(m):
        if is_stateful(q.mach):
            buf.trace.out("\""+lexicon[q]+"\": address of LLVM aggregate storing state of \""+q.bstr()+"\";")
    buf.code(FNDEF, init_name(i), commas(arg_list))
    # 2. generate function body
    buf.trace.out("The entry point of the initialisation is:")
    buf.code("entry:"+NL)
    # 2.1 reserve stack space for local variables
    x_alloc_inst_list(buf, i["initialisation"])
    # 2.2 bind direct imports to elements of state structure
    direct = [ q for q in comp_direct(m) if is_stateful(q.mach) ]
    if direct != []:
        buf.trace.out("The addresses of aggregates representing components of \""+i["id"]+"\"")
        buf.trace.outu("are bound to elements of aggregate representing \""+m["id"]+"\".")
        buf.trace.tab()
        for j in range(len(direct)):
            lbl = names.new_local()
            q = direct[j]
            buf.trace.out("This binds component \"" + q.bstr() + "\" to aggregate element " + str(j)+":")
            tm2 = state_r_name(q.mach)
            buf.code(LOADI, lbl, tm, "%self$", str(j))
            buf.code(STORE, tm2, lexicon[q], lbl)
        buf.trace.untab()
    # 2.3 initialise direct imports
    offset = len(direct)+1
    if comp_direct(m) != []:
        buf.trace.out("Each component is initialised:")
        buf.trace.tab()
        for q in comp_direct(m):
            mq = q.mach     # the imported machine
            arg_list2 = []  # to store parameters needed to initialise mq
            if is_stateful(mq):
                arg_list2.append(state_r_name(mq)+SP+lexicon[q])
                n = len([x for x in comp_indirect(mq) if is_stateful(x.mach)])
                arg_list2.extend(arg_list[offset:offset+n])
                buf.trace.out("Call initialisation function for component \""+q.bstr()+"\".")
                buf.code(CALL, init_name(mq), commas(arg_list2))
        buf.trace.untab()
    # 2.4 translate initialisation instructions
    buf.trace.out("Execute substitutions in initialisation of \""+i["id"]+"\" then exits:")
    buf.trace.tab()
    x_inst_list_label(buf, i["initialisation"], "exit")
    buf.trace.untab()
    buf.trace.out("The exit point of the initialisation is:")
    buf.code(LABEL, "exit")
    buf.code(RET)
    buf.code(FNEND)
    buf.trace.untab()

### TRANSLATION FOR PRINTER

def x_printer(buf, m, i):
    '''
    Input:
      - buf: a CodeBuffer object where the generated code is stored
      - m: root AST node of a B machine
      - i: root AST node of the implementation of m

    Definition of a LLVM function that prints the value of the elements
    composing the state of m m to the standard output stream.
    '''
    global TB, NL, SP
    check_kind(m, {"Machine"})
    check_kind(i, {"Impl"})
    tm = state_r_name(m) # LLVM type name: pointer to structure storing m data
    names.reset()

    buf.trace.out("Definition of function responsible for printing the state,")
    buf.trace.outu("its generation was activated by option --emit-printer.")
    emit_print_i1 = False
    emit_print_i32 = False
    buf.code(FNDEF, print_name(m), state_r_name(m)+" %self$")
    j, nb = 0, len(comp_direct(m))+len(i["variables"])
    buf.code(LABEL, "entry")
    buf.code(CALL, "@$b2llvm.print.ldelim", "")
    for q in comp_direct(m):
        m2 = q.mach
        t2 = state_r_name(m2)
        lbl1 = names.new_local()
        lbl2 = names.new_local()
        buf.code(LOADI, lbl1, tm, "%self$", str(j))
        buf.code(LOADD, lbl2, t2, lbl1)
        buf.code(CALL, print_name(m2), state_r_name(m2) + SP + lbl2)
        j += 1
        if j < nb:
            buf.code(CALL, "@$b2llvm.print.space", "")
    for var in i["variables"]:
        lbl1 = names.new_local()
        lbl2 = names.new_local()
        t2 = x_type(var["type"])
        buf.code(LOADI, lbl1, tm, "%self$", str(j))
        buf.code(LOADD, lbl2, t2, lbl1)
        if t2 == "i1":
            buf.code(CALL, "@$b2llvm.print.i1", t2 + SP + lbl2)
            emit_print_i1 = True
        else:
            assert t2 == "i32"
            buf.code(CALL, "@$b2llvm.print.i32", t2 + SP + lbl2)
            emit_print_i32 = True
        j += 1
        if j < nb:
            buf.code(CALL, "@$b2llvm.print.space", "")
    buf.code(CALL, "@$b2llvm.print.rdelim", "")
    buf.code(RET)
    buf.code(FNEND)
    buf.code(FNDEC, "@$b2llvm.print.ldelim", "")
    buf.code(FNDEC, "@$b2llvm.print.rdelim", "")
    if nb > 1:
        buf.code(FNDEC, "@$b2llvm.print.space", "")
    if emit_print_i1:
        buf.code(FNDEC, "@$b2llvm.print.i1", "i1")
    if emit_print_i32:
        buf.code(FNDEC, "@$b2llvm.print.i32", "i32")


### TRANSLATION OF OPERATIONS

def x_operation(buf, n):
    '''
    Code generation for B operations.

    Input:
      - buf: a CodeBuffer object where the generated code is stored
      - n: an AST node for a B operation
    '''
    global TB, NL
    check_kind(n, {"Oper"})
    names.reset()
    buf.trace.out("The LLVM function implementing B operation \""+n["id"]+"\" in \""+n["root"]["id"]+"\" follows.")
    args = commas([state_r_name(n["root"])+SP+"%self$"]+
                  [x_type(i["type"])+SP+"%"+i["id"] for i in n["inp"]]+
                  [x_type(o["type"])+"*"+SP+"%"+o["id"] for o in n["out"]])
    buf.code(FNDEF, op_name(n), args)
    buf.trace.tab()
    buf.code(LABEL, "entry")
    x_alloc_inst(buf, n["body"])
    x_inst_label(buf, n["body"], "exit")
    buf.code(LABEL, "exit")
    buf.code(RET)
    buf.code(FNEND)
    buf.trace.untab()

### TRANSLATION OF STACK VARIABLE ALLOCATION

def x_alloc_inst_list(buf, il):
    '''
    Generation of frame stack allocation for instruction lists.

    Input:
      - buf: a CodeBuffer object where the generated code is stored
      - il: a list of B instructions AST nodes

    This function is part of a recursive traversal of the syntax tree so that
    all variable declarations are visisted and handled by function
    x_alloc_var_decl.
    '''
    for inst in il:
        x_alloc_inst(buf, inst)

def x_alloc_inst(buf, n):
    '''
    Generation of frame stack allocation for individual instructions.

    Input:
      - buf: a CodeBuffer object where the generated code is stored
      - n: AST node for a B instruction

    This function is part of a recursive traversal of the syntax tree so that
    all variable declarations are visisted and handled by function
    x_alloc_var_decl.
    '''
    check_kind(n, {"Beq", "Blk", "Call", "Case", "If", "Skip", "VarD", "While"})
    if n["kind"] in {"Beq", "Call", "Skip"}:
        return
    elif n["kind"] in {"Case", "If"}:
        for br in n["branches"]:
            x_alloc_inst(buf, br["body"])
    elif n["kind"] in {"Blk", "While"}:
        x_alloc_inst_list(buf, n["body"])
    elif n["kind"] == "VarD":
        x_alloc_var_decl(buf, n)
    else:
        print("error: unknown instruction kind")
        buf.code("<error inserted by b2llvm>")

def x_alloc_var_decl(buf, n):
    '''
    Generation of frame stack allocation for variable declarations.

    Input:
      - buf: a CodeBuffer object where the generated code is stored
      - n: AST node for a B variable declaration

    Emits one LLVM alloca instruction for each declared variable and
    processes the variable declaration body of instructions.
    '''
    global TB, NL, SP
    check_kind(n, {"VarD"})
    buf.trace.out("local variable declarations implemented as frame stack allocations")
    buf.trace.tab()
    for v in n["vars"]:
        buf.trace.out("frame stack allocation for variable "+v["id"])
        buf.code(ALLOC, v["id"], x_type(v["type"]))
    x_alloc_inst_list(buf, n["body"])
    buf.trace.untab()

### TRANSLATION OF INSTRUCTIONS ###

#
# WARNING:
# WARNING: The LLVM is sensitive to the order local variables and labels names
# WARNING: consequently reordering the translation of the different elements
# WARNING: of an AST node may well generate uncompilable LLVM code.
# WARNING:
# WARNING: Have this is mind before changing the order of the instructions in
# WARNING: the following functions.
# WARNING:
#

def x_inst_list_label(buf, l, lbl):
    global TB, NL
    if len(l) == 0:
        buf.code(GOTO, lbl)
    else:
        i = l[0]
        l2 = l[1:]
        if i["kind"] in {"Case", "If", "While"}:
            lbl2 = names.new_label()
            x_inst_label(buf, i, lbl2)
            buf.code(LABEL, lbl2)
        elif i["kind"] in {"Blk"}:
            x_inst_list(buf, i["body"])
        else:
            x_inst(buf, i)
        x_inst_list_label(buf, l2, lbl)

def x_inst_list(buf, il):
    '''
    Input:
      - buf: a CodeBuffer object where the generated code is stored
      - il: list of instruction AST nodes
    '''
    for inst in il:
        if inst["kind"] in {"If", "While"}:
            label = names.new_label()
            x_inst_label(buf, inst, label)
            buf.code(LABEL, label)
        elif inst["kind"] in {"Blk"}:
            x_inst_list(buf, inst["body"])
        else:
            x_inst(buf, inst)

def x_inst_label(buf, n, lbl):
    check_kind(n, {"Beq", "Blk", "Call", "Case", "If", "VarD", "While"})
    if n["kind"] == "Blk":
        x_inst_list_label(buf, n["body"], lbl)
    elif n["kind"] == "Case":
        x_case(buf, n, lbl)
    elif n["kind"] == "If":
        x_if(buf, n, lbl)
    elif n["kind"] == "While":
        x_while(buf, n, lbl)
    elif n["kind"] in {"Beq", "Call"}:
        x_inst(buf, n)
        buf.code(GOTO, lbl)
    elif n["kind"] == "VarD":
        x_inst_list_label(buf, n["body"], lbl)
    else:
        print("error: instruction type unknown")

def x_inst(buf, n):
    check_kind(n, {"Beq", "Call", "VarD"})
    if n["kind"] == "Beq":
        x_beq(buf, n)
    elif n["kind"] == "Call":
        x_call(buf, n)
    elif n["kind"] == "VarD":
        x_inst_list(buf, n["body"])
    elif n["kind"] == "Skip":
        x_skip(buf, n)

### TRANSLATION OF SKIP ###

def x_skip(buf, n):
    check_kind(n, {"Skip"})

### TRANSLATION OF CASE INSTRUCTIONS

def x_case(buf, n, lbl):
    '''
    Generates LLVM code for a B case instruction.

    Input:
      - buf: a CodeBuffer object where the generated code is stored
      - n: an AST node representing a B instruction
      - lbl: a LLVM label for the block where control flow must go after
      executing n.
    '''
    global NL, TB, SP
    check_kind(n, {"Case"})
    v, t = x_expression(buf, n["expr"])
    br = n["branches"]
    # generate one block label for each branch
    labels = x_case_label_list(br)
    # there is a special treatment for in case there is no explicit
    # default branch (the last branch in the AST is not a default branch)
    last = br(len(br)-1)
    default = "val" not in br.keys() or br["val"] == [] or br["val"] == None
    # generate block label for default branch
    if default:
        lblo = labels[len(br)-1]
    else:
        lblo = names.new_label()
    buf.code(SWEXP, t, v, lblo)
    x_case_jump_table(buf, br, labels)
    buf.code(SWEND)
    x_case_block_list(buf, br, labels, lbl, default, lblo)

def x_case_label_list(bl):
    '''
    Input:
      - bl: list of case branches
    Output:
      - list of LLVM block labels, one for each non-default branch
    '''
    return [ names.new_label() for branch in bl]

def x_case_jump_table(buf, bl, labels):
    '''
    Generates a LLVM jump table for a switch instruction implementing the case
    branches.

    Input:
      - buf: a CodeBuffer object where the generated code is stored
      - bl: a list of case branches
      - labels: a list block labels
    '''
    for i in range(len(bl)):
        x_case_val_list(buf, bl[i]["val"], labels[i])

def x_case_val_list(buf, vl, lbl):
    '''
    Generates entries in the LLVM jump table from values to a block label.

    Input:
      - buf: a CodeBuffer object where the generated code is stored
      - vl: a list of AST nodes representing B values
      - lbl: a LLVM block label
    '''
    global TB2, SP, NL
    text2 = bytearray()
    for v in vl:
        # the evaluation of the values should not emit LLVM code
        v, t = x_expression(text2, v)
        assert(len(text2) == 0)
        buf.code(SWVAL, t, v, lbl)

def x_case_block_list(buf, bl, labels, lble, default, lbld):
    '''
    Generates LLVM code blocks of a switch implementing the instructions in the
    branches of a case instruction.

    Input:
      - buf: a CodeBuffer object where the generated code is stored
      - bl: a list of case branches
      - labels: a list block labels
      - lble: label of block where control flow must go after executing a branch
      - default: flag indicating if the last branch is a default branch
      - lbld: label of block for default block
    '''
    for i in range(len(bl)):
        branch = bl[i]
        lbl = labels[i]
        buf.code(LABEL, lbl)
        x_inst_label(buf, branch["body"], lble)
    if not default:
        buf.code(lbld)
        buf.code(GOTO, lble)

### TRANSLATION OF IF INSTRUCTIONS

def x_if(buf, n, lbl):
    '''
    Generates LLVM code for a B if instruction.

    Input:
      - buf: a CodeBuffer object where the generated code is stored
      - n: an AST node representing a B if instruction
      - lbl: a LLVM label for the block where control flow must go after
      executing n.
    '''
    check_kind(n, {"If"})
    buf.trace.out("Execute \""+ellipse(printer.subst_if(0, n))+"\" and branch to \""+lbl+"\".")
    buf.trace.tab()
    x_if_br(buf, n["branches"], lbl)
    buf.trace.untab()

def x_if_br(buf, lbr, lbl):
    '''
    Generates LLVM code for a list of B if instruction branches.

    Input:
      - buf: a CodeBuffer object where the generated code is stored
      - lbr: a list of AST nodes representing B if instruction branches
      - lbl: a LLVM label for the block where control flow must go after
      executing n.
    '''
    nbr = len(lbr)
    assert(nbr>=1)
    for i in range(nbr):
        br = lbr[i]
        check_kind(br, {"IfBr"})
        buf.trace.out("execute if branch \""+ellipse(printer.if_br(0, 0, br))+"\"")
        if i == nbr-1:
            # br is an else branch
            if "cond" not in br.keys() or br["cond"] == None:
                x_inst_label(buf, br["body"], lbl)
            # br is an elsif branch
            else:
                lbl_1 = names.new_label()
                x_formula(buf, br["cond"], lbl_1, lbl)
                buf.code(LABEL, lbl_1)
                x_inst_label(buf, br["body"], lbl)
        else:
            lbl_1 = names.new_label()
            lbl_2 = names.new_label()
            x_formula(buf, br["cond"], lbl_1, lbl_2)
            buf.code(LABEL, lbl_1)
            x_inst_label(buf, br["body"], lbl)
            buf.code(LABEL, lbl_2)

### TRANSLATION OF WHILE INSTRUCTIONS

def x_while(buf, n, lbl):
    '''
    Generates LLVM code for a B while instruction.

    Input:
      - buf: a CodeBuffer object where the generated code is stored
      - n: an AST node representing a B while instruction
      - lbl: a LLVM label for the block where control flow must go after
      executing n.
    '''
    global NL, TB, SP
    check_kind(n, {"While"})
    buf.trace.out("Execute \""+ellipse(printer.subst_while(0, n))+"\" and branch to \""+lbl+"\".")
    buf.trace.tab()
    buf.trace.out("Evaluate loop guard \""+ellipse(printer.condition(n["cond"]))+"\".")
    lbl1 = names.new_label()
    buf.code(GOTO, lbl1)
    buf.code(LABEL, lbl1)
    v = x_pred(buf, n["cond"])
    lbl2 = names.new_label()
    buf.code(CGOTO, v, lbl2, lbl)
    buf.trace.out("Execute loop body \""+ellipse(printer.subst_l(0, n["body"]))+"\".")
    buf.code(LABEL, lbl2)
    x_inst_list_label(buf, n["body"], lbl1)
    buf.trace.untab()

### TRANSLATION OF BECOMES EQUAL INSTRUCTIONS

def x_beq(buf, n):
    '''
    Generates LLVM code for a B assignment (becomes equal) instruction.

    Input:
      - buf: a CodeBuffer object where the generated code is stored
      - n: an AST node representing a B assignment instruction
    '''
    global TB, SP, NL
    check_kind(n, {"Beq"})
    buf.trace.out("Execute assignment \""+printer.beq(0, n)+"\":")
    buf.trace.tab()
    v,t = x_expression(buf, n["rhs"])
    p,_ = x_lvalue(buf, n["lhs"])
    buf.trace.out("Store value at address to achieve assignment.")
    buf.code(STORE, t, v, p)
    buf.trace.untab()

def x_lvalue(buf, n):
    '''
    Translate of "lvalues" (elements to the left of an assignment).

    Input:
      - buf: a CodeBuffer object where the generated code is stored
      - n: AST node for lvalue
    Output:
      A triple composed of a sequence of LLVM instructions computing
      the lvalue, the name of the local storing the lvalue, and the
      type of the lvalue.
    Note:
      Used to translate assignments and operation calls with output(s).
    Caveat:
      Currently limited to simple identifiers.
    '''
    global TB, NL
    check_kind(n, {"Vari","arrayItem"}) 
    buf.trace.out("Evaluate address for \""+printer.term(n)+"\".")
    t = x_type(n["type"]) + "*"
    if n["kind"] == "arrayItem": 
        buf.trace.tab()
        v1,t1 = x_expression(buf, n["base"])
        buf.trace.out("Variable array (base) \""+n["base"]["id"]+"\" is stored at position "+v1+" of \"%self$\". (arrayItem)")
        buf.trace.untab()
        
        #TODO: Add the index to be loaded
        #TODO: Create the function LRExp to getting a sequence of selected elements.
        #commas([ term(x) for x in n["lhs"]])
        
        buf.trace.tab() 
        #for elem in n["index"]:
        vi,ti = x_expression(buf, n["index"])
        v = names.new_local()
        buf.code(LOADI,v,t1+"*",v1,vi)
        t  = "i32"
        buf.trace.out("Variable array (index) \""+printer.term(n["index"])+"\" is stored at position "+vi+" of \"%self$\". (arrayItem)")
        buf.trace.untab()
        
        #TODO: Adjust the size o vector to size=(b-a+1)
        #TODO: Add suport to interval position(p) = (p-a)
        return (v, t)  

    elif n["scope"] == "Impl":
        pos=state_position(n)
        v = names.new_local()
        buf.trace.tab()
        buf.trace.out("Variable \""+n["id"]+"\" is stored at position "+str(pos)+" of \"%self$\".")
        buf.trace.outu("Let temporary " + v + " be the corresponding address:")
        buf.trace.untab()
        buf.code(LOADI, v, state_r_name(n["root"]), "%self$", str(pos))
        return (v, t)
    elif n["scope"] in {"Oper", "Local"}:
        buf.trace.tab()
        buf.trace.out("\""+n["id"]+"\" is stored in the frame stack and represented by \"%"+n["id"]+"\".")
        buf.trace.untab()
        return ("%"+n["id"],t)
    else:
        print("error: unknown scope for variable " + v["id"])
        return ("UNKNOWN", "UNKNOWN")

### TRANSLATION OF CALL INSTRUCTIONS

def x_call(buf, n):
    '''
    Generates LLVM code for a B call operation instruction.

    Input:
      - buf: a CodeBuffer object where the generated code is stored
      - n: an AST node representing a B call operation
    '''
    global SP
    check_kind(n, {"Call"})
    buf.trace.out("Execute operation call \""+printer.call(0, n)+"\".")
    operation = n["op"]
    local = (n["inst"] == None) # is a local operation?
    impl = operation["root"]
    # evaluate arguments
    buf.trace.tab()
    buf.trace.out("Evaluate operation arguments.")
    args = list()
    buf.trace.tab()
    if is_stateful(impl):
        buf.trace.out("(implicit) address of structure representing operation component")
        # get the LLVM type of the machine offering the operation
        if local:
            mach = operation["root"]
        else:
            mach = n["inst"]["root"]
        mach_t = state_r_name(mach)
        if local:
            t = mach_t
            v = "%self$"
            buf.trace.out("is %self$")
        else:
            pos = state_position(n["inst"])
            buf.trace.out("is element "+str(pos)+" of %self$")
            t = state_r_name(n["inst"]["mach"])
            v1 = names.new_local()
            v2 = names.new_local()
            buf.code(LOADI, v1, mach_t, "%self$", str(pos))
            buf.code(LOADD, v2, t, v1)
        args.append(t + SP + v2)
    x_inputs(buf, args, n["inp"])
    x_outputs(buf, args, n["out"])
    buf.trace.untab()
    id = op_name(operation)
    buf.trace.out("Call LLVM function \""+id+"\" implementing B operation \""+n["op"]["id"]+"\".")
    buf.code(CALL, id, commas(args))
    buf.trace.untab()

def x_inputs(buf, args, n):
    global SP
    for elem in n:
        buf.trace.out("Evaluate input parameter \""+printer.term(elem)+"\".")
        v, t = x_expression(buf, elem)
        args.append(t + SP + v)

def x_outputs(buf, args, n):
    global SP
    for elem in n:
        buf.trace.out("Evaluate output parameter \""+printer.term(elem)+"\".")
        v,t = x_lvalue(buf, elem)
        args.append(t + SP + v)

### TRANSLATION OF CONDITIONS ###

def x_formula(buf, n, lbl1, lbl2):
    '''
    Generates LLVM code to evaluate a B formula and branch to either labels.

    Input:
      - buf: a CodeBuffer object where the generated code is stored
      - n: an AST node representing a B formula.
      - lbl1: a LLVM label string
      - lbl2: a LLVM label string
    '''
    check_kind(n, {"Comp", "Form"})
    buf.trace.out("Evaluate formula \""+ellipse(printer.condition(n))+"\", branch to \""+lbl1+"\" if true, to \""+lbl2+"\" otherwise.")
    buf.trace.tab()
    if n["kind"] == "Comp":
        v = x_comp(buf, n)
        buf.code(CGOTO, v, lbl1, lbl2)
    elif n["kind"] == "Form":
        if n["op"] == "and":
            x_and(buf, n, lbl1, lbl2)
        elif n["op"] == "or":
            x_or(buf, n, lbl1, lbl2)
        elif n["op"] == "not":
            x_not(buf, n, lbl1, lbl2)
        else:
            pass
    else:
        pass         
    buf.trace.untab()

def x_comp(buf, n):
    '''
    Generates LLVM code to evaluate a B comparison.

    Input:
      - buf: a CodeBuffer object where the generated code is stored
      - n: an AST node representing a B comparison.
    Output:
      The identifier of the LLVM temporary variable storing the result of
      the comparison. This variable has type "i1".
    '''
    global TB, SP, NL
    check_kind(n, {"Comp"})
    v1,t1 = x_expression(buf, n["arg1"])
    v2,t2 = x_expression(buf, n["arg2"])
    v = names.new_local()
    buf.trace.out("Temporary \""+v+"\" gets the value of \""+ellipse(printer.comp(n))+"\".")
    buf.code(TB+v+" = icmp "+llvm_op(n["op"])+SP+t1+SP+v1+", "+v2+NL)
    return v

def x_and(buf, n, lbl1, lbl2):
    '''
    Generates LLVM code to evaluate a B conjunction and branch to either label.

    Input:
      - buf: a CodeBuffer object where the generated code is stored
      - n: an AST node representing a B conjunction.
      - lbl1: a LLVM label string
      - lbl2: a LLVM label string
    '''
    check_kind(n, {"Form"})
    assert(n["op"] == "and")
    assert(len(n["args"]) == 2)
    lbl = names.new_label()
    arg1 = n["args"][0]
    arg2 = n["args"][1]
    lbl = names.new_label()
    buf.trace.out("Evaluate conjunction \""+ellipse(printer.condition(n))+"\", branch to \""+lbl1+"\" if true, to \""+lbl2+"\" otherwise.")
    buf.trace.tab()
    buf.trace.out("Create a fresh label \""+lbl+"\".")
    x_formula(buf, arg1, lbl, lbl2)
    buf.code(LABEL, lbl)
    x_formula(buf, arg2, lbl1, lbl2)
    buf.trace.untab()

def x_or(buf, n, lbl1, lbl2):
    '''
    Generates LLVM code to evaluate a B disjunction and branch to either label.

    Input:
      - buf: a CodeBuffer object where the generated code is stored
      - n: an AST node representing a B disjunction.
      - lbl1: a LLVM label string
      - lbl2: a LLVM label string
    '''
    check_kind(n, {"Form"})
    assert(n["op"] == "or")
    assert(len(n["args"]) == 2)
    arg1 = n["args"][0]
    arg2 = n["args"][1]
    lbl = names.new_label()
    buf.trace.out("Evaluate disjunction \""+ellipse(printer.condition(n))+"\", branch to \""+lbl1+"\" if true, to \""+lbl2+"\" otherwise.")
    buf.trace.tab()
    buf.trace.out("Create a fresh label \""+lbl+"\".")
    x_formula(buf, arg1, lbl1, lbl)
    buf.code(LABEL, lbl)
    x_formula(buf, arg2, lbl1, lbl2)
    buf.trace.untab()

def x_not(buf, n, lbl1, lbl2):
    '''
    Generates LLVM code to evaluate a B negation and branch to either label.

    Input:
      - buf: a CodeBuffer object where the generated code is stored
      - n: an AST node representing a B negation.
      - lbl1: a LLVM label string
      - lbl2: a LLVM label string
    '''
    check_kind(n, {"Form"})
    assert(n["op"] == "not")
    buf.trace.out("Evaluate negation \""+ellipse(printer.condition(n))+"\", branch to \""+lbl1+"\" if true, to \""+lbl2+"\" otherwise.")
    buf.trace.tab()
    x_formula(buf, n["args"][0], lbl2, lbl1)
    buf.trace.untab()

def x_pred(buf, n):
    if n["kind"] == "Comp":
        return x_comp(buf, n)
    else:
        return ""

### TRANSLATION OF EXPRESSIONS ###

def x_expression(buf, n):
    '''
    Generates LLVM code to evaluate a B expression.

    Input:
      - buf: a CodeBuffer object where the generated code is stored
      - n: an AST node representing a B expression.
    Output:
      A pair containing, the identifier of the LLVM temporary variable storing the value
      of the expression, and the LLVM type of this temporary variable.
    '''
    check_kind(n, {"IntegerLit", "BooleanLit", "Enumerated", 
                   "Vari", "Term", "Cons"})
    buf.trace.out("Evaluate expression \""+ellipse(printer.term(n))+"\".")
    buf.trace.tab()
    if n["kind"] == "IntegerLit":
        res = x_integerlit(buf, n), "i32"
    elif n["kind"] == "BooleanLit":
        res = x_booleanlit(buf, n), "i1"
    elif n["kind"] == "Enumerated":
        res = x_enumerated(buf, n)
    elif n["kind"] == "Vari":
        res = x_name(buf, n)
    elif n["kind"] == "Term":
        res = x_term(buf, n)
    elif n["kind"] == "Cons":
        res = x_expression(buf, n["value"])
    else:
        res = ("","")
    buf.trace.untab()
    buf.trace.outu("The evaluation of \""+ellipse(printer.term(n))+"\" is \""+res[0]+"\".")
    return res

def x_integerlit(buf, n):
    '''
    Generates LLVM code to evaluate a B integer literal.

    Input:
      - buf: a CodeBuffer object where the generated code is stored
      - n: an AST node representing a B integer literal.
    Output:
      A string of the integer literal value.
    '''
    check_kind(n, {"IntegerLit"})
    buf.trace.out("An integer literal is represented as such in LLVM.")
    return n["value"]

def x_booleanlit(buf, n):
    '''
    Generates LLVM code to evaluate a B boolean literal.

    Input:
      - buf: a CodeBuffer object where the generated code is stored
      - n: an AST node representing a B integer literal.
    Output:
      A string of the LLVM boolean literal value, i.e. "1" or "0".
    '''
    check_kind(n, {"BooleanLit"})
    buf.trace.out("A Boolean literal is represented as a one-bit integer in LLVM.")
    return "1" if n["value"] == "TRUE" else "0"

def x_enumerated(buf, n):
    '''
    Generates LLVM code to evaluate an element from an enumerated set.

    Input:
      - buf: a CodeBuffer object where the generated code is stored
      - n: an AST node representing a B enumerated value.
    Output:
      A pair containing a string for the integer value encoding the
      enumerated value, and a string for the integer type encoding
      the corresponding enumerated set.
    '''
    check_kind(n, {"Enumerated"})
    buf.trace.out("An enumerated value is represented as an integer literal.")
    t = n["type"]
    return (str(t["elements"].index(n)), x_type(t))

def x_name(buf, n):
    '''
    Generates LLVM code to evaluate a B identifier in an expression.

    Input:
      - buf: a CodeBuffer object where the generated code is stored
      - n: an AST node representing a B expression.
    Output:
      A pair containing, the identifier of the LLVM variable storing the value
      of the B variable of the given identifier, and the LLVM type of this variable.
    '''
    check_kind(n, {"Vari"})
    bvar, btype = n["id"], n["type"]
    ltype = x_type(btype)
    if n["scope"] == "Local":
        lvar = "%"+bvar
        v2 = names.new_local()
        buf.trace.out("B local variable \""+bvar+"\" is on the LLVM stack at address \""+lvar+"\".")
        buf.trace.out("Temporary \""+v2+"\" gets the contents from this position.")
        buf.code(LOADD, v2, ltype, lvar)
        lvar = v2
    elif n["scope"] == "Oper":
        buf.trace.out("Operation parameter \""+n["id"]+"\" is LLVM parameter \"%"+n["id"]+"\".")
        lvar = "%"+bvar
    elif n["scope"] == "Impl":
        lptr = names.new_local()
        lvar = names.new_local()
        pos = str(state_position(n))
        buf.trace.out("State variable \""+bvar+"\" is stored at position \""+pos+"\" of \"%self$\".")
        buf.trace.out("Let temporary \""+lptr+"\" be the corresponding address.")
        buf.code(LOADI, lptr, state_t_name(n["root"]), "%self$", pos)
        if (n["type"] ==ast.INTEGER or n["type"] ==ast.BOOL):
            buf.code(LOADD, lvar, ltype, lptr)
        else: # Derived data types (Arrays)
            buf.code(GETPT, lvar, ltype, lptr)
    else:
        lvar, type = "", ""
    return (lvar, ltype)

def x_term(buf, n):
    '''
    Generates LLVM code to evaluate a B term.

    Input:
      - buf: a CodeBuffer object where the generated code is stored
      - n: an AST node representing a B term.
    Output:
      A pair containing, the identifier of the LLVM variable storing the value
      of the B term, and the LLVM type of this value.
    '''
    global TB, SP, NL
    check_kind(n, {"Term"})
    v1, t = x_expression(buf, n["args"][0])
    if n["op"] == "succ" or n["op"] == "pred":
        v2 = "1"
    else:
        assert(len(n["args"]) == 2)
        v2, _ = x_expression(buf, n["args"][1])
    v = names.new_local()
    buf.trace.out("Let temporary \""+v+"\" get the value of \""+ellipse(printer.term(n))+"\".")
    buf.code(APPLY, v, llvm_op(n["op"]), t, v1, v2)
    return (v, t)

### LLVM IDENTIFIER GENERATION ###

def state_t_name(n):
    '''
    - Input:
      n: A node representing a B machine
    - Output:
      A string for the name of the LLVM type representing the state of
      (the implementation) of n.
    '''
    check_kind(n, {"Machine", "Impl"})
    if n["kind"] == "Machine":
        return "%"+n["id"]+"$state$"
    else:
        return state_r_name(machine(n))

def state_r_name(n):
    '''
    - Input:
      n: A node representing a B machine
    - Output:
      A string for the name of the LLVM type representing a reference to
      the state of (the implementation) of n.
    '''
    check_kind(n, { "Machine", "Impl" })
    if n["kind"] == "Machine":
        return "%"+n["id"]+"$ref$"
    else:
        return state_r_name(machine(n))

def op_name(n):
    '''
    - Input:
      n: A node representing a B operation
    - Output:
      A string for the name of the LLVM construct representing n.
    '''
    check_kind(n, { "Oper" })
    root = n["root"]
    check_kind(root, { "Impl" })
    machine = root["machine"]
    return "@" + machine["id"] + "$" + n["id"]

def init_name(n):
    '''
    - Input:
      n : a node representing a B machine or implementation
    - Output:
    String with the name of the LLVM function encoding the initialisation
    of that implementation.
    '''
    check_kind(n, {"Machine", "Impl"})
    mach = n if n["kind"] == "Machine" else n["machine"]
    return "@"+mach["id"]+"$init$"

def print_name(n):
    '''
    - Input:
      n : a node representing a B machine or implementation
    - Output:
    String with the name of the LLVM function responsible for printing
    the state of the component.
    '''
    check_kind(n, {"Machine", "Impl"})
    mach = n if n["kind"] == "Machine" else n["machine"]
    return "@"+mach["id"]+"$printf$"

### LLVM names for B operators ###

def llvm_op(str):
    '''
    Input:
        - str: the name of an operator in B0
    Output: The name of the corresponding LLVM operator
    Example:
        >>> llvm_op(=) == eq
        True
        >>> llvm_op(+) == add
        True
    Note: An error message is printed and the empty string
    is returned if the translation has not been defined.
    '''
    lex = dict({"=":"eq", "!=": "ne",
                "<":"slt", "<=":"sle", ">":"sgt", ">=":"sge",
                "+":"add", "-": "sub",
                "succ":"add", "pred":"sub",
                "*":"mul", "/":"sdiv", "mod":"srem"})
    if str not in lex.keys():
        print("error: operator " + str + " not translated")
        return ""
    else:
        return lex[str]

### MISC ###

#
# Function check_kind is used to assert that the arguments of translation
# function arguments are in the correct syntactic category
#
def check_kind(n, s):
    '''
    Input:
       - n: represents a B0 syntactic entity
       - s: a set of syntactic entity class names
    Output: None.
    Description: Checks that the class of n is one in s.
    Example:
       >>> check_kind(n, {"IntegerLit, BooleanLit"})
    '''
    if n["kind"] not in s:
        print(commas([str(el) for el in s]) + " expected, got " + 
              str(n["kind"]) + "\n")

def state_position(n):
    '''
    Input:
      - n: represents a B state variable or imported machine
    Output:
      - position of n in the list of imported machines and state variables
    An error message is printed and the value 0 is returned if n is
    not found.
    '''
    root = n["root"]
    result = 0
    for n2 in root["imports"] + root["variables"]:
        if n2 == n:
            return result
        result += 1
    print("error: position of imported machine or variable not found in implementation")
    return 0

def state_opaque_typedef(buf, m):
    '''
    Input:
      - m: represents a B machine
    Desc:
      Appends to buf the LLVM definition of type pointer to type representing the
      state of n.
      This only makes sense if n is stateful.
    '''
    global NL
    buf.trace.out("The state encoding type for module \""+m["id"]+"\" is defined elsewhere:")
    buf.code(OTYPE, state_t_name(m))

def state_ref_typedef(buf, m):
    '''
    Input:
      - m: represents a B machine
    Desc:
      Adds to buf the LLVM definition of type pointer to type representing the
      state of n.
      This only makes sense if n is stateful.
    '''
    global NL
    buf.trace.out("The type for references to state encodings of \""+m["id"]+"\" is:")
    buf.code(TYPE, state_r_name(m), state_t_name(m)+"*")

###

def is_developed(m):
    check_kind(m, {"Machine"})
    return m["implementation"] != None

def is_base(m):
    check_kind(m, {"Machine"})
    return m["implementation"] == None

def implementation(m):
    check_kind(m, {"Machine"})
    assert(is_developed(m))
    return m["implementation"]

def machine(m):
    check_kind(m, {"Impl"})
    return m["machine"]

### TRANSLATION OF IMPLEMENTATION

def x_type_expr_impo(n):
    check_kind(n, {"Impo"})
    return state_t_name(n["mach"]["impl"])

def x_type_expr_vari(n):
    check_kind(n, {"Vari"})
    return x_type(n["type"])

def x_type_expr_impl(n):
    check_kind(n, {"Impl"})
    result = ""
    tl = []
    for ni in n["imports"]:
        tl.append(x_type_expr_impo(ni))
    for nv in n["variables"]:
        tl.append(x_type_expr_vari(nv))
    result += "{" + commas(tl) + "}"
    return result

### COMP(ONENTS)

class Comp:
    '''
    This class represents components in a B project. Objects of this
    class have the following attributes:
    - a path, which shall be given as a list of strings
    - a machine, which shall be given as the root AST node of the machine
    - id, which is a unique identifier computed when an instance is created
    Instances are convertible to strings, and are hashable.
    '''
    def __init__(self, p, m):
        check_kind(m, {"Machine"})
        self.path = p
        self.mach = m
        self.id = "@"+"$".join(p)+"$"+m["id"]
        self.b_id = m["id"] if p == [""] else ".".join(p+[m["id"]])
    def __str__(self):
        return self.id
    def __hash__(self):
        return self.id.__hash__()
    def bstr(self):
        return self.b_id

def comp_direct(m):
    '''
    List of direct components.

    Inputs:
      - n: root AST node for a B machine
   Output:
     Sequence of components imported by the implementation of machine m.
   '''
    check_kind(m, {"Machine"})
    if m["comp_direct"] == None:
        if is_base(m):
            m["comp_direct"] = []
        else:
            impl = implementation(m)
            m["comp_direct"] = list()
            for impo in impl["imports"]:
                pre = impo["pre"]
                if pre == None:
                    pre = ""
                m["comp_direct"].append(Comp([pre], impo["mach"]))
    return m["comp_direct"]

def comp_indirect(m):
    '''
    List of all (direct and indirect) components.

    Inputs:
      - m: root AST node for a B machine
   Output:
     Sequence of components ordered by
     increasing level in the import tree: imported components, followed by
     components imported from imported components, etc.
     The imports of a machine are those of the corresponding implementation in
     the given project.
   '''
    check_kind(m, {"Machine"})
    if m["comp_indirect"] == None:
        if is_base(m):
            m["comp_indirect"] = []
        else:
            impl = implementation(m)
            v = comp_direct(m)
            # the intention flattens a list of list into a list
            v.extend([ i for sl in [ comp_indirect(mc.mach) for mc in v ]
                         for i in sl ])
            m["comp_indirect"] = v
    return m["comp_indirect"]

def comp_stateful(m):
    '''
    List of (direct and indirect) stateful components.

    Inputs:
      - m: root AST node for a B machine
   Output:
     Sequence of stateful components ordered by
     increasing level in the import tree: imported components, followed by
     components imported from imported components, etc.
     The imports of a machine are those of the corresponding implementation in
     the given project.
   '''
    return [ x  for x in comp_indirect(m) if is_stateful(x.mach) ]

#
# MISC
#

def is_stateful(n):
    '''
    Checks if n is a stateful module

    Inputs:
      - n: a machine or implementation AST root node
    Output:
      boolean
    '''
    check_kind(n, {"Machine", "Impl"})
    if n["stateful"] == None:
        if n["kind"] == "Machine":
            if is_base(n):
                n["stateful"] = n["variables"] != []
            else:
                n["stateful"] = is_stateful(n["implementation"])
        else:
            if n["variables"] != []:
                n["stateful"] = True
            else:
                n["stateful"] = False
                for i in n["imports"]:
                    if is_stateful(i["mach"]):
                        n["stateful"] = True
                        break
    return n["stateful"]

def ellipse(str):
    '''
    Utility that creates a shortened version of a text. If str is greater than 24 characters,
    the first 21 characters are kept, and elliptic ... replaces the rest of str. Therefore
    the resulting string has at most 24 characters.
    '''
    str2 = str.replace("\n", "")
    if len(str2) > 24:
        return str2[:21]+"..."
    else:
        return str2
