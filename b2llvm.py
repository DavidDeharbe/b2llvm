#!/usr/bin/python
import argparse
import b2llvm.codebuf as codebuf
from b2llvm.translate import translate_bxml

progdescription='Generates LLVM code for a B module. In component mode, the generator produces type and function definitions corresponding to the state and operations of a given developed machine. In project mode, the generator instantiates the given module and all the instances of imported modules, and defines a function to link these modules and initialize their execution.'
parser = argparse.ArgumentParser(description=progdescription)
parser.add_argument('b_module',
                    help='name of the B module (machine)')
parser.add_argument('llvm_file',
                    help='output LLVM file name')
parser.add_argument('directory',
                    help='when set, the program will lookup files in that directory')
parser.add_argument('settings',
                    help='project settings file')
parser.add_argument('-m', '--mode', choices=['comp','proj'], default='comp',
                    help='Selects code generation mode.')
parser.add_argument('-t', '--trace', action='store_true',
                    help= 'enables emission of references to B source in LLVM code')
parser.add_argument('-p', '--emit-printer', action='store_true',
                    help= 'enables emission of LLVM functions that print the state of the components')
parser.add_argument('-v', '--verbose', action='store_true',
                    help= 'outputs some information while running')
args = parser.parse_args()
buf = codebuf.CodeBuffer(args.trace)
if (args.verbose):
    print("b2llvm code generation completed")
    print("- BXML directory: " + args.directory)
    print("- B project settings file: " + args.settings)
    print("- B module: " + args.b_module)
    print("- LLVM output file: " + args.llvm_file)
    print("- code generation mode: " + args.mode)
    print("- emits traceability information: " + str(args.trace))
    print("- emits printing functions: " + str(args.emit_printer))
translate_bxml(args.b_module, args.llvm_file, buf, mode=args.mode,
               dir=args.directory, settings=args.settings,
               emit_printer=args.emit_printer)
