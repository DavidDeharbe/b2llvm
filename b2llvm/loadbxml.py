"""Module providing functions to load a BXML file into a Python AST.

This module is responsible for providing functions to load a BXML file and
build the corresponding Python abstract syntax tree, using the format and
the constructors found in file "ast.py".

We use the xml.etree.ElementTree library
See http://docs.python.org/2/library/xml.etree.elementtree.html

1. General design

The translation recurses over the tree. There is one function for
each kind of node. When different kinds of node are possible (for
instance, where a substitution is expected) an additional dispatcher
function is responsible for identifying the actual type of node,
by looking at the XML tag.

2. Symbol table

Most of the recursive traversal of the tree requires as parameter a symbol
table. Such symbol table are provided by class SymbolTable that use a Python
dictionary, where the keys are strings, and the values are the Python
representation of the corresponding B symbol. I expect that no name conflict
occurs in the input XML. Nevertheless, the inclusion in the symbol table is done
through method add, which checks there is no such conflict.

The elements stored into the symbol table are:
  - concrete variables
  - concrete constants/values
  - imports: name of import is mapped to ast import node
  - operations: name of operation is mapped to ast operation node
  - operation parameters
  - local variables

When entering a new scope (e.g. an operation, or a VAR...IN substitution),
a copy of the symbol table is created, and the local symbols are added to
that copy.

3. Associative operators

Expressions consisting of the application of an associative operator to
more than two arguments are represented as a nested application of a
binary application, associated to the left.
For instance a + b + c would be represented as ((a + b) + c).

4. Symbol table(s)

symast is a traditional symbol table where the keys are identifier strings
and the values the AST node of the corresponding B entity. When the loader
enters a new scope, it creates a new symbol table initialized with a copy
of the inherited table.

symimp is a special symbol table to handle imports
- For imports with prefix, the entry in symimp has as key the prefix and
as value the import clause.
- For imports without prefix, there is one entry in symimp for each visible
symbol of the imported machine, and the key is the identifier of the
symbol and the value is the import clause.
In both cases, the key is a string and the value an AST node.

5. References

[LRM] B Language Reference Manual, version 1.8.6. Clearsy.

"""

import os
import xml.etree.ElementTree as ET
import b2llvm.ast as ast
import b2llvm.cache as cache
from b2llvm.bproject import BProject

###
#
# error handling
#
###

class Report(object):
    """Rudimentary error handling."""
    def __init__(self):
        """Constructor"""
        self._error_nb = 0
        self._warn_nb = 0
    def error(self, message):
        """Outputs error message and increments error count."""
        self._error_nb += 1
        print("error: " + message)
    def warn(self, message):
        """Outputs warning message and increments warning count."""
        self._warn_nb += 1
        print("warning: " + message)

###
#
# global variables
#
###

_LOADING = set()
_LOG = Report()

#
# MODULE ENTRY POINTS
#

def load_project(dirname='bxml', filename='project.xml'):
    '''
    Keywords:
      - dirname: path to directory where bxml files are stored;
      default value is 'bxml'.
      - filename: the name of a bproject.bxml file. The default
      value is 'bproject.bxml'.
    Loads the contents of the given file, if it exists, into global variable
    project_db. If the file does not exist, then project_db is left empty,
    i.e. a pair formed by an empty dictionary and an empty set.
    '''
    return BProject(dirname+os.sep+filename)

def load_module(dirname, project, machine):
    '''
    Inputs:
      - dirname: string with path to directory where B modules are stored
      - project: BProject object storing current project settings
      - machine: string with machine name
    Output:
      Root AST node for the representation of m.
    '''
    if not project.has(machine):
        _LOG.error("cannot find machine " + machine + " in project file.")
        raise Exception("resource not found")
    loaded = cache.Cache()
    if project.is_base(machine):
        return load_base_machine(dirname, loaded, machine)
    else:
        assert project.is_developed(machine)
        return load_developed_machine(dirname, project, loaded, machine)

###
#
# modules
#
###

