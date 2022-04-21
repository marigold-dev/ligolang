module AST = Ast_typed
module T = AST.Types
module S = Simple_utils
module Trace = S.Trace

let ident_of_var var = Format.asprintf "%a" T.Var.pp var

let compile_type :
    raise:Errors.compiler_error Trace.raise -> AST.type_expression -> _ =
 fun ~raise (t : AST.type_expression) ->
  t |> Aggregation.compile_type ~raise |> Spilling.compile_type ~raise
  |> fun x -> x.type_content

(*** used to convert `[("a", expr1)] result` to `let a = expr1 in result` *)
let make_expression_with_dependencies :
    (T.expression_variable * AST.expression) list ->
    AST.expression ->
    AST.expression =
 fun dependencies expression ->
  let loc = Simple_utils.Location.Virtual "generated let" in
  dependencies
  |> List.fold ~init:expression ~f:(fun result (binder, expression) ->
         {
           expression_content =
             E_let_in
               {
                 let_binder = binder;
                 rhs = expression;
                 let_result = result;
                 attr =
                   {
                     inline = false;
                     no_mutation = false;
                     view = false;
                     public = false;
                   };
               };
           location = loc;
           type_expression = expression.type_expression;
         })

let match_record_rewrite :
    matchee:AST.expression -> AST.matching_content_record -> AST.expression =
 fun ~matchee -> function
  | { fields = binders; body; _ } ->
    let open Stage_common.Types in
    let fresh = T.Var.fresh () in
    let loc =
      Simple_utils.Location.Virtual "generated let around match expression"
    in
    let dependencies =
      LMap.bindings binders
      |> List.map ~f:(fun (label, (binder, type_expression)) ->
             ( binder,
               {
                 T.expression_content =
                   E_record_accessor
                     {
                       record =
                         {
                           expression_content = E_variable fresh;
                           location = loc;
                           type_expression;
                         };
                       path = label;
                     };
                 location = loc;
                 type_expression;
               } )) in
    let lettified = make_expression_with_dependencies dependencies body in
    let lettified =
      {
        T.expression_content =
          E_let_in
            {
              let_binder = fresh;
              rhs = matchee;
              let_result = lettified;
              attr =
                {
                  inline = false;
                  no_mutation = false;
                  view = false;
                  public = false;
                };
            };
        type_expression = matchee.type_expression;
        location = loc;
      } in
    lettified

let rec compile_ast :
    raise:Errors.compiler_error Trace.raise ->
    Syntax.expr Map.M(String).t ->
    AST.declaration_constant ->
    Syntax.expr =
 fun ~raise eenv decl -> compile_expr ~raise eenv decl.expr

and compile_let_in ~raise eenv (let_in : T.let_in) =
  let binder = ident_of_var let_in.let_binder in
  let rhs = compile_expr ~raise eenv let_in.rhs in
  let eenv = Map.add_exn ~data:rhs ~key:binder eenv in
  compile_expr ~raise eenv let_in.let_result

