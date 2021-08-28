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
  | Num of Z.t
  | Succ
  (* tezos_specific ops *)
  | Address of string
  (*
     ================
     named references
     ================
  *)
  | Ref of 'a

(* Need to set up ppx_import (https://github.com/ocaml-ppx/ppx_import#usage) to import `Z` with `pp` 

[@@deriving show] 
*)

and 'a zinc = 'a zinc_instruction list 

type program = (string * string zinc) list 

module M = struct
  type 'a myfpclass =
    | FP_normal
    | FP_subnormal
    | FP_zero
    | FP_infinite
    | FP_nan
  [@@deriving show]
end
