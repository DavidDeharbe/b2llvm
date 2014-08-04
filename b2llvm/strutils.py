"""This module provides string-manipulating utilities.

- commas: function concatenating string separated with comas
- nconc: concatenates a list of strings
- NL: newline character
- SP: space character
- TB: represents a tabulation
- TB2: represents two tabulations
"""

def commas(string_list):
    '''
    Returns a comma-separated string of the given strings.
    '''
    return ", ".join(string_list)

def nconc(string_list):
    '''
    Concateantes the given strings.
    '''
    return "".join(string_list)

NL = "\n"
SP = " "
TB = "  "
TB2 = TB*2
