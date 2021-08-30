open Trace
module AST = Ast_typed

(* Types defined in ../../stages/6deku-zinc/types.ml *)

let compile_type ~raise t =
  t |> Spilling.compile_type ~raise |> fun x -> x.type_content

let tail_compile_expression :
    raise:Errors.zincing_error raise -> AST.expression -> 'a Zinc.Types.zinc =
 fun ~raise expr ->
  match expr.expression_content with
  | E_literal literal -> (
      match literal with
      | Literal_int x -> [ Num x ]
      | Literal_address s -> [ Address s ]
      | _ -> failwith "literal type not supported")
  | E_constant constant -> (
      match constant.cons_name with
      | C_BYTES_UNPACK -> (
          match expr.type_expression.type_content with
          | T_constant
              { injection = Verbatim "option"; parameters = [ unpacking_type ] }
            -> (
              let compiled_type = compile_type ~raise unpacking_type in
              match constant.arguments with
              | [] ->
                  [ Unpack compiled_type ]
                  (* actually I think this is wrong, need to return to the sacred texts *)
              | _ -> failwith "just need to remember how lambdas work again")
          | _ ->
              failwith
                "Incomprehensible type when processing an unpack expression!")
      | _ -> failwith "Consant type not supported")
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

and other_compile_expression :
    raise:Errors.zincing_error raise -> AST.expression -> 'a Zinc.Types.zinc =
 fun ~raise:_ _expr ->
  failwith "compiling non-tail calls is currently unimplemented"

let compile_declaration :
    raise:Errors.zincing_error raise ->
    AST.declaration' ->
    string * 'a Zinc.Types.zinc =
 fun ~raise declaration ->
  match declaration with
  | Declaration_constant declaration_constant ->
      let name =
        match declaration_constant.name with
        | Some name -> name
        | None -> failwith "declaration with no name?"
      in
      (name, tail_compile_expression ~raise declaration_constant.expr)
  | Declaration_type _declaration_type -> failwith "types not implemented yet"
  | Declaration_module _declaration_module ->
      failwith "modules not implemented yet"
  | Module_alias _module_alias -> failwith "module aliases not implemented yet"

let compile_module :
    raise:Errors.zincing_error raise ->
    AST.module_fully_typed ->
    Zinc.Types.program =
 fun ~raise modul ->
  let (Module_Fully_Typed ast) = modul in
  List.map ast ~f:(fun wrapped ->
      compile_declaration ~raise wrapped.wrap_content)
