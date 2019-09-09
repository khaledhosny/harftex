***Use LuaTeX HarfBuzz variant, luahbtex, instead.***

[![Build Status](https://travis-ci.org/khaledhosny/harftex.svg?branch=master)](https://travis-ci.org/khaledhosny/harftex)

HarfTeX
=======

HarfTeX is a TeX engine based on LuaTeX and aims to combine the flexibility of
LuaTeX with comprehensive support world languages and writing systems
more-or-less out of box (à la XeTeX).

HarfTeX achieves this by including widely used text layout and font loading
libraries (such as [HarfBuzz][1] and ICU). That is while keeping the ability
for its users to replace the text layout engine.

Background
----------

LuaTeX does not provide native support for text layout other than what TeX
originally provided, and instead provide hooks to its internals and Lua
scripting capabilities that allow users (or macro packages) to provide such
support.

While this is a worthwhile goal, the complexity of text layout and font
processing means developing such support from scratch is a complex,
time-consuming task that also needs active ongoing development. This resulted
in practically having only one text layout engine for LuaTeX written by the
ConTeXt team (available through the [`luaotfload`][2] package for LaTeX and
Plain TeX). Though it is a very capable engine, it falls short of supporting
many world writing systems or some advanced text layout capabilities.

HarfTeX started as an attempt to integrate the HarfBuzz text layout library
into LuaTeX as a Lua module and a Lua support package, allowing users to
benefit from a mature, well supported and featureful text layout engine.
However, the LuaTeX team preferred to avoid the extra dependencies and
suggested building a separate engine instead.

Building
--------

Run the build script from the top level directory (see the comment at the op of
the script for a list of the options it take):

    $ ./build.sh


[1]: https://github.com/harfbuzz/harfbuzz
[2]: https://github.com/u-fischer/luaotfload
