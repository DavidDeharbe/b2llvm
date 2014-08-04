B2LLVM = ./b2llvm.py
LLVM_AS = llvm-as-mp-3.1
LLVM_LINK = llvm-link-mp-3.1

%.llvm : bxml/%.bxml
	$(B2LLVM) $* $@ bxml project.xml

init-%.llvm : bxml/%.bxml
	$(B2LLVM) --mode proj $* $@ bxml project.xml

%.bc : %.llvm
	$(LLVM_AS) $< -o $@

bxml/counter.bxml: bxml/counter_i.bxml
	touch bxml/counter.bxml

bxml/wd.bxml: bxml/wd_i.bxml
	touch bxml/wd.bxml

bxml/timer.bxml: bxml/timer_i.bxml
	touch bxml/timer.bxml

bxml/enumeration.bxml: bxml/enumeration_i.bxml
	touch bxml/enumeration.bxml

enumeration: enumeration.bc scaffold-enumeration.bc init-enumeration.bc
	$(LLVM_LINK) $^ -o $@

counter: counter.bc scaffold-counter.bc init-counter.bc
	$(LLVM_LINK) $^ -o $@

wd: counter.bc wd.bc init-wd.bc scaffold-wd.bc
	$(LLVM_LINK) $^ -o $@

timer: counter.bc timer.bc init-timer.bc scaffold-timer.bc
	$(LLVM_LINK) $^ -o $@

all: counter wd timer

clean:
	rm *.bc
