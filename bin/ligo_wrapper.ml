let _ = [ Zinc.Types.Num (Z.of_int 42); Return ]

(*

  let typed, _ = type_file ~raise ~add_warning ~options f stx env in
                    +- Reasonligo.preprocess_file


  let zinc = Zinc_of_typed.compile ~raise typed in

*)

let ligo_to_zinc ~raise ~add_warning ligo_str =
  Test_helpers.to_zinc ~raise ~add_warning ligo_str Env Test_helpers.options
  |> Zinc.Types.program_to_yojson |> Yojson.Safe.pretty_to_string

let interpret_zinc ~raise:_ ~add_warning:_ _zinc_str =
  failwith "not implemented yet"

let main ~raise ~add_warning ~options:_ () =
  let str =
    match Sys.argv with
    | [| _; "ligo-to-zinc"; ligo_str |] ->
        ligo_to_zinc ~raise ~add_warning ligo_str
    | [| _; "interpret-zinc"; y |] -> interpret_zinc ~raise ~add_warning y
    | _ -> "Invalid input!"
  in
  print_endline str

let () =
  let raise = Simple_utils.Trace.{ raise = (fun _ -> assert false) } in
  let add_warning _ = () in
  let options = Test_helpers.options in
  main ~raise ~add_warning ~options ()
