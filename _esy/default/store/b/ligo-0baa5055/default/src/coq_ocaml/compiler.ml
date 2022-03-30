open BinInt
open Datatypes
open List
open Nat
open Specif
open Co_de_bruijn
open Ligo
open Micheline

(** val compile_usages_aux :
    'a1 -> nat -> usage list -> ('a1, string) node list **)

let rec compile_usages_aux nil n = function
| [] -> []
| u :: us0 ->
  (match u with
   | Drop ->
     (Prim (nil, "DIG", ((Int (nil, (Z.of_nat n))) :: []), [])) :: ((Seq
       (nil, (compile_usages_aux nil (S n) us0))) :: ((Prim (nil, "DROP", [],
       [])) :: []))
   | Keep -> compile_usages_aux nil (S n) us0)

(** val compile_usages : 'a1 -> usage list -> ('a1, string) node list **)

let compile_usages nil us =
  compile_usages_aux nil O us

(** val compile_splitting_aux :
    'a1 -> nat -> splitting -> ('a1, string) node list **)

let rec compile_splitting_aux nil n = function
| [] -> []
| s :: ss0 ->
  (match s with
   | Left ->
     (Prim (nil, "DIG", ((Int (nil, (Z.of_nat (add n (length ss0))))) :: []),
       [])) :: (compile_splitting_aux nil (S n) ss0)
   | Right -> compile_splitting_aux nil n ss0
   | Both ->
     app ((Prim (nil, "DIG", ((Int (nil,
       (Z.of_nat (add n (length ss0))))) :: []), [])) :: ((Prim (nil, "DUP",
       [], [])) :: ((Prim (nil, "DUG", ((Int (nil,
       (Z.of_nat (add (S n) (length ss0))))) :: []), [])) :: [])))
       (compile_splitting_aux nil (S n) ss0))

(** val compile_splitting : 'a1 -> splitting -> ('a1, string) node list **)

let compile_splitting nil ss =
  compile_splitting_aux nil O (rev ss)

(** val comb : 'a1 -> ('a1, string) node list -> ('a1, string) node **)

let rec comb nil = function
| [] -> Prim (nil, "unit", [], [])
| a :: az0 ->
  (match az0 with
   | [] -> a
   | _ :: _ -> Prim (nil, "pair", (a :: ((comb nil az0) :: [])), []))

(** val coq_PAIR : 'a1 -> nat -> ('a1, string) node list **)

let coq_PAIR nil n = match n with
| O -> (Prim (nil, "UNIT", [], [])) :: []
| S n0 ->
  (match n0 with
   | O -> []
   | S _ -> (Prim (nil, "PAIR", ((Int (nil, (Z.of_nat n))) :: []), [])) :: [])

(** val coq_UNPAIR : 'a1 -> nat -> ('a1, string) node list **)

let coq_UNPAIR nil n = match n with
| O -> (Prim (nil, "DROP", [], [])) :: []
| S n0 ->
  (match n0 with
   | O -> []
   | S _ ->
     (Prim (nil, "UNPAIR", ((Int (nil, (Z.of_nat n))) :: []), [])) :: [])

(** val coq_GET : 'a1 -> nat -> nat -> ('a1, string) node list **)

let coq_GET nil i n =
  let i0 =
    if PeanoNat.Nat.eqb (S i) n
    then mul (S (S O)) i
    else add (mul (S (S O)) i) (S O)
  in
  (Prim (nil, "GET", ((Int (nil, (Z.of_nat i0))) :: []), [])) :: []

(** val coq_UPDATE : 'a1 -> nat -> nat -> ('a1, string) node list **)

let coq_UPDATE nil i n =
  let i0 =
    if PeanoNat.Nat.eqb (S i) n
    then mul (S (S O)) i
    else add (mul (S (S O)) i) (S O)
  in
  (Prim (nil, "UPDATE", ((Int (nil, (Z.of_nat i0))) :: []), [])) :: []

(** val compile_expr :
    'a1 -> ('a1 -> 'a2 -> ('a1, 'a2, 'a3) static_args -> ('a1, string) node
    list) -> ('a3 -> ('a1, string) node) -> ('a3 -> ('a1, string) node) ->
    ('a1, string) node list -> splitting -> ('a1, 'a2, 'a3) expr -> ('a1,
    string) node list **)

