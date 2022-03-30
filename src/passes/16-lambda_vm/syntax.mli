type ident = string

and prim =
  | Neg
  | Add
  | Sub
  | Mul
  | Div
  | Rem
  | Land
  | Lor
  | Lxor
  | Lsl
  | Lsr
  | Asr
  | Fst
  | Snd

and expr =
  | Var of ident
  | Lam of ident * expr
  | App of
      { funct : expr
      ; arg : expr
      }
  | Const of int64
  | Prim of prim
  | If of
      { predicate : expr
      ; consequent : expr
      ; alternative : expr
      }
  | Pair of
      { first : expr
      ; second : expr
      }

and script =
  { param : ident
  ; code : expr
  }
[@@deriving to_yojson, eq, show { with_path = false }]
