###
#
# b2llvm.names
#
# Module for generating LLVM identifiers.
#
###

llvm_local_var_counter = 0
llvm_label_counter = 0

def new_local():
    '''
    Input: None
    Output: A string representing a LLVM local variable. This string
    is composed by the prefix "%" followed by a number. Function
    reset_llvm_names is responsible for zeroing that number.
    '''
    global llvm_local_var_counter
    result = "%"+str(llvm_local_var_counter)
    llvm_local_var_counter += 1
    return result

def new_label():
    '''
    Input: None
    Output: A string representing a LLVM instruction label. This string
    is composed by the prefix "label" followed by a number. Function
    reset_llvm_names is responsible for zeroing that number.
    '''
    global llvm_label_counter
    result = "label"+str(llvm_label_counter)
    llvm_label_counter += 1
    return result

def reset():
    '''
    Output: None
    The role of this function is to zero the counters used to build
    label and local variable identifiers.
    '''
    global llvm_local_var_counter, llvm_label_counter
    llvm_local_var_counter = 0
    llvm_label_counter = 0
