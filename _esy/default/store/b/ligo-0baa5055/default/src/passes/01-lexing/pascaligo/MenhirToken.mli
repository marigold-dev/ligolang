
(* The type of tokens. *)

type token = 
  | With of (string Wrap.t)
  | While of (string Wrap.t)
  | WILD of (string Wrap.t)
  | Verbatim of (string Wrap.t)
  | Var of (string Wrap.t)
  | VBAR_EQ of (string Wrap.t)
  | VBAR of (string Wrap.t)
  | UIdent of (string Wrap.t)
  | Type of (string Wrap.t)
  | To of (string Wrap.t)
  | Then of (string Wrap.t)
  | TIMES_EQ of (string Wrap.t)
  | TIMES of (string Wrap.t)
  | String of (string Wrap.t)
  | Step of (string Wrap.t)
  | Skip of (string Wrap.t)
  | Set of (string Wrap.t)
  | SLASH_EQ of (string Wrap.t)
  | SLASH of (string Wrap.t)
  | SHARP of (string Wrap.t)
  | SEMI of (string Wrap.t)
  | Remove of (string Wrap.t)
  | Recursive of (string Wrap.t)
  | Record of (string Wrap.t)
  | RPAR of (string Wrap.t)
  | RBRACKET of (string Wrap.t)
  | RBRACE of (string Wrap.t)
  | Patch of (string Wrap.t)
  | PLUS_EQ of (string Wrap.t)
  | PLUS of (string Wrap.t)
  | Or of (string Wrap.t)
  | Of of (string Wrap.t)
  | Not of (string Wrap.t)
  | Nil of (string Wrap.t)
  | Nat of ((string * Z.t) Wrap.t)
  | NE of (string Wrap.t)
  | Mutez of ((string * Int64.t) Wrap.t)
  | Module of (string Wrap.t)
  | Mod of (string Wrap.t)
  | Map of (string Wrap.t)
  | MINUS_EQ of (string Wrap.t)
  | MINUS of (string Wrap.t)
  | List of (string Wrap.t)
  | Lang of (string Region.reg Region.reg)
  | LT of (string Wrap.t)
  | LPAR of (string Wrap.t)
  | LE of (string Wrap.t)
  | LBRACKET of (string Wrap.t)
  | LBRACE of (string Wrap.t)
  | Is of (string Wrap.t)
  | Int of ((string * Z.t) Wrap.t)
  | In of (string Wrap.t)
  | If of (string Wrap.t)
  | Ident of (string Wrap.t)
  | GT of (string Wrap.t)
  | GE of (string Wrap.t)
  | Function of (string Wrap.t)
  | From of (string Wrap.t)
  | For of (string Wrap.t)
  | End of (string Wrap.t)
  | Else of (string Wrap.t)
  | EQ of (string Wrap.t)
  | EOF of (string Wrap.t)
  | Directive of (LexerLib.Directive.t)
  | DOT of (string Wrap.t)
  | Contains of (string Wrap.t)
  | Const of (string Wrap.t)
  | Case of (string Wrap.t)
  | COMMA of (string Wrap.t)
  | COLON of (string Wrap.t)
  | CARET of (string Wrap.t)
  | Bytes of ((string * Hex.t) Wrap.t)
  | Block of (string Wrap.t)
  | BigMap of (string Wrap.t)
  | Begin of (string Wrap.t)
  | Attr of (Attr.t Region.reg)
  | And of (string Wrap.t)
  | ASS of (string Wrap.t)
  | ARROW of (string Wrap.t)

(* The indexed type of terminal symbols. *)

