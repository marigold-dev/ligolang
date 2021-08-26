#!/bin/sh
set -e

"$(dirname "$0")"/setup_switch.sh

opam install -y ocamlformat ocaml-lsp-server alcotest-lwt crowbar 
opam -y user-setup install
