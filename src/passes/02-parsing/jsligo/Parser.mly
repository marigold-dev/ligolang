%{
(* START HEADER *)

[@@@warning "-42"]

open Simple_utils.Region
module CST = Cst_jsligo.CST
open! CST

(* Utilities *)

let mk_wild region =
  let variable = {value="_"; region} in
  let value = {variable; attributes=[]}
  in {region; value}

let list_of_option = function
       None -> []
| Some list -> list

(* END HEADER *)
%}

(* Reductions on error *)

%on_error_reduce gt
%on_error_reduce nseq(Attr)
%on_error_reduce bin_op(add_expr_level,PLUS,mult_expr_level)
%on_error_reduce bin_op(add_expr_level,MINUS,mult_expr_level)
%on_error_reduce call_expr_level
%on_error_reduce bin_op(disj_expr_level,BOOL_OR,conj_expr_level)
%on_error_reduce type_expr
%on_error_reduce core_type
%on_error_reduce chevrons(type_ctor_args)
%on_error_reduce disj_expr_level
%on_error_reduce as_expr_level
%on_error_reduce member_expr
%on_error_reduce add_expr_level
%on_error_reduce nsepseq(binding_initializer,COMMA)
%on_error_reduce nsepseq(module_name,DOT)
%on_error_reduce base_stmt(statement)
%on_error_reduce unary_expr_level
%on_error_reduce bin_op(comp_expr_level,NE,add_expr_level)
%on_error_reduce bin_op(comp_expr_level,LT,add_expr_level)
%on_error_reduce bin_op(comp_expr_level,LE,add_expr_level)
%on_error_reduce bin_op(comp_expr_level,gt,add_expr_level)
%on_error_reduce bin_op(comp_expr_level,GE,add_expr_level)
%on_error_reduce bin_op(comp_expr_level,EQ2,add_expr_level)
%on_error_reduce expr_stmt
%on_error_reduce comp_expr_level
%on_error_reduce conj_expr_level
%on_error_reduce bin_op(conj_expr_level,BOOL_AND,comp_expr_level)
%on_error_reduce return_stmt
(*%on_error_reduce nsepseq(type_expr,COMMA)*)
%on_error_reduce nsepseq(statement,SEMI)
%on_error_reduce nsepseq(variant,VBAR)

(* See [ParToken.mly] for the definition of tokens. *)

(* Entry points *)

%start contract interactive_expr
%type <CST.t> contract
%type <CST.expr> interactive_expr

%%

(* RULES *)

(* Compound constructs *)

par(X):
  "(" X ")" {
    let region = cover $1 $3
    and value  = {lpar=$1; inside=$2; rpar=$3}
    in {region; value} }

chevrons(X):
  "<" X ">" ioption(ZWSP) {
    let region = cover $1 $3
    and value  = {lchevron=$1; inside=$2; rchevron=$3}
    in {region; value} }

gt:
  ">" ioption(ZWSP) { $1 }

%inline brackets(X):
  "[" X "]" {
    let region = cover $1 $3
    and value  = {lbracket=$1; inside=$2; rbracket=$3}
    in {region; value} }

braces(X):
  "{" X "}" {
    let region = cover $1 $3
    and value  = {lbrace=$1; inside=$2; rbrace=$3}
    in {region; value} }

(* Sequences

   Series of instances of the same syntactical category have often to
   be parsed, like lists of expressions, patterns etc. The simplest of
   all is the possibly empty sequence (series), parsed below by
   [seq]. The non-empty sequence is parsed by [nseq]. Note that the
   latter returns a pair made of the first parsed item (the parameter
   [X]) and the rest of the sequence (possibly empty). This way, the
   OCaml typechecker can keep track of this information along the
   static control-flow graph. See module [Utils] for the types
   corresponding to the semantic actions of those rules. *)

(* Non-empty sequence of items *)

nseq(X):
  X         { $1, [] }
| X nseq(X) { let hd,tl = $2 in $1, hd::tl }

