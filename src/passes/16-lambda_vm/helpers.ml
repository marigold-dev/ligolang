module AST = Ast_typed
module T = AST.Types
module S = Simple_utils
module Trace = S.Trace

let dummy_type_expression () =
  T.
    {
      type_content = T_variable (T.Var.fresh ());
      type_meta = None;
      orig_var = None;
      location = Simple_utils.Location.Virtual "generated dummy type expression";
    }
let expression_content_to_expression e =
  T.
    {
      expression_content = e;
      location = Simple_utils.Location.Virtual "generated";
      type_expression = dummy_type_expression ();
    }

let var_to_e_variable v =
  T.
    {
      expression_content = E_variable v;
      location = Simple_utils.Location.Virtual "generated";
      type_expression = dummy_type_expression ();
    }

let lam c = T.Var.fresh () |> var_to_e_variable |> c

let ( let* ) let' in' =
  let v = T.Var.fresh () in
  T.(
    E_let_in
      {
        let_binder = v;
        rhs = let';
        let_result = in' (var_to_e_variable v);
        attr =
          { inline = false; no_mutation = false; view = false; public = false };
      }
    |> expression_content_to_expression)

let app lamb args =
  List.fold_left
    ~f:(fun acc arg ->
      T.E_application { lamb = acc; args = arg }
      |> expression_content_to_expression)
    ~init:lamb args
