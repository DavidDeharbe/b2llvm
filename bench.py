import example_01, example_02, example_03, example_04, example_05, example_06, example_07
import translate

tests_lib = [(example_01.root, "example-01-lib.llvm"),
             (example_02.root, "example-02-lib.llvm"),
             (example_03.root, "example-03-lib.llvm"),
             (example_04.root, "example-04-lib.llvm"),
             (example_05.root, "example-05-lib.llvm"),
             (example_06.root, "example-06-lib.llvm"),
             (example_07.counter_i, "example-07-counter.llvm")]

tests_top = [(example_01.root, "example-01-top.llvm"),
             (example_02.root, "example-02-top.llvm"),
             (example_03.root, "example-03-top.llvm"),
             (example_04.root, "example-04-top.llvm"),
             (example_05.root, "example-05-top.llvm"),
             (example_06.root, "example-06-top.llvm"),
             (example_07.wd_i, "example-07-top.llvm")]

all_tests = ([(test[0], test[1], False) for test in tests_lib] + 
             [(test[0], test[1], True) for test in tests_top])

def run_tests():
    for test in all_tests:
        if test[2]: kind = "(top)" 
        else: kind = "(lib)"
        print("producing file " + test[1] + " " + kind)
        translate.translate(test[0], test[1], test[2])
