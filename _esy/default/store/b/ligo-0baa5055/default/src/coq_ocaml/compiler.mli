open BinInt
open Datatypes
open List
open Nat
open Specif
open Co_de_bruijn
open Ligo
open Micheline

val compile_usages_aux : 'a1 -> nat -> usage list -> ('a1, string) node list

val compile_usages : 'a1 -> usage list -> ('a1, string) node list

val compile_splitting_aux : 'a1 -> nat -> splitting -> ('a1, string) node list

val compile_splitting : 'a1 -> splitting -> ('a1, string) node list

val comb : 'a1 -> ('a1, string) node list -> ('a1, string) node

val coq_PAIR : 'a1 -> nat -> ('a1, string) node list

val coq_UNPAIR : 'a1 -> nat -> ('a1, string) node list

val coq_GET : 'a1 -> nat -> nat -> ('a1, string) node list

val coq_UPDATE : 'a1 -> nat -> nat -> ('a1, string) node list

val compile_expr :
  'a1 -> ('a1 -> 'a2 -> ('a1, 'a2, 'a3) static_args -> ('a1, string) node
  list) -> ('a3 -> ('a1, string) node) -> ('a3 -> ('a1, string) node) ->
  ('a1, string) node list -> splitting -> ('a1, 'a2, 'a3) expr -> ('a1,
  string) node list

val compile_args :
  'a1 -> ('a1 -> 'a2 -> ('a1, 'a2, 'a3) static_args -> ('a1, string) node
  list) -> ('a3 -> ('a1, string) node) -> ('a3 -> ('a1, string) node) ->
  ('a1, string) node list -> splitting -> ('a1, 'a2, 'a3) args -> ('a1,
  string) node list

val compile_binds :
  'a1 -> ('a1 -> 'a2 -> ('a1, 'a2, 'a3) static_args -> ('a1, string) node
  list) -> ('a3 -> ('a1, string) node) -> ('a3 -> ('a1, string) node) ->
  ('a1, string) node list -> splitting -> usage list -> ('a1, 'a2, 'a3) binds
  -> ('a1, string) node list

val compile_cond :
  'a1 -> ('a1 -> 'a2 -> ('a1, 'a2, 'a3) static_args -> ('a1, string) node
  list) -> ('a3 -> ('a1, string) node) -> ('a3 -> ('a1, string) node) ->
  ('a1, string) node list -> splitting -> ('a1, 'a2, 'a3) cond -> (('a1,
  string) node list * ('a1, string) node list) * ('a1, string) node list

val destruct_last : 'a1 list -> ('a1, 'a1 list) sigT option
