module AST = Ast_typed

let compile_expression : AST.expression -> AST.environment -> 'a Zinc.Types.zinc =
 fun expr environment ->
  match expr.expression_content with
  | E_literal literal -> (
      match literal with
      | Literal_int x -> Zinc.Types.[ Num x ]
      | Literal_address s -> Zinc.Types.[ Address s ]
      | _ -> failwith "literal type not supported")
  | E_constant constant -> (
      match constant.cons_name with
      | C_BYTES_UNPACK ->
        (* Need to get the type, convert it into some standard representation, then store it in the function call to be consumed by the interpreter. 
           But I don't feel like doing this until the interpreter is integrated to some extent so it'll have to wait *)
        let _ = environment.type_environment in 
          failwith
            (Printf.sprintf
               "C_BYTES_UNPACK not supported. (Was provided %d arguments. Type \
                was %s)" 
               (List.length constant.arguments)
               (Format.asprintf "%a" AST.PP.type_expression expr.type_expression))
      | _ ->
          failwith "Consant type not supported"
          (* For language constants, like (Cons hd tl) or (plus i j) *))
  | E_variable _expression_variable -> failwith "E_variable unimplemented"
  | E_application _application -> failwith "E_application unimplemented"
  | E_lambda _lambda -> failwith "E_lambda unimplemented"
  | E_recursive _recursive -> failwith "E_recursive unimplemented"
  | E_let_in _let_in -> failwith "E_let_in unimplemented"
  | E_type_in _type_in -> failwith "E_type_in unimplemented"
  | E_mod_in _mod_in -> failwith "E_mod_in unimplemented"
  | E_mod_alias _mod_alias -> failwith "E_mod_alias unimplemented"
  | E_raw_code _raw_code -> failwith "E_raw_code unimplemented"
  (* Variant *)
  | E_constructor _constructor ->
      failwith "E_constructor unimplemented" (* For user defined constructors *)
  | E_matching _matching -> failwith "E_matching unimplemented"
  (* Record *)
  | E_record _expression_label_map -> failwith "E_record unimplemented"
  | E_record_accessor _record_accessor ->
      failwith "E_record_accessor unimplemented"
  | E_record_update _record_update -> failwith "E_record_update unimplemented"
  | E_module_accessor _module_access ->
      failwith "E_module_accessor unimplemented"

let compile_declaration : AST.declaration' -> AST.environment -> string * 'a Zinc.Types.zinc =
 fun declaration environment ->
  match declaration with
  | Declaration_constant declaration_constant ->
      let name =
        match declaration_constant.name with
        | Some name -> name
        | None -> failwith "declaration with no name?"
      in
      (name, compile_expression declaration_constant.expr environment)
  | Declaration_type _declaration_type -> failwith "types not implemented yet"
  | Declaration_module _declaration_module ->
      failwith "modules not implemented yet"
  | Module_alias _module_alias -> failwith "module aliases not implemented yet"

let compile_module :
    AST.module_fully_typed * Ast_typed.environment -> Zinc.Types.program =
 fun modul ->
  let Module_Fully_Typed ast, env = modul in
  List.map ast ~f:(fun wrapped -> compile_declaration wrapped.wrap_content env)
