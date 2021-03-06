(* This module is a wrapper for running the LIGO lexers as standalone
   pieces of software. *)

(* Vendor dependencies *)

module Region = Simple_utils.Region
module FQueue = Simple_utils.FQueue
module Markup = LexerLib.Markup
module Core   = LexerLib.Core

(* LIGO dependencies *)

module type FILE = Preprocessing_shared.File.S

(* The functor *)

module Make (File        : FILE)
            (Token       : Token.S)
            (CLI         : LexerLib.CLI.S)
            (Self_tokens : Self_tokens.S with type token = Token.t) =
  struct
    (* All exits *)

    let print_in_red Region.{value=msg; region} =
      let header = region#to_string ~file:true ~offsets:true `Point
      in Printf.eprintf "\027[31mError %s:\n%s\027[0m\n%!" header msg

    let cli_error msg =
      let msg = Printf.sprintf "Command-line error: %s\n" msg
      in Printf.eprintf "\027[31m%s\027[0m%!" msg

    let print_and_quit msg = print_string msg; flush stdout; exit 0

    (* Checking for errors and valid exits *)

    let check_cli () =
      match CLI.status with
        `SyntaxError  msg
      | `FileNotFound msg -> cli_error msg
      | `Help         buf
      | `CLI          buf -> print_and_quit (Buffer.contents buf)
      | `Version      ver -> print_and_quit (ver ^ "\n")
      | `Conflict (o1,o2) ->
           cli_error (Printf.sprintf "Choose either %s or %s." o1 o2)
      | `Done ->
           match CLI.Preprocessor_CLI.extension with
             Some ext when ext <> File.extension ->
               let msg =
                 Printf.sprintf "Expected extension %s." File.extension
               in cli_error msg
           | _ -> ()

    (* Instantiations *)

    module Token = Token
    type token = Token.t

    module Lexer = Lexer.Make (Token)
    module Scan  = LexerLib.API.Make (Lexer)

    let config =
      object
        method block     = CLI.Preprocessor_CLI.block
        method line      = CLI.Preprocessor_CLI.line
        method input     = CLI.Preprocessor_CLI.input
        method offsets   = CLI.Preprocessor_CLI.offsets
        method mode      = CLI.mode
        method command   = CLI.command
        method is_eof    = Token.is_eof
        method to_region = Token.to_region
        method to_lexeme = Token.to_lexeme
        method to_string = Token.to_string
      end

    (* On the one hand, parsers generated by Menhir are functions that
       expect a parameter of type [Lexing.lexbuf -> token]. On the
       other hand, we want to enable self-passes on the tokens (See
       module [Self_tokens]), which implies that we scan the whole
       input before parsing. Therefore, we make believe to the
       Menhir-generated parser that we scan tokens one by one, when,
       in fact, we have lexed them all already.

       We need to use global references to store information as a way
       to workaround the signature of the parser generated by Menhir.

         * The global reference [window] holds a window of one or two
           tokens, used by our parser library [ParserLib] to make
           error messages. That reference is read by the function
           [get_window] and updated by [set_window]. It is cleared to
           its initial state by [clear].

         * The global reference [called] tells us whether the lexer
           [scan] has been called before or not. If not, this triggers
           the scanning of all the tokens; if so, a token is extracted
           from the global reference [tokens] and the window is
           updated. The reference [called] is reset by calling
           [clear].

         * The global reference [tokens] holds all the tokens from a
           given source. The function [scan] updates it the first time
           it is called (see [called] above).

       In particular, when running the parsers twice, we have to call
       [clear] to reset the global state to force the scanning of all
       the tokens from the new lexing buffer.

       WARNING: By design, the state *is* observable from the
       interface of this module when calling [get_window] and [clear],
       which are exported in the signature. *)

    type window = <
      last_token    : token option;
      current_token : token           (* Including EOF *)
    >

    let window     : window option ref    = ref None
    let get_window : unit -> window option = fun () -> !window

    let set_window ~current ~last : unit =
      window := Some (object
                        method last_token    = last
                        method current_token = current
                      end)

    let called : bool ref = ref false

    let clear () =
      begin
        window := None;
        called := false
      end

    type message = string Region.reg
    type menhir_lexer = Lexing.lexbuf -> (token, message) Stdlib.result

    let rec scan : menhir_lexer =
      let store : token list ref = ref [] in
      fun lexbuf ->
        if !called then
          let token =
            match !store with
              token::tokens ->
                let last =
                  match !window with
                    None -> None
                  | Some window -> Some window#current_token in
                set_window ~current:token ~last;
                store := tokens;
                token
            | [] -> Token.mk_eof Region.ghost
          in Stdlib.Ok token
        else
          let lex_units = Scan.LexUnits.from_lexbuf config lexbuf
          in match Self_tokens.filter lex_units with
               Stdlib.Ok tokens ->
                 store  := tokens;
                 called := true;
                 scan lexbuf
             | Error _ as err -> err

    (* Scanning all tokens with or without a preprocessor *)

    module Preproc =
      Preprocessor.PreprocMainGen.Make (CLI.Preprocessor_CLI)

    let scan_all () : unit =
      let lex_units =
        if CLI.preprocess then
          match Preproc.preprocess () with
            Stdlib.Error (_buffer, msg) ->
              (* Buffer [_buffer] already printed *)
              Stdlib.Error msg
          | Ok (buffer, _deps) ->
              (* Module dependencies [_deps] are dropped. *)
              let string = Buffer.contents buffer in
              let lexbuf = Lexing.from_string string
              in Scan.LexUnits.from_lexbuf config lexbuf
        else
          match config#input with
            Some path -> Scan.LexUnits.from_file config path
          |      None -> Scan.LexUnits.from_channel config stdin
      in match Self_tokens.filter lex_units with
           Stdlib.Error msg -> print_in_red msg
         | Ok _ -> ()
  end
