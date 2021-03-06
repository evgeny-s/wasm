#!/usr/bin/env bash
# Copyright 2019-2020 @polkadot/wasm authors & contributors
# This software may be modified and distributed under the terms
# of the Apache-2.0 license. See the LICENSE file for details.

set -e

# wasm2js for wasm -> asm.js
BINARYEN=( "wasm-opt" "wasm2js" )

unamestr=`uname`

# install wasm-pack as required
if ! [ -x "$(command -v wasm-pack)" ]; then
  echo "*** Installing wasm-pack"
  curl https://rustwasm.github.io/wasm-pack/installer/init.sh -sSf | sh
fi

# CI, Linux
if [[ "$unamestr" == 'Linux' ]]; then
  if [ ! -d "binaryen" ]; then
    echo "*** Downloading binaryen"
    curl -L https://github.com/WebAssembly/binaryen/releases/download/version_91/binaryen-version_91-x86-linux.tar.gz | tar xz
    mkdir -p binaryen/bin

    for BIN in "${BINARYEN[@]}"; do
      mv binaryen-version_91/$BIN binaryen/bin
    done
  fi
else
  # install binaryen as required
  if [ ! -d "binaryen" ]; then
    echo "*** Cloning binaryen"
    git clone --recursive https://github.com/WebAssembly/binaryen.git
    rm -rf binaryen/test
  fi

  for BIN in "${BINARYEN[@]}"; do
    if [ ! -f "binaryen/bin/$BIN" ]; then
      echo "*** Building $BIN"
      cd binaryen
      cmake . && make $BIN
      cd ..
    fi
  done
fi

