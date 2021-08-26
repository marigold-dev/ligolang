(*open Trace
open Main_errors

*)

open Test_helpers

open Ast_imperative.Combinators

let init_env = Environment.default Environment.Protocols.current

let type_file f =
  type_file f Env options


let simple1 ~raise ~add_warning () : unit =
  let program = type_file ~raise ~add_warning "./contracts/simple1.ligo" in
  expect_eq_evaluate ~raise program "i" (e_int 42)

let main = test_suite "Zinc tests" [test_w "simple1" simple1 ]
