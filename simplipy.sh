#!/bin/bash

if [[ $1 = '' ]]; then
	echo "Missing arguments: simpliPy.sh <Python directory>

Example: simpliPy.sh ~/pyout"
	exit 1
fi

echo "Original size is"
du -hs $1

read -p "Press [Enter] to simplipy " -n1 -s


cd $1


echo "Running unit-tests" #add -v for verbosity
bin/python -m unittest discover --start-directory lib/python2.7

echo "Are you happy with the results?"
read -p "Press [Enter] to continue or ctrl+Z to abort " -n1 -s


echo "Remove all unit test directories" #named 'test' or 'tests' ...
find . -type d -name "test*" -print0 | xargs -0 rm -rf


#compile all the .py into .pyc
#Alternatively `python -O -m compileall -f .` to produce .pyo
echo "Compling .py files"
python -m compileall -f .


echo "Removing all the .py files ..."
find . -type f -name "*.py" -delete


echo "Removing all the .pyo files ..."
#OR remove all the .pyc files, if you used -O earlier
#find . -type f -name "*.pyc" -delete
find . -type f -name "*.pyo" -delete


echo "Removing duplicated binaries"
rm bin/python2.7 bin/python2


#remove the include/ directory if you don't plan calling Python
#from your C or C++ code
echo "Removing /include"
rm -rf include/


echo "Removing the man-pages"
rm -rf share/

echo "Done, the reduced size is:"
du -hs $1


echo "Running the simplipied version"
bin/python -c "import sys;print(sys.version)"