#!/bin/sh
set -e
set -x

printf '' | opam switch create . ocaml-base-compiler.4.10.2 --no-install || true
eval $(opam config env)
