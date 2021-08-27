open Test_helpers
(* open Ast_imperative.Combinators *)

let init_env = Environment.default Environment.Protocols.current

let type_file f = type_file f Env options

let simple1 ~raise ~add_warning () : unit =
  let should_be = 42 in
  let typed = type_file ~raise ~add_warning "./contracts/simple1.ligo" in
  let zinc = Ligo_compile.Zinc_of_typed.compile ~raise (typed |> fst) in
  match zinc with
  | [ ("i", [ Num x ]) ] when x = Z.of_int should_be -> ()
  | [ ("i", [ Num x ]) ] ->
      failwith
        (Printf.sprintf
           "zinc compilation seems a little wrong - got %s instead of %d"
           (Z.to_string x) should_be)
  | _ -> failwith "zinc compilation seems totally wrong"

let main = test_suite "Zinc tests" [ test_w "simple1" simple1 ]
