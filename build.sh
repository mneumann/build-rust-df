#!/bin/sh

PREFIX=/usr/local
WRK=`pwd`/work

# snapshot for: 2014-09-05
GH_COMMIT=67b97ab

# XXX: Patch snapshot.py to download from ntecs.de
#export SNAPSHOT_FILE=`pwd`/rust-stage0-2014-08-29-6025926-dragonfly-x86_64-87b7d3d21de83dfe4c66a77fe7d3b85f14d97cf7.tar.bz2

fetch()
{
  mkdir -p ${WRK}
  if [ ! -e ${WRK}/rust ]; then
    cd ${WRK}
    git clone https://github.com/rust-lang/rust.git
    cd rust
    git submodule init
    git submodule update
  fi
  cd ${WRK}/rust
  git checkout -f ${GH_COMMIT}
  cd ${WRK}
}

pre_configure_patch()
{
  cd ${WRK}/rust
  patch -p1 < ${WRK}/../files/pre-configure.patch
}

do_configure()
{
  cd ${WRK}/rust
  ./configure --prefix=${PREFIX}
}

post_configure_patch()
{
  cd ${WRK}/rust
  cd src/llvm
  patch -p1 < ${WRK}/../files/llvm.patch
  cd ../jemalloc
  patch -p1 < ${WRK}/../files/jemalloc.patch
  cd ../..
}

compile()
{
  gmake
  gmake snap-stage3
}

fetch

pre_configure_patch

do_configure

post_configure_patch

#compile
