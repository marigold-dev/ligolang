let _ =  [ Zinc.Types.Num (Z.of_int 42); Return ]

let () = match Sys.argv with 
  | [| _; "ligo-to-zinc";   y |] -> let raise = Simple_utils.Trace.{ raise = fun _ -> assert false } in 
                                    let add_warning = fun _ -> () in 
                                    Test_helpers.to_zinc ~raise ~add_warning y Env Test_helpers.options |> Zinc.Types.program_to_yojson |> Yojson.Safe.pretty_to_string |> print_endline;
  | [| _; "interpret-zinc"; y |] -> print_endline y;
  | _ -> print_endline "Hello, World!"
