(* Driver for the JsLIGO parser *)

(* Vendor dependencies *)

module Region = Simple_utils.Region

(* Internal dependencies *)

module Comments      = Preprocessing_jsligo.Comments
module File          = Preprocessing_jsligo.File
module Token         = Lexing_jsligo.Token
module Self_tokens   = Lexing_jsligo.Self_tokens
module CST           = Cst_jsligo.CST
module ParErr        = Parser_msg
module ParserMainGen = Parsing_shared.ParserMainGen

(* CLIs *)

module Preproc_CLI = Preprocessor.CLI.Make (Comments)
module   Lexer_CLI =     LexerLib.CLI.Make (Preproc_CLI)
module  Parser_CLI =    ParserLib.CLI.Make (Lexer_CLI)

(* Renamings on the parser generated by Menhir to suit the functor. *)

module Parser =
  struct
    include Parsing_jsligo.Parser
    type tree = CST.t

    let main = contract

    module Incremental =
      struct
        let main = Incremental.contract
      end
  end

module Pretty =
  struct
    include Parsing_jsligo.Pretty
    type tree = CST.t
  end

module Printer =
  struct
    include Cst_jsligo.Printer
    type tree = CST.t
  end

(* Finally... *)

module Main = ParserMainGen.Make
                (File)
                (Comments)
                (Token)
                (ParErr)
                (Self_tokens)
                (CST)
                (Parser)
                (Printer)
                (Pretty)
                (Parser_CLI)

let () = Main.check_cli ()
let () = Main.parse ()
