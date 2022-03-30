open BinInt

type annot = string list

type ('l, 'p) node =
| Int of 'l * Z.t
| String of 'l * string
| Bytes of 'l * bytes
| Prim of 'l * 'p * ('l, 'p) node list * annot
| Seq of 'l * ('l, 'p) node list
