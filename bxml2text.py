tests_bxml = ['bxml/counter_i.bxml', 'bxml/swap_i.bxml']

import loadbxml
import printer

def test_load_bxml():
  for test in tests_bxml:
    n = loadbxml.load_implementation(test)
    ascii = printer.implementation(n)
    print(ascii)

