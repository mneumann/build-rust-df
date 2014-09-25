#!/bin/sh

PREFIX=/usr/local
WRK=`pwd`/work

# snapshot for: 2014-09-10
GH_COMMIT=6faa4f3

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
  git pull
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
  cd ${WRK}/rust
  gmake
  gmake snap-stage3
}

fetch
pre_configure_patch
do_configure
post_configure_patch
compile
