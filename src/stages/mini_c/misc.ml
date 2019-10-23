open Types
open Combinators
open Trace

module Errors = struct

  let missing_entry_point name =
    let title () = "missing entry point" in
    let content () = "no entry point with the given name" in
    let data = [
      ("name" , fun () -> name) ;
    ] in
    error ~data title content

  let not_functional_main name =
    let title () = "not functional main" in
    let content () = "main should be a function" in
    let data = [
      ("name" , fun () -> Format.asprintf "%s" name) ;
    ] in
    error ~data title content

end

module Free_variables = struct

  type bindings = string list
  let mem : string -> bindings -> bool = List.mem
  let singleton : string -> bindings = fun s -> [ s ]
  let union : bindings -> bindings -> bindings = (@)
  let unions : bindings list -> bindings = List.concat
  let empty : bindings = []
  let of_list : string list -> bindings = fun x -> x

  let rec expression : bindings -> expression -> bindings = fun b e ->
    let self = expression b in
    match e.content with
    | E_literal v -> value b v
    | E_closure f -> lambda b f
    | E_skip -> empty
    | E_constant (_, xs) -> unions @@ List.map self xs
    | E_application (f, x) -> unions @@ [ self f ; self x ]
    | E_variable n -> var_name b n
    | E_make_empty_map _ -> empty
    | E_make_empty_list _ -> empty
    | E_make_empty_set _ -> empty
    | E_make_none _ -> empty
    | E_iterator (_, ((v, _), body), expr) ->
      unions [ expression (union (singleton v) b) body ;
               self expr ;
             ]
    | E_fold (((v, _), body), collection, initial) ->
      unions [ expression (union (singleton v) b) body ;
               self collection ;
               self initial ;
             ]
    | E_if_bool (x, bt, bf) -> unions [ self x ; self bt ; self bf ]
    | E_if_none (x, bn, ((s, _), bs)) ->
      unions [ self x ;
               self bn ;
               expression (union (singleton s) b) bs ;
             ]
    | E_if_cons (x, bnil , (((h, _) , (t, _)) , bcons)) ->
      unions [ self x ;
               self bnil ;
               expression (unions [ singleton h ; singleton t ; b ]) bcons ;
             ]
    | E_if_left (x, ((l, _), bl), ((r, _), br)) ->
      unions [ self x ;
               expression (union (singleton l) b) bl ;
               expression (union (singleton r) b) br ;
             ]
    | E_let_in ((v , _) , expr , body) ->
      unions [ self expr ;
               expression (union (singleton v) b) body ;
             ]
    | E_sequence (x, y) -> union (self x) (self y)
    (* we do not consider the assigned variable free... seems strange,
       but, matches ast_typed, and does not cause any troubles? *)
    | E_assignment (_, _, e) -> self e
    | E_while (cond , body) -> union (self cond) (self body)

  and var_name : bindings -> var_name -> bindings = fun b n ->
    if mem n b
    then empty
    else singleton n

  and value : bindings -> value -> bindings = fun b v ->
    let self = value b in
    match v with
    | D_unit
    | D_bool _
    | D_nat _
    | D_timestamp _
    | D_mutez _
    | D_int _
    | D_string _
    | D_bytes _
    | D_none
    | D_operation _
      -> empty
    | D_pair (x, y) -> unions [ self x ; self y ]
    | D_left x
    | D_right x
    | D_some x
      -> self x
    | D_map kvs
    | D_big_map kvs
      -> unions @@ List.map (fun (k, v) -> unions [ self k ; self v ]) kvs
    | D_list xs
    | D_set xs
      -> unions @@ List.map self xs
    | D_function f ->
      lambda b f

  and lambda : bindings -> anon_function -> bindings = fun b l ->
    let b = union (singleton l.binder) b in
    expression b l.body

end

(*
   Converts `expr` in `fun () -> expr`.
*)
let functionalize (body : expression) : expression =
  let content = E_literal (D_function { binder = "_" ; body }) in
  let type_value = t_function t_unit body.type_value in
  { content ; type_value }

