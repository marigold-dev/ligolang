open Zinc.Types

type env_item = ZE of zinc_m_instruction | ClosE of clos
[@@deriving show] [@@deriving eq]

and stack_item =
  | Z of zinc_m_instruction
  | Clos of clos
  | Marker of zinc_m * env_item list
[@@deriving show] [@@deriving eq]

and clos = { code : zinc_m; env : env_item list }
[@@deriving show] [@@deriving eq]

let env_to_stack x =
  match x with ZE z -> Z z | ClosE { code; env } -> Clos { code; env }

let stack_to_env x =
  match x with
  | Z z -> ZE z
  | Clos { code; env } -> ClosE { code; env }
  | Marker (_, _) -> failwith "tried to convert a marker to an environment item"

let apply_zinc (instructions : zinc_m) (env : env_item list)
    (stack : stack_item list) =
  match (instructions, env, stack) with
  | Grab :: c, env, Z v :: s -> (c, ZE v :: env, s)
  | Grab :: c, env, Clos v :: s -> (c, ClosE v :: env, s)
  | Grab :: c, env, Marker (c', e') :: s ->
      (c', e', Clos { code = Grab :: c; env } :: s)
  | Return :: _, _, Z v :: Marker (c', e') :: s -> (c', e', Z v :: s)
  | Return :: _, _, Clos { code = c'; env = e' } :: s -> (c', e', s)
  | PushRetAddr c' :: c, env, s -> (c, env, Marker (c', env) :: s)
  | Apply :: _, _, Clos { code = c'; env = e' } :: s -> (c', e', s)
  (* Below here is just modern SECD *)
  | Access n :: c, env, s -> (
      let nth = List.nth env n in
      match nth with
      | Some nth -> (c, env, (nth |> env_to_stack) :: s)
      | None ->
          failwith
            "tried to access a value that didn't exist in the environment")
  | Closure c' :: c, env, s -> (c, env, Clos { code = c'; env } :: s)
  | EndLet :: c, _ :: env, s -> (c, env, s)
  (* math *)
  | Num n :: c, env, s -> (c, env, Z (Num n) :: s)
  | Succ :: c, env, Z (Num i) :: s -> (c, env, Z (Num (Z.add i Z.one)) :: s)
  (* should be unreachable *)
  | _ -> failwith "cannot progress past this point"