(* Non-empty separated sequence of items *)

nsepseq(item,sep):
  item                       {                        $1, [] }
| item sep nsepseq(item,sep) { let h,t = $3 in $1, ($2,h)::t }

(* The rule [sep_or_term(item,sep)] ("separated or terminated list")
   parses a non-empty list of items separated by [sep], and optionally
   terminated by [sep]. *)

sep_or_term_list(item,sep):
  nsepseq(item,sep) {
    $1, None
  }
| nseq(item sep {$1,$2}) {
    let (first,sep), tail = $1 in
    let rec trans (seq, prev_sep as acc) = function
      [] -> acc
    | (item, next_sep) :: others ->
        trans ((prev_sep,item)::seq, next_sep) others in
    let list, term = trans ([],sep) tail
    in (first, List.rev list), Some term }

(* Helpers *)

%inline type_param  : "<ident>"  { $1 }
%inline field_name  : "<ident>"  { $1 }
%inline module_name : "<uident>" { $1 }
%inline ctor        : "<uident>" { $1 }

(* NOTES *)

(* The reason for rules [if_cond], [while_cond] and [switch_cond],
   instead of the obvious [par(expr)], is meant to identify the
   syntactic construct for error messages. The only [par(expr)] as a
   left-hand side in an LR item corresponds to
   [member_expr: ... | par(expr)]
   so the context is clear: a general expression between parentheses. *)

(* Entry point *)

interactive_expr:
  expr EOF { $1 }

(* Entry point *)

contract:
  toplevel_stmts EOF { {statements=$1; eof=$2} : CST.t }

(* TOP-LEVEL STATEMENTS *)

toplevel_stmts:
  stmt_or_namespace ";" toplevel_stmts {
    Utils.nseq_cons (TopLevel ($1, Some $2)) $3
  }
| stmt_or_namespace ";"? {
    TopLevel ($1,$2), []
  }
| "<directive>" toplevel_stmts {
    Utils.nseq_cons (Directive $1) $2 }

stmt_or_namespace:
  statement | namespace_stmt { $1 }

(* Namespace Statement *)

namespace_stmt:
  "export" namespace {
    let region = cover $1 (statement_to_region $2)
    in SExport {region; value=$1,$2} }
| namespace { $1 }

namespace:
 "namespace" module_name braces(stmts_or_namespace) {
    let region = cover $1 $3.region
    in SNamespace {region; value=$1,$2,$3} }

stmts_or_namespace: (* TODO: Keep terminator *)
  sep_or_term_list(stmt_or_namespace,";") { fst $1 }

(* STATEMENTS *)

statement:
  base_stmt(statement) | if_stmt(statement) { $1 }

base_stmt(right_stmt):
  expr_stmt                  { SExpr   $1 }
| return_stmt                { SReturn $1 }
| block_stmt                 { SBlock  $1 }
| switch_stmt                { SSwitch $1 }
| import_stmt                { SImport $1 }
| export_decl                { SExport $1 }
| declaration
| if_else_stmt(right_stmt)
| for_of_stmt(right_stmt)
| while_stmt(right_stmt)     { $1 }

closed_stmt:
  base_stmt(closed_stmt) { $1 }

(* Bounded loops *)

for_of_stmt(right_stmt):
  "for" "(" index_kind "<ident>" "of" expr_stmt ")" right_stmt {
    let stop   = statement_to_region $8 in
    let region = cover $1 stop
    and value  = {kwd_for=$1; lpar=$2; index_kind=$3; index=$4;
                  kwd_of=$5; expr=$6; rpar=$7; statement=$8}
    in SForOf {region; value} }

index_kind:
  "const" { `Const $1 }
| "let"   { `Let   $1 }

(* Unbounded loops *)

while_stmt(right_stmt):
  "while" par(while_cond) right_stmt {
    let cond : expr par reg = $2 in
    let {lpar; inside=expr; rpar} : expr CST.par = cond.value in
    let region = cover $1 (statement_to_region $3)
    and value = {kwd_while=$1; lpar; expr; rpar; statement=$3}
    in SWhile {region; value} }