def load_base_machine(dirname, loaded, machine):
    '''
    Loads B base machine from file to Python AST.

    Parameters:
      - dirname
      - loaded: cache from identifiers to root AST machine.
      - machine: the name of a B machine.
    Result:
    A Python representation of the B machine.
    Output:
    The routine prints to stdout error messages and warnings; at the end
    it reports the number of errors and warnings detected and printed
    during the execution.
    '''
    global _LOADING, _LOG
    if loaded.has(id):
        return loaded.get(id)
    if machine in _LOADING:
        _LOG.error("there seems to be a recursive dependency in imports")
    _LOADING.add(machine)
    # symbol table: symbol to AST node
    symast = SymbolTable()
    symimp = SymbolTable()
    tree = ET.parse(path(dirname, machine))
    root = tree.getroot()
    assert root.tag == 'Machine'
    assert root.get("type") == "abstraction"
    sets = []
    constants = load_values(root, symast)
    variables = load_concrete_variables(root, symast)
    operations = load_operations(root, symast, symimp)
    pymachine = ast.make_base_machine(machine, sets, constants, variables, 
                                      operations)
    symast.clear()
    symimp.clear()
    _LOADING.remove(machine)
    loaded.set(machine, pymachine)
    return pymachine

def load_developed_machine(dirname, project, loaded, machine):
    '''
    Loads BXML a developed machine from file to Python AST. All dependent
    components are loaded, including implementations of developed
    machines.

    Parameters:
      - dirname: the directory where the project files are stored
      - project: project settings object
      - loaded: cache from identifiers to root AST machine.
      - machine: the name of a developed B machine
    Result:
    A Python representation of the B machine
    Output:
    The routine prints to stdout error messages and warnings; at the end
    it reports the number of errors and warnings detected and printed
    during the execution.
    '''
    global _LOG
    if loaded.has(machine):
        return loaded.get(machine)
    if machine in _LOADING:
        _LOG.error("there seems to be a recursive dependency in imports")
    _LOADING.add(machine)
    if not project.has(machine):
        _LOG.error("machine " + machine + " not found in project settings")
        return None
    if not project.is_developed(machine):
        _LOG.error("machine " + machine + " is not a developed machine.")
        return None
    tree = ET.parse(path(dirname, machine))
    root = tree.getroot()
    assert root.tag == 'Machine'
    assert root.get("type") == "abstraction"
    assert name_attr(root) == machine
    sets = []
    impl_id = project.implementation(machine)
    pyimpl = load_implementation(dirname, project, loaded, impl_id)
    pymachine = ast.make_developed_machine(machine, sets, pyimpl)
    pyimpl["machine"] = pymachine
    _LOADING.remove(machine)
    loaded.set(machine, pymachine)
    return pymachine

def load_implementation(dirname, project, loaded, module):
    '''
    Loads B implementation to Python AST.

    Parameters:
      - dirname: the directory where BXML files are to be found
      - project: the object representing the B project settings.
      - loaded: cache from identifiers to root AST machine.
      - module: the identifier of the implementation
    Result:
      A Python representation of the B implementation, or None if some
      error occured.
    Output:
      The routine prints to stdout error messages and warnings; at the end
      it reports the number of errors and warnings detected and printed
      during the execution.
    '''
    global _LOG
    if loaded.has(module):
        return loaded.get(module)
    if module in _LOADING:
        _LOG.error("there seems to be a recursive dependency in imports")
    symast = SymbolTable()
    symast.add("BOOL", ast.BOOL)
    symast.add("INTEGER", ast.INTEGER)
    symimp = SymbolTable()
    _LOADING.add(module)
    tree = ET.parse(path(dirname, module))
    root = tree.getroot()
    assert root.tag == 'Machine'
    assert root.get("type") == "implementation"
    impl_name = name_attr(root)
    assert impl_name == module
    imports = load_imports(root, symast, symimp, dirname, project, loaded)
    sets = load_sets(root, symast)
    constants = load_values(root, symast)
    variables = load_concrete_variables(root, symast)
    initialisation = load_initialisation(root, symast, symimp)
    operations = load_operations(root, symast, symimp)
    symast.clear()
    symimp.clear()
    pyimpl = ast.make_implementation(impl_name, imports, sets, constants, 
                                     variables, initialisation, operations)
    _LOADING.remove(module)
    loaded.set(module, pyimpl)
    return pyimpl

