let _ = [ Zinc.Types.Num (Z.of_int 42); Return ]

(*

  let typed, _ = type_file ~raise ~add_warning ~options f stx env in
                    +- Reasonligo.preprocess_file


  let zinc = Zinc_of_typed.compile ~raise typed in

*)

let ligo_to_zinc ~raise ~add_warning ligo_str =
  Test_helpers.to_zinc ~raise ~add_warning ligo_str Env Test_helpers.options
  |> Zinc.Types.program_to_yojson |> Yojson.Safe.to_string

let interpret_zinc ~raise:_ ~add_warning:_ code_str stack_str _env_str =
  let _code = code_str |> Yojson.Safe.from_string |> Zinc.Types.zinc_of_yojson in 
  let _stack = stack_str |> Yojson.Safe.from_string |> Zinc.Types.stack_of_yojson in assert false

let main ~raise ~add_warning ~options:_ () =
  let str =
    match Sys.argv with
    | [| _; "ligo-to-zinc"; ligo_str |] ->
        ligo_to_zinc ~raise ~add_warning ligo_str
    | [| _; "interpret-zinc"; code_str; stack_str; env_str |] -> interpret_zinc ~raise ~add_warning code_str stack_str env_str
    | _ -> "Invalid input!"
  in
  let () = print_endline "=============== output ==============" in
  print_endline str

let () =
  let raise = Simple_utils.Trace.{ raise = (fun _ -> assert false) } in
  let add_warning _ = () in
  let options = Test_helpers.options in
  main ~raise ~add_warning ~options ()