while_cond:
  expr { $1 }

(* Expressions as Statements *)

expr_stmt:
  as_expr_level "=" expr_stmt  { EAssign     ($1, {value = Eq;       region = $2}, $3) }
| as_expr_level "*=" expr_stmt { EAssign     ($1, {value = Assignment_operator Times_eq; region = $2}, $3) }
| as_expr_level "/=" expr_stmt { EAssign     ($1, {value = Assignment_operator Div_eq;   region = $2}, $3) }
| as_expr_level "%=" expr_stmt { EAssign     ($1, {value = Assignment_operator Mod_eq;   region = $2}, $3) }
| as_expr_level "+=" expr_stmt { EAssign     ($1, {value = Assignment_operator Plus_eq;  region = $2}, $3) }
| as_expr_level "-=" expr_stmt { EAssign     ($1, {value = Assignment_operator Min_eq;   region = $2}, $3) }
| fun_expr                    { EFun    $1         }
| as_expr_level               { $1 }

as_expr_level:
  as_expr_level "as" type_expr {
    let start  = expr_to_region $1
    and stop   = type_expr_to_region $3 in
    let region = cover start stop
    and value  = $1, $2, $3
    in EAnnot {region; value}
  }
| disj_expr_level { $1 }

disj_expr_level:
  bin_op(disj_expr_level, "||", conj_expr_level) {
    ELogic (BoolExpr (Or $1)) }
| conj_expr_level { $1 }

bin_op(arg1,op,arg2):
  arg1 op arg2 {
    let start  = expr_to_region $1
    and stop   = expr_to_region $3 in
    let region = cover start stop
    and value  = {arg1=$1; op=$2; arg2=$3}
    in {region; value} }

conj_expr_level:
  bin_op(conj_expr_level, "&&", comp_expr_level) {
    ELogic (BoolExpr (And $1)) }
| comp_expr_level { $1 }

comp_expr_level:
  bin_op(comp_expr_level, "<", add_expr_level)  {
    ELogic (CompExpr (Lt $1)) }
| bin_op(comp_expr_level, "<=", add_expr_level) {
    ELogic (CompExpr (Leq $1)) }
| bin_op(comp_expr_level, gt, add_expr_level)   {
    ELogic (CompExpr (Gt $1)) }
| bin_op(comp_expr_level, ">=", add_expr_level) {
    ELogic (CompExpr (Geq $1)) }
| bin_op(comp_expr_level, "==", add_expr_level) {
    ELogic (CompExpr (Equal $1)) }
| bin_op(comp_expr_level, "!=", add_expr_level) {
    ELogic (CompExpr (Neq $1)) }
| add_expr_level { $1 }

add_expr_level:
  bin_op(add_expr_level, "+", mult_expr_level)   {  EArith (Add $1) }
| bin_op(add_expr_level, "-", mult_expr_level)   {  EArith (Sub $1) }
| mult_expr_level                                {               $1 }

mult_expr_level:
  bin_op(mult_expr_level, "*", unary_expr_level) { EArith (Mult $1) }
| bin_op(mult_expr_level, "/", unary_expr_level) {  EArith (Div $1) }
| bin_op(mult_expr_level, "%", unary_expr_level) {  EArith (Mod $1) }
| unary_expr_level                               {               $1 }

unary_expr_level:
  "-" call_expr_level {
    let start = $1 in
    let stop = expr_to_region $2 in
    let region = cover start stop
    and value  = {op=$1; arg=$2}
    in EArith (Neg {region; value})
  }
| "!" call_expr_level {
    let start = $1 in
    let stop = expr_to_region $2 in
    let region = cover start stop
    and value  = {op=$1; arg=$2} in
    ELogic (BoolExpr (Not ({region; value})))
  }
| call_expr_level { $1 }

call_expr_level:
  call_expr | member_expr { $1 }

