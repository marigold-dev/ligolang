let find_index x lst =
  let rec func x lst c =
    match lst with
    | [] -> None
    | hd :: tl -> if hd = x then Some c else func x tl (c + 1)
  in
  func x lst 0
