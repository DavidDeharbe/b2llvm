#
# This is a crude script to generate coverage data from the set of benchmarks
# that we currently have.
# It relies on the installation of the Python script "coverage"
# https://bitbucket.org/ned/coveragepy
#
#!/bin/bash
COV_RUN="coverage run --source=b2llvm.py,b2llvm -p"
echo "Cleaning up existing coverage data."
coverage erase
echo "Generating new coverage data."
$COV_RUN ./b2llvm.py -v -m comp counter counter.llvm bxml project.xml > /dev/null
$COV_RUN ./b2llvm.py -m comp enumeration enumeration.llvm bxml project.xml
$COV_RUN ./b2llvm.py -m comp array array.llvm bxml project.xml
$COV_RUN ./b2llvm.py -m comp ioint ioint.llvm bxml project.xml
$COV_RUN ./b2llvm.py -m comp counter counter.llvm bxml project.xml
$COV_RUN ./b2llvm.py -m comp wd wd.llvm bxml project.xml
$COV_RUN ./b2llvm.py -m comp timer timer.llvm bxml project.xml
$COV_RUN ./b2llvm.py -m proj counter init-counter.llvm bxml project.xml
$COV_RUN ./b2llvm.py -m proj wd init-wd.llvm bxml project.xml
$COV_RUN ./b2llvm.py -m proj timer init-timer.llvm bxml project.xml
$COV_RUN ./b2llvm.py -t -m comp ioint ioint.llvm bxml project.xml
$COV_RUN ./b2llvm.py -t -m comp counter counter.llvm bxml project.xml
$COV_RUN ./b2llvm.py -t -m comp wd wd.llvm bxml project.xml
$COV_RUN ./b2llvm.py -t -m comp timer timer.llvm bxml project.xml
$COV_RUN ./b2llvm.py -t -m proj counter init-counter.llvm bxml project.xml
$COV_RUN ./b2llvm.py -t -m proj wd init-wd.llvm bxml project.xml
$COV_RUN ./b2llvm.py -t -m proj timer init-timer.llvm bxml project.xml
$COV_RUN ./b2llvm.py -p -t -m comp ioint ioint.llvm bxml project.xml
$COV_RUN ./b2llvm.py -p -t -m comp counter counter.llvm bxml project.xml
$COV_RUN ./b2llvm.py -p -t -m comp timer timer.llvm bxml project.xml
$COV_RUN ./b2llvm.py -p -t -m comp wd wd.llvm bxml project.xml
$COV_RUN ./b2llvm.py -p -t -m proj wd wd.llvm bxml project.xml
#$COV_RUN ./b2llvm.py -p -t -m proj array array.llvm bxml project.xml
echo "Combining coverage data."
coverage combine
echo "Generating coverage report."
coverage html -d coverage_html
open coverage_html/index.html
echo "Coverage report is now available."
