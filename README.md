Overview
--------
Simplipy *reduces the size* of a Python installation, for use in embedded systems where storage space is critical.


* **No performance impact** - it will not work faster because something was removed, nor will it work slower for the same reason.
* **Functionality is preserved** - Simplipy does what it does, mainly by avoiding data duplication, rather than by removing features. As a result, a "simplipied" Python will behave like a regular one, unless you take extra steps to strip out more bits.

This instrument is used by Dekart to make a slimmer version of Python for microcontrollers, these are applied in telemetry and industrial automation systems. For more details, have a look at http://telecontrol.md or http://dekart.md

What can be thrown out
----------------------
* Compiled `pyc` files are the only ones actually needed, everything else is optional.

 * Alternatively, `pyo` can be used, they are optimized `pyc` files and offer the same functionality. The difference is that they have no assertions inside them (which is not a problem for our needs)

* documentation in `share/`
* tests, usually located in subdirectories named `test` or `tests` inside `lib/python2.7`
* duplicated binaries in `bin/`: `python`, `python2` and `python2.7` have an identical hash and they are not symlinks to each other, therefore 2 out of these can be deleted without losing anything of value

If you desperately need more space, there's more you can remove:

* header files in `include/`, if you know you won't be tying Python to C or C++ code.
* modules you know won't use for your specific problem, ex: `wsgiref`, `email`, `lib-tk`, `ctypes`, etc. The usual suspects are:

 * `lib/idlelib/` - IDLE can go, an embedded system is not suitable for IDEs
 * `lib/distutils/` - you won't be using the system to create other modules
 * `lib/lib2to3/`




How to skin a python
--------------------

* **Suppress the creation of pyc**: Since `pyc` files are created automagically, you will eventually end up with `.py` and `.pyo` files, roughly doubling the space used by your Python distribution in the worst case (if all modules are used). You can suppress the generation of these files by calling Python with `-B`, or by setting the `PYTHONDONTWRITEBYTECODE` environment variable.
* **Generate the .pyc files then remove the original .py** - this will produce the `pyc`, thus calling the Python interpreter in a regular fashion will not cause other files to be created, hence your Python size will not grow.

Notes:

* The size of a `.py` and the corresponding `.pyc` is usually the same, sometimes the `pyc` is a bit bigger, sometimes it is the other way around. Therefore one can consider that space-wise, these approaches are equivalent. 
* A program doesn't run any faster when it is read from a ".pyc" or ".pyo" file than when it is read from a ".py" file; the only thing that's faster about ".pyc" or ".pyo" files is the speed with which they are loaded.
* The drawback of invoking the Python interpreter with `-B` is that it is likely that not everyone on the system is aware of that, hence .pyc files will be created because someone forgot about `-B` or the environment variable. Therefore approaches that cause less friction are preferred.

Metrics
=======
Here are some actual numbers that put things into perspective::

```
 alex@ralien ~/pyout $ find . -name "*.pyo" -ls | awk '{total += $7} END {print total}'
 9663502
 alex@ralien ~/pyout $ find . -name "*.pyc" -ls | awk '{total += $7} END {print total}'
 9704832
 alex@ralien ~/pyout $ find . -name "*.py" -ls | awk '{total += $7} END {print total}'
 10688590
```

 criteria   |   pyo  |   pyc  |   py    
------------|--------|--------|---------
 size       | 9.6 MB | 9.7 MB | 10.6 MB
 debugable  |  no    |  no    |  yes
 load speed | fast   | fast   | normal


* If you delete `py` files, you cannot see the source code of a module, though it is not a problem in the context of embedded systems.

Overall, Simplipy can provide a 50% reduction with its default settings::
```
 alex@ralien ~ $ du -hs ~/pyout-original
 98M	/home/alex/pyout-original
 alex@ralien ~ $ du -hs ~/pyout
 49M	/home/alex/pyout
```




Workflow
--------
1. compile Python from source
 * How to compile: http://www.diveintopython.net/installing_python/source.html
 * in this example it is assumed that everything goes into `/home/alex/pyout`
 * if you've done it all right, the directory will contain the following subdirectories: `bin  include  lib  share`
2. `simplipy.sh /home/alex/pyout` - run this and follow the on-screen action.
 * All the changes will be made in-place, therefore it might be a good idea to make a copy of the original directory, in case you'll need it later or wish to examine the differences.



References
----------
* http://stackoverflow.com/questions/8822335/what-does-python-file-extensions-pyc-pyd-pyo-stand-for
* http://effbot.org/pyfaq/how-do-i-create-a-pyc-file.htm
* http://stackoverflow.com/questions/850630/python-py-pyo-pyc-which-can-be-eliminated-for-an-embedded-system

Other projects with a similar objective:

* http://www.tinypy.org
* http://micropython.org/
* https://code.google.com/p/python-on-a-chip/