type _ terminal = 
  | T_error : unit terminal
  | T_With : (string Wrap.t) terminal
  | T_While : (string Wrap.t) terminal
  | T_WILD : (string Wrap.t) terminal
  | T_Verbatim : (string Wrap.t) terminal
  | T_Var : (string Wrap.t) terminal
  | T_VBAR_EQ : (string Wrap.t) terminal
  | T_VBAR : (string Wrap.t) terminal
  | T_UIdent : (string Wrap.t) terminal
  | T_Type : (string Wrap.t) terminal
  | T_To : (string Wrap.t) terminal
  | T_Then : (string Wrap.t) terminal
  | T_TIMES_EQ : (string Wrap.t) terminal
  | T_TIMES : (string Wrap.t) terminal
  | T_String : (string Wrap.t) terminal
  | T_Step : (string Wrap.t) terminal
  | T_Skip : (string Wrap.t) terminal
  | T_Set : (string Wrap.t) terminal
  | T_SLASH_EQ : (string Wrap.t) terminal
  | T_SLASH : (string Wrap.t) terminal
  | T_SHARP : (string Wrap.t) terminal
  | T_SEMI : (string Wrap.t) terminal
  | T_Remove : (string Wrap.t) terminal
  | T_Recursive : (string Wrap.t) terminal
  | T_Record : (string Wrap.t) terminal
  | T_RPAR : (string Wrap.t) terminal
  | T_RBRACKET : (string Wrap.t) terminal
  | T_RBRACE : (string Wrap.t) terminal
  | T_Patch : (string Wrap.t) terminal
  | T_PLUS_EQ : (string Wrap.t) terminal
  | T_PLUS : (string Wrap.t) terminal
  | T_Or : (string Wrap.t) terminal
  | T_Of : (string Wrap.t) terminal
  | T_Not : (string Wrap.t) terminal
  | T_Nil : (string Wrap.t) terminal
  | T_Nat : ((string * Z.t) Wrap.t) terminal
  | T_NE : (string Wrap.t) terminal
  | T_Mutez : ((string * Int64.t) Wrap.t) terminal
  | T_Module : (string Wrap.t) terminal
  | T_Mod : (string Wrap.t) terminal
  | T_Map : (string Wrap.t) terminal
  | T_MINUS_EQ : (string Wrap.t) terminal
  | T_MINUS : (string Wrap.t) terminal
  | T_List : (string Wrap.t) terminal
  | T_Lang : (string Region.reg Region.reg) terminal
  | T_LT : (string Wrap.t) terminal
  | T_LPAR : (string Wrap.t) terminal
  | T_LE : (string Wrap.t) terminal
  | T_LBRACKET : (string Wrap.t) terminal
  | T_LBRACE : (string Wrap.t) terminal
  | T_Is : (string Wrap.t) terminal
  | T_Int : ((string * Z.t) Wrap.t) terminal
  | T_In : (string Wrap.t) terminal
  | T_If : (string Wrap.t) terminal
  | T_Ident : (string Wrap.t) terminal
  | T_GT : (string Wrap.t) terminal
  | T_GE : (string Wrap.t) terminal
  | T_Function : (string Wrap.t) terminal
  | T_From : (string Wrap.t) terminal
  | T_For : (string Wrap.t) terminal
  | T_End : (string Wrap.t) terminal
  | T_Else : (string Wrap.t) terminal
  | T_EQ : (string Wrap.t) terminal
  | T_EOF : (string Wrap.t) terminal
  | T_Directive : (LexerLib.Directive.t) terminal
  | T_DOT : (string Wrap.t) terminal
  | T_Contains : (string Wrap.t) terminal
  | T_Const : (string Wrap.t) terminal
  | T_Case : (string Wrap.t) terminal
  | T_COMMA : (string Wrap.t) terminal
  | T_COLON : (string Wrap.t) terminal
  | T_CARET : (string Wrap.t) terminal
  | T_Bytes : ((string * Hex.t) Wrap.t) terminal
  | T_Block : (string Wrap.t) terminal
  | T_BigMap : (string Wrap.t) terminal
  | T_Begin : (string Wrap.t) terminal
  | T_Attr : (Attr.t Region.reg) terminal
  | T_And : (string Wrap.t) terminal
  | T_ASS : (string Wrap.t) terminal
  | T_ARROW : (string Wrap.t) terminal
