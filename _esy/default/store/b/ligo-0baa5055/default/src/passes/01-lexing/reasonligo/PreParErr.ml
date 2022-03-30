
(* This file was auto-generated based on "es6fun_errors.msg.in". *)

(* Please note that the function [message] can raise [Not_found]. *)

let message =
  fun s ->
    match s with
    | 78 ->
        "Unexpected token 5.\n"
    | 79 ->
        "Unexpected token.\n"
    | 0 ->
        "Unexpected token.\n"
    | 71 ->
        "Ill-formed code injection.\nAt this point, if the expression is complete, a closing bracket ']' is expected.\n"
    | 28 | 55 | 54 ->
        "Ill-formed code injection.\n"
    | 81 ->
        "Unexpected token.\n"
    | 57 ->
        "Unexpected token.\n"
    | 52 ->
        "Unexpected token.\n"
    | 59 ->
        "Unexpected token.\n"
    | 68 ->
        "Unexpected token.\n"
    | 76 ->
        "Unexpected token.\n"
    | 69 ->
        "Unexpected token.\n"
    | 31 ->
        "Unexpected token.\n"
    | 65 ->
        "Unexpected token.\n"
    | 33 ->
        "Unexpected token.\n"
    | 66 ->
        "Unexpected token.\n"
    | 62 ->
        "Unexpected token. \n"
    | 34 ->
        "Unexpected token. \n"
    | 83 ->
        "Unexpected token.\n"
    | 63 ->
        "Unexpected token.\n"
    | _ ->
        raise Not_found