(* Function calls *)

call_expr:
  lambda par(ioption(nsepseq(fun_arg,","))) {
    let par    = $2.value in
    let start  = expr_to_region $1
    and stop   = $2.region in
    let region = cover start stop in
    let args   =
      match par.inside with
        None ->
          Unit {region=stop; value = (par.lpar, par.rpar)}
      | Some args ->
          Multiple {$2 with value = {par with inside=args}}
    in ECall {region; value = ($1, args)} }

fun_arg:
  expr { $1 }

lambda:
  call_expr | member_expr { $1 }

(* General expressions *)

expr:
  expr_stmt | object_literal { $1 }

member_expr:
  "<ident>"       { EVar     $1          }
| "<int>"         { EArith   (Int $1)    }
| "<bytes>"       { EBytes   $1          }
| "<string>"      { EString  (String $1) }
| ctor_expr       { EConstr  $1          }
| projection      { EProj    $1          }
| code_inj        { ECodeInj $1          }
| par(expr)       { EPar     $1          }
| module_access_e { EModA    $1          }
| array_literal   { EArray   $1          }
| "_"             { EVar     {value="_"; region=$1} }

(* Qualified values *)

module_access_e:
  module_name "." module_var_e {
    let start  = $1.region in
    let stop   = expr_to_region $3 in
    let region = cover start stop in
    let value  = {module_name=$1; selector=$2; field=$3}
    in {region; value} }

module_var_e:
  module_access_e { EModA $1 }
| field_name      { EVar  $1 }
(* | projection      { EProj $1 }*) (* TODO *)

(* Code injection *)

code_inj:
  "<ident>" "<verbatim>"
| "<uident>" "<verbatim>"    {
    let region = cover $1.region $2.region
    and value  = {language=$1; code = EString (Verbatim $2)}
    in {region; value} }

(* Tuple projection *)

projection:
  member_expr brackets(expr) {
    let region = cover (expr_to_region $1) $2.region in
    let value  = {expr=$1; selection = Component $2 }
    in {region; value}
  }
| member_expr "." field_name {
    let selection =
      FieldName {region = cover $2 $3.region;
                 value  = {dot=$2; value=$3}} in
    let region = cover (expr_to_region $1) $3.region
    and value  = {expr=$1; selection}
    in {region; value} }

(* Constructor applications *)

ctor_expr:
  ctor "(" ctor_args? ")" {
    let region = cover $1.region $4
    in {region; value = $1,$3} }

ctor_args:
  nsepseq(ctor_arg,",") {
    let region = nsepseq_to_region expr_to_region $1
    in ESeq {region; value=$1} }

ctor_arg:
  expr_stmt { $1 }

(* Export Declaration *)

export_decl:
  "export" declaration {
    let region = cover $1 (statement_to_region $2)
    in {region; value=($1,$2)} }

(* Block of Statements *)

block_stmt:
  braces(statements) { $1 : (statement, semi) Utils.nsepseq braces reg}

(* Switch Statement *)

switch_stmt:
  "switch" par(switch_cond) braces(cases) {
    let par : expr CST.par reg = $2 in
    let {lpar; inside=expr; rpar} : expr CST.par = par.value in
    let braces : _ CST.braces reg = $3 in
    let {lbrace; inside=cases; rbrace} : _ CST.braces = braces.value in
    let region = cover $1 $3.region in
    let value = {kwd_switch=$1; lpar; expr; rpar;
                 lbrace; cases; rbrace}
    in {region; value} }

switch_cond:
  expr { $1 }

cases:
  nseq(case) ioption(default_case) {
    match $2 with
      None -> $1
    | Some default ->
       Utils.(nseq_rev $1 |> nseq_cons default |> nseq_rev)
  }
| default_case { $1,[] }

case:
  "case" expr ":" ioption(case_statements) {
    Switch_case {kwd_case=$1; expr=$2; colon=$3; statements=$4} }

