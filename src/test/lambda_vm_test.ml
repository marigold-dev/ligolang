(* Compiling *)
open Lambda_vm

let init_env = Environment.default Environment.Protocols.current

let to_lambda ~raise ~add_warning path =
  let typed =
    Ligo_compile.Utils.type_file
      ~raise
      ~add_warning
      ~options:Test_helpers.options
      path
      "auto"
      Env
  in
  let result = Ligo_compile.To_lambda.compile ~raise typed in
  result


let blank_raise_and_warn f =
  f
    ~raise:Simple_utils.Trace.{ raise = (fun _ -> assert false) }
    ~add_warning:(fun _ -> ())


type test =
     raise:Main_errors.all Simple_utils.Trace.raise
  -> add_warning:(Main_warnings.all -> unit)
  -> unit
  -> unit

let expect_program =
  Alcotest.(
    check
      (Alcotest.testable
         (fun ppf program -> Fmt.pf ppf "%s" (Syntax.show_expr program))
         Syntax.equal_expr ))


let expect_simple_compile_to contract_file (expected_zinc : Syntax.expr) : test
    =
 fun ~raise ~add_warning () ->
  let to_lambda = to_lambda ~raise ~add_warning in
  let ext = "mligo" in
  let contract = Printf.sprintf "./contracts/%s.%s" contract_file ext in
  let lambda = to_lambda contract in
  expect_program
    (Printf.sprintf "compiling %s" contract_file)
    expected_zinc
    lambda


let simple_1 = expect_simple_compile_to "simple1" @@ Const 3L

let simple_2 =
  expect_simple_compile_to "simple2"
  @@ App { funct = Lam ("y", Var "y"); arg = Const 3L }


let simple_3 =
  expect_simple_compile_to "simple3"
  @@ App
       { funct =
           Lam
             ( "gen#18"
             , App
                 { funct =
                     App
                       { funct = Prim Add
                       ; arg = App { funct = Prim Fst; arg = Var "gen#18" }
                       }
                 ; arg = App { funct = Prim Snd; arg = Var "gen#18" }
                 } )
       ; arg = Pair { first = Const 3L; second = Const 3L }
       }


let simple_4 = expect_simple_compile_to "simple4" @@ Const 1L

let main =
  let open Test_helpers in
  test_suite
    "lambda_vm_test"
    [ test_w "simple1" simple_1
    ; test_w "simple2" simple_2
    ; test_w "simple3" simple_3
    ; test_w "simple4" simple_4
    ]