###
#
# machine clauses
#
###

def load_imports(root, symast, symimp, dirname, project, loaded):
    '''
    Parameters:
      - root: XML ElementTree representing the root of an implementation
      - symast: a symbol table
      - c: cache from identifiers to root AST machine.
    Result:
      List of import AST nodes.
    Side effects:
      All externally visible elements of the imported modules are added
      to the symbol table.
      All the named imports are added to the symbol table.
    '''
    imports = root.find("./Imports")
    if imports == None:
        return []
    imports = [load_import(i, symast, dirname, project, loaded)
               for i in imports.findall("./Referenced_Machine")]
    # Add visible symbols from imported machines ([LRM, Appendix C.10])
    acc = [] # store machines that have already been processed
    for pyimp in imports:
        pymach = pyimp["mach"]
        if pymach not in acc:
            for symbol in visible_symbols(pymach):
                symast.add(symbol["id"], symbol)
            acc.append(pymach)
        if pyimp["pre"] != None:
            symimp.add(pyimp["pre"], pyimp)
        else:
            for symbol in visible_symbols(pymach):
                symimp.add(symbol["id"], pyimp)
    return imports

def load_import(xmlimp, symast, dirname, project, loaded):
    '''
    Loads one import clause to Python AST and update symbol table.

    Parameters:
      - xmlimp: a BXML tree element for an import.
      - symast: symbol table.
      - c: cache from identifiers to root AST machine.
    Result:
      A Python AST node representing the import clause.
    Side effects:
      If the import clause has a prefix, then it is added to the
      symbol table, together with the result node.
    '''
    global _LOG
    module = xmlimp.find("./Name").text
    if not project.has(module):
        _LOG.error("machine "+module+" not found in project settings")
        return None
    if project.is_developed(module):
        mach = load_developed_machine(dirname, project, loaded, module)
    else:
        mach = load_base_machine(dirname, loaded, module)
    instance = xmlimp.find("./Instance")
    if instance != None:
        pyimp = ast.make_import(mach, instance.text)
        symast.add(instance.text, pyimp)
    else:
        pyimp = ast.make_import(mach)
    return pyimp

def load_sets(root, symast):
    """Loads SETS clause to Python AST and updates symbol table."""
    xmlsets = root.findall("./Sets/Set")
    result = []
    for xmlset in xmlsets:
        name = value(xmlset.find("Identifier"))
        xmlelements = xmlset.findall("Enumerated_Values/Identifier")
        elements = []
        for ex in xmlelements:
            ename = value(ex)
            epyval = ast.make_enumerated(ename)
            symast.add(ename, epyval)
            elements.append(epyval)
        pyval = ast.make_enumeration(name, elements)
        symast.add(name, pyval)
        result.append(pyval)
    return result

def load_values(root, symast):
    """Loads VALUES clause to Python AST and updates symbol table."""
    xmlvals = root.findall("./Values/Valuation")
    result = []
    for xmlval in xmlvals:
        value_id = ident(xmlval)
        children = xmlval.findall("./*")
        assert len(children) == 1
        xmlexp = children[0]
        value_exp = load_exp(xmlexp, symast)
        value_type = load_type(xmlexp, symast)
        pyval = ast.make_const(value_id, value_type, value_exp)
        result.append(pyval)
        symast.add(value_id, pyval)
    return result

def load_concrete_variables(elem, symast):
    '''
    Input:
    - elem: the BXML tree root node of a B implementation
    - symat: the symbol table used in abstract syntax tree
    Output:
    A Python dict mapping variable identifier (strings) to the Python
    representation for the concrete variables in the B implementation.
    '''
    xmlvars = elem.findall("./Concrete_Variables/Identifier")
    
    xmlinv = elem.findall(".//Invariant//Expression_Comparison[@operator=':']")
    
    result = []
    for xmlvar in xmlvars:
        asttype = load_type(xmlvar, symast)
        if asttype == None :
            asttype =  get_inv_type(xmlvar,xmlinv)
        assert asttype != None
        name = value(xmlvar)
        astvar = ast.make_imp_var(name, asttype)
        symast.add(name, astvar)
        result.append(astvar)
    
    return result

