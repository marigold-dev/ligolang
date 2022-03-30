
(* This file was auto-generated based on "errors.msg.in". *)

(* Please note that the function [message] can raise [Not_found]. *)

let message =
  fun s ->
    match s with
    | 144 | 348 ->
        "Ill-formed parametric type declaration.\nAt this point, the right-hand side is expected as a type expression.\n"
    | 143 | 347 ->
        "Ill-formed parametric type declaration.\nAt this point, the assignment symbol '=' is expected, followed by a\ntype expression.\n"
    | 140 | 344 ->
        "Ill-formed type declaration.\nAt this point, one of the following is expected:\n  * the assignment symbol '=' followed by a type expression;\n  * type parameters between chevrons '<' and '>', if defining a\n    parametric type.\n"
    | 438 ->
        "Ill-formed record expression.\nAt this point, one of the following is expected:\n  * another field assignment;\n  * a closing brace '}' if the record type is complete.\n"
    | 437 ->
        "Ill-formed record expression.\nAt this point, if the field is complete, one of the following is\nexpected:\n  * a comma ',' followed by another field;\n  * a closing brace '}' if the record is complete.\n"
    | 112 | 449 ->
        "Ill-formed tuple expression.\nAt this point, one of the following is expected:\n  * a component as an expression;\n  * an ellipsis '...' followed by an expression whose type is a tuple.\n"
    | 232 ->
        "Ill-formed assignment.\nAt this point, the right-hand side is expected as an expression.\n"
    | 336 ->
        "Ill-defined value declaration.\nAt this point, one of the following is expected:\n  * the keyword 'const';\n  * the keyword 'let'.\n"
    | 265 ->
        "Ill-formed attributed variable in a pattern.\nAt this point, if the attribute is complete, a variable is\nexpected.\n"
    | 32 ->
        "Ill-formed record type.\nAt this point, if the attribute is complete, a field name is expected.\n"
    | 56 ->
        "Ill-formed type expression.\nAt this point, one of the following is expected:\n  * an opening brace '{' if defining a record type;\n  * an opening bracket '[' if defining a tuple of types;\n  * a variant of sum type starting with a vertical bar '|'.\n"
    | 0 | 505 | 502 ->
        "Ill-formed contract.\nAt this point, a top-level statement is expected.\n"
    | 1 | 319 ->
        "Ill-formed unbounded (\"while\") loop.\nAt this point, a Boolean expression is expected between parentheses.\n"
    | 2 ->
        "Ill-formed while loop.\nAt this point, a Boolean expression is expected.\n"
    | 480 ->
        "Ill-formed unbounded (\"while\") loop.\nAt this point, if the conditional expression is complete, a closing\nparenthesis ')' is expected.\n"
    | 483 | 320 ->
        "Ill-formed unbounded (\"while\") loop.\nAt this point, the body of the loop is expected as a statement.\n"
    | 504 ->
        "Ill-formed top-level statement.\nAt this point, if the statement is complete, one of the following is\nexpected:\n  * a semicolon ';' followed by another statement;\n  * a semicolon ';' followed by the end of file;\n  * the end of the file.\n"
    | 169 ->
        "Ill-formed function call.\nAt this point, one of the following is expected:\n  * a comma ',' followed by an argument as an expression;\n  * a closing parenthesis ')' if there are no more arguments.\n"
    | 170 ->
        "Ill-formed function call.\nAt this point, an argument is expected as an expression.\n"
    | 163 ->
        "Ill-formed function call.\nAt this point, one of the following is expected:\n  * an argument as an expression;\n  * a closing parenthesis ')' if there are no arguments.\n"
    | 155 ->
        "Ill-formed selection in a tuple.\nAt this point, the index of a component is expected, '0' denoting the\nfirst component.\n"
    | 245 ->
        "Ill-formed selection in a tuple.\nAt this point, a closing bracket ']' is expected.\n"
    | 247 ->
        "Ill-formed selection in a record.\nAt this point, the name of a record field is expected.\n"
    | 285 ->
        "Ill-formed value declaration.\nAt this point, the expression to bound is expected.\n"
    | 178 | 175 | 207 | 205 | 209 | 201 | 199 | 197 | 180 | 191 | 195 | 193 | 160 | 149 | 511 | 8 | 224 | 226 | 228 | 230 | 234 ->
        "Ill-formed expression.\nAt this point, an expression is expected.\n"
    | 102 ->
        "Ill-formed selection of a type in a module.\nAt this point, the selection symbol '.' is expected, followed by the\nqualified name of a type.\n"
    | 85 ->
        "Ill-formed parenthesised type expression.\nAt this point, a closing parenthesis ')' is expected.\n"
    | 89 ->
        "Ill-formed functional type.\nAt this point, if the parameter type is complete, one of the following\nis expected:\n  * a comma ',' followed by a parameter as a variable;\n  * a closing parenthesis ')' if there are no more parameters.\n"
    | 52 ->
        "Ill-formed functional type.\nAt this point, an arrow '=>' is expected, followed by the return type.\n"
    | 90 ->
        "Ill-formed functional type.\nAt this point, a parameter is expected as a variable.\n"
    | 91 ->
        "Ill-formed function parameter declaration.\nAt this point, a colon ':' is expected, followed by the type of the parameter.\n"
    | 36 ->
        "Ill-formed record type.\nAt this point, one of the following is expected:\n  * a comma ',' followed by another field declaration;\n  * a closing brace '}' if the record type is complete.\n"
    | 48 ->
        "Ill-formed tuple of types.\nAt this point, one of the following is expected:\n  * a comma ',' followed by another component as a type expression;\n  * a closing bracket ']' if the tuple is complete.\n"
    | 33 | 25 ->
        "Ill-formed record type.\nAt this point, one of the following is expected:\n  * a comma ',' followed by another field declaration;\n  * a colon ':' followed by a type expression;\n  * a closing brace '}' if the record type is complete.\n"
    | 236 ->
        "Ill-formed annotated expression.\nAt this point, a type expression is expected.\n"
    | 53 ->
        "Ill-formed functional type expression.\nAt this point, the return type is expected as a type expression.\n"
    | 49 ->
        "Ill-formed tuple of types.\nAt this point, a component is expected as a type expression.\n"
    | 14 | 57 | 59 ->
        "Ill-formed variant of a sum type.\nAt this point, one of the following is expected:\n  * attributes for the variant;\n  * an opening bracket '[' followed by a data constructor as a string.\n"
    | 16 | 62 ->
        "Ill-formed variant of a sum type.\nAt this point, one of the following is expected:\n  * a comma ',' followed by a constructor parameter as a type\n    expression;\n  * a closing bracket ']' if the constructor is constant.\n"
    | 15 | 61 ->
        "Ill-formed variant of a sum type.\nAt this point, a data constructor is expected as a string, starting\nwith a capital letter.\n"
    | 71 ->
        "Ill-formed variant of a sum type.\nAt this point, one of the following is expected:\n  * a comma ',' followed by another constructor parameter as a type\n    expression;\n  * a closing bracket ']' if the variant is complete.\n"
    | 18 | 72 | 64 ->
        "Ill-formed variant of a sum type.\nAt this point, a constructor parameter is expected as a type\nexpression.\n"
    | 60 ->
        "Ill-formed variant of a sum type.\nAt this point, if the attribute is complete, an opening bracket '[' is expected.\n"
    | 37 ->
        "Ill-formed record type.\nAt this point, one of the following is expected:\n  * a field declaration;\n  * a closing brace '}' if there are no more fields.\n"
    | 77 | 24 ->
        "Ill-formed record type.\nAt this point, a field declaration is expected.\n"
    | 4 ->
        "Ill-formed code injection, module access, or constructor.\nAt this point, one of the following is expected:\n  * a verbatim string if defining code injection;\n  * the selection symbol '.' followed by the qualified name of a value\n    in a module;\n  * an opening parenthesis '(' followed by a constructor argument as\n    an expression.\n"
    | 101 ->
        "Ill-formed selection of a type in a module.\nAt this point, the qualified name of a type is expected.\n"
    | 475 ->
        "Ill-formed selection of a value in a module.\nAt this point, the qualified name of a value is expected.\n"
    | 476 ->
        "Ill-formed selection of a value in a module.\nAt this point, the selection symbol '.' is expected, followed by the\nqualified name of a value.\n"
    | 125 | 337 ->
        "Ill-formed type declaration.\nAt this point, the name of the type being defined is expected.\n"
    | 126 | 338 ->
        "Ill-formed type declaration.\nAt this point, one of the following is expected:\n  * an opening chevron '<' followed by type parameters, if defining a\n    parametric type;\n  * an assignment symbol '=' followed by a type expression, if the\n    type is not parametric.\n"
    | 128 ->
        "Ill-formed parametric type declaration.\nAt this point, one of the following is expected:\n  * a comma ',' followed by another type parameter;\n  * a closing chevron '>' if there are no more type parameters.\n"
    | 132 | 136 | 341 ->
        "Ill-formed parametric type declaration.\nAt this point, an assignment symbol '=' is expected, followed by a\ntype expression.\n"
    | 473 ->
        "Ill-formed instantiation of a constructor.\nAt this point, an argument is expected as an expression.\n"
    | 6 ->
        "Ill-formed instantiation of a constructor.\nAt this point, one of the following is expected:\n  * arguments as expressions separated by commas ',';\n  * a closing parenthesis ')' if the constructor has no arguments.\n"
    | 472 ->
        "Ill-formed instantiation of a parametric type.\nAt this point, if the argument is complete, one of the following is\nexpected:\n  * a comma ',' followed by another argument as an expression;\n  * a closing parenthesis ')' if there are no more arguments.\n"
    | 20 ->
        "Ill-formed instantiation of a parametric type.\nAt this point, a type argument is expected as a type expression.\n"
    | 98 ->
        "Ill-formed instantiation of a parametric type.\nAt this point, another type argument is expected as a type expression.\n"
    | 97 ->
        "Ill-formed instantiation of a parametric type.\nAt this point, one of the following is expected:\n  * a comma ',' followed by another type argument as a type expression;\n  * a closing chevron '>' if there are no more arguments.\n"
    | 129 | 127 ->
        "Ill-formed parametric type declaration.\nAt this point, a type parameter is expected.\n"
    | 134 | 141 | 345 | 339 | 342 | 137 ->
        "Ill-formed type declaration.\nAt this point, a type expression is expected.\n"
    | 484 ->
        "Ill-formed module declaration.\nAt this point, the name of the module is expected, starting with a\ncapital letter.\n"
    | 485 ->
        "Ill-formed module declaration.\nAt this point, an opening brace '{' is expected, followed by\nstatements and/or submodules.\n"
    | 486 ->
        "Ill-formed module declaration.\nAt this point, the first statement or submodule is expected.\n"
    | 491 ->
        "Ill-formed module declaration.\nAt this point, if the statement is complete, one of the following is\nexpected:\n  * a semicolon ';' followed by another statement or submodule;\n  * a closing brace '}' if the module is complete.\n"
    | 492 ->
        "Ill-formed module declaration.\nAt this point, one of the following is expected:\n  * a statement or a submodule declaration;\n  * a closing brace '}' if the module is complete.\n"
    | 465 ->
        "Ill-formed parenthesised expression.\nAt this point, a closing parenthesis ')' is expected.\n"
    | 284 ->
        "Ill-formed value declaration.\nAt this point, one of the following is expected:\n  * the assignment symbol '=' followed by an expression;\n  * a type annotation starting with a colon ':'.\n"
    | 12 | 23 ->
        "Ill-formed type annotation.\nAt this point, a type expression is expected.\n"
    | 287 ->
        "Ill-formed value declaration.\nAt this point, if the type annotation is complete, the assignment\nsymbol '=' is expected, followed by an expression.\n"
    | 288 ->
        "Ill-formed value declaration.\nAt this point, an expression is expected.\n"
    | 261 ->
        "Ill-formed tuple pattern.\nAt this point, a tuple component is expected as a pattern.\n"
    | 271 ->
        "Ill-formed pattern for the rest of a tuple.\nAt this point, a variable is expected to match the rest of the tuple.\n"
    | 270 ->
        "Ill-formed tuple pattern.\nAt this point, one of the following is expected:\n  * another component as a pattern;\n  * a pattern matching the rest of the tuple, starting with an\n    ellipsis '...'.\n"
    | 268 ->
        "Ill-formed tuple pattern.\nAt this point, one of the following is expected:\n  * a comma ',' followed by another tuple component as a pattern;\n  * a comma ',' followed by a pattern matching the rest of the tuple,\n    starting with an ellipsis '...';\n  * a closing bracket ']' if the tuple pattern is complete.\n"
    | 276 ->
        "Ill-formed record pattern.\nAt this point, field patterns are expected to be separated by commas\n','.\n"
    | 277 ->
        "Ill-formed record pattern.\nAt this point, one of the following is expected:\n  * the assignment symbol '=' followed by a default value as an\n    expression;\n  * a colon ':' followed by a pattern for the right-hand side of the\n    field;\n  * a comma ',' followed by another field pattern;\n  * a closing brace '}' if the record pattern is complete.\n"
    | 278 ->
        "Ill-formed record pattern.\nAt this point, the default value for the field is expected as an\nexpression.\n"
    | 295 ->
        "Ill-formed record pattern.\nAt this point, one of the following is expected:\n  * another field pattern;\n  * a pattern matching the rest of the record, starting with an\n    ellipsis '...'.\n"
    | 280 ->
        "Ill-formed record field pattern.\nAt this point, one of the following is expected:\n  * optional attributes followed by a variable;\n  * a catch-all '_' pattern;\n  * a record pattern;\n  * a tuple pattern.\n"
    | 296 ->
        "Ill-formed record pattern.\nAt this point, a variable is expected to match the remaining record.\n"
    | 293 ->
        "Ill-formed record pattern.\nAt this point, one of the following is expected:\n  * a comma ',' followed by another field pattern;\n  * a comma ',' followed by an ellipsis '...' and a variable matching\n    the rest of the record;\n  * a closing brace '}' if the record pattern is complete.\n"
    | 10 ->
        "Ill-formed functional expression or parenthesised expression.\nAt this point, one of the following is expected:\n  * a closing parenthesis ')', if defining a function with no\n    parameters;\n  * a parameter name, if defining a function with parameters;\n  * an expression, if defining a parenthesised expression.\n"
    | 457 ->
        "Ill-formed functional expression.\nAt this point, if the type of the parameter is complete, one of the\nfollowing is expected:\n  * a comma ',' followed by another parameter;\n  * a closing parenthesis ')' if there are no more parameters.\n"
    | 157 | 11 ->
        "Ill-formed functional expression.\nAt this point, one of the following is expected:\n  * an arrow '=>' followed by the function body;\n  * the return type annotation starting with a colon ':'.\n"
    | 458 ->
        "Ill-formed function parameters.\nAt this point, another parameter is expected.\n"
    | 452 | 242 ->
        "Ill-formed functional expression.\nAt this point, if the return type is complete, an arrow '=>' is\nexpected, followed by the body.\n"
    | 460 ->
        "Ill-formed function parameter.\nAt this point, if the parameter name is complete, a type annotation is\nexpected to start with a colon ':'.\n"
    | 22 ->
        "Ill-formed function parameter or parenthesised expression.\nAt this point, one of the following is expected:\n  * a parameter if defining a functional type;\n  * a type expression if writing a parenthesised type.\n"
    | 463 ->
        "Ill-formed function parameter or parenthesised expression.\nAt this point, one of the following is expected:\n  * a type annotation starting with a colon ':', if defining a\n    parameter;\n  * a closing parenthesis ')' otherwise.\n"
    | 448 ->
        "Ill-formed tuple expression.\nAt this point, if the component is complete, one of the following is\nexpected:\n  * a comma ',' followed by another component;\n  * a closing bracket ']' if the tuple is complete.\n"
    | 443 ->
        "Ill-formed tuple inclusion.\nAt this point, an expression denoting the included tuple is expected.\n"
    | 124 ->
        "Ill-formed block of statements.\nAt this point, the first statement is expected.\n"
    | 416 ->
        "Ill-formed switch statement.\nAt this point, if the last case is complete, a closing brace '}' is\nexpected.\n"
    | 406 ->
        "Ill-formed switch statement.\nAt this point, one of the following is expected:\n  * another statement for the current case;\n  * a new case starting with the keyword 'case';\n  * the default case starting with the keyword 'default';\n  * a `break` to terminate the current switch;\n  * a closing brace '}' if the switch is complete.\n"
    | 405 ->
        "Ill-formed switch statement.\nAt this point, if the case statement is complete, one of the following\nis expected:\n  * a semicolon ';' followed by another case statement;\n  * a new case starting with the keyword 'case';\n  * the default case starting with the keyword 'default';\n  * a closing brace '}' if the switch is complete.\n"
    | 147 ->
        "Ill-formed switch statement.\nAt this point, the expression evaluated against the cases is expected.\n"
    | 146 ->
        "Ill-formed switch statement.\nAt this point, an expression between parentheses is expected.\n"
    | 253 ->
        "Ill-formed switch statement.\nAt this point, cases are expected between braces '{' '}'.\n"
    | 254 ->
        "Ill-formed switch statement.\nAt this point, a case starting with the keyword 'case' is expected.\n"
    | 255 ->
        "Ill-formed switch statement.\nAt this point, a colon ':' for the default case is expected.\n"
    | 410 ->
        "Ill-formed switch statement.\nAt this point, if the case expression is complete, a colon ':' is\nexpected.\n"
    | 256 ->
        "Ill-formed switch statement.\nAt this point, one of the following is expected:\n  * case statements separated by semicolons ';';\n  * a `break` to terminate the current switch;\n  * a closing brace '}' if the switch is complete.\n"
    | 411 ->
        "Ill-formed switch statement.\nAt this point, one of the following is expected:\n  * case statements separated by semicolons ';';\n  * a new case starting with the keyword 'case';\n  * the default case starting with the keyword 'default';\n  * a `break` to terminate the current switch;\n  * a closing brace '}' if the switch is complete.\n"
    | 250 ->
        "Ill-formed switch statement.\nAt this point, if the expression is complete, a closing parenthesis\n')' is expected.\n"
    | 409 ->
        "Ill-formed switch statement.\nAt this point, an expression is expected, whose value is used to\nselect the case to be executed first.\n"
    | 424 ->
        "Ill-formed block of statements.\nAt this point, one of the following is expected:\n  * another statement;\n  * a closing brace '}' if the block is complete.\n"
    | 421 ->
        "Ill-formed block of statements.\nAt this point, if the statement is complete, a closing brace '}' is\nexpected.\n"
    | 307 ->
        "Ill-formed module aliasing.\nAt this point, the assignment symbol '=' is expected, followed by the\nqualified name of the aliased module\n"
    | 306 ->
        "Ill-formed module aliasing.\nAt this point, the alias is expected as a module name.\n"
    | 310 | 308 ->
        "Ill-formed module aliasing.\nAt this point, the qualified name of the aliased module is expected.\n"
    | 314 ->
        "Ill-formed conditional statement.\nAt this point, the condition is expected as an expression.\n"
    | 9 ->
        "Ill-formed parenthesised expression.\nAt this point, an expression is expected.\n"
    | 321 | 313 ->
        "Ill-formed conditional statement.\nAt this point, the condition is expected as an expression between\nparentheses.\n"
    | 322 | 318 ->
        "Ill-formed conditional statement.\nAt this point, the statement executed when the condition is true is\nexpected.\n"
    | 378 | 384 ->
        "Ill-formed conditional statement.\nAt this point, the statement of the 'else' branch is expected.\n"
    | 315 ->
        "Ill-formed conditional statement.\nAt this point, if the condition is complete, a closing parenthesis ')'\nis expected.\n"
    | 123 | 111 | 453 | 158 | 243 ->
        "Ill-formed functional expression.\nAt this point, the body is expected as one of the following:\n  * an expression;\n  * a block of statements between braces '{' '}'.\n"
    | 385 | 323 ->
        "Ill-formed bounded (\"for\") loop.\nAt this point, an opening parenthesis '(' is expected, followed by\neither the keyword 'const' or 'let'.\n"
    | 386 | 324 ->
        "Ill-formed bounded (\"for\") loop.\nAt this point, one of the following is expected:\n  * the 'const' keyword,\n  * the 'let' keyword;\nfollowed by the index as a variable.\n"
    | 387 | 327 ->
        "Ill-formed bounded (\"for\") loop.\nAt this point, the index is expected as a variable.\n"
    | 388 | 328 ->
        "Ill-formed bounded (\"for\") loop.\nAt this point, the keyword 'of' is expected, followed by the index\nrange as an expression.\n"
    | 389 | 329 ->
        "Ill-formed bounded (\"for\") loop.\nAt this point, the range of the index is expected as an expression.\n"
    | 391 | 331 ->
        "Ill-formed bounded (\"for\") loop.\nAt this point, the body of the loop is expected as a statement.\n"
    | 330 | 390 ->
        "Ill-formed bounded (\"for\") loop.\nAt this point, if the expression denoting the index range is complete,\na closing parenthesis ')' is expected.\n"
    | 332 ->
        "Ill-formed export declaration.\nAt this point, a value or type declaration is expected.\n"
    | 487 ->
        "Ill-formed export declaration.\nAt this point, one of the following is expected:\n  * a value or type declaration, if exporting a declaration;\n  * the keyword 'namespace', if exporting a namespace.\n"
    | 352 | 350 | 333 | 259 | 304 ->
        "Ill-formed value declaration.\nAt this point, a pattern is expected, e.g. a variable.\n"
    | 513 ->
        "Ill-formed expression.\nAt this point, if the expression is complete, the end of the input is\nexpected.\n"
    | 114 ->
        "Ill-formed record expression.\nAt this point, field declarations are expected, separated by commas ','.\n"
    | 435 ->
        "Ill-formed record expression.\nAt this point, an expression is expected to be assigned to the field.\n"
    | 434 ->
        "Ill-formed record expression.\nAt this point, a colon ':' is expected, followed by the expression\nassigned to the field.\n"
    | 118 ->
        "Ill-formed record expression.\nAt this point, one of the following is expected:\n  * a colon ':' followed by the expression assigned to the field;\n  * a comma ',' followed by another field assignment, if the field is\n    punned (that is, the name of the field is also the variable\n    assigned to it);\n  * a closing brace '}' if the record is complete.\n"
    | 119 ->
        "Ill-formed record expression.\nAt this point, a record is expected as an expression.\n"
    | _ ->
        raise Not_found
