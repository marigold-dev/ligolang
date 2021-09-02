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
  (* ASTs *)
  | MakeRecord of
      ((Stage_common.Types.label
       [@equal
         fun (Stage_common.Types.Label a) (Stage_common.Types.Label b) ->
           String.equal a b]
       [@printer
         fun fmt -> function Stage_common.Types.Label s -> fprintf fmt "%s" s])
      * (Mini_c.Types.type_content
        [@equal fun a b -> a = b]
        [@printer fun fmt -> fprintf fmt "(%a)" Mini_c.PP.type_content]))
      list
  (* math *)
  | Num of Z.t [@printer fun fmt v -> fprintf fmt "%s" (Z.to_string v)]
  | Succ
  (* serialization *)
  | Bytes of bytes
  | Pack
  | Unpack of
      (Mini_c.Types.type_content
      [@equal fun a b -> a = b]
      [@printer fun fmt -> fprintf fmt "(%a)" Mini_c.PP.type_content])
  (* tezos_specific operations *)
  | Address of string
  | Chain_ID
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