def load_initialisation(elem, symast, symimp):
    """Loads the XML child for initialisation to an AST node."""
    initialisation = elem.find("./Initialisation")
    if initialisation == None:
        return []
    xmlsubst = initialisation.find("./*")
    return [ load_sub(xmlsubst, symast, symimp) ]

def load_operations(elem, symast, symimp):
    """Loads all XML elements for operations to a list of AST nodes."""
    operations = elem.findall(".//Operation")
    return [load_operation(op, symast, symimp) for op in operations]

def load_operation(elem, symast, symimp):
    """Loads an XML element for an operation to an AST node."""
    assert elem.tag == "Operation"
    name = name_attr(elem)
    body = elem.find("./Body/*")
    inputs = elem.findall("./Input_Parameters/Identifier")
    outputs = elem.findall("./Output_Parameters/Identifier")
    symast2 = symast.copy()
    p_inputs = [ load_parameter(param, symast2) for param in inputs ]
    p_outputs = [ load_parameter(param, symast2) for param in outputs ]
    p_body = load_sub(body, symast2, symimp)
    symast2.clear()
    return ast.make_oper(name, p_inputs, p_outputs, p_body)

def load_parameter(elem, symast):
    """Loads an XML element for an operation parameter to an AST node."""
    name = value(elem)
    pytype = load_type(elem, symast)
    astnode = ast.make_arg_var(name, pytype)
    symast.add(name, astnode)
    return astnode

###
#
# substitutions
#
###

def load_sub(elem, symast, symimp):
    '''
    Inputs:
      - elem: a XML node representing a B0 substitution
      - symast: symbol table as Python dictionary mapping strings to
      Python nodes
    Output:
      Python node representing the substitution n
    '''
    global _LOG
    if elem.tag == "Bloc_Substitution":
        astnode = load_block_substitution(elem, symast, symimp)
    elif elem.tag == "Skip":
        astnode = load_skip(elem)
    elif elem.tag == "Assert_Substitution":
        astnode = load_assert_substitution(elem)
    elif elem.tag == "If_Substitution":
        astnode = load_if_substitution(elem, symast, symimp)
    elif elem.tag == "Affectation_Substitution":
        astnode = load_becomes_eq(elem, symast)
    elif elem.tag == "Case_Substitution":
        astnode = load_case_substitution(elem, symast, symimp)
    elif elem.tag == "VAR_IN":
        astnode = load_var_in(elem, symast, symimp)
    elif elem.tag == "Binary_Substitution":
        astnode = load_binary_substitution(elem, symast, symimp)
    elif elem.tag == "Nary_Substitution":
        astnode = load_nary_substitution(elem, symast, symimp)
    elif elem.tag == "Operation_Call":
        astnode = load_operation_call(elem, symast, symimp)
    elif elem.tag == "While":
        astnode = load_while(elem, symast, symimp)
    elif elem.tag == "Becomes_In":
        astnode = load_becomes_in(elem, symast)
    elif elem.tag in {"Choice_Substitution", "Becomes_Such_That",
                   "Select_Substitution", "ANY_Substitution",
                   "LET_Substitution"}:
        _LOG.error("unexpected substitution: " + elem.tag)
        astnode = ast.make_skip()
    else:
        _LOG.error("unrecognized substitution: " + elem.tag)
        astnode = ast.make_skip()
    return astnode

def load_block_substitution(elem, symast, symimp):
    """Load an XML element for a block substitution to an AST node."""
    assert elem.tag == "Bloc_Substitution"
    substs = [ load_sub(s, symast, symimp) for s in elem.findall("./*") ]
    return ast.make_blk(substs)

def load_skip(elem):
    """Load an XML element for a SKIP substitution to an AST node."""
    assert elem.tag == "Skip"
    return ast.make_skip()

