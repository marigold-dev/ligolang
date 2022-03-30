
(* The type of tokens. *)

type token = 
  | ZWSP of (string Wrap.t)
  | While of (string Wrap.t)
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
  | Return of (string Wrap.t)
  | RPAR of (string Wrap.t)
  | REM_EQ of (string Wrap.t)
  | REM of (string Wrap.t)
  | RBRACKET of (string Wrap.t)
  | RBRACE of (string Wrap.t)
  | PLUS_EQ of (string Wrap.t)
  | PLUS of (string Wrap.t)
  | Of of (string Wrap.t)
  | Namespace of (string Wrap.t)
  | NE of (string Wrap.t)
  | MULT_EQ of (string Wrap.t)
  | MINUS_EQ of (string Wrap.t)
  | MINUS of (string Wrap.t)
  | LineCom of (string Wrap.t)
  | Let of (string Wrap.t)
  | LT of (string Wrap.t)
  | LPAR of (string Wrap.t)
  | LE of (string Wrap.t)
  | LBRACKET of (string Wrap.t)
  | LBRACE of (string Wrap.t)
  | Int of ((string * Z.t) Wrap.t)
  | Import of (string Wrap.t)
  | If of (string Wrap.t)
  | Ident of (string Wrap.t)
  | GT of (string Wrap.t)
  | GE of (string Wrap.t)
  | For of (string Wrap.t)
  | Export of (string Wrap.t)
  | Else of (string Wrap.t)
  | EQ2 of (string Wrap.t)
  | EQ of (string Wrap.t)
  | EOF of (string Wrap.t)
  | ELLIPSIS of (string Wrap.t)
  | Directive of (LexerLib.Directive.t)
  | Default of (string Wrap.t)
  | DOT of (string Wrap.t)
  | DIV_EQ of (string Wrap.t)
  | Const of (string Wrap.t)
  | Case of (string Wrap.t)
  | COMMA of (string Wrap.t)
  | COLON of (string Wrap.t)
  | Bytes of ((string * Hex.t) Wrap.t)
  | Break of (string Wrap.t)
  | BlockCom of (string Wrap.t)
  | BOOL_OR of (string Wrap.t)
  | BOOL_NOT of (string Wrap.t)
  | BOOL_AND of (string Wrap.t)
  | Attr of (Attr.t Region.reg)
  | As of (string Wrap.t)
  | ARROW of (string Wrap.t)

(* The indexed type of terminal symbols. *)

type _ terminal = 
  | T_error : unit terminal
  | T_ZWSP : (string Wrap.t) terminal
  | T_While : (string Wrap.t) terminal
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
  | T_Return : (string Wrap.t) terminal
  | T_RPAR : (string Wrap.t) terminal
  | T_REM_EQ : (string Wrap.t) terminal
  | T_REM : (string Wrap.t) terminal
  | T_RBRACKET : (string Wrap.t) terminal
  | T_RBRACE : (string Wrap.t) terminal
  | T_PLUS_EQ : (string Wrap.t) terminal
  | T_PLUS : (string Wrap.t) terminal
  | T_Of : (string Wrap.t) terminal
  | T_Namespace : (string Wrap.t) terminal
  | T_NE : (string Wrap.t) terminal
  | T_MULT_EQ : (string Wrap.t) terminal
  | T_MINUS_EQ : (string Wrap.t) terminal
  | T_MINUS : (string Wrap.t) terminal
  | T_LineCom : (string Wrap.t) terminal
  | T_Let : (string Wrap.t) terminal
  | T_LT : (string Wrap.t) terminal
  | T_LPAR : (string Wrap.t) terminal
  | T_LE : (string Wrap.t) terminal
  | T_LBRACKET : (string Wrap.t) terminal
  | T_LBRACE : (string Wrap.t) terminal
  | T_Int : ((string * Z.t) Wrap.t) terminal
  | T_Import : (string Wrap.t) terminal
  | T_If : (string Wrap.t) terminal
  | T_Ident : (string Wrap.t) terminal
  | T_GT : (string Wrap.t) terminal
  | T_GE : (string Wrap.t) terminal
  | T_For : (string Wrap.t) terminal
  | T_Export : (string Wrap.t) terminal
  | T_Else : (string Wrap.t) terminal
  | T_EQ2 : (string Wrap.t) terminal
  | T_EQ : (string Wrap.t) terminal
  | T_EOF : (string Wrap.t) terminal
  | T_ELLIPSIS : (string Wrap.t) terminal
  | T_Directive : (LexerLib.Directive.t) terminal
  | T_Default : (string Wrap.t) terminal
  | T_DOT : (string Wrap.t) terminal
  | T_DIV_EQ : (string Wrap.t) terminal
  | T_Const : (string Wrap.t) terminal
  | T_Case : (string Wrap.t) terminal
  | T_COMMA : (string Wrap.t) terminal
  | T_COLON : (string Wrap.t) terminal
  | T_Bytes : ((string * Hex.t) Wrap.t) terminal
  | T_Break : (string Wrap.t) terminal
  | T_BlockCom : (string Wrap.t) terminal
  | T_BOOL_OR : (string Wrap.t) terminal
  | T_BOOL_NOT : (string Wrap.t) terminal
  | T_BOOL_AND : (string Wrap.t) terminal
  | T_Attr : (Attr.t Region.reg) terminal
  | T_As : (string Wrap.t) terminal
  | T_ARROW : (string Wrap.t) terminal