let compile_expr nil op_code lit_type lit_value =
  let rec compile_expr0 env outer = function
  | E_var _ -> compile_splitting nil outer
  | E_let_in (_, inner, e1, e2) ->
    let (env1, env2) = split inner env in
    let (outer0, inner0) = assoc_splitting outer inner in
    (Seq (nil, (compile_expr0 env1 outer0 e1))) :: ((Seq (nil,
    (compile_binds0 env2 inner0 (filter_keeps (right_usages outer0)) e2))) :: [])
  | E_tuple (_, args0) ->
    (Seq (nil, (compile_args0 env outer args0))) :: ((Seq (nil,
      (coq_PAIR nil (args_length args0)))) :: [])
  | E_let_tuple (_, inner, e1, e2) ->
    let (env1, env2) = split inner env in
    let (outer0, inner0) = assoc_splitting outer inner in
    (Seq (nil, (compile_expr0 env1 outer0 e1))) :: ((Seq (nil,
    (coq_UNPAIR nil (binds_length e2)))) :: ((Seq (nil,
    (compile_binds0 env2 inner0 (filter_keeps (right_usages outer0)) e2))) :: []))
  | E_proj (_, e0, i, n) ->
    (Seq (nil, (compile_expr0 env outer e0))) :: ((Seq (nil,
      (coq_GET nil i n))) :: [])
  | E_update (_, args0, i, n) ->
    (Seq (nil, (compile_args0 env outer args0))) :: ((Seq (nil,
      (coq_UPDATE nil i n))) :: [])
  | E_app (_, e0) ->
    (Seq (nil, (compile_args0 env outer e0))) :: ((Prim (nil, "SWAP", [],
      [])) :: ((Prim (nil, "EXEC", [], [])) :: []))
  | E_lam (_, e0, b) ->
    let a =
      let Binds (_, l0, _) = e0 in
      (match l0 with
       | [] -> Prim (nil, "unit", [], [])
       | a :: l1 ->
         (match l1 with
          | [] -> a
          | _ :: _ -> Prim (nil, "unit", [], [])))
    in
    (match env with
     | [] ->
       (Seq (nil, (compile_splitting nil outer))) :: ((Prim (nil, "LAMBDA",
         (a :: (b :: ((Seq (nil, (compile_binds0 [] [] [] e0))) :: []))),
         [])) :: [])
     | _ :: _ ->
       let body =
         let Binds (l, l0, e1) = e0 in
         (match l with
          | [] ->
            (Seq (nil, ((Prim (nil, "DUP", [], [])) :: ((Prim (nil, "CDR",
              [], [])) :: ((Prim (nil, "SWAP", [], [])) :: ((Prim (nil,
              "CAR", [], [])) :: [])))))) :: ((Seq (nil,
              (coq_UNPAIR nil (length env)))) :: ((Prim (nil, "DIG", ((Int
              (nil, (Z.of_nat (length env)))) :: []), [])) :: ((Seq (nil,
              (compile_binds0 env (repeat Left (length env))
                (repeat Keep (length env)) e0))) :: [])))
          | u :: l1 ->
            (match u with
             | Drop ->
               (match l1 with
                | [] ->
                  (match l0 with
                   | [] ->
                     (Seq (nil, ((Prim (nil, "DUP", [], [])) :: ((Prim (nil,
                       "CDR", [], [])) :: ((Prim (nil, "SWAP", [],
                       [])) :: ((Prim (nil, "CAR", [],
                       [])) :: [])))))) :: ((Seq (nil,
                       (coq_UNPAIR nil (length env)))) :: ((Prim (nil, "DIG",
                       ((Int (nil, (Z.of_nat (length env)))) :: []),
                       [])) :: ((Seq (nil,
                       (compile_binds0 env (repeat Left (length env))
                         (repeat Keep (length env)) e0))) :: [])))
                   | _ :: l2 ->
                     (match l2 with
                      | [] ->
                        (Prim (nil, "CAR", [], [])) :: ((Seq (nil,
                          (coq_UNPAIR nil (length env)))) :: ((Seq (nil,
                          (compile_expr0 env (repeat Left (length env)) e1))) :: []))
                      | _ :: _ ->
                        (Seq (nil, ((Prim (nil, "DUP", [], [])) :: ((Prim
                          (nil, "CDR", [], [])) :: ((Prim (nil, "SWAP", [],
                          [])) :: ((Prim (nil, "CAR", [],
                          [])) :: [])))))) :: ((Seq (nil,
                          (coq_UNPAIR nil (length env)))) :: ((Prim (nil,
                          "DIG", ((Int (nil,
                          (Z.of_nat (length env)))) :: []), [])) :: ((Seq
                          (nil,
                          (compile_binds0 env (repeat Left (length env))
                            (repeat Keep (length env)) e0))) :: [])))))
                | _ :: _ ->
                  (Seq (nil, ((Prim (nil, "DUP", [], [])) :: ((Prim (nil,
                    "CDR", [], [])) :: ((Prim (nil, "SWAP", [],
                    [])) :: ((Prim (nil, "CAR", [], [])) :: [])))))) :: ((Seq
                    (nil, (coq_UNPAIR nil (length env)))) :: ((Prim (nil,
                    "DIG", ((Int (nil, (Z.of_nat (length env)))) :: []),
                    [])) :: ((Seq (nil,
                    (compile_binds0 env (repeat Left (length env))
                      (repeat Keep (length env)) e0))) :: []))))
             | Keep ->
               (Seq (nil, ((Prim (nil, "DUP", [], [])) :: ((Prim (nil, "CDR",
                 [], [])) :: ((Prim (nil, "SWAP", [], [])) :: ((Prim (nil,
                 "CAR", [], [])) :: [])))))) :: ((Seq (nil,
                 (coq_UNPAIR nil (length env)))) :: ((Prim (nil, "DIG", ((Int
                 (nil, (Z.of_nat (length env)))) :: []), [])) :: ((Seq (nil,
                 (compile_binds0 env (repeat Left (length env))
                   (repeat Keep (length env)) e0))) :: [])))))
       in
       (Seq (nil, (compile_splitting nil outer))) :: ((Seq (nil,
       (coq_PAIR nil (length env)))) :: ((Prim (nil, "LAMBDA", ((Prim (nil,
       "pair", ((comb nil env) :: (a :: [])), [])) :: (b :: ((Seq (nil,
       body)) :: []))), [])) :: ((Prim (nil, "SWAP", [], [])) :: ((Prim (nil,
       "APPLY", [], [])) :: [])))))
  | E_operator (l, op, sargs, args0) ->
    (Seq (nil, (compile_args0 env outer args0))) :: ((Seq (nil,
      (op_code l op sargs))) :: [])
  | E_literal (_, lit) ->
    (Prim (nil, "PUSH", ((lit_type lit) :: ((lit_value lit) :: [])),
      [])) :: []
  | E_pair (_, e0) ->
    (Seq (nil, (compile_args0 env outer e0))) :: ((Prim (nil, "PAIR", [],
      [])) :: [])
  | E_car (_, e0) ->
    (Seq (nil, (compile_expr0 env outer e0))) :: ((Prim (nil, "CAR", [],
      [])) :: [])
  | E_cdr (_, e0) ->
    (Seq (nil, (compile_expr0 env outer e0))) :: ((Prim (nil, "CDR", [],
      [])) :: [])
  | E_unit _ ->
    (Seq (nil, (compile_splitting nil outer))) :: ((Prim (nil, "UNIT", [],
      [])) :: [])
  | E_left (_, b, e0) ->
    (Seq (nil, (compile_expr0 env outer e0))) :: ((Prim (nil, "LEFT",
      (b :: []), [])) :: [])
  | E_right (_, a, e0) ->
    (Seq (nil, (compile_expr0 env outer e0))) :: ((Prim (nil, "RIGHT",
      (a :: []), [])) :: [])
  | E_if_left (_, e0) ->
    let (p, e3) = compile_cond0 env outer e0 in
    let (e1, e2) = p in
    (Seq (nil, e1)) :: ((Prim (nil, "IF_LEFT", ((Seq (nil, e2)) :: ((Seq
    (nil, e3)) :: [])), [])) :: [])
  | E_if_bool (_, e0) ->
    let (p, e3) = compile_cond0 env outer e0 in
    let (e1, e2) = p in
    (Seq (nil, e1)) :: ((Prim (nil, "IF", ((Seq (nil, e2)) :: ((Seq (nil,
    e3)) :: [])), [])) :: [])
  | E_if_none (_, e0) ->
    let (p, e3) = compile_cond0 env outer e0 in
    let (e1, e2) = p in
    (Seq (nil, e1)) :: ((Prim (nil, "IF_NONE", ((Seq (nil, e2)) :: ((Seq
    (nil, e3)) :: [])), [])) :: [])
  | E_if_cons (_, e0) ->
    let (p, e3) = compile_cond0 env outer e0 in
    let (e1, e2) = p in
    (Seq (nil, e1)) :: ((Prim (nil, "IF_CONS", ((Seq (nil, e2)) :: ((Seq
    (nil, e3)) :: [])), [])) :: [])
  | E_iter (_, inner, e1, e2) ->
    let (env1, env2) = split inner env in
    let inner0 = flip_splitting inner in
    let (outer0, inner1) = assoc_splitting outer inner0 in
    (Seq (nil, (compile_expr0 env2 outer0 e2))) :: ((Prim (nil, "ITER", ((Seq
    (nil, ((Seq (nil,
    (compile_binds0 env1 (keep_rights (left_usages inner1))
      (filter_keeps (right_usages outer0)) e1))) :: ((Prim (nil, "DROP", [],
    [])) :: [])))) :: []), [])) :: ((Seq (nil,
    (compile_usages nil (right_usages inner1)))) :: ((Prim (nil, "UNIT", [],
    [])) :: [])))
  | E_map (_, inner, e1, e2) ->
    let (env1, env2) = split inner env in
    let inner0 = flip_splitting inner in
    let (outer0, inner1) = assoc_splitting outer inner0 in
    (Seq (nil, (compile_expr0 env2 outer0 e2))) :: ((Prim (nil, "MAP", ((Seq
    (nil,
    (compile_binds0 env1 (keep_rights (left_usages inner1))
      (filter_keeps (right_usages outer0)) e1))) :: []), [])) :: ((Seq (nil,
    (compile_usages nil (Keep :: (right_usages inner1))))) :: []))
  | E_loop_left (_, inner, e1, b, e2) ->
    let (env1, env2) = split inner env in
    let inner0 = flip_splitting inner in
    let (outer0, inner1) = assoc_splitting outer inner0 in
    (Seq (nil, (compile_expr0 env2 outer0 e2))) :: ((Prim (nil, "LEFT",
    (b :: []), [])) :: ((Prim (nil, "LOOP_LEFT", ((Seq (nil,
    (compile_binds0 env1 (keep_rights (left_usages inner1))
      (filter_keeps (right_usages outer0)) e1))) :: []), [])) :: ((Seq (nil,
    (compile_usages nil (Keep :: (right_usages inner1))))) :: [])))
  | E_fold (_, inner1, e1, inner2, e2, e3) ->
    let (env1, env') = split inner1 env in
    let (env2, env3) = split inner2 env' in
    let (outer0, inner3) = assoc_splitting outer inner1 in
    let (inner4, inner5) = assoc_splitting inner3 inner2 in
    (Seq (nil, (compile_expr0 env1 outer0 e1))) :: ((Seq (nil,
    (compile_expr0 env2 (Right :: inner4) e2))) :: ((Prim (nil, "ITER", ((Seq
    (nil, ((Prim (nil, "SWAP", [], [])) :: ((Prim (nil, "PAIR", [],
    [])) :: ((Seq (nil,
    (compile_binds0 env3 (keep_rights (left_usages inner5))
      (filter_keeps (right_usages inner4)) e3))) :: []))))) :: []),
    [])) :: ((Seq (nil,
    (compile_usages nil (Keep :: (right_usages inner5))))) :: [])))
  | E_fold_right (_, elem, inner1, e1, inner2, e2, e3) ->
    let (env1, env') = split inner1 env in
    let (env2, env3) = split inner2 env' in
    let (outer0, inner3) = assoc_splitting outer inner1 in
    let (inner4, inner5) = assoc_splitting inner3 inner2 in
    (Seq (nil, (compile_expr0 env1 outer0 e1))) :: ((Seq (nil,
    (compile_expr0 env2 (Right :: inner4) e2))) :: ((Seq (nil, ((Prim (nil,
    "NIL", (elem :: []), [])) :: ((Prim (nil, "SWAP", [], [])) :: ((Prim
    (nil, "ITER", ((Seq (nil, ((Prim (nil, "CONS", [], [])) :: []))) :: []),
    [])) :: []))))) :: ((Prim (nil, "ITER", ((Seq (nil, ((Prim (nil, "PAIR",
    [], [])) :: ((Seq (nil,
    (compile_binds0 env3 (keep_rights (left_usages inner5))
      (filter_keeps (right_usages inner4)) e3))) :: [])))) :: []),
    [])) :: ((Seq (nil,
    (compile_usages nil (Keep :: (right_usages inner5))))) :: []))))
  | E_failwith (x, e0) ->
    (Seq (nil, (compile_expr0 env outer e0))) :: ((Prim (x, "FAILWITH", [],
      [])) :: [])
  | E_raw_michelson (_, a, b, code) ->
    (Prim (nil, "PUSH", ((Prim (nil, "lambda", (a :: (b :: [])),
      [])) :: ((Seq (nil, code)) :: [])), [])) :: []
  | E_global_constant (_, _, hash, args0) ->
    (Seq (nil, (compile_args0 env outer args0))) :: ((Prim (nil, "constant",
      ((String (nil, hash)) :: []), [])) :: [])
  and compile_args0 env outer = function
  | Args_nil -> []
  | Args_cons (inner, e0, args0) ->
    let (env1, env2) = split inner env in
    let (outer', inner') = assoc_splitting outer inner in
    (Seq (nil, (compile_expr0 env1 outer' e0))) :: ((Seq (nil,
    (compile_args0 env2 (Right :: inner') args0))) :: [])
  and compile_binds0 env outer proj = function
  | Binds (us, az, e0) ->
    let env' = app (select us az) env in
    let outer' = app (repeat Left (length (select us az))) outer in
    (Seq (nil, (compile_usages nil (app us proj)))) :: ((Seq (nil,
    (compile_expr0 env' outer' e0))) :: [])
  and compile_cond0 env outer = function
  | Cond (inner1, e1, inner2, b2, b3) ->
    let (env1, env') = split inner1 env in
    let (env2, env3) = split inner2 env' in
    let (outer', inner1') = assoc_splitting outer inner1 in
    let (outerR, innerR) = assoc_splitting inner1' inner2 in
    let (outerL, innerL) = assoc_splitting inner1' (flip_splitting inner2) in
    (((compile_expr0 env1 outer' e1),
    (compile_binds0 env2 innerL (right_usages outerL) b2)),
    (compile_binds0 env3 innerR (right_usages outerR) b3))
  in compile_expr0

(** val compile_args :
    'a1 -> ('a1 -> 'a2 -> ('a1, 'a2, 'a3) static_args -> ('a1, string) node
    list) -> ('a3 -> ('a1, string) node) -> ('a3 -> ('a1, string) node) ->
    ('a1, string) node list -> splitting -> ('a1, 'a2, 'a3) args -> ('a1,
    string) node list **)

let compile_args nil op_code lit_type lit_value =
  let rec compile_expr0 env outer = function
  | E_var _ -> compile_splitting nil outer
  | E_let_in (_, inner, e1, e2) ->
    let (env1, env2) = split inner env in
    let (outer0, inner0) = assoc_splitting outer inner in
    (Seq (nil, (compile_expr0 env1 outer0 e1))) :: ((Seq (nil,
    (compile_binds0 env2 inner0 (filter_keeps (right_usages outer0)) e2))) :: [])
  | E_tuple (_, args0) ->
    (Seq (nil, (compile_args0 env outer args0))) :: ((Seq (nil,
      (coq_PAIR nil (args_length args0)))) :: [])
  | E_let_tuple (_, inner, e1, e2) ->
    let (env1, env2) = split inner env in
    let (outer0, inner0) = assoc_splitting outer inner in
    (Seq (nil, (compile_expr0 env1 outer0 e1))) :: ((Seq (nil,
    (coq_UNPAIR nil (binds_length e2)))) :: ((Seq (nil,
    (compile_binds0 env2 inner0 (filter_keeps (right_usages outer0)) e2))) :: []))
  | E_proj (_, e0, i, n) ->
    (Seq (nil, (compile_expr0 env outer e0))) :: ((Seq (nil,
      (coq_GET nil i n))) :: [])
  | E_update (_, args0, i, n) ->
    (Seq (nil, (compile_args0 env outer args0))) :: ((Seq (nil,
      (coq_UPDATE nil i n))) :: [])
  | E_app (_, e0) ->
    (Seq (nil, (compile_args0 env outer e0))) :: ((Prim (nil, "SWAP", [],
      [])) :: ((Prim (nil, "EXEC", [], [])) :: []))
  | E_lam (_, e0, b) ->
    let a =
      let Binds (_, l0, _) = e0 in
      (match l0 with
       | [] -> Prim (nil, "unit", [], [])
       | a :: l1 ->
         (match l1 with
          | [] -> a
          | _ :: _ -> Prim (nil, "unit", [], [])))
    in
    (match env with
     | [] ->
       (Seq (nil, (compile_splitting nil outer))) :: ((Prim (nil, "LAMBDA",
         (a :: (b :: ((Seq (nil, (compile_binds0 [] [] [] e0))) :: []))),
         [])) :: [])
     | _ :: _ ->
       let body =
         let Binds (l, l0, e1) = e0 in
         (match l with
          | [] ->
            (Seq (nil, ((Prim (nil, "DUP", [], [])) :: ((Prim (nil, "CDR",
              [], [])) :: ((Prim (nil, "SWAP", [], [])) :: ((Prim (nil,
              "CAR", [], [])) :: [])))))) :: ((Seq (nil,
              (coq_UNPAIR nil (length env)))) :: ((Prim (nil, "DIG", ((Int
              (nil, (Z.of_nat (length env)))) :: []), [])) :: ((Seq (nil,
              (compile_binds0 env (repeat Left (length env))
                (repeat Keep (length env)) e0))) :: [])))
          | u :: l1 ->
            (match u with
             | Drop ->
               (match l1 with
                | [] ->
                  (match l0 with
                   | [] ->
                     (Seq (nil, ((Prim (nil, "DUP", [], [])) :: ((Prim (nil,
                       "CDR", [], [])) :: ((Prim (nil, "SWAP", [],
                       [])) :: ((Prim (nil, "CAR", [],
                       [])) :: [])))))) :: ((Seq (nil,
                       (coq_UNPAIR nil (length env)))) :: ((Prim (nil, "DIG",
                       ((Int (nil, (Z.of_nat (length env)))) :: []),
                       [])) :: ((Seq (nil,
                       (compile_binds0 env (repeat Left (length env))
                         (repeat Keep (length env)) e0))) :: [])))
                   | _ :: l2 ->
                     (match l2 with
                      | [] ->
                        (Prim (nil, "CAR", [], [])) :: ((Seq (nil,
                          (coq_UNPAIR nil (length env)))) :: ((Seq (nil,
                          (compile_expr0 env (repeat Left (length env)) e1))) :: []))
                      | _ :: _ ->
                        (Seq (nil, ((Prim (nil, "DUP", [], [])) :: ((Prim
                          (nil, "CDR", [], [])) :: ((Prim (nil, "SWAP", [],
                          [])) :: ((Prim (nil, "CAR", [],
                          [])) :: [])))))) :: ((Seq (nil,
                          (coq_UNPAIR nil (length env)))) :: ((Prim (nil,
                          "DIG", ((Int (nil,
                          (Z.of_nat (length env)))) :: []), [])) :: ((Seq
                          (nil,
                          (compile_binds0 env (repeat Left (length env))
                            (repeat Keep (length env)) e0))) :: [])))))
                | _ :: _ ->
                  (Seq (nil, ((Prim (nil, "DUP", [], [])) :: ((Prim (nil,
                    "CDR", [], [])) :: ((Prim (nil, "SWAP", [],
                    [])) :: ((Prim (nil, "CAR", [], [])) :: [])))))) :: ((Seq
                    (nil, (coq_UNPAIR nil (length env)))) :: ((Prim (nil,
                    "DIG", ((Int (nil, (Z.of_nat (length env)))) :: []),
                    [])) :: ((Seq (nil,
                    (compile_binds0 env (repeat Left (length env))
                      (repeat Keep (length env)) e0))) :: []))))
             | Keep ->
               (Seq (nil, ((Prim (nil, "DUP", [], [])) :: ((Prim (nil, "CDR",
                 [], [])) :: ((Prim (nil, "SWAP", [], [])) :: ((Prim (nil,
                 "CAR", [], [])) :: [])))))) :: ((Seq (nil,
                 (coq_UNPAIR nil (length env)))) :: ((Prim (nil, "DIG", ((Int
                 (nil, (Z.of_nat (length env)))) :: []), [])) :: ((Seq (nil,
                 (compile_binds0 env (repeat Left (length env))
                   (repeat Keep (length env)) e0))) :: [])))))
       in
       (Seq (nil, (compile_splitting nil outer))) :: ((Seq (nil,
       (coq_PAIR nil (length env)))) :: ((Prim (nil, "LAMBDA", ((Prim (nil,
       "pair", ((comb nil env) :: (a :: [])), [])) :: (b :: ((Seq (nil,
       body)) :: []))), [])) :: ((Prim (nil, "SWAP", [], [])) :: ((Prim (nil,
       "APPLY", [], [])) :: [])))))
  | E_operator (l, op, sargs, args0) ->
    (Seq (nil, (compile_args0 env outer args0))) :: ((Seq (nil,
      (op_code l op sargs))) :: [])
  | E_literal (_, lit) ->
    (Prim (nil, "PUSH", ((lit_type lit) :: ((lit_value lit) :: [])),
      [])) :: []
  | E_pair (_, e0) ->
    (Seq (nil, (compile_args0 env outer e0))) :: ((Prim (nil, "PAIR", [],
      [])) :: [])
  | E_car (_, e0) ->
    (Seq (nil, (compile_expr0 env outer e0))) :: ((Prim (nil, "CAR", [],
      [])) :: [])
  | E_cdr (_, e0) ->
    (Seq (nil, (compile_expr0 env outer e0))) :: ((Prim (nil, "CDR", [],
      [])) :: [])
  | E_unit _ ->
    (Seq (nil, (compile_splitting nil outer))) :: ((Prim (nil, "UNIT", [],
      [])) :: [])
  | E_left (_, b, e0) ->
    (Seq (nil, (compile_expr0 env outer e0))) :: ((Prim (nil, "LEFT",
      (b :: []), [])) :: [])
  | E_right (_, a, e0) ->
    (Seq (nil, (compile_expr0 env outer e0))) :: ((Prim (nil, "RIGHT",
      (a :: []), [])) :: [])
  | E_if_left (_, e0) ->
    let (p, e3) = compile_cond0 env outer e0 in
    let (e1, e2) = p in
    (Seq (nil, e1)) :: ((Prim (nil, "IF_LEFT", ((Seq (nil, e2)) :: ((Seq
    (nil, e3)) :: [])), [])) :: [])
  | E_if_bool (_, e0) ->
    let (p, e3) = compile_cond0 env outer e0 in
    let (e1, e2) = p in
    (Seq (nil, e1)) :: ((Prim (nil, "IF", ((Seq (nil, e2)) :: ((Seq (nil,
    e3)) :: [])), [])) :: [])
  | E_if_none (_, e0) ->
    let (p, e3) = compile_cond0 env outer e0 in
    let (e1, e2) = p in
    (Seq (nil, e1)) :: ((Prim (nil, "IF_NONE", ((Seq (nil, e2)) :: ((Seq
    (nil, e3)) :: [])), [])) :: [])
  | E_if_cons (_, e0) ->
    let (p, e3) = compile_cond0 env outer e0 in
    let (e1, e2) = p in
    (Seq (nil, e1)) :: ((Prim (nil, "IF_CONS", ((Seq (nil, e2)) :: ((Seq
    (nil, e3)) :: [])), [])) :: [])
  | E_iter (_, inner, e1, e2) ->
    let (env1, env2) = split inner env in
    let inner0 = flip_splitting inner in
    let (outer0, inner1) = assoc_splitting outer inner0 in
    (Seq (nil, (compile_expr0 env2 outer0 e2))) :: ((Prim (nil, "ITER", ((Seq
    (nil, ((Seq (nil,
    (compile_binds0 env1 (keep_rights (left_usages inner1))
      (filter_keeps (right_usages outer0)) e1))) :: ((Prim (nil, "DROP", [],
    [])) :: [])))) :: []), [])) :: ((Seq (nil,
    (compile_usages nil (right_usages inner1)))) :: ((Prim (nil, "UNIT", [],
    [])) :: [])))
  | E_map (_, inner, e1, e2) ->
    let (env1, env2) = split inner env in
    let inner0 = flip_splitting inner in
    let (outer0, inner1) = assoc_splitting outer inner0 in
    (Seq (nil, (compile_expr0 env2 outer0 e2))) :: ((Prim (nil, "MAP", ((Seq
    (nil,
    (compile_binds0 env1 (keep_rights (left_usages inner1))
      (filter_keeps (right_usages outer0)) e1))) :: []), [])) :: ((Seq (nil,
    (compile_usages nil (Keep :: (right_usages inner1))))) :: []))
  | E_loop_left (_, inner, e1, b, e2) ->
    let (env1, env2) = split inner env in
    let inner0 = flip_splitting inner in
    let (outer0, inner1) = assoc_splitting outer inner0 in
    (Seq (nil, (compile_expr0 env2 outer0 e2))) :: ((Prim (nil, "LEFT",
    (b :: []), [])) :: ((Prim (nil, "LOOP_LEFT", ((Seq (nil,
    (compile_binds0 env1 (keep_rights (left_usages inner1))
      (filter_keeps (right_usages outer0)) e1))) :: []), [])) :: ((Seq (nil,
    (compile_usages nil (Keep :: (right_usages inner1))))) :: [])))
  | E_fold (_, inner1, e1, inner2, e2, e3) ->
    let (env1, env') = split inner1 env in
    let (env2, env3) = split inner2 env' in
    let (outer0, inner3) = assoc_splitting outer inner1 in
    let (inner4, inner5) = assoc_splitting inner3 inner2 in
    (Seq (nil, (compile_expr0 env1 outer0 e1))) :: ((Seq (nil,
    (compile_expr0 env2 (Right :: inner4) e2))) :: ((Prim (nil, "ITER", ((Seq
    (nil, ((Prim (nil, "SWAP", [], [])) :: ((Prim (nil, "PAIR", [],
    [])) :: ((Seq (nil,
    (compile_binds0 env3 (keep_rights (left_usages inner5))
      (filter_keeps (right_usages inner4)) e3))) :: []))))) :: []),
    [])) :: ((Seq (nil,
    (compile_usages nil (Keep :: (right_usages inner5))))) :: [])))
  | E_fold_right (_, elem, inner1, e1, inner2, e2, e3) ->
    let (env1, env') = split inner1 env in
    let (env2, env3) = split inner2 env' in
    let (outer0, inner3) = assoc_splitting outer inner1 in
    let (inner4, inner5) = assoc_splitting inner3 inner2 in
    (Seq (nil, (compile_expr0 env1 outer0 e1))) :: ((Seq (nil,
    (compile_expr0 env2 (Right :: inner4) e2))) :: ((Seq (nil, ((Prim (nil,
    "NIL", (elem :: []), [])) :: ((Prim (nil, "SWAP", [], [])) :: ((Prim
    (nil, "ITER", ((Seq (nil, ((Prim (nil, "CONS", [], [])) :: []))) :: []),
    [])) :: []))))) :: ((Prim (nil, "ITER", ((Seq (nil, ((Prim (nil, "PAIR",
    [], [])) :: ((Seq (nil,
    (compile_binds0 env3 (keep_rights (left_usages inner5))
      (filter_keeps (right_usages inner4)) e3))) :: [])))) :: []),
    [])) :: ((Seq (nil,
    (compile_usages nil (Keep :: (right_usages inner5))))) :: []))))
  | E_failwith (x, e0) ->
    (Seq (nil, (compile_expr0 env outer e0))) :: ((Prim (x, "FAILWITH", [],
      [])) :: [])
  | E_raw_michelson (_, a, b, code) ->
    (Prim (nil, "PUSH", ((Prim (nil, "lambda", (a :: (b :: [])),
      [])) :: ((Seq (nil, code)) :: [])), [])) :: []
  | E_global_constant (_, _, hash, args0) ->
    (Seq (nil, (compile_args0 env outer args0))) :: ((Prim (nil, "constant",
      ((String (nil, hash)) :: []), [])) :: [])
  and compile_args0 env outer = function
  | Args_nil -> []
  | Args_cons (inner, e0, args0) ->
    let (env1, env2) = split inner env in
    let (outer', inner') = assoc_splitting outer inner in
    (Seq (nil, (compile_expr0 env1 outer' e0))) :: ((Seq (nil,
    (compile_args0 env2 (Right :: inner') args0))) :: [])
  and compile_binds0 env outer proj = function
  | Binds (us, az, e0) ->
    let env' = app (select us az) env in
    let outer' = app (repeat Left (length (select us az))) outer in
    (Seq (nil, (compile_usages nil (app us proj)))) :: ((Seq (nil,
    (compile_expr0 env' outer' e0))) :: [])
  and compile_cond0 env outer = function
  | Cond (inner1, e1, inner2, b2, b3) ->
    let (env1, env') = split inner1 env in
    let (env2, env3) = split inner2 env' in
    let (outer', inner1') = assoc_splitting outer inner1 in
    let (outerR, innerR) = assoc_splitting inner1' inner2 in
    let (outerL, innerL) = assoc_splitting inner1' (flip_splitting inner2) in
    (((compile_expr0 env1 outer' e1),
    (compile_binds0 env2 innerL (right_usages outerL) b2)),
    (compile_binds0 env3 innerR (right_usages outerR) b3))
  in compile_args0

(** val compile_binds :
    'a1 -> ('a1 -> 'a2 -> ('a1, 'a2, 'a3) static_args -> ('a1, string) node
    list) -> ('a3 -> ('a1, string) node) -> ('a3 -> ('a1, string) node) ->
    ('a1, string) node list -> splitting -> usage list -> ('a1, 'a2, 'a3)
    binds -> ('a1, string) node list **)

let compile_binds nil op_code lit_type lit_value =
  let rec compile_expr0 env outer = function
  | E_var _ -> compile_splitting nil outer
  | E_let_in (_, inner, e1, e2) ->
    let (env1, env2) = split inner env in
    let (outer0, inner0) = assoc_splitting outer inner in
    (Seq (nil, (compile_expr0 env1 outer0 e1))) :: ((Seq (nil,
    (compile_binds0 env2 inner0 (filter_keeps (right_usages outer0)) e2))) :: [])
  | E_tuple (_, args0) ->
    (Seq (nil, (compile_args0 env outer args0))) :: ((Seq (nil,
      (coq_PAIR nil (args_length args0)))) :: [])
  | E_let_tuple (_, inner, e1, e2) ->
    let (env1, env2) = split inner env in
    let (outer0, inner0) = assoc_splitting outer inner in
    (Seq (nil, (compile_expr0 env1 outer0 e1))) :: ((Seq (nil,
    (coq_UNPAIR nil (binds_length e2)))) :: ((Seq (nil,
    (compile_binds0 env2 inner0 (filter_keeps (right_usages outer0)) e2))) :: []))
  | E_proj (_, e0, i, n) ->
    (Seq (nil, (compile_expr0 env outer e0))) :: ((Seq (nil,
      (coq_GET nil i n))) :: [])
  | E_update (_, args0, i, n) ->
    (Seq (nil, (compile_args0 env outer args0))) :: ((Seq (nil,
      (coq_UPDATE nil i n))) :: [])
  | E_app (_, e0) ->
    (Seq (nil, (compile_args0 env outer e0))) :: ((Prim (nil, "SWAP", [],
      [])) :: ((Prim (nil, "EXEC", [], [])) :: []))
  | E_lam (_, e0, b) ->
    let a =
      let Binds (_, l0, _) = e0 in
      (match l0 with
       | [] -> Prim (nil, "unit", [], [])
       | a :: l1 ->
         (match l1 with
          | [] -> a
          | _ :: _ -> Prim (nil, "unit", [], [])))
    in
    (match env with
     | [] ->
       (Seq (nil, (compile_splitting nil outer))) :: ((Prim (nil, "LAMBDA",
         (a :: (b :: ((Seq (nil, (compile_binds0 [] [] [] e0))) :: []))),
         [])) :: [])
     | _ :: _ ->
       let body =
         let Binds (l, l0, e1) = e0 in
         (match l with
          | [] ->
            (Seq (nil, ((Prim (nil, "DUP", [], [])) :: ((Prim (nil, "CDR",
              [], [])) :: ((Prim (nil, "SWAP", [], [])) :: ((Prim (nil,
              "CAR", [], [])) :: [])))))) :: ((Seq (nil,
              (coq_UNPAIR nil (length env)))) :: ((Prim (nil, "DIG", ((Int
              (nil, (Z.of_nat (length env)))) :: []), [])) :: ((Seq (nil,
              (compile_binds0 env (repeat Left (length env))
                (repeat Keep (length env)) e0))) :: [])))
          | u :: l1 ->
            (match u with
             | Drop ->
               (match l1 with
                | [] ->
                  (match l0 with
                   | [] ->
                     (Seq (nil, ((Prim (nil, "DUP", [], [])) :: ((Prim (nil,
                       "CDR", [], [])) :: ((Prim (nil, "SWAP", [],
                       [])) :: ((Prim (nil, "CAR", [],
                       [])) :: [])))))) :: ((Seq (nil,
                       (coq_UNPAIR nil (length env)))) :: ((Prim (nil, "DIG",
                       ((Int (nil, (Z.of_nat (length env)))) :: []),
                       [])) :: ((Seq (nil,
                       (compile_binds0 env (repeat Left (length env))
                         (repeat Keep (length env)) e0))) :: [])))
                   | _ :: l2 ->
                     (match l2 with
                      | [] ->
                        (Prim (nil, "CAR", [], [])) :: ((Seq (nil,
                          (coq_UNPAIR nil (length env)))) :: ((Seq (nil,
                          (compile_expr0 env (repeat Left (length env)) e1))) :: []))
                      | _ :: _ ->
                        (Seq (nil, ((Prim (nil, "DUP", [], [])) :: ((Prim
                          (nil, "CDR", [], [])) :: ((Prim (nil, "SWAP", [],
                          [])) :: ((Prim (nil, "CAR", [],
                          [])) :: [])))))) :: ((Seq (nil,
                          (coq_UNPAIR nil (length env)))) :: ((Prim (nil,
                          "DIG", ((Int (nil,
                          (Z.of_nat (length env)))) :: []), [])) :: ((Seq
                          (nil,
                          (compile_binds0 env (repeat Left (length env))
                            (repeat Keep (length env)) e0))) :: [])))))
                | _ :: _ ->
                  (Seq (nil, ((Prim (nil, "DUP", [], [])) :: ((Prim (nil,
                    "CDR", [], [])) :: ((Prim (nil, "SWAP", [],
                    [])) :: ((Prim (nil, "CAR", [], [])) :: [])))))) :: ((Seq
                    (nil, (coq_UNPAIR nil (length env)))) :: ((Prim (nil,
                    "DIG", ((Int (nil, (Z.of_nat (length env)))) :: []),
                    [])) :: ((Seq (nil,
                    (compile_binds0 env (repeat Left (length env))
                      (repeat Keep (length env)) e0))) :: []))))
             | Keep ->
               (Seq (nil, ((Prim (nil, "DUP", [], [])) :: ((Prim (nil, "CDR",
                 [], [])) :: ((Prim (nil, "SWAP", [], [])) :: ((Prim (nil,
                 "CAR", [], [])) :: [])))))) :: ((Seq (nil,
                 (coq_UNPAIR nil (length env)))) :: ((Prim (nil, "DIG", ((Int
                 (nil, (Z.of_nat (length env)))) :: []), [])) :: ((Seq (nil,
                 (compile_binds0 env (repeat Left (length env))
                   (repeat Keep (length env)) e0))) :: [])))))
       in
       (Seq (nil, (compile_splitting nil outer))) :: ((Seq (nil,
       (coq_PAIR nil (length env)))) :: ((Prim (nil, "LAMBDA", ((Prim (nil,
       "pair", ((comb nil env) :: (a :: [])), [])) :: (b :: ((Seq (nil,
       body)) :: []))), [])) :: ((Prim (nil, "SWAP", [], [])) :: ((Prim (nil,
       "APPLY", [], [])) :: [])))))
  | E_operator (l, op, sargs, args0) ->
    (Seq (nil, (compile_args0 env outer args0))) :: ((Seq (nil,
      (op_code l op sargs))) :: [])
  | E_literal (_, lit) ->
    (Prim (nil, "PUSH", ((lit_type lit) :: ((lit_value lit) :: [])),
      [])) :: []
  | E_pair (_, e0) ->
    (Seq (nil, (compile_args0 env outer e0))) :: ((Prim (nil, "PAIR", [],
      [])) :: [])
  | E_car (_, e0) ->
    (Seq (nil, (compile_expr0 env outer e0))) :: ((Prim (nil, "CAR", [],
      [])) :: [])
  | E_cdr (_, e0) ->
    (Seq (nil, (compile_expr0 env outer e0))) :: ((Prim (nil, "CDR", [],
      [])) :: [])
  | E_unit _ ->
    (Seq (nil, (compile_splitting nil outer))) :: ((Prim (nil, "UNIT", [],
      [])) :: [])
  | E_left (_, b, e0) ->
    (Seq (nil, (compile_expr0 env outer e0))) :: ((Prim (nil, "LEFT",
      (b :: []), [])) :: [])
  | E_right (_, a, e0) ->
    (Seq (nil, (compile_expr0 env outer e0))) :: ((Prim (nil, "RIGHT",
      (a :: []), [])) :: [])
  | E_if_left (_, e0) ->
    let (p, e3) = compile_cond0 env outer e0 in
    let (e1, e2) = p in
    (Seq (nil, e1)) :: ((Prim (nil, "IF_LEFT", ((Seq (nil, e2)) :: ((Seq
    (nil, e3)) :: [])), [])) :: [])
  | E_if_bool (_, e0) ->
    let (p, e3) = compile_cond0 env outer e0 in
    let (e1, e2) = p in
    (Seq (nil, e1)) :: ((Prim (nil, "IF", ((Seq (nil, e2)) :: ((Seq (nil,
    e3)) :: [])), [])) :: [])
  | E_if_none (_, e0) ->
    let (p, e3) = compile_cond0 env outer e0 in
    let (e1, e2) = p in
    (Seq (nil, e1)) :: ((Prim (nil, "IF_NONE", ((Seq (nil, e2)) :: ((Seq
    (nil, e3)) :: [])), [])) :: [])
  | E_if_cons (_, e0) ->
    let (p, e3) = compile_cond0 env outer e0 in
    let (e1, e2) = p in
    (Seq (nil, e1)) :: ((Prim (nil, "IF_CONS", ((Seq (nil, e2)) :: ((Seq
    (nil, e3)) :: [])), [])) :: [])
  | E_iter (_, inner, e1, e2) ->
    let (env1, env2) = split inner env in
    let inner0 = flip_splitting inner in
    let (outer0, inner1) = assoc_splitting outer inner0 in
    (Seq (nil, (compile_expr0 env2 outer0 e2))) :: ((Prim (nil, "ITER", ((Seq
    (nil, ((Seq (nil,
    (compile_binds0 env1 (keep_rights (left_usages inner1))
      (filter_keeps (right_usages outer0)) e1))) :: ((Prim (nil, "DROP", [],
    [])) :: [])))) :: []), [])) :: ((Seq (nil,
    (compile_usages nil (right_usages inner1)))) :: ((Prim (nil, "UNIT", [],
    [])) :: [])))
  | E_map (_, inner, e1, e2) ->
    let (env1, env2) = split inner env in
    let inner0 = flip_splitting inner in
    let (outer0, inner1) = assoc_splitting outer inner0 in
    (Seq (nil, (compile_expr0 env2 outer0 e2))) :: ((Prim (nil, "MAP", ((Seq
    (nil,
    (compile_binds0 env1 (keep_rights (left_usages inner1))
      (filter_keeps (right_usages outer0)) e1))) :: []), [])) :: ((Seq (nil,
    (compile_usages nil (Keep :: (right_usages inner1))))) :: []))
  | E_loop_left (_, inner, e1, b, e2) ->
    let (env1, env2) = split inner env in
    let inner0 = flip_splitting inner in
    let (outer0, inner1) = assoc_splitting outer inner0 in
    (Seq (nil, (compile_expr0 env2 outer0 e2))) :: ((Prim (nil, "LEFT",
    (b :: []), [])) :: ((Prim (nil, "LOOP_LEFT", ((Seq (nil,
    (compile_binds0 env1 (keep_rights (left_usages inner1))
      (filter_keeps (right_usages outer0)) e1))) :: []), [])) :: ((Seq (nil,
    (compile_usages nil (Keep :: (right_usages inner1))))) :: [])))
  | E_fold (_, inner1, e1, inner2, e2, e3) ->
    let (env1, env') = split inner1 env in
    let (env2, env3) = split inner2 env' in
    let (outer0, inner3) = assoc_splitting outer inner1 in
    let (inner4, inner5) = assoc_splitting inner3 inner2 in
    (Seq (nil, (compile_expr0 env1 outer0 e1))) :: ((Seq (nil,
    (compile_expr0 env2 (Right :: inner4) e2))) :: ((Prim (nil, "ITER", ((Seq
    (nil, ((Prim (nil, "SWAP", [], [])) :: ((Prim (nil, "PAIR", [],
    [])) :: ((Seq (nil,
    (compile_binds0 env3 (keep_rights (left_usages inner5))
      (filter_keeps (right_usages inner4)) e3))) :: []))))) :: []),
    [])) :: ((Seq (nil,
    (compile_usages nil (Keep :: (right_usages inner5))))) :: [])))
  | E_fold_right (_, elem, inner1, e1, inner2, e2, e3) ->
    let (env1, env') = split inner1 env in
    let (env2, env3) = split inner2 env' in
    let (outer0, inner3) = assoc_splitting outer inner1 in
    let (inner4, inner5) = assoc_splitting inner3 inner2 in
    (Seq (nil, (compile_expr0 env1 outer0 e1))) :: ((Seq (nil,
    (compile_expr0 env2 (Right :: inner4) e2))) :: ((Seq (nil, ((Prim (nil,
    "NIL", (elem :: []), [])) :: ((Prim (nil, "SWAP", [], [])) :: ((Prim
    (nil, "ITER", ((Seq (nil, ((Prim (nil, "CONS", [], [])) :: []))) :: []),
    [])) :: []))))) :: ((Prim (nil, "ITER", ((Seq (nil, ((Prim (nil, "PAIR",
    [], [])) :: ((Seq (nil,
    (compile_binds0 env3 (keep_rights (left_usages inner5))
      (filter_keeps (right_usages inner4)) e3))) :: [])))) :: []),
    [])) :: ((Seq (nil,
    (compile_usages nil (Keep :: (right_usages inner5))))) :: []))))
  | E_failwith (x, e0) ->
    (Seq (nil, (compile_expr0 env outer e0))) :: ((Prim (x, "FAILWITH", [],
      [])) :: [])
  | E_raw_michelson (_, a, b, code) ->
    (Prim (nil, "PUSH", ((Prim (nil, "lambda", (a :: (b :: [])),
      [])) :: ((Seq (nil, code)) :: [])), [])) :: []
  | E_global_constant (_, _, hash, args0) ->
    (Seq (nil, (compile_args0 env outer args0))) :: ((Prim (nil, "constant",
      ((String (nil, hash)) :: []), [])) :: [])
  and compile_args0 env outer = function
  | Args_nil -> []
  | Args_cons (inner, e0, args0) ->
    let (env1, env2) = split inner env in
    let (outer', inner') = assoc_splitting outer inner in
    (Seq (nil, (compile_expr0 env1 outer' e0))) :: ((Seq (nil,
    (compile_args0 env2 (Right :: inner') args0))) :: [])
  and compile_binds0 env outer proj = function
  | Binds (us, az, e0) ->
    let env' = app (select us az) env in
    let outer' = app (repeat Left (length (select us az))) outer in
    (Seq (nil, (compile_usages nil (app us proj)))) :: ((Seq (nil,
    (compile_expr0 env' outer' e0))) :: [])
  and compile_cond0 env outer = function
  | Cond (inner1, e1, inner2, b2, b3) ->
    let (env1, env') = split inner1 env in
    let (env2, env3) = split inner2 env' in
    let (outer', inner1') = assoc_splitting outer inner1 in
    let (outerR, innerR) = assoc_splitting inner1' inner2 in
    let (outerL, innerL) = assoc_splitting inner1' (flip_splitting inner2) in
    (((compile_expr0 env1 outer' e1),
    (compile_binds0 env2 innerL (right_usages outerL) b2)),
    (compile_binds0 env3 innerR (right_usages outerR) b3))
  in compile_binds0

(** val compile_cond :
    'a1 -> ('a1 -> 'a2 -> ('a1, 'a2, 'a3) static_args -> ('a1, string) node
    list) -> ('a3 -> ('a1, string) node) -> ('a3 -> ('a1, string) node) ->
    ('a1, string) node list -> splitting -> ('a1, 'a2, 'a3) cond -> (('a1,
    string) node list * ('a1, string) node list) * ('a1, string) node list **)

let compile_cond nil op_code lit_type lit_value =
  let rec compile_expr0 env outer = function
  | E_var _ -> compile_splitting nil outer
  | E_let_in (_, inner, e1, e2) ->
    let (env1, env2) = split inner env in
    let (outer0, inner0) = assoc_splitting outer inner in
    (Seq (nil, (compile_expr0 env1 outer0 e1))) :: ((Seq (nil,
    (compile_binds0 env2 inner0 (filter_keeps (right_usages outer0)) e2))) :: [])
  | E_tuple (_, args0) ->
    (Seq (nil, (compile_args0 env outer args0))) :: ((Seq (nil,
      (coq_PAIR nil (args_length args0)))) :: [])
  | E_let_tuple (_, inner, e1, e2) ->
    let (env1, env2) = split inner env in
    let (outer0, inner0) = assoc_splitting outer inner in
    (Seq (nil, (compile_expr0 env1 outer0 e1))) :: ((Seq (nil,
    (coq_UNPAIR nil (binds_length e2)))) :: ((Seq (nil,
    (compile_binds0 env2 inner0 (filter_keeps (right_usages outer0)) e2))) :: []))
  | E_proj (_, e0, i, n) ->
    (Seq (nil, (compile_expr0 env outer e0))) :: ((Seq (nil,
      (coq_GET nil i n))) :: [])
  | E_update (_, args0, i, n) ->
    (Seq (nil, (compile_args0 env outer args0))) :: ((Seq (nil,
      (coq_UPDATE nil i n))) :: [])
  | E_app (_, e0) ->
    (Seq (nil, (compile_args0 env outer e0))) :: ((Prim (nil, "SWAP", [],
      [])) :: ((Prim (nil, "EXEC", [], [])) :: []))
  | E_lam (_, e0, b) ->
    let a =
      let Binds (_, l0, _) = e0 in
      (match l0 with
       | [] -> Prim (nil, "unit", [], [])
       | a :: l1 ->
         (match l1 with
          | [] -> a
          | _ :: _ -> Prim (nil, "unit", [], [])))
    in
    (match env with
     | [] ->
       (Seq (nil, (compile_splitting nil outer))) :: ((Prim (nil, "LAMBDA",
         (a :: (b :: ((Seq (nil, (compile_binds0 [] [] [] e0))) :: []))),
         [])) :: [])
     | _ :: _ ->
       let body =
         let Binds (l, l0, e1) = e0 in
         (match l with
          | [] ->
            (Seq (nil, ((Prim (nil, "DUP", [], [])) :: ((Prim (nil, "CDR",
              [], [])) :: ((Prim (nil, "SWAP", [], [])) :: ((Prim (nil,
              "CAR", [], [])) :: [])))))) :: ((Seq (nil,
              (coq_UNPAIR nil (length env)))) :: ((Prim (nil, "DIG", ((Int
              (nil, (Z.of_nat (length env)))) :: []), [])) :: ((Seq (nil,
              (compile_binds0 env (repeat Left (length env))
                (repeat Keep (length env)) e0))) :: [])))
          | u :: l1 ->
            (match u with
             | Drop ->
               (match l1 with
                | [] ->
                  (match l0 with
                   | [] ->
                     (Seq (nil, ((Prim (nil, "DUP", [], [])) :: ((Prim (nil,
                       "CDR", [], [])) :: ((Prim (nil, "SWAP", [],
                       [])) :: ((Prim (nil, "CAR", [],
                       [])) :: [])))))) :: ((Seq (nil,
                       (coq_UNPAIR nil (length env)))) :: ((Prim (nil, "DIG",
                       ((Int (nil, (Z.of_nat (length env)))) :: []),
                       [])) :: ((Seq (nil,
                       (compile_binds0 env (repeat Left (length env))
                         (repeat Keep (length env)) e0))) :: [])))
                   | _ :: l2 ->
                     (match l2 with
                      | [] ->
                        (Prim (nil, "CAR", [], [])) :: ((Seq (nil,
                          (coq_UNPAIR nil (length env)))) :: ((Seq (nil,
                          (compile_expr0 env (repeat Left (length env)) e1))) :: []))
                      | _ :: _ ->
                        (Seq (nil, ((Prim (nil, "DUP", [], [])) :: ((Prim
                          (nil, "CDR", [], [])) :: ((Prim (nil, "SWAP", [],
                          [])) :: ((Prim (nil, "CAR", [],
                          [])) :: [])))))) :: ((Seq (nil,
                          (coq_UNPAIR nil (length env)))) :: ((Prim (nil,
                          "DIG", ((Int (nil,
                          (Z.of_nat (length env)))) :: []), [])) :: ((Seq
                          (nil,
                          (compile_binds0 env (repeat Left (length env))
                            (repeat Keep (length env)) e0))) :: [])))))
                | _ :: _ ->
                  (Seq (nil, ((Prim (nil, "DUP", [], [])) :: ((Prim (nil,
                    "CDR", [], [])) :: ((Prim (nil, "SWAP", [],
                    [])) :: ((Prim (nil, "CAR", [], [])) :: [])))))) :: ((Seq
                    (nil, (coq_UNPAIR nil (length env)))) :: ((Prim (nil,
                    "DIG", ((Int (nil, (Z.of_nat (length env)))) :: []),
                    [])) :: ((Seq (nil,
                    (compile_binds0 env (repeat Left (length env))
                      (repeat Keep (length env)) e0))) :: []))))
             | Keep ->
               (Seq (nil, ((Prim (nil, "DUP", [], [])) :: ((Prim (nil, "CDR",
                 [], [])) :: ((Prim (nil, "SWAP", [], [])) :: ((Prim (nil,
                 "CAR", [], [])) :: [])))))) :: ((Seq (nil,
                 (coq_UNPAIR nil (length env)))) :: ((Prim (nil, "DIG", ((Int
                 (nil, (Z.of_nat (length env)))) :: []), [])) :: ((Seq (nil,
                 (compile_binds0 env (repeat Left (length env))
                   (repeat Keep (length env)) e0))) :: [])))))
       in
       (Seq (nil, (compile_splitting nil outer))) :: ((Seq (nil,
       (coq_PAIR nil (length env)))) :: ((Prim (nil, "LAMBDA", ((Prim (nil,
       "pair", ((comb nil env) :: (a :: [])), [])) :: (b :: ((Seq (nil,
       body)) :: []))), [])) :: ((Prim (nil, "SWAP", [], [])) :: ((Prim (nil,
       "APPLY", [], [])) :: [])))))
  | E_operator (l, op, sargs, args0) ->
    (Seq (nil, (compile_args0 env outer args0))) :: ((Seq (nil,
      (op_code l op sargs))) :: [])
  | E_literal (_, lit) ->
    (Prim (nil, "PUSH", ((lit_type lit) :: ((lit_value lit) :: [])),
      [])) :: []
  | E_pair (_, e0) ->
    (Seq (nil, (compile_args0 env outer e0))) :: ((Prim (nil, "PAIR", [],
      [])) :: [])
  | E_car (_, e0) ->
    (Seq (nil, (compile_expr0 env outer e0))) :: ((Prim (nil, "CAR", [],
      [])) :: [])
  | E_cdr (_, e0) ->
    (Seq (nil, (compile_expr0 env outer e0))) :: ((Prim (nil, "CDR", [],
      [])) :: [])
  | E_unit _ ->
    (Seq (nil, (compile_splitting nil outer))) :: ((Prim (nil, "UNIT", [],
      [])) :: [])
  | E_left (_, b, e0) ->
    (Seq (nil, (compile_expr0 env outer e0))) :: ((Prim (nil, "LEFT",
      (b :: []), [])) :: [])
  | E_right (_, a, e0) ->
    (Seq (nil, (compile_expr0 env outer e0))) :: ((Prim (nil, "RIGHT",
      (a :: []), [])) :: [])
  | E_if_left (_, e0) ->
    let (p, e3) = compile_cond0 env outer e0 in
    let (e1, e2) = p in
    (Seq (nil, e1)) :: ((Prim (nil, "IF_LEFT", ((Seq (nil, e2)) :: ((Seq
    (nil, e3)) :: [])), [])) :: [])
  | E_if_bool (_, e0) ->
    let (p, e3) = compile_cond0 env outer e0 in
    let (e1, e2) = p in
    (Seq (nil, e1)) :: ((Prim (nil, "IF", ((Seq (nil, e2)) :: ((Seq (nil,
    e3)) :: [])), [])) :: [])
  | E_if_none (_, e0) ->
    let (p, e3) = compile_cond0 env outer e0 in
    let (e1, e2) = p in
    (Seq (nil, e1)) :: ((Prim (nil, "IF_NONE", ((Seq (nil, e2)) :: ((Seq
    (nil, e3)) :: [])), [])) :: [])
  | E_if_cons (_, e0) ->
    let (p, e3) = compile_cond0 env outer e0 in
    let (e1, e2) = p in
    (Seq (nil, e1)) :: ((Prim (nil, "IF_CONS", ((Seq (nil, e2)) :: ((Seq
    (nil, e3)) :: [])), [])) :: [])
  | E_iter (_, inner, e1, e2) ->
    let (env1, env2) = split inner env in
    let inner0 = flip_splitting inner in
    let (outer0, inner1) = assoc_splitting outer inner0 in
    (Seq (nil, (compile_expr0 env2 outer0 e2))) :: ((Prim (nil, "ITER", ((Seq
    (nil, ((Seq (nil,
    (compile_binds0 env1 (keep_rights (left_usages inner1))
      (filter_keeps (right_usages outer0)) e1))) :: ((Prim (nil, "DROP", [],
    [])) :: [])))) :: []), [])) :: ((Seq (nil,
    (compile_usages nil (right_usages inner1)))) :: ((Prim (nil, "UNIT", [],
    [])) :: [])))
  | E_map (_, inner, e1, e2) ->
    let (env1, env2) = split inner env in
    let inner0 = flip_splitting inner in
    let (outer0, inner1) = assoc_splitting outer inner0 in
    (Seq (nil, (compile_expr0 env2 outer0 e2))) :: ((Prim (nil, "MAP", ((Seq
    (nil,
    (compile_binds0 env1 (keep_rights (left_usages inner1))
      (filter_keeps (right_usages outer0)) e1))) :: []), [])) :: ((Seq (nil,
    (compile_usages nil (Keep :: (right_usages inner1))))) :: []))
  | E_loop_left (_, inner, e1, b, e2) ->
    let (env1, env2) = split inner env in
    let inner0 = flip_splitting inner in
    let (outer0, inner1) = assoc_splitting outer inner0 in
    (Seq (nil, (compile_expr0 env2 outer0 e2))) :: ((Prim (nil, "LEFT",
    (b :: []), [])) :: ((Prim (nil, "LOOP_LEFT", ((Seq (nil,
    (compile_binds0 env1 (keep_rights (left_usages inner1))
      (filter_keeps (right_usages outer0)) e1))) :: []), [])) :: ((Seq (nil,
    (compile_usages nil (Keep :: (right_usages inner1))))) :: [])))
  | E_fold (_, inner1, e1, inner2, e2, e3) ->
    let (env1, env') = split inner1 env in
    let (env2, env3) = split inner2 env' in
    let (outer0, inner3) = assoc_splitting outer inner1 in
    let (inner4, inner5) = assoc_splitting inner3 inner2 in
    (Seq (nil, (compile_expr0 env1 outer0 e1))) :: ((Seq (nil,
    (compile_expr0 env2 (Right :: inner4) e2))) :: ((Prim (nil, "ITER", ((Seq
    (nil, ((Prim (nil, "SWAP", [], [])) :: ((Prim (nil, "PAIR", [],
    [])) :: ((Seq (nil,
    (compile_binds0 env3 (keep_rights (left_usages inner5))
      (filter_keeps (right_usages inner4)) e3))) :: []))))) :: []),
    [])) :: ((Seq (nil,
    (compile_usages nil (Keep :: (right_usages inner5))))) :: [])))
  | E_fold_right (_, elem, inner1, e1, inner2, e2, e3) ->
    let (env1, env') = split inner1 env in
    let (env2, env3) = split inner2 env' in
    let (outer0, inner3) = assoc_splitting outer inner1 in
    let (inner4, inner5) = assoc_splitting inner3 inner2 in
    (Seq (nil, (compile_expr0 env1 outer0 e1))) :: ((Seq (nil,
    (compile_expr0 env2 (Right :: inner4) e2))) :: ((Seq (nil, ((Prim (nil,
    "NIL", (elem :: []), [])) :: ((Prim (nil, "SWAP", [], [])) :: ((Prim
    (nil, "ITER", ((Seq (nil, ((Prim (nil, "CONS", [], [])) :: []))) :: []),
    [])) :: []))))) :: ((Prim (nil, "ITER", ((Seq (nil, ((Prim (nil, "PAIR",
    [], [])) :: ((Seq (nil,
    (compile_binds0 env3 (keep_rights (left_usages inner5))
      (filter_keeps (right_usages inner4)) e3))) :: [])))) :: []),
    [])) :: ((Seq (nil,
    (compile_usages nil (Keep :: (right_usages inner5))))) :: []))))
  | E_failwith (x, e0) ->
    (Seq (nil, (compile_expr0 env outer e0))) :: ((Prim (x, "FAILWITH", [],
      [])) :: [])
  | E_raw_michelson (_, a, b, code) ->
    (Prim (nil, "PUSH", ((Prim (nil, "lambda", (a :: (b :: [])),
      [])) :: ((Seq (nil, code)) :: [])), [])) :: []
  | E_global_constant (_, _, hash, args0) ->
    (Seq (nil, (compile_args0 env outer args0))) :: ((Prim (nil, "constant",
      ((String (nil, hash)) :: []), [])) :: [])
  and compile_args0 env outer = function
  | Args_nil -> []
  | Args_cons (inner, e0, args0) ->
    let (env1, env2) = split inner env in
    let (outer', inner') = assoc_splitting outer inner in
    (Seq (nil, (compile_expr0 env1 outer' e0))) :: ((Seq (nil,
    (compile_args0 env2 (Right :: inner') args0))) :: [])
  and compile_binds0 env outer proj = function
  | Binds (us, az, e0) ->
    let env' = app (select us az) env in
    let outer' = app (repeat Left (length (select us az))) outer in
    (Seq (nil, (compile_usages nil (app us proj)))) :: ((Seq (nil,
    (compile_expr0 env' outer' e0))) :: [])
  and compile_cond0 env outer = function
  | Cond (inner1, e1, inner2, b2, b3) ->
    let (env1, env') = split inner1 env in
    let (env2, env3) = split inner2 env' in
    let (outer', inner1') = assoc_splitting outer inner1 in
    let (outerR, innerR) = assoc_splitting inner1' inner2 in
    let (outerL, innerL) = assoc_splitting inner1' (flip_splitting inner2) in
    (((compile_expr0 env1 outer' e1),
    (compile_binds0 env2 innerL (right_usages outerL) b2)),
    (compile_binds0 env3 innerR (right_usages outerR) b3))
  in compile_cond0

(** val destruct_last : 'a1 list -> ('a1, 'a1 list) sigT option **)

let rec destruct_last = function
| [] -> None
| y :: l0 ->
  Some
    (match destruct_last l0 with
     | Some s -> let Coq_existT (x, s0) = s in Coq_existT (x, (y :: s0))
     | None -> Coq_existT (y, []))
