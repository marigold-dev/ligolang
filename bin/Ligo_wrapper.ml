let _ = [ Zinc_types.Types.Num (Z.of_int 42); Return ]

(*

  let typed, _ = type_file ~raise ~add_warning ~options f stx env in
                    +- Reasonligo.preprocess_file


  let zinc = Zinc_of_typed.compile ~raise typed in

*)

let str_to_zinc ~raise ~add_warning zinc_str =
  zinc_str |> Yojson.Safe.from_string |> Zinc_types.Types.program_of_yojson

let ligo_to_zinc ~raise ~add_warning ligo_str =
  Ok
    (Test_helpers.to_zinc ~raise ~add_warning ligo_str Env Test_helpers.options
    |> Zinc_types.Types.program_to_yojson |> Yojson.Safe.to_string)

let interpret_zinc ~raise:_ ~add_warning:_ ~zinc_state =
  let zinc_state =
    zinc_state |> Yojson.Safe.from_string |> Zinc_types.Types.zinc_state_of_yojson
  in
  match zinc_state with
  | Ok (code, env, stack) ->
      Ok
        (Zincing.Interpreter.apply_zinc (code, env, stack)
        |> Zinc_types.Types.interpreter_output_to_yojson |> Yojson.Safe.to_string)
  | _ -> Error "parsing error"

let main ~raise ~add_warning ~options:_ () =
  let output =
    match Sys.argv with
    | [| _; "ligo-to-zinc"; ligo_str |] ->
        ligo_to_zinc ~raise ~add_warning ligo_str
    | [| _; "interpret-zinc"; zinc_state |] ->
        interpret_zinc ~raise ~add_warning ~zinc_state
    | _ ->
        Error
          (Printf.sprintf "Invalid input! %s"
             (Sys.argv |> Array.to_list |> String.concat ", "))
  in
  match output with
  | Ok msg ->
      let () = print_endline "=============== output ===============" in
      print_endline msg
  | Error msg ->
      let () = print_endline "=============== error ===============" in
      print_endline msg

let () =
  let raise = Simple_utils.Trace.{ raise = (fun _ -> assert false) } in
  let add_warning _ = () in
  let options = Test_helpers.options in
  main ~raise ~add_warning ~options ()
