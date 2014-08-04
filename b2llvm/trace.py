"""This module is responsible for providing support for traceability.

Traceability is obtained by insering comments in the generated LLVM code.
For readability purposes, these comments are numbered. The numbered are
tiered, e.g. ... 2.3, 2.3.1, 2.3.2, 2.3.3, 2.4, 2.4.1 ...
The comments are produced line-by-line.

- INI initializes the module, indicating if traceability is active or not
- TAB adds a tier to the numbering scheme
- UNTAB removes a tier to the numbering scheme
- OUT adds a newly-numbered comment line
- OUTU adds a non-numbered comment line

"""
import math
from b2llvm.strutils import NL, SP

class Tracer(object):
    '''
    Class offering traceability support
    '''
    def __init__(self, activate):
        '''
        Constructor.

        Inputs:
        activate: a flag setting traceability generation.
        '''
        self._tiers = [0]
        self._active = activate
        self._text = bytearray()

    def _spacing(self):
        """Whitespace string the width of the current index"""
        global SP
        return " ".join([nb_digits(i)*SP for i in self._tiers])

    def _numbering(self):
        """String corresponding to the current index."""
        return ".".join([str(i) for i in self._tiers])

    def outu(self, msg):
        """Outputs a non-numbered one-line traceability message"""
        global NL
        if self._active:
            self._text.extend(bytearray(";;"+SP+self._spacing()+SP+msg+NL))

    def out(self, msg):
        """Outputs a numbered one-line traceability message."""
        global NL
        if self._active:
            last = self._tiers.pop()
            self._tiers.append(last+1)
            self._text.extend(bytearray(";;"+self._numbering()+SP+msg+NL))

    def extend(self, msg):
        self._text.extend(msg)

    def tab(self):
        """Adds a tier to the traceability index."""
        if self._active:
            self._tiers.append(0)

    def untab(self):
        """Removes a tier from the traceability index."""
        if self._active:
            self._tiers.pop()

    def text(self):
        return str(self._text)

def nb_digits(number):
    """Yields the number of digits in given non-negative integer."""
    if number == 0:
        return 1
    else:
        return int(math.floor(math.log(number, 10))+1)

