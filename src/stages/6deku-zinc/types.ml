type 'a zinc_instruction =
  | Grab
  | Return
  | PushRetAddr of 'a zinc
  | Apply
  | Access of int
  | Closure of 'a zinc
  | EndLet
  | Succ
  | Num of int
  | Ref of 'a
and 'a zinc = 'a zinc_instruction list

type program = (string * string zinc_instruction) list