def load_assert_substitution(elem):
    """Load an XML element for a ASSERT substitution to an AST node."""
    global _LOG
    assert elem.tag == "Assert_Substitution"
    _LOG.warn("assertion replaced by skip")
    return ast.make_skip()

def load_if_substitution(elem, symast, symimp):
    """Load an XML element for a IF substitution to an AST node."""
    global _LOG
    assert elem.tag == "If_Substitution"
    if elem.get("elseif") != None:
        _LOG.error("unrecognized elseif attribute in IF substitution")
        return ast.make_skip()
    xmlcond = elem.find("./Condition")
    xmlthen = elem.find("./Then")
    xmlelse = elem.find("./Else")
    pycond = load_boolean_expression(xmlcond.find("./*"), symast)
    pythen = load_sub(xmlthen.find("./*"), symast, symimp)
    thenbr = ast.make_if_br(pycond, pythen)
    if xmlelse == None:
        return ast.make_if([thenbr])
    else:
        pyelse = load_sub(xmlelse.find("./*"), symast, symimp)
        elsebr = ast.make_if_br(None, pyelse)
        return ast.make_if([thenbr, elsebr])

def load_becomes_eq(elem, symast):
    """Load an XML element for a becomes equal substitution to an AST node."""
    global _LOG
    assert elem.tag == "Affectation_Substitution"
    lhs = elem.findall("./Variables/*")
    rhs = elem.findall("./Values/*")
    if len(lhs) != 1 or len(rhs) != 1:
        _LOG.error("unsupported multiple becomes equal substitution")
        return ast.make_skip()
    dst = load_exp(lhs[0], symast)
    src = load_exp(rhs[0], symast)
    return ast.make_beq(dst, src)

def load_becomes_in(elem, symast):
    """Load an XML element for a becomes in substitution to an AST node."""
    assert elem.tag == "Becomes_In"
    lhs = elem.findall("./Variables/*")
    dst = [ load_exp(x, symast) for x in lhs ]
    return ast.make_bin(dst)

def load_case_branch(elem, symast, symimp):
    """Load an XML element for a case branch to an AST node."""
    return ast.make_case_br(load_exp(elem.find("./Value/*"), symast),
                            load_sub(elem.find("./Then/*"), symast, symimp))

def load_case_default(elem, symast, symimp):
    """Load an XML element for a case default branch to an AST node."""
    return ast.make_case_br(None, load_sub(elem.find("./Choice/Then/*"),
                                           symast, symimp))

def load_case_substitution(node, symast, symimp):
    """Load an XML element for a case substitution to an AST node."""
    assert node.tag == "Case_Substitution"
    xmlexpr = node.find("./Value/*")
    xmlbranches = node.findall("./Choices/Choice")
    xmlelse = node.find("./Else")
    pyexpr = load_exp(xmlexpr, symast)

    pybranches = [ load_case_branch(x, symast, symimp) for x in xmlbranches ]
    if xmlelse != None:
        pybranches.append(load_case_default(xmlelse, symast, symimp))
    return ast.make_case(pyexpr, pybranches)

def load_var_in(node, symast, symimp):
    """Load an XML element for a variable declaration to an AST node."""
    assert node.tag == "VAR_IN"
    xmlvars = node.findall("./Variables/Identifier")
    xmlbody = node.find("./Body")
    symast2 = symast.copy()
    pyvars = []
    for xmlvar in xmlvars:
        name = value(xmlvar)
        pytype = load_type(xmlvar, symast)
        pyvar = ast.make_loc_var(name, pytype)
        symast2.add(name, pyvar)
        pyvars.append(pyvar)
    pybody = [ load_sub(xmlbody.find("./*"), symast2, symimp) ]
    symast2.clear()
    return ast.make_var_decl(pyvars, pybody)

def load_binary_substitution(node, symast, symimp):
    """Load an XML element for a binary substitution to an AST node."""
    global _LOG
    assert node.tag == "Binary_Substitution"
    oper = operator(node)
    if oper == "||":
        _LOG.error("parallel substitution cannot be translated")
        return ast.make_skip()
    elif oper == ";":
        left = node.find("./Left")
        right = node.find("./Right")
        return [load_sub(left, symast, symimp), load_sub(right, symast, symimp)]
    else:
        _LOG.error("unrecognized binary substitution")
        return ast.make_skip()

