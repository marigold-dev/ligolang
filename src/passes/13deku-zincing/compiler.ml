module AST = Ast_typed

let compile_module : AST.module_fully_typed -> Zinc.Types.program =
 fun ast ->
  let ast = match ast with Module_Fully_Typed a -> a in
  assert false
