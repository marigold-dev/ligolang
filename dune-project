(lang dune 2.8)

(name ligo)

(using menhir 2.0)

(using coq 0.2)

(generate_opam_files true)

(source
 (uri "https://gitlab.com/ligolang/tezos"))

(bug_reports "https://gitlab.com/ligolang/tezos/issues")

(license MIT)

(authors "Galfour")

(maintainers "contact@ligolang.org")


(package
 (name ligo)
 (synopsis "A high-level language which compiles to Michelson")
 (depends
  (menhir
   (>= 20200624))
  (ocamlgraph
   (>= 2.0.0))
  (coq
   (and
    :build
    (>= 8.12)
    (< 8.13)))
  (ppx_deriving
   (>= 5.2.1))
  (ppx_deriving_yojson
   (>= 3.6.1))
  (ppx_expect
   (>= 0.14.1))
  (tezos-010-PtGRANAD-test-helpers
   (>= 10.2))
  (yojson
   (>= 1.7.0))
  (alcotest
   (and
    :with-test
    (>= 1.0)
    (< 1.1)))
  (getopt
   (>= 20120615))
  (terminal_size
   (>= 0.1.4))
  (pprint
   (>= 20200410))
  (linenoise
   (>= 1.3.1))
  (qcheck
   (>= 0.17))
  (ocaml-migrate-parsetree
   (= 2.1.0))
  (lwt
   (= 5.3.0))
  (bisect_ppx
   (and
    :dev
    (>= 2.5.0)))
  (tezos-base
   (>= 10.2))
  (tezos-crypto
   (>= 10.2))
  (tezos-micheline
   (>= 10.2))))