def load_nary_substitution(node, symast, symimp):
    """Load an XML element for a nary substitution to an AST node."""
    global _LOG
    assert node.tag == "Nary_Substitution"
    oper = operator(node)
    if oper == "||":
        _LOG.error("parallel substitution cannot be translated")
        return ast.make_skip()
    elif oper == ";":
        substs = node.findall("./*")
        return ast.make_blk([load_sub(sub, symast, symimp) for sub in substs])
    else:
        _LOG.error("unrecognized n-ary substitution")
        return ast.make_skip()

def load_operation_call(node, symast, symimp):
    """Load an XML element for an operation call to an AST node."""
    assert node.tag == "Operation_Call"
    xmlname = node.find("./Name/*")
    # Operation from import w/o prefix:
    #   <Identifier value='get'>
    # Operation from import w prefix:
    #   <Identifier value='hh.get' instance='hh' component='get'>
    xmlout = node.findall("./Output_Parameters/*")
    xmlinp = node.findall("./Input_Parameters/*")
    astout = [ load_identifier(x, symast) for x in xmlout ]
    astinp = [ load_identifier(x, symast) for x in xmlinp ]
    instance = xmlname.get('instance')
    if instance == None:
        name = value(xmlname)
    else:
        name = xmlname.get('component')

    astop = symast.get(name)
    # operation is from a directly imported module
    if name in symimp.keys():
        impo = symimp.get(name)
        return ast.make_call(astop, astinp, astout, impo)
    # operation is from a prefixed imported module
    elif instance in symimp.keys():
        impo = symimp.get(instance)
        return ast.make_call(astop, astinp, astout, impo)
    # operation is local
    else:
        return ast.make_call(astop, astinp, astout)

def load_while(node, symast, symimp):
    """Load an XML element for a while instruction to an AST node."""
    assert node.tag == "While"
    xmlcond = node.find("./Condition/*")
    xmlbody = node.find("./Body/*")
    pycond = load_boolean_expression(xmlcond, symast)
    pybody = load_sub(xmlbody, symast, symimp)
    return ast.make_while(pycond, [pybody])

###
#
# expressions
#
###

def load_exp(node, symast):
    """Load an XML element for an expression to an AST node."""
    global _LOG
    if node.tag == "Binary_Expression":
        pynode = load_binary_expression(node, symast)
    elif node.tag == "Nary_Expression":
        pynode = load_nary_expression(node, symast)
    elif node.tag == "Unary_Expression":
        pynode = load_unary_expression(node, symast)
    elif node.tag == "Boolean_Litteral":
        pynode = load_boolean_literal(node)
    elif node.tag == "Integer_Litteral":
        pynode = load_integer_literal(node)
    elif node.tag == "Identifier":
        pynode = load_identifier(node, symast)
    elif node.tag == "Boolean_Expression":
        pynode = load_boolean_expression(node, symast)
    elif node.tag in {"EmptySet", "EmptySeq", "Quantified_Expression",
                   "Quantified_Set", "String_Litteral", "Struct", "Record"}:
        _LOG.error("unexpected expression " + node.tag)
        pynode = None
    else:
        _LOG.error("unknown expression " + node.tag)
        pynode = None
    return pynode

def load_identifier(node, symast):
    """Load an XML element for an identifier to an AST node."""
    return symast.get(value(node))

def load_boolean_literal(node):
    """Load an XML element for an Boolean literal to an AST node."""
    global _LOG
    assert node.tag == "Boolean_Litteral"
    if value(node) == "TRUE":
        return ast.TRUE
    elif value(node) == "FALSE":
        return ast.FALSE
    else:
        _LOG.error("unknown boolean literal")

def load_integer_literal(node):
    """Load an XML element for an integer literal to an AST node."""
    assert node.tag == "Integer_Litteral"
    return ast.make_intlit(int(value(node)))

