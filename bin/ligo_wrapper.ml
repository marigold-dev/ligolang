let _ = [ Zinc.Types.Num (Z.of_int 42); Return ]

(*

  let typed, _ = type_file ~raise ~add_warning ~options f stx env in
                    +- Reasonligo.preprocess_file


  let zinc = Zinc_of_typed.compile ~raise typed in

*)

let str_to_zinc ~raise ~add_warning zinc_str =
  zinc_str |> Yojson.Safe.from_string |> Zinc.Types.program_of_yojson
  
let ligo_to_zinc ~raise ~add_warning ligo_str =
  Ok (Test_helpers.to_zinc ~raise ~add_warning ligo_str Env Test_helpers.options
  |> Zinc.Types.program_to_yojson |> Yojson.Safe.to_string)

let interpret_zinc ~raise:_ ~add_warning:_ ~code_str ~env_str ~stack_str  =
  let code = code_str |> Yojson.Safe.from_string |> Zinc.Types.zinc_of_yojson in 
  let stack = stack_str |> Yojson.Safe.from_string |> Zinc.Types.stack_of_yojson in
  let env = env_str |> Yojson.Safe.from_string |> Zinc.Types.env_of_yojson in 
  match (code, env, stack) with 
  | Ok code, Ok env, Ok stack -> Ok (Zincing.Interpreter.apply_zinc (code, env, stack) |> Zinc.Types.zinc_state_to_yojson |> Yojson.Safe.to_string)
  | _ -> Error "parsing error"


let main ~raise ~add_warning ~options:_ () =
  let output =
    match Sys.argv with
    | [| _; "ligo-to-zinc"; ligo_str |] ->
        ligo_to_zinc ~raise ~add_warning ligo_str
    | [| _; "interpret-zinc"; code_str; env_str; stack_str  |] -> interpret_zinc ~raise ~add_warning ~code_str ~env_str ~stack_str 
    | _ -> Error (Printf.sprintf "Invalid input! %s" (Sys.argv |> Array.to_list |> String.concat ", "))
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
