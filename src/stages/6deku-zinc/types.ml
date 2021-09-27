let equal_label (Stage_common_types.Types.Label a) (Stage_common_types.Types.Label b) =
  String.equal a b

let pp_label
    (fprintf :
      Format.formatter ->
      ('a, Format.formatter, unit, unit, unit, unit) format6 ->
      'a) fmt = function
  | Stage_common_types.Types.Label s -> fprintf fmt "(Label \"%s\")" s

let equal_type_content a b = a = b

let pp_type_content
    (fprintf :
      Format.formatter ->
      ('a, Format.formatter, unit, unit, unit, unit) format6 ->
      'a) fmt =
  fprintf fmt "(%a)" Mini_c_types.PP.type_content

type zinc_instruction =
  (* ====================
     zinc core operations
     ====================
  *)
  | Grab
  | Return
  | PushRetAddr of zinc
  | Apply
  | Access of int
  | Closure of zinc
  | EndLet
  (*
     ===============
     zinc extensions
     ===============
  *)
  (* ASTs *)
  | MakeRecord of
      ((Stage_common_types.Types.label
       [@equal equal_label] [@printer pp_label fprintf])
      * (Mini_c_types.Types.type_content
        [@equal equal_type_content] [@printer pp_type_content fprintf]))
      list
  | RecordAccess of
      (Stage_common_types.Types.label[@equal equal_label] [@printer pp_label fprintf])
  (* math *)
  | Num of (Z.t[@printer fun fmt v -> fprintf fmt "%s" (Z.to_string v)])
  | Add
  (* boolean *)
  | Bool of bool
  | Eq
  (* Crypto *)
  | Key of string
  | HashKey
  | Hash of Digestif.BLAKE2B.t
  (* serialization *)
  | Bytes of bytes
  (*
  Thinking of replacing pack/unpack with this
  | Ty of ty
  | Set_global
  | Get_global
  *)
  | Pack
  | Unpack of
      (Mini_c_types.Types.type_content
      [@equal equal_type_content]
      [@printer fun fmt -> fprintf fmt "(%a)" Mini_c_types.PP.type_content])
  (* tezos_specific operations *)
  | Address of string
  | ChainID
  (* Random handling stuff (need to find a better way to do that) *)
  | Done
[@@deriving show { with_path = false }, eq]

and zinc = zinc_instruction list [@@deriving show { with_path = false }, eq]

type program = (string * zinc) list [@@deriving show { with_path = false }, eq]
