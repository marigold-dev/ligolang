open Trace
module AST = Ast_typed

(* Types defined in ../../stages/6deku-zinc/types.ml *)

let compile_type ~raise t =
  t |> Spilling.compile_type ~raise |> fun x -> x.type_content

let rec tail_compile :
    raise:Errors.zincing_error raise -> AST.expression -> 'a Zinc.Types.zinc =
 fun ~raise expr ->
  let compile_function ?return:(ret = false) tail_compiled_func args =
    let rec comp l =
      match l with
      | [] ->
          if ret then List.append tail_compiled_func Zinc.Types.[ Return ]
          else tail_compiled_func
      | arg :: args -> other_compile ~raise ~k:(comp args) arg
    in
    args |> List.rev |> comp
  in

  match expr.expression_content with
  | E_constant constant ->
      let compiled_constant =
        compile_constant ~raise constant expr.type_expression
      in
      compile_function ~return:true [ compiled_constant ] constant.arguments
  | _ -> other_compile ~raise ~k:[ Return ] expr

and other_compile :
    raise:Errors.zincing_error raise ->
    AST.expression ->
    k:'a Zinc.Types.zinc ->
    'a Zinc.Types.zinc =
 fun ~raise:_ expr ~k ->
  match expr.expression_content with
  | E_literal literal -> (
      match literal with
      | Literal_int x -> Num x :: k
      | Literal_address s -> Address s :: k
      | Literal_bytes b -> Bytes b :: k
      | _ -> failwith "literal type not supported")
  | E_constant _constant -> failwith "E_constant unimplemented"
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

and compile_constant :
    raise:Errors.zincing_error raise ->
    AST.constant ->
    AST.type_expression ->
    'a Zinc.Types.zinc_instruction =
 fun ~raise constant type_expression ->
  match constant.cons_name with
  | C_BYTES_UNPACK -> (
      match type_expression.type_content with
      | T_constant
          { injection = Verbatim "option"; parameters = [ unpacking_type ] } ->
          let compiled_type = compile_type ~raise unpacking_type in
          Unpack compiled_type
      | _ ->
          failwith "Incomprehensible type when processing an unpack expression!"
      )
  | _ -> failwith "Consant type not supported"

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
      (name, tail_compile ~raise declaration_constant.expr)
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
