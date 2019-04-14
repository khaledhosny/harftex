HarfTeX
=======

This is a “light” LuaTeX fork that bundles [luaharfbuzz][1], with some other
small changes to LuaTeX.

Building
--------

To generate the build scripts after freshly cloning the repository (requires
autoconf, automake and possibly other autotools packages):

    $ cd source
    $ ./reautoconf
    $ cd -

Then run the build script from the top level directory (see the comment at the
op of the script for a list of the options it take):

    $ ./build.sh


[1]: https://github.com/ufyTeX/luaharfbuzz
