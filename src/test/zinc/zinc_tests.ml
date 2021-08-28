open Test_helpers

(* Helpers *)

(* Compiling *)
let init_env = Environment.default Environment.Protocols.current

let type_file f = type_file f Env options

(* Alcotest setup *)
(*
let zinc_testable =
  Alcotest.testable
    (fun ppf zinc -> Fmt.pf ppf "%s" ((assert false) zinc))
    (fun a b -> assert false)
*)
(* ================ *)
(* Tests *)

let simple1 ~raise ~add_warning i v () : unit =
  let contract = Printf.sprintf "./contracts/simple%d.ligo" i in
  let typed = type_file ~raise ~add_warning contract in
  let zinc = Ligo_compile.Zinc_of_typed.compile ~raise (typed |> fst) in
  match zinc with
  | [ ("i", [ x ]) ] when x = v -> ()
  | _ -> failwith (Printf.sprintf "zinc compilation of %s seems wrong" contract)

let main =
  test_suite "Zinc tests"
    [
      test_w "simple1" (simple1 1 (Num (Z.of_int 42)));
      test_w "simple2" (simple1 2 (Num (Z.of_int 42)));
      test_w "simple3" (simple1 3 (Num (Z.of_int 42)));
      test_w "simple4" (simple1 4 (Num (Z.of_int 42)));
    ]