and compile_expr ~raise eenv expr =
  let open Syntax in
  match expr.expression_content with
  | E_literal lit -> (
    match lit with
    | Literal_int l
    | Literal_mutez l ->
      Syntax.Const (Z.to_int64 l)
    | Literal_unit -> Syntax.Const 0L
    | err ->
      failwith
        (Format.asprintf "literal type not supported: %a" AST.PP.literal err))
  | E_variable var ->
    let var_name = ident_of_var var in
    Map.find eenv var_name |> Option.value ~default:(Var var_name)
  | E_constant const -> (
    let match_prim = function
      | T.C_ADD -> Add
      | C_SUB -> Sub
      | C_MUL -> Mul
      | C_DIV -> Div
      | C_NEG -> Neg
      | C_MOD -> Rem (* todo needs abs *)
      | C_OR -> Lor
      | C_AND -> Land
      | C_EDIV -> failwith "todo" (* encode with prim or ligo code? *)
      | _ -> failwith "unreachable" in
    match const.cons_name with
    | (C_ADD | C_SUB | C_MUL | C_DIV | C_MOD | C_OR | C_AND) as x ->
      App
        {
          funct =
            App
              {
                funct = Prim (match_prim x);
                arg = compile_expr ~raise eenv @@ List.hd_exn const.arguments;
              };
          arg = compile_expr ~raise eenv @@ List.last_exn const.arguments;
        }
    | C_PAIR ->
      List.fold_right
        ~init:(compile_expr ~raise eenv @@ List.last_exn const.arguments)
        ~f:(fun x acc ->
          Pair { first = compile_expr ~raise eenv x; second = acc })
      @@ List.drop_last_exn const.arguments
    | C_NEG as prim ->
      App
        {
          funct = Prim (match_prim prim);
          arg = compile_expr ~raise eenv @@ List.hd_exn const.arguments;
        }
    | C_FALSE -> Const 0L
    | C_TRUE -> Const 1L
    | _ -> failwith "todo")
  | E_lambda lam ->
    Lam (ident_of_var lam.binder, compile_expr ~raise eenv lam.result)
  | E_application app ->
    App
      {
        funct = compile_expr ~raise eenv app.lamb;
        arg = compile_expr ~raise eenv app.args;
      }
  | E_let_in expr -> compile_let_in ~raise eenv expr
  | E_matching { matchee; cases = Match_record record } ->
    compile_expr ~raise eenv (match_record_rewrite ~matchee record)
  | E_matching { matchee; cases = Match_variant variant } ->
    compile_pattern_matching ~raise eenv ~matchee variant
  | E_record_accessor { record; path } ->
    let rows = record.type_expression.type_content in
    Format.printf "%a" AST.PP.expression record;
    let var = compile_expr ~raise eenv record in
    let label =
      match rows with
      | T_record rows ->
        let[@warning "-8"] (Some (label, _)) =
          let bindings = T.LMap.bindings rows.content in
          List.findi bindings ~f:(fun _ (k, _) -> Poly.(k = path)) in
        (T.LMap.cardinal rows.content, label)
      | T_sum rows ->
        let (Label path) = path in
        (T.LMap.cardinal rows.content, int_of_string path)
      | T_constant _ ->
        let (Stage_common.Types.Label path) = path in
        (2, int_of_string path)
      | x ->
        failwith @@ Format.asprintf "constructor %a\n" AST.PP.type_content x
    in
    let access =
      match label with
      | 2, 0 -> App { funct = Prim Fst; arg = var }
      | 2, 1 -> App { funct = Prim Snd; arg = var }
      | _size, _idx ->
        (* FIX ME*)
        var in
    access
  | E_record expression_label_map ->
    let bindings = Stage_common.Types.LMap.bindings expression_label_map in
    List.fold_right
      ~init:(compile_expr ~raise eenv @@ snd @@ List.last_exn bindings)
      ~f:(fun (_, x) acc ->
        Pair { first = compile_expr ~raise eenv x; second = acc })
    @@ List.drop_last_exn bindings
  | E_constructor { constructor = Label "TRUE"; element = _ } -> Const 1L
  | E_constructor { constructor = Label "FALSE"; element = _ } -> Const 0L
  | E_constructor { constructor = Label constructor; element } -> (
    let idx =
      expr.type_expression.type_content |> function
      | T_sum r
      | T_record r ->
        let rows = T.LMap.keys r.content in
        List.findi ~f:(fun _ (T.Label x) -> Poly.(constructor = x)) rows
        |> Stdlib.Option.get
        |> fst
      | T_constant const
        when String.(Stage_common.Constant.to_string const.injection = "option")
        -> (
        match constructor with
        | "Some" -> 0
        | "None" -> 1
        | x -> failwith @@ Format.asprintf "invalid constructor %s" x)
      | x ->
        failwith
        @@ Format.asprintf "Unsupported type in pattern match: %a\n"
             AST.PP.type_content x in
    match element.expression_content with
    | T.E_literal Literal_unit -> Const (Int.to_int64 idx)
    | _ ->
      Pair
        {
          first = Const (Int.to_int64 idx);
          second = compile_expr ~raise eenv element;
        })
  | _ -> failwith @@ Format.asprintf "unsupported %a" AST.PP.expression expr

and compile_pattern_matching ~raise environment ~matchee cases =
  let compiled_type = compile_type ~raise matchee.T.type_expression in
  let pattern_match_common cases fn =
    let code =
      List.map
        ~f:(fun { T.constructor = Label lbl; pattern = ppat; body } ->
          let eenv =
            Map.set environment ~key:(ident_of_var ppat)
              ~data:(compile_expr ~raise environment body) in
          let compiled = compile_expr ~raise eenv body in
          Printf.printf "label: %s \n" lbl;
          let idx = fn lbl in
          (idx, compiled))
        cases
      |> List.sort ~compare:(fun (x, _) (y, _) -> Int.compare x y)
      |> List.map ~f:snd in
    List.fold_right
      ~f:(fun x acc ->
        Syntax.If { predicate = Const 1L; alternative = acc; consequent = x })
      ~init:(List.last_exn code)
    @@ List.drop_last_exn code in
  match (compiled_type, cases) with
  | T_or _, { cases; _ } ->
    let rows =
      matchee.type_expression.type_content |> function
      | T_sum r
      | T_record r ->
        T.LMap.keys r.content
      | x -> failwith @@ Format.asprintf "%a\n" AST.PP.type_content x in
    let fn lbl =
      List.findi ~f:(fun _ (Label label) -> String.(label = lbl)) rows
      |> Stdlib.Option.get
      |> fst in
    pattern_match_common cases fn
  | T_option _, { cases; _ } ->
    pattern_match_common cases (function
      | "Some" -> 0
      | "None" -> 1
      | _ -> failwith "invalid case")
  | T_base TB_bool, { cases; _ } ->
    pattern_match_common cases (function
      | "False" -> 0
      | "True" -> 1
      | _ -> failwith "invalid case")
  | _ ->
    failwith
      (Format.asprintf
         "E_matching unimplemented. Need to implement matching for %a"
         Mini_c.PP.type_content
         (compile_type ~raise matchee.type_expression))

let compile_module :
    raise:Errors.compiler_error Trace.raise -> AST.program -> Syntax.expr =
 fun ~raise ast ->
  let constant_declaration_extractor :
      AST.declaration_loc -> AST.declaration_constant option = function
    | { wrap_content = Declaration_constant declaration_constant; _ } ->
      Some declaration_constant
    | _ -> None in
  let constants = List.filter_map ~f:constant_declaration_extractor ast in
  let eenv = Map.empty (module String) in
  let _, compiled =
    List.fold_left constants ~init:(eenv, Syntax.Const 1L)
      ~f:(fun (eenv, _) decl ->
        let compiled = compile_ast ~raise eenv decl in
        let binder = T.Var.to_name_exn decl.binder in
        let eenv = Map.set ~key:binder ~data:compiled eenv in
        (eenv, compiled)) in
  compiled
