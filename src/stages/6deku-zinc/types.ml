type zinc_type = T_Void | T_Unit | T_Num | T_Pair | T_Either
[@@deriving show { with_path = false }, eq]

type 'a zinc_instruction =
  (* ====================
     zinc core operations
     ====================
  *)
  | Grab
  | Return
  | PushRetAddr of 'a zinc
  | Apply
  | Access of int
  | Closure of 'a zinc
  | EndLet
  (*
     ===============
     zinc extensions
     ===============
  *)
  (* math *)
  | Num of Z.t [@printer fun fmt v -> fprintf fmt "%s" (Z.to_string v)]
  | Succ
  (* serialization *)
  | Pack
  | Unpack of Mini_c.Types.type_content
      [@printer fun fmt v -> fprintf fmt "Unpack (%a)" Mini_c.PP.type_content v]
      [@equal fun a b -> a = b] (* @equal doesn't actually work here, the syntax seems to be totally ignored, no idea why *)
  (* tezos_specific operations *)
  | Address of string
  (*
     ================
     named references
     ================
  *)
  | Ref of 'a
[@@deriving show { with_path = false }, eq]

and 'a zinc = 'a zinc_instruction list
[@@deriving show { with_path = false }, eq]

type program = (string * string zinc) list
[@@deriving show { with_path = false }, eq]

module M = struct
  type 'a myfpclass =
    | FP_normal
    | FP_subnormal
    | FP_zero
    | FP_infinite
    | FP_nan
  [@@deriving show]
end
