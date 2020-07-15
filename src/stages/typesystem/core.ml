type    unionfind             =    Ast_typed.unionfind
type    constant_tag          =    Ast_typed.constant_tag
type    accessor              =    Ast_typed.label
type    type_value            =    Ast_typed.type_value
type    p_constraints         =    Ast_typed.p_constraints
type    p_forall              =    Ast_typed.p_forall
type    simple_c_constructor  =    Ast_typed.simple_c_constructor
type    simple_c_constant     =    Ast_typed.simple_c_constant
type    c_const               =    Ast_typed.c_const
type    c_equation            =    Ast_typed.c_equation
type    c_typeclass           =    Ast_typed.c_typeclass
type    c_access_label        =    Ast_typed.c_access_label
type    type_constraint       =    Ast_typed.type_constraint
type    typeclass             =    Ast_typed.typeclass
type 'a typeVariableMap       = 'a Ast_typed.typeVariableMap
type    structured_dbs        =    Ast_typed.structured_dbs
type    constraints           =    Ast_typed.constraints
type    c_constructor_simpl   =    Ast_typed.c_constructor_simpl
type    c_const_e             =    Ast_typed.c_const_e
type    c_equation_e          =    Ast_typed.c_equation_e
type    c_typeclass_simpl     =    Ast_typed.c_typeclass_simpl
type    c_poly_simpl          =    Ast_typed.c_poly_simpl
type    type_constraint_simpl =    Ast_typed.type_constraint_simpl
type    state                 =    Solver_types.typer_state

type type_variable = Ast_typed.type_variable
type type_expression = Ast_typed.type_expression

(* generate a new type variable and gave it an id *)
let fresh_type_variable : ?name:string -> unit -> type_variable = fun ?name () ->
  let fresh_name = Var.fresh ?name () in
  let () = (if Ast_typed.Debug.debug_new_typer && false then Printf.printf "Generated variable %s\n%!%s\n%!" (Var.debug fresh_name) (Printexc.get_backtrace ())) in
  fresh_name

let type_expression'_of_simple_c_constant : constant_tag * type_expression list -> Ast_typed.type_content option = fun (c, l) ->
  match c, l with
  | C_contract  , [x]     -> Some (Ast_typed.T_operator{operator=TC_contract;args=[x]})
  | C_option    , [x]     -> Some (Ast_typed.T_operator{operator=TC_option; args=[x]})
  | C_list      , [x]     -> Some (Ast_typed.T_operator{operator=TC_list; args=[x]})
  | C_set       , [x]     -> Some (Ast_typed.T_operator{operator=TC_set; args=[x]})
  | C_map       , [k ; v] -> Some (Ast_typed.T_operator{operator=TC_map; args=[k;v]})
  | C_big_map   , [k ; v] -> Some (Ast_typed.T_operator{operator=TC_big_map; args=[k;v]})
  | C_arrow     , [x ; y] -> Some (Ast_typed.T_arrow {type1=x ; type2=y}) (* For now, the arrow type constructor is special *)
  | C_record    , _lst    -> None
  | C_variant   , _lst    -> None
  | (C_contract | C_option | C_list | C_set | C_map | C_big_map | C_arrow ), _ -> None

  | C_unit      , [] -> Some (Ast_typed.T_constant(TC_unit))
  | C_string    , [] -> Some (Ast_typed.T_constant(TC_string))
  | C_bytes     , [] -> Some (Ast_typed.T_constant(TC_bytes))
  | C_nat       , [] -> Some (Ast_typed.T_constant(TC_nat))
  | C_int       , [] -> Some (Ast_typed.T_constant(TC_int))
  | C_mutez     , [] -> Some (Ast_typed.T_constant(TC_mutez))
  | C_operation , [] -> Some (Ast_typed.T_constant(TC_operation))
  | C_address   , [] -> Some (Ast_typed.T_constant(TC_address))
  | C_key       , [] -> Some (Ast_typed.T_constant(TC_key))
  | C_key_hash  , [] -> Some (Ast_typed.T_constant(TC_key_hash))
  | C_chain_id  , [] -> Some (Ast_typed.T_constant(TC_chain_id))
  | C_signature , [] -> Some (Ast_typed.T_constant(TC_signature))
  | C_timestamp , [] -> Some (Ast_typed.T_constant(TC_timestamp))
  | (C_unit | C_string | C_bytes | C_nat | C_int | C_mutez | C_operation | C_address | C_key | C_key_hash | C_chain_id | C_signature | C_timestamp), _::_ ->
      None
