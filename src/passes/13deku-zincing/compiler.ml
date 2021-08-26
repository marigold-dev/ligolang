module AST = Ast_typed

let compile_module : AST.module_fully_typed -> Zinc.Types.program =
 fun ast ->
  let ast = match ast with Module_Fully_Typed a -> a in
  let fst = match ast |> List.hd with Some a -> a in
  let content = fst.wrap_content in
  let idk =
    match content with
    | Declaration_constant declaration_constant -> assert false
    | Declaration_type declaration_type -> assert false
    | Declaration_module declaration_module -> assert false
    | Module_alias module_alias -> assert false
  in
  idk
