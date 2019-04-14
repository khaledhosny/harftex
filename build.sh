#!/usr/bin/env bash
#
# Copyright (c) 2005-2011 Martin Schröder <martin@luatex.org>
# Copyright (c) 2009-2014 Taco Hoekwater <taco@luatex.org>
# Copyright (c) 2012-2014 Luigi Scarso   <luigi@luatex.org>
#
# Permission to use, copy, modify, and distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
# WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
# ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
# WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
# ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
# OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
#
# new script to build harftex binaries
# ----------
# Options:
#      --buildtag= : build directory <- 'build'-<tag>
#      --make      : only make, no make distclean; configure
#      --parallel  : make -j 8 -l 8.0
#      --nostrip   : do not strip binary
#      --warnings= : enable compiler warnings
#      --mingw[32] : crosscompile for mingw32
#      --mingw64   : crosscompile for mingw64
#      --host=     : target system for mingw32 cross-compilation
#      --build=    : build system for mingw32 cross-compilation
#      --arch=     : crosscompile for ARCH on OS X
#      --clang     : use clang & clang++
#      --debug     : CFLAGS="-g -O0" --warnings=max --nostrip
#      --debugopt  : CFLAGS="-g -O3" --warnings=max --nostrip
#      --stripbin  : strip program to use (default strip)
#      --tlopt     : option to pass to TeXLive configure
$DEBUG
#export CFLAGS="-D_FORTIFY_SOURCE=2 -O3"
#export CXXFLAGS="-D_FORTIFY_SOURCE=2 -O3"

# try to find bash, in case the standard shell is not capable of
# handling the generated configure's += variable assignments
if which bash >/dev/null
then
 CONFIG_SHELL=`which bash`
 export CONFIG_SHELL
fi

# try to find gnu make; we may need it
MAKE="make V=0"
if make -v 2>&1| grep "GNU Make" >/dev/null
then 
  echo "Your make is a GNU-make; I will use that"
elif gmake -v >/dev/null 2>&1
then
  MAKE=gmake;
  export MAKE;
  echo "You have a GNU-make installed as gmake; I will use that"
else
  echo "I can't find a GNU-make; I'll try to use make and hope that works." 
  echo "If it doesn't, please install GNU-make."
fi

BUILDTAG=
ONLY_MAKE=FALSE
STRIP_HARFTEX=TRUE
WARNINGS=yes
MINGW=FALSE
MINGWCROSS32=FALSE
MINGWCROSS64=FALSE
MACCROSS=FALSE
CLANG=FALSE
CONFHOST=
CONFBUILD=
JOBS_IF_PARALLEL=${JOBS_IF_PARALLEL:-8}
MAX_LOAD_IF_PARALLEL=${MAX_LOAD_IF_PARALLEL:-8}
TARGET_CC=gcc
TARGET_TCFLAGS=
STRIPBIN=
TEXLIVEOPT=

CFLAGS="$CFLAGS"
CXXFLAGS="$CXXFLAGS"


until [ -z "$1" ]; do
  case "$1" in
    --arch=*		) MACCROSS=TRUE; ARCH=`echo $1 | sed 's/--arch=\(.*\)/\1/' ` ;;
    --build=*		) CONFBUILD="$1"     ;;
    --buildtag=*	) BUILDTAG="$1"      ;;
    --clang		) export CC=clang; export CXX=clang++ ; TARGET_CC=$CC ; CLANG=TRUE ;;
    --debug		) STRIP_HARFTEX=FALSE; WARNINGS=max ; CFLAGS="-O0 -g -ggdb3 $CFLAGS" ; CXXFLAGS="-O0 -g -ggdb3 $CXXFLAGS"  ;;
    --debugopt		) STRIP_HARFTEX=FALSE; WARNINGS=max ; CFLAGS="-O3 -g -ggdb3 $CFLAGS" ; CXXFLAGS="-O3 -g -ggdb3 $CXXFLAGS"  ;;
    --host=*		) CONFHOST="$1"      ;;
    --make		) ONLY_MAKE=TRUE     ;;
    --mingw|--mingw32	) MINGWCROSS32=TRUE  ;;
    --mingw64		) MINGWCROSS64=TRUE  ;;
    --nostrip		) STRIP_HARFTEX=FALSE ;;
    --parallel		) MAKE="$MAKE -j $JOBS_IF_PARALLEL -l $MAX_LOAD_IF_PARALLEL" ;;
    --stripbin=*	) STRIPBIN="$1"      ;;
    --tlopt=*		) TEXLIVEOPT=`echo $1 | sed 's/--tlopt=\(.*\)/\1/' `         ;;
    --warnings=*	) WARNINGS=`echo $1 | sed 's/--warnings=\(.*\)/\1/' `        ;;
    *			) echo "ERROR: invalid build.sh parameter: $1"; exit 1       ;;
  esac
  shift
done

#
STRIP=strip
HARFTEXEXE=harftex

case `uname` in
  CYGWIN*	) HARFTEXEXE=harftex.exe ;;
  MINGW*	) HARFTEXEXE=harftex.exe ;;
  Darwin	) STRIP="strip -u -r" ;;
