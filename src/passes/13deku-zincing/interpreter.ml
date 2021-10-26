open Simple_utils
open Zinc_types.Types

let env_to_stack : env_item -> stack_item = function #env_item as x -> x

let initial_state ?initial_stack:(stack = []) a = (a, [], stack)

let interpret_zinc :
    interpreter_context -> interpreter_input -> interpreter_output =
 fun interpreter_context (code, env, stack) ->
  let apply_once (code : zinc_extended) (env : env_item list)
      (stack : stack_item list) =
    let () =
      print_endline
        (Format.asprintf "interpreting:\ncode:  %a\nenv:   %a\nstack: %a"
           pp_zinc_extended code pp_env env pp_stack stack)
    in
    match (code, env, stack) with
    | Grab :: c, env, (#env_item as v) :: s -> `Some (c, v :: env, s)
    | Grab :: c, env, `Marker (c', e') :: s ->
        `Some (c', e', `Clos { code = Grab :: c; env } :: s)
    | Grab :: _, _, [] -> failwith "nothing to grab!"
    | Return :: _, _, `Z v :: `Marker (c', e') :: s -> `Some (c', e', `Z v :: s)
    | Return :: _, _, `Clos { code = c'; env = e' } :: s -> `Some (c', e', s)
    | PushRetAddr c' :: c, env, s -> `Some (c, env, `Marker (c', env) :: s)
    | Apply :: _, _, `Clos { code = c'; env = e' } :: s -> `Some (c', e', s)
    (* Below here is just modern SECD *)
    | Access n :: c, env, s -> (
        let nth = List.nth env n in
        match nth with
        | Some nth -> `Some (c, env, (nth |> env_to_stack) :: s)
        | None -> `Internal_error "Tried to access env item out of bounds")
    | Closure c' :: c, env, s -> `Some (c, env, `Clos { code = c'; env } :: s)
    | EndLet :: c, _ :: env, s -> `Some (c, env, s)
    (* zinc extensions *)
    (* operations that jsut drop something on the stack haha *)
    | ( ((Num _ | Address _ | Key _ | Hash _ | Bool _ | String _ | Mutez _) as v)
        :: c,
        env,
        s ) ->
        `Some (c, env, `Z v :: s)
    (* ADTs *)
    | MakeRecord r :: c, env, s ->
        let rec zipExtra x y =
          match (x, y) with
          | x :: xs, y :: ys ->
              let zipped, extra = zipExtra xs ys in
              ((x, y) :: zipped, extra)
          | [], y -> ([], y)
          | _ -> failwith "more items in left list than in right"
        in
        let record_contents, new_stack = zipExtra r s in
        let record_contents =
          List.fold record_contents ~init:LMap.empty
            ~f:(fun acc (label, value) -> acc |> LMap.add label value)
        in
        `Some (c, env, `Record record_contents :: new_stack)
    | RecordAccess accessor :: c, env, `Record r :: s ->
        `Some (c, env, (r |> LMap.find accessor) :: s)
    | MatchVariant vs :: c, env, `Variant (Label label, item) :: s -> (
        match
          List.find_map vs ~f:(fun (Label match_arm, constructors) ->
              if String.equal match_arm label then Some constructors else None)
        with
        | None -> `Internal_error "inexhaustive match"
        | Some match_code ->
            `Some (List.concat [ match_code; c ], env, item :: s))
    (* Math *)
    | Add :: c, env, `Z (Num a) :: `Z (Num b) :: s ->
        `Some (c, env, `Z (Num (Z.add a b)) :: s)
    | Add :: c, env, `Z (Mutez a) :: `Z (Mutez b) :: s ->
        `Some (c, env, `Z (Mutez (Z.add a b)) :: s)
    (* Booleans *)
    | Eq :: c, env, a :: b :: s ->
        `Some (c, env, `Z (Bool (equal_stack_item a b)) :: s)
    (* Crypto *)
    | HashKey :: c, env, `Z (Key key) :: s ->
        let h = Digestif.BLAKE2B.hmac_string ~key:"???" key in
        `Some (c, env, `Z (Hash h) :: s)
    (* Tezos specific *)
    | ChainID :: c, env, s ->
        `Some
          ( c,
            env,
            `Z
              (* TODO: fix this usage of Digestif.BLAKE2B.hmac_string - should use an effect system or smth.
                 Also probably shouldn't use key like this. *)
              (let h =
                 Digestif.BLAKE2B.hmac_string ~key:"???" "chain id hash here!"
               in
               Hash h)
            :: s )
    | Contract_opt :: c, env, `Z (Address address) :: s ->
        (* todo: abstract this into a function *)
        let contract =
          match interpreter_context.get_contract_opt address with
          | Some (address, entrypoint) ->
              `Variant
                (Label "Some", `Z (Extensions (Contract (address, entrypoint))))
          | None -> `Variant (Label "None", Utils.unit_record)
        in
        `Some (c, env, contract :: s)
    | ( MakeTransaction :: c,
        env,
        r
        :: `Z (Mutez amount)
           :: `Z (Extensions (Contract contract)) :: s )
      when equal_stack_item r Utils.unit_record ->
        `Some (c, env, `Z (Extensions (Operation (Transaction (amount, contract)) )) :: s) 
    (* should be unreachable except when program is done *)
    | [ Return ], _, _ -> `Done
    | Failwith :: _, _, `Z (String s) :: _ -> `Failwith s
    (* should not be reachable *)
    | x :: _, _, _ ->
        `Internal_error
          (Format.asprintf "%a unimplemented!" pp_zinc_instruction_extended x)
    | _ ->
        `Internal_error
          (Format.asprintf "somehow ran out of code without hitting return!")
  in
  let code : zinc_extended = generalize_zinc code in
  let rec loop code env stack =
    match apply_once code env stack with
    | `Done -> Success (env, stack)
    | `Failwith s -> Failure s
    | `Internal_error s -> failwith s
    | `Some (code, env, stack) -> loop code env stack
  in
  loop code env stack
