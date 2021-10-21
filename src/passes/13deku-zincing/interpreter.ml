open Simple_utils
open Zinc_types.Types

let env_to_stack : env_item -> stack_item = function #env_item as x -> x

let initial_state ?initial_stack:(stack = []) a = (a, [], stack)

let rec apply_zinc (instructions, env, stack) =
  let apply_once (instructions : zinc) (env : env_item list)
      (stack : stack_item list) =
    let () =
      print_endline
        (Format.asprintf "interpreting:\ncode:  %a\nenv:   %a\nstack: %a"
           pp_zinc instructions pp_env env pp_stack stack)
    in
    match (instructions, env, stack) with
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
    | ((Num _ | Address _ | Key _ | Hash _ | Bool _ | String _) as v) :: c, env, s -> `Some (c, env, `Z v :: s)
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
    (* Math *)
    | Add :: c, env, `Z (Num a) :: `Z (Num b) :: s ->
        `Some (c, env, `Z (Num (Z.add a b)) :: s)
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
    (* should be unreachable except when program is done *)
    | Return :: _, _, _ -> `Done
    | Failwith :: _, _, `Z (String s) :: _ -> `Failwith s
    (* should not be reachable *)
    | x :: _, _, _ ->
        `Internal_error (Format.asprintf "%a unimplemented!" pp_zinc_instruction x)
    | _ ->
        `Internal_error
          (Format.asprintf "somehow ran out of instructions without hitting return!")
  in
  match apply_once instructions env stack with
  | `Done -> Success (instructions, env, stack)
  | `Failwith s -> Failure s
  | `Internal_error s -> failwith s
  | `Some (instructions, env, stack) -> apply_zinc (instructions, env, stack)

module Utils = struct
  let unit_record = `Record Zinc_types.Types.LMap.empty
end
