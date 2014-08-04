"""
This module provides a class to store text produced during code generation.

The class is called CodeBuffer.

The constructor has a unique, Boolean, argument. If the argument is True, then
the code buffer will also store all traceability information passed to
it. Otherwise it will discard that information.

For a given CodeBuffer object buf, the available method calls are:

buf.code(template, args): adds to the code buffer the string template fill with
the given arguments.

buf.trace.out(str), buf.trace.outu(str), buf.trace.tab, buf.trace.untab: invokes
the corresponding methods offered by the b2llvm.trace to add to the code buffer
traceability information (if it has been activated in the constructor).

buf.contents(): returns all the text that has been added to the buffer.

"""
import math
from b2llvm.strutils import NL, SP
from b2llvm.trace import Tracer

class CodeBuffer:
    '''
    Class offering traceability support
    '''
    trace = None
    def __init__(self, activate):
        '''
        Constructor.

        Inputs:
        activate: a flag setting traceability generation.
        '''
        self.trace = Tracer(activate)

    def code(self, template, *args):
        """Appends text formed by filling template with args to the buffer."""
        self.trace.extend(bytearray(template.format(*args)))

    def contents(self):
        """Returns all the text put into the buffer so far"""
        return self.trace.text()