def setup_expression(node, handlers):
    """Preprocesses a XML expression node.

    Returns a handler to apply to the results of loading the expression
    arguments, and the list of the XML elements representing the expression
    arguments.

    """
    global _LOG
    fun = operator(node)
    if fun not in handlers.keys():
        _LOG.error("unexpected operator " + fun)
        return None
    return handlers[fun], discard_attributes(node)

def load_unary(node, symast, tag, table):
    """Load an XML element for a unary to an AST node."""
    assert node.tag == tag
    fun, xmlargs = setup_expression(node, table)
    assert len(xmlargs) == 1
    pyarg = load_exp(xmlargs[0], symast)
    return fun(pyarg)

def load_binary(node, symast, tag, table):
    """Load an XML element for a binary to an AST node."""
    assert node.tag == tag
    fun, xmlargs = setup_expression(node, table)
    assert len(xmlargs) == 2
    pyargs = [ load_exp(xmlarg, symast) for xmlarg in xmlargs ]
    return fun(pyargs[0], pyargs[1])

def load_nary(node, symast, tag, table):
    """Load an XML element for a nary to an AST node."""
    assert node.tag == tag
    fun, xmlargs = setup_expression(node, table)
    assert len(xmlargs) >= 2
    pyargs = [ load_exp(xmlarg, symast) for xmlarg in xmlargs ]
    return list_combine_ltr(pyargs, fun)

def load_unary_expression(node, symast):
    """Load an XML element for a unary expression to an AST node."""
    return load_unary(node, symast, "Unary_Expression",
                      {"pred":ast.make_pred, "succ":ast.make_succ})

def load_binary_expression(node, symast):
    """Load an XML element for a binary expression to an AST node."""
    return load_binary(node, symast, "Binary_Expression",
                       {"+":ast.make_sum, "-":ast.make_diff,
                        "*":ast.make_prod,"(":ast.make_arrayItem})

def load_nary_expression(node, symast):
    """Load an XML element for a nary expression to an AST node."""
    return load_nary(node, symast, "Nary_Expression",
                     {"+":ast.make_sum, "*":ast.make_prod})

def load_binary_predicate(node, symast):
    """Load an XML element for a binary predicate to an AST node."""
    return load_binary(node, symast, "Binary_Predicate",
                       {"&":ast.make_and, "or":ast.make_or})

def load_unary_predicate(node, symast):
    """Load an XML element for a unary predicate to an AST node."""
    return load_unary(node, symast, "Unary_Predicate", {"not":ast.make_not})

def load_nary_predicate(node, symast):
    """Load an XML element for a nary predicate to an AST node."""
    assert node.tag == "Nary_Predicate"
    fun, xmlargs = setup_expression(node, {"&":ast.make_and, "or":ast.make_or})
    assert len(xmlargs) >= 2
    pyargs = [ load_boolean_expression(arg, symast) for arg in xmlargs ]
    return list_combine_ltr(pyargs, fun)

def load_expression_comparison(node, symast):
    """Load an XML element for a comparison to an AST node."""
    return load_binary(node, symast, "Expression_Comparison",
                       {"=": ast.make_eq, "/=": ast.make_neq,
                        ">": ast.make_gt, ">=": ast.make_ge,
                        "<": ast.make_lt, "<=": ast.make_le})

def load_boolean_expression(node, symast):
    """Load an XML element for a Boolean expression to an AST node."""
    global _LOG
    if node.tag == "Binary_Predicate":
        return load_binary_predicate(node, symast)
    elif node.tag == "Expression_Comparison":
        return load_expression_comparison(node, symast)
    elif node.tag == "Unary_Predicate":
        return load_unary_predicate(node, symast)
    elif node.tag == "Nary_Predicate":
        return load_nary_predicate(node, symast)
    elif node.tag in {"Quantified_Predicate", "Set"}:
        _LOG.error("unexpected boolean expression" + node.tag)
        return None
    else:
        _LOG.error("unknown boolean expression " + node.tag)
        return None

###
#
# symbol table stuff
#
###