esac

WARNINGFLAGS=--enable-compiler-warnings=$WARNINGS

B=build

if [ "x$CONFHOST" != "x" ]
then
 B="build-$CONFHOST"
 B=`printf "$B"| sed 's/--host=//'`
fi

if [ "$CLANG" = "TRUE" ]
then
  B="$B-clang"
fi

if [ "x$BUILDTAG" != "x" ]
then
  B="${BUILDTAG#--buildtag=}"
fi


OLDPATH=$PATH
if [ "$MINGWCROSS32" = "TRUE" ]
then
  B=build-windows32
  : ${CONFHOST:=--host=i686-w64-mingw32}
  CFLAGS="-Wno-unknown-pragmas -mtune=nocona -g -O3 $CFLAGS"
  CXXFLAGS="-Wno-unknown-pragmas -mtune=nocona -g -O3 $CXXFLAGS"
  LDFLAGS="-Wl,--large-address-aware -Wl,--stack,2621440 $CFLAGS"
  export CFLAGS CXXFLAGS LDFLAGS
fi
if [ "$MINGWCROSS64" = "TRUE" ]
then
  B=build-windows64
  : ${CONFHOST:=--host=x86_64-w64-mingw32}
  CFLAGS="-Wno-unknown-pragmas -mtune=nocona -g -O3 -fno-lto -fno-use-linker-plugin $CFLAGS"
  CXXFLAGS="-Wno-unknown-pragmas -mtune=nocona -g -O3 -fno-lto -fno-use-linker-plugin $CXXFLAGS"
  LDFLAGS="${LDFLAGS} -fno-lto -fno-use-linker-plugin -static-libgcc -static-libstdc++"
  export CFLAGS CXXFLAGS LDFLAGS
fi
if [ "$MINGWCROSS32" = "TRUE" ] || [ "$MINGWCROSS64" = "TRUE" ]
then
  case `uname -s` in
    Linux)  platform="x86_64-linux"; build_tripple="x86_64-unknown-linux-gnu" ;;
    Darwin) platform="x86_64-darwin"; build_tripple="x86_64-apple-darwin" ;;
  esac

  : ${CONFBUILD:=--build=$build_tripple}
  PATH=`pwd`/extrabin/mingw/$platform:/usr/mingw32/bin:$PATH
  HARFTEXEXE=harftex.exe
  RANLIB="${CONFHOST#--host=}-ranlib"
  STRIP="${CONFHOST#--host=}-strip"
fi

if [ "$MACCROSS" = "TRUE" ]
then
  # make sure that architecture parameter is valid
  case $ARCH in
    i386 | x86_64 | ppc | ppc64 ) ;;
    * ) echo "ERROR: architecture $ARCH is not supported"; exit 1;;
  esac
  B=build-$ARCH
  if [ "x$CONFHOST" != "x" ]
    then
    B="build-$CONFHOST"
    B=`printf "$B"| sed 's/--host=//'`
  fi
  CFLAGS="-arch $ARCH -g -O2 $CFLAGS"
  CXXFLAGS="-arch $ARCH -g -O2 $CXXFLAGS"
  LDFLAGS="-arch $ARCH $LDFLAGS" 
  STRIP="${CONFHOST#--host=}-strip -u -r -A -n"
  #STRIP="${CONFHOST#--host=}-strip"
  export CFLAGS CXXFLAGS LDFLAGS
fi


if [ "x$STRIPBIN" != "x" ]
then
 STRIP="${STRIPBIN#--stripbin=}"
fi


if [ "$STRIP_HARFTEX" = "FALSE" ]
then
    export CFLAGS
    export CXXFLAGS
fi

# ----------
# clean up, if needed
if [ -r "$B"/Makefile -a $ONLY_MAKE = "FALSE" ]
then
  rm -rf "$B"
elif [ ! -r "$B"/Makefile ]
then
    ONLY_MAKE=FALSE
fi
if [ ! -r "$B" ]
then
  mkdir "$B"
fi

cd "$B"

if [ "$ONLY_MAKE" = "FALSE" ]
then
TL_MAKE=$MAKE ../source/configure  $TEXLIVEOPT $CONFHOST $CONFBUILD  $WARNINGFLAGS\
    --enable-silent-rules \
    --disable-all-pkgs \
    --disable-shared    \
    --disable-largefile \
    --disable-ipc \
    --disable-dump-share \
    --enable-coremp  \
    --enable-web2c  \
    --enable-harftex \
   || exit 1 
fi


$MAKE
(cd texk/web2c; $MAKE $HARFTEXEXE )  || exit $?

# go back
cd ..

if [ "$STRIP_HARFTEX" = "TRUE" ] ;
then
  $STRIP "$B"/texk/web2c/$HARFTEXEXE
else
  echo "harftex binary not stripped"
fi

if [ "$MINGWCROSS32" = "TRUE" ] || [ "$MINGWCROSS64" = "TRUE" ]
then
  PATH=$OLDPATH
fi

# show the result
ls -l "$B"/texk/web2c/$HARFTEXEXE
