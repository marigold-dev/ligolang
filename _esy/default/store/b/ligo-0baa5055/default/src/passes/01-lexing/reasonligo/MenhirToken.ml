
type token = 
  | WILD of (string Wrap.t)
  | Verbatim of (string Wrap.t)
  | VBAR of (string Wrap.t)
  | UIdent of (string Wrap.t)
  | Type of (string Wrap.t)
  | TIMES of (string Wrap.t)
  | Switch of (string Wrap.t)
  | String of (string Wrap.t)
  | SLASH of (string Wrap.t)
  | SEMI of (string Wrap.t)
  | Rec of (string Wrap.t)
  | RPAR of (string Wrap.t)
  | RBRACKET of (string Wrap.t)
  | RBRACE of (string Wrap.t)
  | QUOTE of (string Wrap.t)
  | PLUS2 of (string Wrap.t)
  | PLUS of (string Wrap.t)
  | Or of (string Wrap.t)
  | Nat of ((string * Z.t) Wrap.t)
  | NOT of (string Wrap.t)
  | NE of (string Wrap.t)
  | Mutez of ((string * Int64.t) Wrap.t)
  | Module of (string Wrap.t)
  | Mod of (string Wrap.t)
  | MINUS of (string Wrap.t)
  | Lxor of (string Wrap.t)
  | Lsr of (string Wrap.t)
  | Lsl of (string Wrap.t)
  | Lor of (string Wrap.t)
  | Let of (string Wrap.t)
  | Lang of (string Region.reg Region.reg)
  | Land of (string Wrap.t)
  | LT of (string Wrap.t)
  | LPAR of (string Wrap.t)
  | LE of (string Wrap.t)
  | LBRACKET of (string Wrap.t)
  | LBRACE of (string Wrap.t)
  | Int of ((string * Z.t) Wrap.t)
  | If of (string Wrap.t)
  | Ident of (string Wrap.t)
  | GT of (string Wrap.t)
  | GE of (string Wrap.t)
  | Else of (string Wrap.t)
  | ES6FUN of (string Wrap.t)
  | EQ2 of (string Wrap.t)
  | EQ of (string Wrap.t)
  | EOF of (string Wrap.t)
  | ELLIPSIS of (string Wrap.t)
  | Directive of (LexerLib.Directive.t)
  | DOT of (string Wrap.t)
  | COMMA of (string Wrap.t)
  | COLON of (string Wrap.t)
  | Bytes of ((string * Hex.t) Wrap.t)
  | BOOL_OR of (string Wrap.t)
  | BOOL_AND of (string Wrap.t)
  | Attr of (Attr.t Region.reg)
  | ARROW of (string Wrap.t)

type _ terminal = 
  | T_error : unit terminal
  | T_WILD : (string Wrap.t) terminal
  | T_Verbatim : (string Wrap.t) terminal
  | T_VBAR : (string Wrap.t) terminal
  | T_UIdent : (string Wrap.t) terminal
  | T_Type : (string Wrap.t) terminal
  | T_TIMES : (string Wrap.t) terminal
  | T_Switch : (string Wrap.t) terminal
  | T_String : (string Wrap.t) terminal
  | T_SLASH : (string Wrap.t) terminal
  | T_SEMI : (string Wrap.t) terminal
  | T_Rec : (string Wrap.t) terminal
  | T_RPAR : (string Wrap.t) terminal
  | T_RBRACKET : (string Wrap.t) terminal
  | T_RBRACE : (string Wrap.t) terminal
  | T_QUOTE : (string Wrap.t) terminal
  | T_PLUS2 : (string Wrap.t) terminal
  | T_PLUS : (string Wrap.t) terminal
  | T_Or : (string Wrap.t) terminal
  | T_Nat : ((string * Z.t) Wrap.t) terminal
  | T_NOT : (string Wrap.t) terminal
  | T_NE : (string Wrap.t) terminal
  | T_Mutez : ((string * Int64.t) Wrap.t) terminal
  | T_Module : (string Wrap.t) terminal
  | T_Mod : (string Wrap.t) terminal
  | T_MINUS : (string Wrap.t) terminal
  | T_Lxor : (string Wrap.t) terminal
  | T_Lsr : (string Wrap.t) terminal
  | T_Lsl : (string Wrap.t) terminal
  | T_Lor : (string Wrap.t) terminal
  | T_Let : (string Wrap.t) terminal
  | T_Lang : (string Region.reg Region.reg) terminal
  | T_Land : (string Wrap.t) terminal
  | T_LT : (string Wrap.t) terminal
  | T_LPAR : (string Wrap.t) terminal
  | T_LE : (string Wrap.t) terminal
  | T_LBRACKET : (string Wrap.t) terminal
  | T_LBRACE : (string Wrap.t) terminal
  | T_Int : ((string * Z.t) Wrap.t) terminal
  | T_If : (string Wrap.t) terminal
  | T_Ident : (string Wrap.t) terminal
  | T_GT : (string Wrap.t) terminal
  | T_GE : (string Wrap.t) terminal
  | T_Else : (string Wrap.t) terminal
  | T_ES6FUN : (string Wrap.t) terminal
  | T_EQ2 : (string Wrap.t) terminal
  | T_EQ : (string Wrap.t) terminal
  | T_EOF : (string Wrap.t) terminal
  | T_ELLIPSIS : (string Wrap.t) terminal
  | T_Directive : (LexerLib.Directive.t) terminal
  | T_DOT : (string Wrap.t) terminal
  | T_COMMA : (string Wrap.t) terminal
  | T_COLON : (string Wrap.t) terminal
  | T_Bytes : ((string * Hex.t) Wrap.t) terminal
  | T_BOOL_OR : (string Wrap.t) terminal
  | T_BOOL_AND : (string Wrap.t) terminal
  | T_Attr : (Attr.t Region.reg) terminal
  | T_ARROW : (string Wrap.t) terminal
