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

let expect_simple_compile_to ?reason:(enabled = false) ~raise ~add_warning
    contract_file (output : Zinc.Types.program) () =
  let to_zinc = to_zinc ~raise ~add_warning in

  let contract =
    Printf.sprintf "./contracts/%s.%s" contract_file
      (if enabled then "religo" else "ligo")
  in
  let zinc = to_zinc contract in
  expect_program (Printf.sprintf "compiling %s" contract_file) output zinc

(* ================ *)
(* Tests *)

(*
  match zinc with
  | when x = v -> ()
  | _ -> failwith (Printf.sprintf "zinc compilation of %s seems wrong" contract)*)

let simple_1 =
  expect_simple_compile_to "simple1" [ ("i", [ Num (Z.of_int 42); Return ]) ]

let simple_2 =
  expect_simple_compile_to "simple2" [ ("i", [ Num (Z.of_int 42); Return ]) ]

let simple_3 =
  expect_simple_compile_to "simple3"
    [
      ("my_address", [ Address "tz1KqTpEZ7Yob7QbPE4Hy4Wo8fHG8LhKxZSx"; Return ]);
    ]

let simple_4 =
  expect_simple_compile_to "simple4"
    [
      ( "my_option_string",
        [
          Bytes (Bytes.of_string "\202\254\186\190");
          Unpack (T_base TB_string);
          Return;
        ] );
    ]

let id =
  expect_simple_compile_to "id_func" [ ("id", [ Grab; Access 0; Return ]) ]

let chain_id =
  expect_simple_compile_to "chain_id" [ ("chain_id", [ ChainID; Return ]) ]

let chain_id_func =
  expect_simple_compile_to "chain_id_func"
    [ ("chain_id", [ Grab; ChainID; Return ]) ]

let tuple_creation =
  expect_simple_compile_to "tuple_creation"
    [
      ( "dup",
        [
          Grab;
          Access 0;
          Access 0;
          MakeRecord
            Stage_common.Types.
              [ (Label "0", T_base TB_int); (Label "1", T_base TB_int) ];
          Return;
        ] );
    ]

let check_hash_key =
  expect_simple_compile_to "key_hash"
    [
      ( "check_hash_key",
        [
          Grab;
          Access 0;
          Grab;
          Access 0;
          Grab;
          Access 0;
          RecordAccess (Label "1");
          Grab;
          Access 1;
          RecordAccess (Label "0");
          Grab;
          Access 1;
          HashKey;
          Grab;
          Access 0;
          Access 0;
          Access 1;
          Eq;
          MakeRecord
            [ (Label "0", T_base TB_bool); (Label "1", T_base TB_key_hash) ];
          EndLet;
          EndLet;
          EndLet;
          EndLet;
          Return;
        ] );
    ]

let basic_function_application =
  expect_simple_compile_to ~reason:true "basic_function_application" [ ("a", [(Num (Z.of_int 3)); Grab; (Access 0); Return])]

let main =
  test_suite "Zinc tests"
    [
      test_w "simple1" simple_1;
      test_w "simple2" simple_2;
      test_w "simple3" simple_3;
      test_w "simple4" simple_4;
      test_w "id" id;
      test_w "chain_id" chain_id;
      test_w "chain_id_func" chain_id_func;
      test_w "tuple_creation" tuple_creation;
      test_w "check_hash_key" check_hash_key;
      test_w "basic_function_application" basic_function_application;
    ]
