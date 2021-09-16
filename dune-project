(lang dune 2.8)

(name ligo)

(using menhir 2.0)

(using coq 0.2)

(generate_opam_files true)

(source
 (github anchpop/ligolang))

(license MIT)

(authors "Galfour")

(maintainers "contact@ligolang.org")

(package
 (name ligo_slim)
 ; optional version override to allow single package point
 ; releases.
 (version 1.0.1)
 (synopsis "A version of the Ligo library with reduced features"))

(package
 (name ligo)
 (synopsis "A high-level language which compiles to Michelson")
 (depends
  (ligo_slim
   (= 1.0.1))
  (menhir
   (>= 20200624))
  (ocamlgraph
   (>= 2.0.0))
  (coq
   (and
    :build
    (>= 8.12)
    (< "8.13")))
  (ppx_deriving
   (>= 5.2.1))
  (ppx_deriving_yojson
   (>= 3.6.1))
  (ppx_expect
   (>= 0.14.1))
  (tezos-utils :dev)
  (proto-alpha-utils :dev)
  (ligo-008-PtEdo2Zk-test-helpers :~dev)
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
  (ParserLib
   (>= 1.0))
  (LexerLib
   (>= 1.1))
  (UnionFind
   (>= 1.0))
  (RedBlackTrees
   (>= 1.0))
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
    (>= 2.5.0)))))
