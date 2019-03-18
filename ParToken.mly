%{
%}

(* Tokens (mirroring thise defined in module LexToken) *)

  (* Literals *)

%token              <LexToken.lexeme Region.reg> String
%token <(LexToken.lexeme * MBytes.t) Region.reg> Bytes
%token      <(LexToken.lexeme * Z.t) Region.reg> Int
%token              <LexToken.lexeme Region.reg> Ident
%token              <LexToken.lexeme Region.reg> Constr

  (* Symbols *)

%token <Region.t> SEMI        (* ";"   *)
%token <Region.t> COMMA       (* ","   *)
%token <Region.t> LPAR        (* "("   *)
%token <Region.t> RPAR        (* ")"   *)
%token <Region.t> LBRACE      (* "{"   *)
%token <Region.t> RBRACE      (* "}"   *)
%token <Region.t> LBRACKET    (* "["   *)
%token <Region.t> RBRACKET    (* "]"   *)
%token <Region.t> CONS        (* "#"   *)
%token <Region.t> VBAR        (* "|"   *)
%token <Region.t> ARROW       (* "->"  *)
%token <Region.t> ASS         (* ":="  *)
%token <Region.t> EQUAL       (* "="   *)
%token <Region.t> COLON       (* ":"   *)
%token <Region.t> OR          (* "||"  *)
%token <Region.t> AND         (* "&&"  *)
%token <Region.t> LT          (* "<"   *)
%token <Region.t> LEQ         (* "<="  *)
%token <Region.t> GT          (* ">"   *)
%token <Region.t> GEQ         (* ">="  *)
%token <Region.t> NEQ         (* "=/=" *)
%token <Region.t> PLUS        (* "+"   *)
%token <Region.t> MINUS       (* "-"   *)
%token <Region.t> SLASH       (* "/"   *)
%token <Region.t> TIMES       (* "*"   *)
%token <Region.t> DOT         (* "."   *)
%token <Region.t> WILD        (* "_"   *)
%token <Region.t> CAT         (* "^"   *)

  (* Keywords *)

%token <Region.t> Begin       (* "begin"      *)
%token <Region.t> Const       (* "const"      *)
%token <Region.t> Copy        (* "copy"       *)
%token <Region.t> Do          (* "do"         *)
%token <Region.t> Down        (* "down"       *)
%token <Region.t> Fail        (* "fail"       *)
%token <Region.t> If          (* "if"         *)
%token <Region.t> In          (* "in"         *)
%token <Region.t> Is          (* "is"         *)
%token <Region.t> Entrypoint  (* "entrypoint" *)
%token <Region.t> For         (* "for"        *)
%token <Region.t> Function    (* "function"   *)
%token <Region.t> Type        (* "type"       *)
%token <Region.t> Of          (* "of"         *)
%token <Region.t> Var         (* "var"        *)
%token <Region.t> End         (* "end"        *)
%token <Region.t> Then        (* "then"       *)
%token <Region.t> Else        (* "else"       *)
%token <Region.t> Match       (* "match"      *)
%token <Region.t> Nothing     (* "nothing"    *)
%token <Region.t> Procedure   (* "procedure"  *)
%token <Region.t> Record      (* "record"     *)
%token <Region.t> Step        (* "step"       *)
%token <Region.t> Storage     (* "storage"    *)
%token <Region.t> To          (* "to"         *)
%token <Region.t> Mod         (* "mod"        *)
%token <Region.t> Not         (* "not"        *)
%token <Region.t> While       (* "while"      *)
%token <Region.t> With        (* "with"       *)

  (* Data constructors *)

%token <Region.t> C_False     (* "False" *)
%token <Region.t> C_None      (* "None"  *)
%token <Region.t> C_Some      (* "Some"  *)
%token <Region.t> C_True      (* "True"  *)
%token <Region.t> C_Unit      (* "Unit"  *)

  (* Virtual tokens *)

%token <Region.t> EOF

%%