default_case:
  "default" ":" ioption(case_statements) {
    Switch_default_case {kwd_default=$1; colon=$2; statements=$3} }

case_statements:
  sep_or_term_list(case_statement,";") {
    fst $1 : (statement, semi) Utils.nsepseq }

case_statement:
  statement { $1 }

(* Return Statements *)

return_stmt:
  "return" {
    let value = {kwd_return=$1; expr=None}
    in {region=$1; value}
  }
| "return" expr {
    let region = cover $1 (expr_to_region $2)
    and value  = {kwd_return=$1; expr = Some $2}
    in {region; value} }

(* Conditional Statements *)

if_stmt(right_stmt):
  "if" par(if_cond) right_stmt {
    let region = cover $1 (statement_to_region $3) in
    let value  = {kwd_if=$1; test=$2.value; ifso=$3; ifnot=None}
    in SCond {region; value} }

if_else_stmt(right_stmt):
  "if" par(if_cond) closed_stmt "else" right_stmt {
    let region = cover $1 (statement_to_region $5)
    and value  = {kwd_if=$1; test=$2.value; ifso=$3; ifnot = Some ($4,$5)}
    in SCond {region; value} }

if_cond:
  expr { $1 }

(* Array Patterns *)

array_pattern:
  brackets(array_item_patterns) { PArray $1 }

array_item_patterns:
  array_item_pattern {
    $1, []
  }
| array_item_patterns "," array_item_pattern {
    Utils.(nsepseq_rev $1 |> nsepseq_cons $3 $2 |> nsepseq_rev)
  }
| array_item_patterns "," array_rest_pattern  {
    Utils.(nsepseq_rev $1 |> nsepseq_cons $3 $2 |> nsepseq_rev) }

array_item_pattern:
  var_pattern   { PVar $1           }
| "_"           { PVar (mk_wild $1) }
| array_pattern { $1                }

array_rest_pattern:
  "..." "<ident>" {
    let region = cover $1 $2.region
    and value  = {ellipsis=$1; rest=$2}
    in PRest {region; value} }

type_annotation:
  ":" type_expr { $1, $2 }

(* Attributes *)

%inline attributes:
  ioption(nseq("[@attr]") { Utils.nseq_to_list $1 }) { list_of_option $1 }

(* DECLARATIONS *)

declaration:
  let_decl | const_decl | type_decl { $1 }

let_decl:
  attributes "let" binding_list {
    let stop   = nsepseq_to_region (fun e -> e.region) $3 in
    let region = cover $2 stop
    and value  = {kwd_let=$2; bindings=$3; attributes=$1}
    in SLet {region; value} }

const_decl:
  attributes "const" binding_list {
    let stop   = nsepseq_to_region (fun e -> e.region) $3 in
    let region = cover $2 stop
    and value  = {kwd_const=$2; bindings=$3; attributes=$1}
    in SConst {region; value} }

(* PATTERNS *)

binding_list:
  nsepseq(binding_initializer,",") { $1 }

binding_initializer:
  binding_pattern ioption(type_annotation) "=" expr {
    let start  = pattern_to_region $1
    and stop   = expr_to_region $4 in
    let region = cover start stop
    and value  = {binders=$1; lhs_type=$2; eq=$3; expr=$4}
    in {region; value} }

binding_pattern:
  var_pattern    { PVar $1 }
| "_"            { PVar (mk_wild $1) }
| object_pattern
| array_pattern  { $1 }

var_pattern:
  attributes "<ident>" {
    let value = {variable=$2; attributes=$1}
    in {$2 with value} }

(* Record patterns (a.k.a. "object patterns" in JS) *)

object_pattern:
  braces(property_patterns) { PObject $1 }

property_patterns:
  property_pattern {
    $1, []
  }
| property_patterns "," property_pattern {
    Utils.(nsepseq_rev $1 |> nsepseq_cons $3 $2 |> nsepseq_rev)
  }