let get_entry (lst : program) (name : string) : (expression * int) result =
  let%bind entry_expression =
    trace_option (Errors.missing_entry_point name) @@
    let aux x =
      let (((decl_name , decl_expr) , _)) = x in
      if (decl_name = name)
      then Some decl_expr
      else None
    in
    List.find_map aux lst
  in
  let entry_index =
    let aux x =
      let (((decl_name , _) , _)) = x in
      decl_name = name
    in
    List.find_index aux lst
  in
  ok (entry_expression , entry_index)


(*
   Assume the following code:
   ```
     const x = 42
     const y = 120
     const z = 423
     const f = () -> x + y
   ```
   It is transformed in:
   ```
     const f = () ->
       let x = 42 in
       let y = 120 in
       let z = 423 in
       x + y
   ```

   The entry-point can be an expression, which is then functionalized if
   `to_functionalize` is set to true.
*)
let aggregate_entry (lst : program) (name : string) (to_functionalize : bool) : expression result =
  let%bind (entry_expression , entry_index) = get_entry lst name in
  let pre_declarations = List.until entry_index lst in
  let wrapper =
    let aux prec cur =
      let (((name , expr) , _)) = cur in
      e_let_in name expr.type_value expr prec
    in
    fun expr -> List.fold_right' aux expr pre_declarations
  in
  match (entry_expression.content , to_functionalize) with
  | (E_literal (D_function l) , false) -> (
      let l' = { l with body = wrapper l.body } in
      let e' = { entry_expression with content = E_literal (D_function l') } in
      ok e'
    )
  | (E_closure l , false) -> (
      let l' = { l with body = wrapper l.body } in
      let%bind t' =
        let%bind (_ , input_ty , output_ty) = get_t_closure entry_expression.type_value in
        ok (t_function input_ty output_ty)
      in
      let e' = {
        content = E_literal (D_function l') ;
        type_value = t' ;
      } in
      ok e'
    )
  | (_ , true) -> (
      ok @@ functionalize @@ wrapper entry_expression
    )
  | _ -> (
      Format.printf "Not functional: %a\n" PP.expression entry_expression ;
      fail @@ Errors.not_functional_main name
  )

let rec expression_to_value (exp: expression) : value result =
  match exp.content with
    | E_literal v -> ok @@ v
    | E_constant ("map" , lst) ->
      let aux el =
        let%bind l = expression_to_value el in
        match l with
          | D_pair (a , b) -> ok @@ (a , b)
          | _ -> fail @@ simple_error "??" in
      let%bind lstl = bind_map_list aux lst in
      ok @@ D_map lstl
    | E_constant ("big_map" , lst) ->
      let aux el =
        let%bind l = expression_to_value el in
        match l with
          | D_pair (a , b) -> ok @@ (a , b)
          | _ -> fail @@ simple_error "??" in
      let%bind lstl = bind_map_list aux lst in
      ok @@ D_big_map lstl
    | E_constant ("PAIR" , fst::snd::[]) ->
      let%bind fstl = expression_to_value fst in
      let%bind sndl = expression_to_value snd in
      ok @@ D_pair (fstl , sndl)
    | E_constant ("UNIT", _) -> ok @@ D_unit
    | E_constant ("UPDATE", _) ->
      let rec handle_prev upd =
        match upd.content with
        | E_constant ("UPDATE" , [k;v;prev]) ->
          begin
            match v.content with
              | E_constant ("SOME" , [i]) ->
                let%bind kl = expression_to_value k in
                let%bind il  = expression_to_value i in
                let%bind prevl = handle_prev prev in
                ok @@ (kl,il)::prevl
              | E_constant ("NONE" , []) ->
                let%bind prevl = handle_prev prev in
                ok @@ prevl
              | _ -> failwith "UPDATE second parameter is not an option"
          end
        | E_make_empty_map _ ->
          ok @@ []
        | _ -> failwith "Ill-constructed map"
      in
      begin
      match exp.type_value with
        | T_big_map _ ->
          let%bind kvl = handle_prev exp in
          ok @@ D_big_map kvl
        | T_map _ ->
          let%bind kvl = handle_prev exp in
          ok @@ D_map kvl
        | _ -> failwith "UPDATE with a non-map type_value"
      end
    | _ as nl ->
      let expp = Format.asprintf "'%a'" PP.expression' nl in
      fail @@ simple_error ("Can not convert expression "^expp^" to literal")
