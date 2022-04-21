val expression_content_to_expression :
  Ast_typed.Types.expression_content -> Ast_typed.Types.expression

val lam :
  (Ast_typed.expression -> Ast_typed.Types.expression) ->
  Ast_typed.Types.expression
val dummy_type_expression : unit -> Ast_typed.Types.type_expression
val ( let* ) :
  Ast_typed.Types.expression ->
  (Ast_typed.Types.expression -> Ast_typed.Types.expression) ->
  Ast_typed.Types.expression
val app :
  Ast_typed.Types.expression ->
  Ast_typed.Types.expression list ->
  Ast_typed.Types.expression
