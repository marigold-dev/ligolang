(* Use `dune build -w @zinctest --no-buffer` to run just the zinc tests! *)

open Test_helpers

(* Helpers *)

(* Compiling *)
let init_env = Environment.default Environment.Protocols.current

let to_zinc f = to_zinc f Env options

let blank_raise_and_warn f =
  f ~raise:Trace.{ raise = (fun _ -> assert false) } ~add_warning:(fun _ -> ())

(* Alcotest setup *)
let zinc_testable =
  Alcotest.testable
    (fun ppf zinc ->
      Fmt.pf ppf "%s" ([%derive.show: string Zinc.Types.zinc] zinc))
    [%derive.eq: string Zinc.Types.zinc]

let program_testable =
  Alcotest.testable
    (fun ppf zinc -> Fmt.pf ppf "%s" ([%derive.show: Zinc.Types.program] zinc))
    [%derive.eq: Zinc.Types.program]

let expect_program = Alcotest.(check program_testable)

let expect_simple_compile_to ~raise ~add_warning contract_file output () =
  let to_zinc = to_zinc ~raise ~add_warning in

  let contract = Printf.sprintf "./contracts/%s.ligo" contract_file in
  let zinc = to_zinc contract in
  expect_program
    (Printf.sprintf "compiling %s" contract_file)
    [ ("i", [ output ]) ]
    zinc

(* ================ *)
(* Tests *)

(*
  match zinc with
  | when x = v -> ()
  | _ -> failwith (Printf.sprintf "zinc compilation of %s seems wrong" contract)*)

let simple_1 = expect_simple_compile_to "simple1" (Num (Z.of_int 42))

let simple_2 = expect_simple_compile_to "simple2" (Num (Z.of_int 42))

let simple_3 = expect_simple_compile_to "simple3" (Num (Z.of_int 42))

let simple_4 = expect_simple_compile_to "simple4" (Num (Z.of_int 42))

let main =
  test_suite "Zinc tests"
    [
      test_w "simple1" simple_1;
      test_w "simple2" simple_2;
      test_w "simple3" simple_3;
      test_w "simple4" simple_4;
    ]
