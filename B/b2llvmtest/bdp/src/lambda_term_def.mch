/* lambda_term_def
 * Author: 
 * Creation date: 11/08/14
 */
MACHINE
    lambda_term_def
ABSTRACT_CONSTANTS
    next
PROPERTIES
    next = % arg . ( arg : INT | arg + 1 )
END
