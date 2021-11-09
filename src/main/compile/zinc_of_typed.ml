open Zincing
open Main_errors
open Trace
module SMap = Map.Make (String)

let compile_with_modules ~raise ?module_env:_ :
    Ast_typed.module_fully_typed -> Ast_typed.environment -> Zinc_types.program =
 fun m env ->
  (* trace ~raise spilling_tracer @@ compile_module ~module_env:module_env p *)
  trace ~raise spilling_tracer @@ compile_module m env

let compile ~raise ?(module_env = SMap.empty) :
    Ast_typed.module_fully_typed -> Ast_typed.environment -> Zinc_types.program =
 fun m env ->
  (*let zinc,_ = compile_with_modules ~raise ~module_env:module_env p in
    zinc*)
  let zinc = compile_with_modules ~raise ~module_env m env in
  zinc