| property_patterns "," object_rest_pattern {
    Utils.(nsepseq_rev $1 |> nsepseq_cons $3 $2 |> nsepseq_rev) }

property_pattern:
  "<ident>" "=" expr {
    let region = cover $1.region (expr_to_region $3) in
    let value  = {property=$1; eq=$2; value=$3}
    in PAssign {region; value}
  }
| "<ident>" ":" binding_initializer {
    let region = cover $1.region $3.region
    and value  = {property=$1; colon=$2; target=$3}
    in PDestruct {region; value}
  }
| var_pattern { PVar $1 }

object_rest_pattern:
  "..." "<ident>" {
    let region = cover $1 $2.region
    and value  = {ellipsis=$1; rest=$2}
    in PRest {region; value} }

(* Type declarations *)

type_decl:
  "type" type_name ioption(type_params) "=" type_expr {
    let region = cover $1 (type_expr_to_region $5) in
    let value  = {kwd_type=$1; name=$2; params=$3; eq=$4; type_expr=$5}
    in SType {region; value} }

type_params:
  chevrons(nsepseq(type_param,",")) { $1 }

%inline
type_name:
  "<ident>" | "<uident>" { $1 }

(* TYPE EXPRESSIONS *)

type_expr:
  fun_type | sum_type | core_type { $1 }

(* Functional types *)

fun_type:
  par(nsepseq(fun_param,",")) "=>" type_expr {
    let stop   = type_expr_to_region $3 in
    let region = cover $1.region stop
    and value  = $1.value, $2, $3
    in TFun {region; value} }

fun_param:
  "<ident>" type_annotation {
    let colon, type_expr = $2
    in {name=$1; colon; type_expr} }

(* Sum types *)

sum_type:
  attributes "|" nsepseq(variant, "|") {
    let start    = $2 in
    let stop     = nsepseq_to_region (fun x -> x.region) $3 in
    let region   = cover start stop in
    let variants = {region; value=$3} in
    let value    = {attributes=$1; leading_vbar = Some $2; variants}
    in TSum {region; value} }

variant:
  attributes brackets(variant_comp) {
    let region = $2.region
    and value  = {attributes=$1; tuple=$2}
    in {region; value} }

%inline variant_comp:
  "<string>"                 { {constr=$1; params = None} }
| "<string>" "," ctor_params { {constr=$1; params = Some ($2,$3)} }

ctor_params:
  nsepseq(ctor_param,",") { $1 }

ctor_param:
  type_expr { $1 }

(* Core types *)

core_type:
  "<string>"            { TString $1 }
| "<int>"               { TInt    $1 }
| "_"                   { TVar    {value="_"; region=$1} }
| type_name             { TVar    $1 }
| module_access_t       { TModA   $1 }
| object_type           { TObject $1 }
| type_ctor_app         { TApp    $1 }
| attributes type_tuple { TProd   {inside=$2; attributes=$1} }
| par(type_expr)        { TPar    $1 }

(* Tuples of types *)

type_tuple:
  brackets(type_components) { $1 }

type_components:
  nsepseq(type_component,",") { $1 }

type_component:
  type_expr { $1 }

(* Application of type arguments to type constructors *)

type_ctor_app:
  type_name chevrons(type_ctor_args) {
    let region = cover $1.region $2.region
    in {region; value = $1,$2} }

type_ctor_args:
  nsepseq(type_ctor_arg,",") { $1 }

type_ctor_arg:
  type_expr { $1 }

(* Selection of types in modules (a.k.a. qualified type name) *)

module_access_t:
  "<uident>" "." module_var_t {
    let start  = $1.region
    and stop   = type_expr_to_region $3 in
    let region = cover start stop
    and value  = {module_name=$1; selector=$2; field=$3}
    in {region; value} }

module_var_t:
  module_access_t { TModA $1 }
| "<ident>"       { TVar  $1 }

(* Record types (a.k.a. "object types" in JS) *)

