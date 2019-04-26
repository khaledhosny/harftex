[![Build Status](https://travis-ci.org/khaledhosny/harftex.svg?branch=master)](https://travis-ci.org/khaledhosny/harftex)

HarfTeX
=======

HarfTeX is a TeX engine based on LuaTeX and aims to combine the flexibility of
LuaTeX with comprehensive support world languages and writing systems
more-or-less out of box (à la XeTeX).

HarfTeX achieves this by including widely used text layout and font loading
libraries (such as [HarfBuzz][1] and ICU). That is while keeping the ability
for its users to replace the text layout engine.

Building
--------

Run the build script from the top level directory (see the comment at the op of
the script for a list of the options it take):

    $ ./build.sh


[1]: https://github.com/harfbuzz/harfbuzz
