module Errors = Errors
module Helpers = Helpers

let module_obj ~raise = Helpers.map_module @@ Obj_ligo.check_obj_ligo ~raise
let expression_obj ~raise = Obj_ligo.check_obj_ligo ~raise

let all_module_passes ~add_warning ~raise = [
  Unused.unused_map_module ~add_warning;
  Muchused.muchused_map_module ~add_warning;
  Helpers.map_module @@ Recursion.check_tail_expression ~raise ;
  Helpers.map_module @@ Recursion.remove_rec_expression ;
  Helpers.map_module @@ Pattern_matching_simpl.peephole_expression ~raise ;
]

let all_expression_passes ~raise = [
  Helpers.map_expression @@ Recursion.check_tail_expression ~raise ;
  Helpers.map_expression @@ Recursion.remove_rec_expression ;
  Pattern_matching_simpl.peephole_expression ~raise ;
  Obj_ligo.check_obj_ligo ~raise ;
]

let contract_passes ~raise = [
  Contract_passes.self_typing ~raise ;
  No_nested_big_map.self_typing ~raise ;
  Contract_passes.entrypoint_typing ~raise ;
]

let all_module ~add_warning ~raise init =
  List.fold ~f:(|>) (all_module_passes ~add_warning ~raise) ~init

let all_expression ~raise init =
  List.fold ~f:(|>) (all_expression_passes ~raise) ~init

let all_contract ~raise main_name prg =
  let contract_type = Helpers.fetch_contract_type ~raise main_name prg in
  let data : Contract_passes.contract_pass_data = {
    contract_type = contract_type ;
    main_name = main_name ;
    } in
  let all_p = List.map ~f:(fun pass -> Helpers.fold_map_module pass data) @@ contract_passes ~raise in
  let prg = List.fold ~f:(fun x f -> snd @@ f x) all_p ~init:prg in
  let prg = Contract_passes.remove_unused ~raise main_name prg in
  let prg = module_obj ~raise prg in
  prg

let all = [
  Recursion.check_tail_expression
]

let map_expression = Helpers.map_expression

let fold_expression = Helpers.fold_expression

let fold_map_expression = Helpers.fold_map_expression