class SymbolTable(object):
    """Class for symbol tables."""
    def __init__(self):
        """Constructor. Prefills with MAXINT."""
        self._table = dict()
        self._table["MAXINT"] = ast.MAXINT
    def __str__(self):
        """Converts object to string."""
        return "{"+",".join([key for key in self._table.keys()])+"}"
    def add(self, name, node):
        """Adds an element, checking if there is a conflict."""
        if name in self._table:
            _LOG.error("name clash ("+name+")")
        self._table[name] = node
    def rem(self, name):
        """Removes an element, checking if it is present."""
        if name not in self._table.keys():
            _LOG.error(name+"not found in table")
        self._table.pop(name)
    def get(self, name):
        """Gets an element (i.e. an AST node) from its name."""
        if name not in self._table.keys():
            _LOG.error(name+"not found in table")
        return self._table[name]
    def clear(self):
        """Empties the symbol table."""
        self._table.clear()
    def copy(self):
        """Creates a copy."""
        result = SymbolTable()
        result._table = self._table.copy()
        return result
    def keys(self):
        """Returns symbol table keys."""
        return self._table.keys()

###
#
# bxml shortcuts
#
###

def ident(node):
    '''
    Returns the value of an XML element "ident" attribute.

    Return type is string, or None if there is no such attribute.
    '''
    return node.get("ident")

def value(node):
    '''
    Returns the value of an XML element "value" attribute.

    Return type is string, or None if there is no such attribute.
    '''
    return node.get("value")

def operator(node):
    '''
    Returns the value of an XML element "operator" attribute.

    Return type is string, or None if there is no such attribute.
    '''
    return node.get("operator")

def name_attr(node):
    '''
    Returns the value of an XML element "name" attribute.

    Return type is string, or None if there is no such attribute.
    '''
    return node.get("name")

###
#
# general-purpose accumulators
#
###

def list_combine_ltr(some_list, some_fun):
    '''
    Inputs:
      - some_list: a list
      - f: a binary function defined on the elements of l
    Output:
    Left-to-right application of f to the elements of l.
    Example:
       some_list = [ 'a', 'b', 'c' ]
       some_fun = lambda x, y: '(' + x + '+' + y + ')'
       list_combine_ltr(some_list, f) --> '((a+b)+c)'
    '''
    result = some_list[0]
    for idx in range(1, len(some_list)):
        result = some_fun(result, some_list[idx])
    return result

###
#
# utilities
#
###

def get_inv_type(xmlid, xmlinv):
    '''
    Input:
    - xmlid: a XML node representing an identifier
    - xmlinv: a XML node
    Output:
    - The right node that define the variable type 
    '''
    for xmlinvElem in xmlinv:
        varName = xmlinvElem[0].get("value")
        if (varName == xmlid.get("value")):
            elem = xmlinvElem
            break
    assert elem != None
    function = elem[1]
    
    if (function.get("operator")=="-->"):
        domxml = function[0] 
        ranxml = function[1]
        res = ast.make_arrayType(domxml,ranxml)
    assert res != None
    return res   
  
    
def load_type(xmlid, symast):
    '''
    Input:
    - xmlid: a XML node representing an identifier
    Output:
    - AST node representing the type for xmlid
    Note:
    - Assumes that the XML attribute TypeInfo exists and
    is an identifier with the name of the type.
    '''
    return symast.get(value(xmlid.find("./Attributes/TypeInfo/Identifier")))

def discard_attributes(exp):
    '''
    Inputs:
      - exp: a bxml expression node
    Output:
    All the bxml children node that are not tagged as "Attributes"
    Note:
    The nodes discarded by this function usually contain the typing
    information of the expression.
    '''
    return [child for child in exp.findall("./*") if child.tag != "Attributes"]

def visible_symbols(machine):
    '''
    List of symbols defined in m that are externally visible.

    Parameters:
      - machine: Python AST node for a machine.
    Result:
      List of Python AST nodes representing the entities defined in m
      and accessible from other modules. If m is a developed machine,
      the list is taken from its corresponding implementation.
    '''
    assert machine["kind"] in { "Machine" }
    impl = machine["implementation"]
    return impl["concrete_constants"]+impl["variables"]+impl["operations"]


def path(dirname, module):
    """Builds path from directory path and module name."""
    return dirname + os.sep + module + '.bxml'
