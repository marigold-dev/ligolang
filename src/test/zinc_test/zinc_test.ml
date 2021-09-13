(* Use `dune build -w @zinctest --no-buffer` to run just the zinc tests! *)

open Test_helpers

(* Helpers *)

(* Compiling *)
let init_env = Environment.default Environment.Protocols.current

let to_zinc f = to_zinc f Env options

let blank_raise_and_warn f =
  f ~raise:Trace.{ raise = (fun _ -> assert false) } ~add_warning:(fun _ -> ())

(* Alcotest setup *)

let expect_program =
  Alcotest.(
    check
      (Alcotest.testable
         (fun ppf program -> Fmt.pf ppf "%a" Zinc.Types.pp_program program)
         Zinc.Types.equal_program))

let expect_code =
  Alcotest.(
    check
      (Alcotest.testable
         (fun ppf zinc -> Fmt.pf ppf "%a" Zinc.Types.pp_zinc zinc)
         Zinc.Types.equal_zinc))

let expect_env =
  Alcotest.(
    check
      (Alcotest.testable
         (fun ppf env -> Fmt.pf ppf "%a" Zincing.Interpreter.pp_env env)
         Zincing.Interpreter.equal_env))

let expect_stack =
  Alcotest.(
    check
      (Alcotest.testable
         (fun ppf stack -> Fmt.pf ppf "%a" Zincing.Interpreter.pp_stack stack)
         Zincing.Interpreter.equal_stack))

let expect_simple_compile_to ?reason:(enabled = false) ?(index = 0)
    ?(initial_stack = []) ?code ?env ?stack ~raise ~add_warning contract_file
    (expected_zinc : Zinc.Types.program) () =
  let to_zinc = to_zinc ~raise ~add_warning in
  let contract =
    Printf.sprintf "./contracts/%s.%s" contract_file
      (if enabled then "religo" else "ligo")
  in
  let zinc = to_zinc contract in
  let () =
    expect_program
      (Printf.sprintf "compiling %s" contract_file)
      expected_zinc zinc
  in
  let output_code, output_env, output_stack =
    List.nth_exn zinc index |> snd
    |> Zincing.Interpreter.initial_state ~initial_stack
    |> Zincing.Interpreter.apply_zinc
  in
  let () =
    match code with
    | Some expected_code ->
        expect_code
          (Printf.sprintf "evaluating code for %s" contract_file)
          expected_code output_code
    | None -> ()
  in
  let () =
    match env with
    | Some expected_zinc ->
        expect_env
          (Printf.sprintf "evaluating env for %s" contract_file)
          expected_zinc output_env
    | None -> ()
  in
  let () =
    match stack with
    | Some expected_stack ->
        expect_stack
          (Printf.sprintf "evaluating stack for %s" contract_file)
          expected_stack output_stack
    | None -> ()
  in
  ()

(* ================ *)
(* Tests *)

let simple_1 =
  expect_simple_compile_to "simple1"
    [ ("i", [ Num (Z.of_int 42); Return ]) ]
    ~stack:[ `Z (Num (Z.of_int 42)) ]

let simple_2 =
  expect_simple_compile_to "simple2"
    [ ("i", [ Num (Z.of_int 42); Return ]) ]
    ~stack:[ `Z (Num (Z.of_int 42)) ]

let simple_3 =
  expect_simple_compile_to "simple3"
    [
      ("my_address", [ Address "tz1KqTpEZ7Yob7QbPE4Hy4Wo8fHG8LhKxZSx"; Return ]);
    ]
    ~stack:[ `Z (Address "tz1KqTpEZ7Yob7QbPE4Hy4Wo8fHG8LhKxZSx") ]

(*let simple_4 =
  expect_simple_compile_to "simple4"
    [
      ( "my_option_string",
        [
          Bytes (Bytes.of_string "\202\254\186\190");
          Unpack (T_base TB_string);
          Return;
        ] );
    ]*)

let id =
  expect_simple_compile_to "id_func"
    [ ("id", [ Grab; Access 0; Return ]) ]
    ~initial_stack:[ `Z (Num (Z.of_int 42)) ]
    ~stack:[ `Z (Num (Z.of_int 42)) ]

let chain_id =
  expect_simple_compile_to "chain_id"
    [ ("chain_id", [ ChainID; Return ]) ]
    ~stack:
      [
        `Z
          (let h =
             Digestif.BLAKE2B.hmac_string ~key:"???" "chain id hash here!"
           in
           Zinc.Types.Hash h);
      ]

let chain_id_func =
  expect_simple_compile_to "chain_id_func"
    [ ("chain_id", [ Grab; ChainID; Return ]) ]
    ~initial_stack:[ Zincing.Interpreter.Utils.unit_record ]

let tuple_creation =
  let open Zinc.Types in
  let open Stage_common.Types in
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
    ~initial_stack:[ `Z (Num Z.one) ]
    ~stack:
      [
        `Record
          LMap.(
            let one = `Z (Num Z.one) in
            empty |> add (Label "0") one |> add (Label "1") one);
      ]

let check_record_destructure =
  let open Zinc.Types in
  expect_simple_compile_to "check_record_destructure"
    [
      ( "check_record_destructure",
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
          Access 0;
          Add;
          EndLet;
          EndLet;
          EndLet;
          Return;
        ] );
    ]
    ~initial_stack:
      Stage_common.Types.LMap.
        [
          `Record
            (let one = `Z (Num Z.one) in
             empty |> add (Label "0") one |> add (Label "1") one);
        ]

let check_hash_key =
  let open Zinc.Types in
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
    ~initial_stack:
      Stage_common.Types.LMap.
        [
          `Record
            (empty
            |> add (Label "0")
                 (`Z
                   (let h =
                      Digestif.BLAKE2B.hmac_string ~key:"???" "hashy hash!"
                    in
                    Zinc.Types.Hash h))
            |> add (Label "1") (`Z (Key "Hashy hash!")));
        ]

let basic_function_application =
  expect_simple_compile_to ~reason:true "basic_function_application"
    [ ("a", [ Num (Z.of_int 3); Grab; Access 0; Return ]) ]
    ~stack:[ `Z (Num (Z.of_int 3)) ]

let basic_link =
  expect_simple_compile_to ~reason:true "basic_link"
    [
      ("a", [ Num (Z.of_int 1); Return ]);
      ("b", [ Num (Z.of_int 1); Grab; Access 0; Return ]);
    ]
    ~index:1
    ~stack:[ `Z (Num (Z.of_int 1)) ]

let _main =
  test_suite "Zinc tests"
    [
      test_w "simple1" simple_1;
      test_w "simple2" simple_2;
      test_w "simple3" simple_3;
      (*test_w "simple4" simple_4;*)
      test_w "id" id;
      test_w "chain_id" chain_id;
      test_w "chain_id_func" chain_id_func;
      test_w "tuple_creation" tuple_creation;
      test_w "check_record_destructure" check_record_destructure;
      test_w "check_hash_key" check_hash_key;
      test_w "basic_function_application" basic_function_application;
      test_w "basic_link" basic_link;
    ]

let main =
  test_suite "Zinc tests"
    [
      test_w "simple1" simple_1;
      test_w "simple2" simple_2;
      test_w "simple3" simple_3;
      (*test_w "simple4" simple_4;*)
      test_w "id" id;
      test_w "chain_id" chain_id;
      test_w "chain_id_func" chain_id_func;
      test_w "tuple_creation" tuple_creation;
      test_w "check_record_destructure" check_record_destructure;
      test_w "check_hash_key" check_hash_key;
      test_w "basic_function_application" basic_function_application;
      test_w "basic_link" basic_link;
    ]
