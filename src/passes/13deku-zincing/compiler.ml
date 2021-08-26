module AST = Ast_typed

let compile_module : AST.module_fully_typed -> Zinc.Types.program =
 fun ast ->
  let ast = match ast with Module_Fully_Typed a -> a in
  let fst = match ast |> List.hd with | Some a -> a | None -> assert false in
  let content = fst.wrap_content in
  let idk =
    match content with
    | Declaration_constant _declaration_constant -> assert false
    | Declaration_type _declaration_type -> assert false
    | Declaration_module _declaration_module -> assert false
    | Module_alias _module_alias -> assert false
  in
  idk
