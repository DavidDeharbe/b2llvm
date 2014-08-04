"""Module responsible for representing B project settings.

B project settings inform what are the developed and base machines. For the
developed machine, the settings additionally record what is the corresponding
implementation.

"""
from b2llvm.strutils import commas
import xml.etree.ElementTree as ET

def text(elem, child):
    """Returns text of XML element child."""
    return elem.find(child).text

class BProject(object):
    '''
    Class representing B projects settings.
    '''
    def __init__(self, name):
        '''
        Constructor, takes as input the path of a bproject.xml file.
        '''
        root = ET.parse(name).getroot()
        implements = root.findall("./developed")
        self.implement = { text(e, "./machine"):text(e, "./implementation")
                           for e in implements }
        foreign = root.findall("./base")
        self.developed = self.implement.keys()
        self.base = { e.find("./machine").text for e in foreign }

    def is_developed(self, mach):
        ''' Tests if a machine is a developed machine.

        Inputs:
        - mach: a machine name
        Returns:
        True iff m is declared as developed.
        '''
        return mach in self.developed

    def is_base(self, mach):
        ''' Tests if a machine is a base machine.

        Inputs:
        - m: a machine name
        Returns:
        True iff m is declared as base.
        '''
        return mach in self.base

    def has(self, mach):
        ''' Tests if a machine belongs to a B project

        Inputs:
        - m: a machine name
        Returns:
        True if m is a developed or a base machine declared in project,
        False otherwise.
        '''
        return self.is_developed(mach) or self.is_base(mach)

    def implementation(self, mach):
        """Gets implementation of machine."""
        assert self.is_developed(mach)
        return self.implement[mach]

    def implements_str(self):
        "Return list of strings formed by each machine and implementation."
        return [ m + ":" + i for m, i in self.implement.items()]

    def __str__(self):
        return ("developed = {" + commas(self.developed) + "}\n" +
                "implement = {" + commas(self.implements_str()) + "}\n" +
                "base = {" + commas(self.base) + "}\n")