object_type:
  attributes "{" sep_or_term_list(field_decl,",") "}" {
    let fields, terminator = $3 in
    let region = cover $2 $4
    and value = {
      compound = Some (Braces ($2,$4));
      ne_elements = fields;
      terminator;
      attributes=$1}
    in {region; value} }

field_decl:
  attributes field_name {
    let value = {
      field_name=$2;
      colon=ghost;  (* TODO: Create a "new" CST node *)
      field_type = TVar $2;
      attributes=$1}
    in {$2 with value}
  }
| attributes field_name type_annotation {
    let colon, field_type = $3 in
    let stop   = type_expr_to_region field_type in
    let region = cover $2.region stop in
    let value : field_decl = {
      field_name=$2; colon; field_type; attributes= $1}
    in {region; value} }

(* Import statement *)

import_stmt:
  "import" module_name "=" nsepseq(module_name,".") {
    let region = cover $1 (nsepseq_to_region (fun a -> a.region) $4)
    and value = {kwd_import=$1; alias=$2; equal=$3; module_path=$4}
    in {region; value} }

(* Statements *)

(* TODO: Keep terminator *)
statements:
  sep_or_term_list(statement,";") {
    fst $1 : (statement, semi) Utils.nsepseq }

(* Expressions *)

fun_expr:
  par(parameters) ioption(type_annotation) "=>" body {
    let region = cover $1.region (body_to_region $4) in
    let value  = {parameters = EPar $1; lhs_type=$2; arrow=$3; body=$4}
    in {region; value}
  }
| "(" ")" ioption(type_annotation) "=>" body {
    let region     = cover $1 $2 in
    let parameters = EUnit {region; value = ($1,$2)} in
    let region     = cover $1 (body_to_region $5) in
    let value      = {parameters; lhs_type=$3; arrow=$4; body=$5}
    in {region; value}
  }
| "<ident>" "=>" body {
    let region     = cover $1.region (body_to_region $3)
    and parameters = EVar $1 in
    let value = {parameters; lhs_type=None; arrow=$2; body=$3}
    in {region; value} }

parameters:
  nsepseq(parameter,",") {
    let region = nsepseq_to_region expr_to_region $1
    in ESeq {region; value=$1} }

(* Note: we use [expr] to avoid an LR conflict, and obtain instead
   the item
   ## par(expr) -> LPAR expr . RPAR [ ... ]
   ## parameter -> expr . type_annotation [ RPAR COMMA ]
*)

parameter:
  expr type_annotation {
    let colon, type_expr = $2 in
    let start  = expr_to_region $1
    and stop   = type_expr_to_region type_expr in
    let region = cover start stop
    and value  = $1, colon, type_expr
    in EAnnot {region; value} }

body:
  braces(statements) { FunctionBody   $1 }
| expr_stmt          { ExpressionBody $1 }

(* Tuples (a.k.a "arrays" is JS) *)

array_item:
  expr       { Expr_entry $1 }
| "..." expr {
  let region = cover $1 (expr_to_region $2) in
  let value: array_item_rest = {ellipsis=$1; expr =$2}
  in Rest_entry {region; value} }

array_literal:
  brackets(ioption(nsepseq(array_item,","))) { $1 }

(* Records (a.k.a. "objects" in JS) *)

object_literal: (* TODO: keep the terminator *)
  braces(sep_or_term_list(property,",") { fst $1 }) { EObject $1 }

property:
  field_name {
    let region = $1.region
    and value  = EVar $1 in
    Punned_property {region; value}
  }
| property_name ":" expr {
    let region = cover (expr_to_region $1) (expr_to_region $3)
    and value = {name=$1; colon=$2; value=$3}
    in Property {region; value}
  }
| "..." expr_stmt {
    let region = cover $1 (expr_to_region $2)
    and value : CST.property_rest = {ellipsis=$1; expr=$2}
    in Property_rest {region; value} }

property_name:
  "<int>"    {       EArith (Int $1) }
| ctor
| field_name {               EVar $1 }
| "<string>" {   EString (String $1) }
