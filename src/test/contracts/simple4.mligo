let y = false && true
type t = 
First 
| Second 
| Third
let rec x (a: int): int = 
  if a <= 0 then 0 else x (a - 1)
let yy = x 5
let y = First
let x = match y with 
| Second -> 2
| First -> 1 
| Third -> 3
