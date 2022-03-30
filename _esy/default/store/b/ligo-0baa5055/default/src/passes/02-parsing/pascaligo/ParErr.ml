
(* This file was auto-generated based on "errors.msg.in". *)

(* Please note that the function [message] can raise [Not_found]. *)

let message =
  fun s ->
    match s with
    | 116 ->
        "Ill-formed type parameters.\nAt this point, a type parameter is expected.\n"
    | 115 ->
        "Ill-formed type parameters.\nAt this point, one of the following is expected:\n  * a comma ',' followed by another type parameter;\n  * a closing chevron '>' if there are no more parameters.\n"
    | 114 ->
        "Ill-formed type parameters.\nAt this point, type parameters are expected, separated by commas ','.\n"
    | 755 | 761 ->
        "Ill-formed record expression or record patch.\nAt this point, the right-hand side of the field assignment is expected\nas an expression.\n"
    | 744 ->
        "Ill-formed record expression or patch.\nAt this point, if the attribute is complete, one of the following is\nexpected:\n  * another attribute;\n  * a field name, if defining a record;\n  * a selection of a record field in a module, like 'A.B.x';\n  * a selection from modules, records or/and tuples, like 'x.y.1.0',\n    if defining a patch.\n"
    | 684 ->
        "Ill-formed clause of a case expression.\nAt this point, the right-hand side of the clause is expected as an\nexpression.\n"
    | 683 ->
        "Ill-formed clause of a case expression.\nAt this point, if the pattern is complete, an arrow '->' is expected,\nfollowed by one of the following:\n  * a single instruction;\n  * a block of statements (instructions and declarations).\n"
    | 682 | 690 ->
        "Ill-formed case expression.\nAt this point, a clause is expected, starting with a pattern.\n"
    | 673 ->
        "Ill-formed key-value binding in a map.\nAt this point, the value is expected as an expression.\nNote: A binding is made of two expressions (a key and a value)\nseparated by an arrow '->'.\n"
    | 672 ->
        "Ill-formed key-value binding in a map.\nAt this point, if the key is complete, an arrow '->' is expected.\n"
    | 553 ->
        "Ill-formed clause of a case instruction.\nAt this point, one of the following is expected:\n  * a single instruction;\n  * a block of statements (instructions and declarations).\n"
    | 552 ->
        "Ill-formed clause of a case instruction.\nAt this point, if the pattern is complete, an arrow '->' is expected.\n"
    | 551 | 577 ->
        "Ill-formed case instruction.\nAt this point, a clause is expected, starting with a pattern.\n"
    | 234 ->
        "Ill-formed record expression or record patch.\nAt this point, one of the following is expected:\n  * a field name, if defining a record;\n  * a selection of a record field in a module, like 'A.B.x';\n  * a selection from modules, records or/and tuples, like 'x.y.1.0',\n    if defining a patch;\n  * parenthesised expression as one of the above.\n"
    | 233 ->
        "Ill-formed qualified pattern.\nAt this point, the selection operator '.' is expected.\n"
    | 189 ->
        "Ill-formed record pattern.\nAt this point, the right-hand side of the field assignment is expected\nas a pattern.\n"
    | 178 ->
        "Ill-formed list pattern.\nAt this point, if the list element is complete, one of the following\nis expected:\n  * another element as a pattern;\n  * a closing bracket ']' if the list is complete.\n"
    | 173 ->
        "Ill-formed parenthesised/tuple/typed pattern.\nAt this point, if the pattern is complete, one of the following is\nexpected:\n  * a closing parenthesis ')' if writing a parenthesised pattern;\n  * a type annotation starting with a colon ':', if writing a typed\n    pattern;\n  * a comma ',' if writing a tuple pattern.\n"
    | 163 ->
        "Ill-formed list pattern.\nAt this point, a list is expected as a pattern.\n"
    | 151 ->
        "Ill-formed tuple pattern.\nAt this point, a component as a pattern is expected.\n"
    | 138 ->
        "Ill-formed tuple pattern or parenthesised pattern.\nAt this point, a pattern is expected.\n"
    | 136 ->
        "Ill-formed list pattern.\nAt this point, one of the following is expected:\n  * a list element as a pattern;\n  * a closing bracket ']' if the list is empty.\n"
    | 135 ->
        "Ill-formed list pattern.\nAt this point, an opening bracket `[` is expected.\n"
    | 127 ->
        "Ill-formed constructor pattern.\nAt this point, a constructor parameter is expected as a pattern.\n"
    | 87 ->
        "Ill-formed record type.\nAt this point, if the attribute is complete, the following is\nexpected:\n  * another attribute of the field;\n  * the name of the field.\n"
    | 28 | 89 ->
        "Ill-formed record declaration.\nAt this point, the type of the field is expected.\n"
    | 29 ->
        "Ill-formed map type.\nAt this point, a pair of types is expected: the type of the keys and\nthe type of the values, respectively. For example: '(int, string)'.\n"
    | 432 ->
        "Ill-formed patch of a record.\nAt this point, one of the following is expected:\n  * an opening bracket '[';\n  * a function call whose value is a record;\n  * a parenthesised expression denoting a record.\n"
    | 648 ->
        "Ill-formed attributed statement.\nAt this point, if the attribute is complete, one of the following is\nexpected:\n  * a variable declaration, starting with the keyword 'var';\n  * an instruction.\n"
    | 613 | 695 | 622 | 700 ->
        "Ill-formed function expression.\nAt this point, the keyword 'is' is expected, followed by the function\nbody as an expression.\n"
    | 365 ->
        "Ill-formed variable declaration.\nAt this point, the assignment symbol ':=' is expected, followed by an\nexpression whose value is first assigned.\n"
    | 176 ->
        "Ill-formed parenthesised pattern.\nAt this point, a closing parenthesis ')' is expected.\n"
    | 71 ->
        "Ill-formed type expression.\nAt this point, one of the following is expected:\n  * another attribute;\n  * a type expression is expected, other than a functional type, a\n    cartesian type or a sum type. (For those, use parentheses.)\n"
    | 16 ->
        "Ill-formed qualified type expression.\nAt this point, the selection operator '.' is expected.\n"
    | 530 ->
        "Ill-formed iteration over a list.\nAt this point, if the expression is complete, the body of the loop is\nexpected as a block of statements (declarations and instructions).\n"
    | 527 ->
        "Ill-formed iteration over a set.\nAt this point, if the expression is complete, the body of the loop is\nexpected as a block of statements (declarations and instructions).\n"
    | 244 ->
        "Ill-formed list expression.\nAt this point, an opening bracket '[' is expected.\n"
    | 229 ->
        "Ill-formed set expression.\nAt this point, an opening bracket '[' is expected.\n"
    | 427 ->
        "Ill-formed set expression.\nAt this point, one of the following is expected:\n  * an opening bracket '[' followed by set elements;\n  * a function call denoting a set;\n  * a parenthesised expression denoting a set.\n"
    | 773 ->
        "Ill-formed set expression.\nAt this point, if the set element is complete, one of the following is\nexpected:\n  * another element;\n  * a closing bracket ']' if the set is complete.\n"
    | 721 ->
        "Ill-formed list expression.\nAt this point, if the list element is complete, one of the following\nis expected:\n  * another element;\n  * a closing bracket ']' if the list is complete.\n"
    | 780 ->
        "Ill-formed constructor expression.\nAt this point, if the argument is complete, one of the following is\nexpected:\n  * a comma ',' followed by another argument as an expression;\n  * a closing parenthesis ')' if there are no more arguments.\n"
    | 660 ->
        "Ill-formed function call.\nAt this point, if the argument is complete, one of the following is\nexpected:\n  * a comma ',' followed by another argument as an expression;\n  * a closing parenthesis ')' if there are no more arguments.\n"
    | 227 | 781 ->
        "Ill-formed constructor expression.\nAt this point, an argument to the constructor is expected as an\nexpression.\n"
    | 150 ->
        "Ill-formed tuple pattern.\nAt this point, if the component is complete, a comma ',' is expected.\n"
    | 149 ->
        "Ill-formed tuple pattern.\nAt this point, a component is expected as a pattern.\n"
    | 206 ->
        "Ill-formed parenthesised pattern.\nAt this point, if the pattern is complete, one of the following is\nexpected:\n  * a type annotation starting with a colon ':';\n  * a closing parenthesis ')'.\n"
    | 205 ->
        "Ill-formed parenthesised pattern.\nAt this point, a pattern is expected.\n"
    | 204 ->
        "Ill-formed qualified pattern.\nAt this point, one of the following is expected:\n  * the selection operator '.' if the qualification is not complete;\n  * an opening parenthesis '(' followed by constructor parameters as\n    patterns.\n"
    | 203 ->
        "Ill-formed qualified pattern.\nAt this point, one of the following is expected:\n  * a submodule name if the qualification is not complete;\n  * a data constructor name;\n  * a variable;\n  * a parenthesised pattern.\n"
    | 544 ->
        "Ill-formed iteration over a map.\nAt this point, a map is expected as an expression.\n"
    | 543 ->
        "Ill-formed iteration over a map.\nAt this point, the keyword 'map' is expected.\n"
    | 542 ->
        "Ill-formed iteration over a map.\nAt this point, the keywords 'in map' are expected.\n"
    | 541 ->
        "Ill-formed iteration over a map.\nAt this point, the value (as opposed to the key) of the binding is\nexpected as a variable.\n"
    | 367 | 280 | 598 ->
        "Ill-formed expression.\nAt this point, if the attribute is complete, one of the following is\nexpected:\n  * another attribute;\n  * an expression.\nNote: Some expressions need to be parenthesised.\n"
    | 717 ->
        "Ill-formed typed expression.\nAt this point, a type expression is expected.\n"
    | 612 | 694 | 621 | 699 ->
        "Ill-formed function expression.\nAt this point, the return type is expected.\n"
    | 455 | 463 | 792 | 785 ->
        "Ill-formed function declaration.\nAt this point, the return type is expected.\n"
    | 472 ->
        "Ill-formed constant declaration.\nAt this point, the type of the constant is expected.\n"
    | 364 ->
        "Ill-formed variable declaration.\nAt this point, the type of the variable is expected.\n"
    | 174 ->
        "Ill-formed typed pattern.\nAt this point, the type of the values matching the pattern is\nexpected.\n"
    | 731 ->
        "Ill-formed map expression.\nAt this point, if the key-value binding is complete, one of the\nfollowing is expected:\n  * another binding;\n  * a closing bracket ']' if the map is complete.\nNote: A binding is made of two expressions (a key and a value)\nseparated by an arrow '->'.\n"
    | 719 ->
        "Ill-formed code injection.\nAt this point, if the expression denoting the code to inject is\ncomplete, then a closing bracket ']' is expected.\n"
    | 708 ->
        "Ill-formed parenthesised or tuple expression.\nAt this point, if the expression is complete, one of the following is\nexpected:\n  * a comma ',' followed by an expression, if defining a tuple;\n  * a closing parenthesis ')' if defining a parenthesised expression.\n"
    | 713 ->
        "Ill-formed tuple expression.\nAt this point, if the component is complete, one of the following is\nexpected:\n  * a comma ',' followed by another component as an expression;\n  * a closing parenthesis ')' if there are no more components.\n"
    | 679 ->
        "Ill-formed case expression.\nAt this point, if the analysed expression is complete, the keyword\n'of' is expected, followed by an opening bracket '['.\n"
    | 668 ->
        "Ill-formed big map expression.\nAt this point, if the key-value binding is complete, one of the\nfollowing is expected:\n  * another binding;\n  * a closing bracket ']' if the big map is complete.\nNote: A binding is made of two expressions (a key and a value)\nseparated by an arrow '->'.\n"
    | 664 ->
        "Ill-formed general loop.\nAt this point, if the condition is complete, the body of the loop is\nexpected as a block of statements (instructions and declarations).\n"
    | 416 ->
        "Ill-formed map lookup.\nAt this point, if the key is complete, a closing bracket ']' is\nexpected.\n"
    | 548 ->
        "Ill-formed case instruction.\nAt this point, if the analysed expression is complete, the keyword\n'of' is expected, followed by an opening bracket '['.\n"
    | 535 ->
        "Ill-formed iteration over a numerical interval.\nAt this point, if the final value of the index is complete, one of the\nfollowing is expected:\n  * a step clause introduced by the keyword 'step', followed by\n    the index increment as an expression;\n  * a loop body as a block of statements (instructions and\n    declarations).\n"
    | 533 ->
        "Ill-formed iteration over a numerical interval.\nAt this point, if the initial value of the index is complete, the\nkeyword 'to' is expected.\n"
    | 603 ->
        "Ill-formed block expression.\nAt this point, the keyword 'with' is expected, followed by an\nexpression whose value is that of the block.\n"
    | 594 | 259 ->
        "Ill-formed function expression.\nAt this point, one of the following is expected:\n  * type parameters between chevrons ('<' and '>');\n  * value parameters between parentheses.\n"
    | 595 | 260 ->
        "Ill-formed function expression.\nAt this point, parameter declarations are expected between\nparentheses.\n"
    | 592 | 702 ->
        "Ill-formed conditional expression.\nAt this point, if the condition is complete, the keyword 'then' is\nexpected, followed by an expression.\n"
    | 506 | 521 ->
        "Ill-formed conditional instruction.\nAt this point, if the condition is complete, the keyword 'then' is\nexpected, followed by an instruction or a block of statements\n(instructions and declarations).\n"
    | 734 ->
        "Ill-formed parenthesised expression.\nAt this point, if the expression is complete, a closing parenthesis\n')' is expected.\n"
    | 235 ->
        "Ill-formed parenthesised expression.\nAt this point, an expression is expected, followed by a closing\nparenthesis ')'.\n"
    | 500 ->
        "Ill-formed module declaration.\nAt this point, an opening brace '{' is expected, followed by\ndeclarations.\n"
    | 400 ->
        "Ill-formed selection of a value from a module.\nAt this point, one of the following is expected:\n  * a submodule if the value is not fully qualified;\n  * a value or function name;\n  * a parenthesised expression.\n"
    | 201 ->
        "Ill-formed constructor pattern.\nAt this point, another parameter is expected as a pattern.\n"
    | 200 ->
        "Ill-formed constructor pattern.\nAt this point, if the parameter is complete, one of the following is\nexpected:\n  * a comma ',' followed by another parameter as a pattern;\n  * a closing parenthesis ')' if there are no more parameters.\n"
    | 153 ->
        "Ill-formed tuple pattern.\nAt this point, a component is expected as a pattern.\n"
    | 152 ->
        "Ill-formed tuple pattern.\nAt this point, if the component is complete, one of the following is\nexpected:\n  * a comma ',' followed by another component as a pattern;\n  * a closing parenthesis ')' if there are no more components.\n"
    | 142 ->
        "Ill-formed pattern.\nAt this point, if the attribute is complete, one of the following is\nexpected:\n  * another attribute;\n  * a pattern other than a cons pattern.\nNote: Use parentheses for a cons pattern, like '(x::y)'.\n"
    | 3 | 7 ->
        "Ill-formed parametric type declaration.\nAt this point, a type parameter is expected as a variable.\n"
    | 6 ->
        "Ill-formed parametric type declaration.\nAt this point, one of the following is expected:\n  * a comma ',' followed by another type parameter;\n  * a closing parenthesis ')' if there are no more parameters.\n"
    | 446 ->
        "Ill-formed module aliasing.\nAt this point, a module name is expected.\nMore generally, a qualified module name is expected, e.g. 'A.B.C'.\n"
    | 442 ->
        "Ill-formed module declaration.\nAt this point, the name of the module is expected, starting with an\nuppercase letter.\n"
    | 443 ->
        "Ill-formed module declaration.\nAt this point, the keyword 'is' is expected.\n"
    | 444 ->
        "Ill-formed module declaration.\nAt this point, one of the following is expected:\n  * the qualified name of a module being aliased, e.g. 'A.B.C';\n  * a module body starting with an opening brace '{'.\n"
    | 502 ->
        "Ill-formed module declaration.\nAt this point, if the declaration is complete, one of the\nfollowing is expected:\n  * another declaration;\n  * a closing brace '}' if there are no more declarations.\nNote: 'var' declarations are not valid at top-level in modules.\n"
    | 448 | 501 ->
        "Ill-formed module declaration.\nAt this point, a declaration is expected.\nNote: 'var' declarations are not valid at top-level in modules.\n"
    | 494 ->
        "Ill-formed module declaration.\nAt this point, if the declaration is complete, one of the\nfollowing is expected:\n  * another declaration;\n  * the keyword 'end' if there are no more declarations.\nNote: 'var' declarations are valid only in blocks.\n"
    | 801 ->
        "Ill-formed contract.\nAt this point, if the top-level declaration is complete, one of the\nfollowing is expected:\n  * another declaration starting with the keyword 'type', 'const',\n    'function', 'recursive' or 'module';\n  * the end of the file.\nNote: 'var' declarations are valid only in blocks.\n"
    | 483 ->
        "Ill-formed declaration.\nAt this point, one of the following is expected:\n  * an attribute;\n  * the keyword 'type' if defining a type;\n  * the keyword 'const' if defining a constant;\n  * the keyword 'function' if defining a function;\n  * the keywords 'recursive function' if defining a recursive\n    function;\n  * the keyword 'module' if defining a module.\n"
    | 360 | 269 ->
        "Ill-formed block of statements.\nAt this point, statements are expected, separated by semicolons ';'.\nNote: A statement is either an instruction or a declaration.\n"
    | 25 ->
        "Ill-formed record type.\nAt this point, one of the following is expected:\n  * field declarations separated by semicolons ';';\n  * a closing bracket ']' if the record is empty.\n"
    | 64 ->
        "Ill-formed sum type.\nAt this point, if the attribute of the type is complete, one of the\nfollowing is expected:\n  * another attribute;\n  * a vertical bar '|' introducing a variant.\n"
    | 24 ->
        "Ill-formed record type.\nAt this point, an opening bracket '[' is expected.\n"
    | 0 ->
        "Ill-formed contract.\nAt this point, a top-level declaration is expected, starting with the\nkeyword 'type', 'const', 'function', 'recursive' or 'module'.\nNote: 'var' declarations are valid only in blocks.\n"
    | 104 ->
        "Ill-formed sum type.\nAt this point, if the attribute is complete, one of the following is\nexpected:\n  * another attribute for the variant;\n  * the data constructor of the variant, starting with an uppercase\n    letter.\n"
    | 1 ->
        "Ill-formed type declaration.\nAt this point, the name of the type is expected.\n"
    | 107 ->
        "Ill-formed parametric type declaration.\nAt this point, the keyword 'is' is expected, followed by a type\nexpression.\n"
    | 2 ->
        "Ill-formed type declaration.\nAt this point, one of the following is expected:\n  * an opening parenthesis '(' followed by a type variable, if the type\n    is parametric;\n  * the keyword 'is' followed by a type expression.\n"
    | 70 | 74 ->
        "Ill-formed product type.\nAt this point, a type expression is expected.\nHint: You may want to check the priority and associativity of\ntype operators, or use parentheses.\n"
    | 77 ->
        "Ill-formed function type.\nAt this point, the return type is expected.\n"
    | 22 ->
        "Ill-formed set type.\nAt this point, the type of the elements is expected between\nparentheses.\n"
    | 84 ->
        "Ill-formed record type.\nAt this point, if the field is complete, one of the following is\nexpected:\n  * another field declaration;\n  * a closing bracket ']' if the record is complete.\n"
    | 30 | 57 ->
        "Ill-formed type tuple.\nAt this point, a component is expected as a type expression.\n"
    | 56 ->
        "Ill-formed type tuple.\nAt this point, if the type expression is complete, one of the\nfollowing is expected:\n  * a comma ',' followed by another component as a type expression;\n  * a closing parenthesis ')' if there are no more components.\n"
    | 31 ->
        "Ill-formed list type.\nAt this point, the type of the elements is expected between\nparentheses.\n"
    | 96 ->
        "Ill-formed parenthesised type expression.\nAt this point, if the type expression is complete, a closing\nparenthesis ')' is expected.\n"
    | 18 ->
        "Ill-formed parenthesised type expression.\nAt this point, a type expression is expected.\n"
    | 11 | 108 ->
        "Ill-formed type declaration.\nAt this point, a type expression is expected.\n"
    | 13 ->
        "Ill-formed sum type.\nAt this point, one of the following is expected:\n  * attributes for a variant;\n  * the data constructor of a variant, starting with an uppercase\n    letter.\n"
    | 15 ->
        "Ill-formed variant of a sum type.\nAt this point, the parameter of the constructor is expected as a type\nexpression.\nNote: If it is a sum type, use parentheses.\n"
    | 17 ->
        "Ill-formed selection of a type from a module.\nAt this point, one of the following is expected:\n  * a submodule name if the name is not fully qualified;\n  * a type name;\n  * a parenthesised type expression.\n"
    | 37 ->
        "Ill-formed big map type.\nAt this point, a pair of types is expected: the type of the keys and\nthe type of the values, respectively.\n"
    | 111 ->
        "Ill-formed recursive function declaration.\nAt this point, the keyword 'function' is expected, followed by the name\nof the function.\n"
    | 222 | 451 ->
        "Ill-formed function declaration.\nAt this point, value parameters are expected between parentheses.\n"
    | 450 | 113 ->
        "Ill-formed function declaration.\nAt this point, one of the following is expected:\n  * type parameters between chevrons ('<' and '>').\n  * value parameters between parentheses.\n"
    | 456 | 786 | 793 | 464 ->
        "Ill-formed function declaration.\nAt this point, if the return type is complete, the keyword 'is' is\nexpected, followed by the function body as an expression.\n"
    | 453 | 457 | 465 | 461 | 790 | 794 | 224 | 787 ->
        "Ill-formed function declaration.\nAt this point, the function body is expected as an expression.\n"
    | 467 ->
        "Ill-formed constant declaration.\nAt this point, a pattern is expected, e.g. a variable.\n"
    | 469 ->
        "Ill-formed constant declaration.\nAt this point, one of the following is expected:\n  * a colon ':' followed by the type of the constant;\n  * the assignment symbol '=', followed by an expression\n    whose value is that of the constant.\n"
    | 477 | 481 | 470 | 474 ->
        "Ill-formed constant declaration.\nAt this point, an expression is expected, whose value is that of the\nconstant.\n"
    | 480 | 473 ->
        "Ill-formed constant declaration.\nAt this point, if the type is complete, the assignment symbol '=' is\nexpected, followed by an expression whose value is that of the\nconstant.\n"
    | 479 ->
        "Ill-formed constant declaration.\nAt this point, the type of the constant is expected.\n"
    | 476 ->
        "Ill-formed constant declaration.\nAt this point, one of the following is expected:\n  * the assignment symbol '=';\n  * a type annotation starting with a colon ':'.\n"
    | 804 ->
        "Ill-formed expression.\nAt this point, an expression is expected.\n"
    | 335 | 318 | 333 | 316 | 310 ->
        "Ill-formed arithmetic expression.\nAt this point, an expression is expected.\nHint: You may want to check the priority and associativity of\noperators, or use parentheses.\n"
    | 348 | 338 | 346 | 344 | 342 | 340 ->
        "Ill-formed comparison expression.\nAt this point, a comparable expression is expected.\nHint: You may want to check the priority and associativity of\noperators, or use parentheses.\n"
    | 380 | 378 ->
        "Ill-formed Boolean expression.\nAt this point, a Boolean expression is expected.\nHint: You may want to check the priority and associativity of\noperators, or use parentheses.\n"
    | 279 ->
        "Ill-formed membership test in a set.\nAt this point, a potential set element is expected as an expression.\nHint: You may want to check the priority and associativity of\noperators, or use parentheses.\n"
    | 331 ->
        "Ill-formed list expression.\nAt this point, a list is expected as an expression.\nHint: You may want to check the priority and associativity of\noperators, or use parentheses.\n"
    | 321 ->
        "Ill-formed string expression.\nAt this point, a string expression is expected.\nHint: You may want to check the priority and associativity of\noperators, or use parentheses.\n"
    | 230 ->
        "Ill-formed set expression.\nAt this point, one of the following is expected:\n  * elements as expressions separated by semicolons ';';\n  * a closing bracket ']' if the set is empty.\n"
    | 232 ->
        "Ill-formed record expression or patch.\nAt this point, one of the following is expected:\n  * a field name, if defining a record;\n  * a selection of a record field in a module, like 'A.B.x';\n  * a selection from modules, records or/and tuples, like 'x.y.1.0',\n    if defining a patch;\n  * a closing bracket ']' if defining an empty record.\n"
    | 236 ->
        "Ill-formed unary expression.\nAt this point, a Boolean expression is expected.\nHint: You may want to check the priority and associativity of\noperators, or use parentheses.\n"
    | 435 | 240 ->
        "Ill-formed map expression.\nAt this point, an opening bracket '[' is expected.\n"
    | 241 ->
        "Ill-formed map expression.\nAt this point, one of the following is expected:\n  * key-value bindings separated by semicolons ';';\n  * a closing bracket ']' if the map is empty.\nNote: A binding is made of two expressions (a key and a value)\nseparated by an arrow '->'.\n"
    | 243 ->
        "Ill-formed unary expression.\nAt this point, an arithmetic expression is expected.\nHint: You may want to check the priority and associativity of\noperators, or use parentheses.\n"
    | 129 ->
        "Ill-formed record pattern.\nAt this point, an opening bracket '[' is expected.\n"
    | 130 ->
        "Ill-formed record pattern.\nAt this point, one of the following is expected:\n  * field patterns separated by semicolons ';';\n  * a closing bracket ']' if the record is empty.\n"
    | 186 ->
        "Ill-formed record pattern.\nAt this point, if the field pattern is complete, one of the following\nis expected:\n  * another field pattern;\n  * a closing bracket ']' if the record is complete.\n"
    | 245 ->
        "Ill-formed list expression.\nAt this point, one of the following is expected:\n  * elements as expressions separated by semicolons ';';\n  * a closing bracket ']' if the list is empty.\n"
    | 247 ->
        "Ill-formed code injection.\nAt this point, an expression is expected, whose value is a verbatim\nstring containing the code to inject.\n"
    | 248 ->
        "Ill-formed parenthesised/tuple/typed expression.\nAt this point, an expression is expected.\n"
    | 710 | 714 ->
        "Ill-formed tuple expression.\nAt this point, a tuple component is expected as an expression.\n"
    | 706 ->
        "Ill-formed typed expression.\nAt this point, if the type is complete, a closing parenthesis ')' is\nexpected.\n"
    | 703 | 593 ->
        "Ill-formed conditional expression.\nAt this point, the contents of the 'then' branch is expected as an\nexpression.\n"
    | 705 | 628 ->
        "Ill-formed conditional expression.\nAt this point, the contents of the 'else' branch is expected as an\nexpression.\n"
    | 314 ->
        "Ill-formed functional update of a record.\nAt this point, a record is expected a an expression.\n"
    | 806 ->
        "Ill-formed expression.\nAt this point, if the expression is complete, the end of the file is\nexpected.\n"
    | 428 ->
        "Ill-formed function call.\nAt this point, an opening parenthesis is expected, followed by an\nargument.\n"
    | 661 | 276 ->
        "Ill-formed function call.\nAt this point, an argument is expected as an expression.\n"
    | 415 ->
        "Ill-formed map lookup.\nAt this point, a key is expected as an expression.\n"
    | 449 | 112 ->
        "Ill-formed function declaration.\nAt this point, the name of the function is expected.\n"
    | 123 ->
        "Ill-formed function parameter declaration.\nAt this point, a pattern is expected, e.g. a variable.\n"
    | 218 | 120 ->
        "Ill-formed function parameter declaration.\nAt this point, one of the following is expected:\n  * the keyword 'const' if the parameter is constant in the body;\n  * the keyword 'var' if the parameter is variable in the body.\nNote: Each parameter is initialised with a copy of the corresponding\nargument (on the caller side).\n"
    | 214 ->
        "Ill-formed function parameter declaration.\nAt this point, the type of the parameter is expected.\n"
    | 220 ->
        "Ill-formed function parameter declaration.\nAt this point, if the parameter declaration is complete, one of the\nfollowing is expected:\n  * a semicolon ';' followed by another parameter declaration;\n  * a closing parenthesis ')' if there are no more parameters.\n"
    | 213 ->
        "Ill-formed function parameter declaration.\nAt this point, if the parameter is complete, one of the following is\nexpected:\n  * a colon ':' followed by the type of the parameter;\n  * a semicolon ';' followed by another parameter declaration;\n  * a closing parenthesis ')' if there are no more parameters.\n"
    | 789 | 452 | 460 | 223 ->
        "Ill-formed function declaration.\nAt this point, one of the following is expected:\n  * a colon ':' followed by the return type;\n  * the keyword 'is' followed by the function body as an expression.\n"
    | 261 | 596 | 617 | 697 ->
        "Ill-formed function expression.\nAt this point, one of the following is expected:\n  * a colon ':' followed by the return type;\n  * the keyword 'is' followed by the function body as an expression.\n"
    | 262 | 614 | 696 | 597 | 698 | 618 | 623 | 701 ->
        "Ill-formed function expression.\nAt this point, the body is expected as an expression.\n"
    | 263 ->
        "Ill-formed case expression.\nAt this point, the analysed expression is expected.\n"
    | 680 ->
        "Ill-formed case expression.\nAt this point, an opening bracket '[' is expected.\n"
    | 681 ->
        "Ill-formed case expression.\nAt this point, one of the following is expected:\n  * a clause made of a pattern and an expression separated by an arrow\n    '->';\n  * a vertical bar '|' followed by a clause.\n"
    | 359 ->
        "Ill-formed block of statements.\nAt this point, an opening brace '{' is expected.\n"
    | 654 ->
        "Ill-formed block of statements.\nAt this point, if the statement is complete, one of the following is\nexpected:\n  * another statement (instruction or declaration);\n  * a closing brace '}' if there are no more statements.\n"
    | 266 ->
        "Ill-formed big map expression.\nAt this point, an opening bracket '[' is expected.\n"
    | 267 ->
        "Ill-formed big map expression.\nAt this point, one of the following is expected:\n  * key-value bindings separated by semicolons ';';\n  * a closing bracket ']' if the big map is empty.\nNote: A binding is made of two expressions (a key and a value)\nseparated by an arrow '->'.\n"
    | 270 ->
        "Ill-formed general loop.\nAt this point, the condition is expected as a Boolean expression.\n"
    | 361 ->
        "Ill-formed variable declaration.\nAt this point, a pattern is expected, e.g. a variable.\n"
    | 363 ->
        "Ill-formed variable declaration.\nAt this point, one of the following is expected:\n  * a colon ':' followed by the type of the variable;\n  * the assignment symbol ':=' followed by an expression whose\n    value is the first assigned.\n"
    | 394 | 396 | 389 | 366 ->
        "Ill-formed variable declaration.\nAt this point, an expression is expected, whose value is the first\nassigned.\n"
    | 393 ->
        "Ill-formed variable declaration.\nAt this point, if the type is complete, the assignment symbol ':=' is\nexpected.\n"
    | 392 ->
        "Ill-formed variable declaration.\nAt this point, the type of the variable is expected.\n"
    | 391 ->
        "Ill-formed variable declaration.\nAt this point, one of the following is expected:\n  * the assignment symbol ':=';\n  * a type annotation starting with a colon ':'.\n"
    | 666 ->
        "Ill-formed block of statements.\nAt this point, if the statement is complete, one of the following is\nexpected:\n  * another statement (instruction or declaration);\n  * the keyword 'end' if the block is complete.\n"
    | 374 | 604 ->
        "Ill-formed block expression.\nAt this point, an expression is expected, whose value is that of the\nblock.\n"
    | 373 ->
        "Ill-formed block expression.\nAt this point, the keyword 'with' is expected, followed by an\nexpression whose value is that of the whole block.\n"
    | 412 | 511 ->
        "Ill-formed removal from a set or a map.\nAt this point, one of the following is expected:\n  * the keyword 'set' followed by set elements as expressions;\n  * the keyword 'map' followed by bindings or a function call or a\n    parenthesised expression.\n"
    | 509 | 410 ->
        "Ill-formed removal from a set or a map.\nAt this point, the set element or key map to remove is expected as an\nexpression.\n"
    | 510 | 411 ->
        "Ill-formed removal from a map or a set.\nAt this point, if the map key or the set element to remove is\ncomplete, the keyword 'from' is expected.\n"
    | 422 | 514 ->
        "Ill-formed removal from a map.\nAt this point, the map is expected as an expression.\n"
    | 413 | 512 ->
        "Ill-formed removal from a set.\nAt this point, the set is expected as an expression.\n"
    | 760 | 748 ->
        "Ill-formed record expression or record patch.\nAt this point, if the left-hand side of the field is complete, a lens\nis expected amongst: '=', '+=', '-=', '*=', '/='. or '|='.\n"
    | 741 ->
        "Ill-formed record expression or record patch.\nAt this point, if the field assignment is complete, one of the\nfollowing is expected:\n  * another assignment;\n  * a closing bracket ']' if the record or patch is complete.\n"
    | 231 ->
        "Ill-formed record expression or record patch.\nAt this point, an opening bracket '[' is expected.\n"
    | 426 | 518 ->
        "Ill-formed patch instruction.\nAt this point, one of the following is expected:\n  * a record literal, starting with the keyword 'record';\n  * a map literal, starting with the keyword 'map';\n  * a set literal, starting with the keyword 'set';\n  * the keyword 'record', 'set' or 'map', followed by either a\n    function call or a parenthesised expression denoting a record, a\n    set or a map, respectively.\n"
    | 425 | 517 ->
        "Ill-formed patch instruction.\nAt this point, if the expression is complete, the keyword 'with' is\nexpected.\n"
    | 424 | 516 ->
        "Ill-formed patch instruction.\nAt this point, the patched data structure is expected as an\nexpression.\n"
    | 256 | 252 | 283 ->
        "Ill-formed selection from a record or a tuple.\nAt this point, one of the following is expected:\n  * a record field name, if selecting from a record;\n  * the index of a tuple component, '0' or '@0' denoting the first\n    component.\n"
    | 250 | 591 ->
        "Ill-formed conditional expression.\nAt this point, the condition is expected as a Boolean expression.\n"
    | 505 | 520 ->
        "Ill-formed conditional instruction.\nAt this point, the condition is expected as a Boolean expression.\n"
    | 507 | 522 ->
        "Ill-formed conditional instruction.\nAt this point, the 'then' branch is expected as one of the following:\n  * a single instruction;\n  * a block of statements (instructions and declarations).\n"
    | 641 | 583 ->
        "Ill-formed conditional instruction.\nAt this point, if the 'then' branch is complete, the keyword 'else' is\nexpected, followed by either\n  * a single instruction;\n  * a block of statements (instructions and declarations).\n"
    | 642 | 584 ->
        "Ill-formed conditional instruction.\nAt this point, the 'else' branch is expected as either\n  * a single instruction;\n  * a block of statements (instructions and declarations).\n"
    | 558 | 589 ->
        "Ill-formed assignment instruction.\nAt this point, if the expression is complete, the assignment symbol\n':=' is expected.\n"
    | 559 | 590 ->
        "Ill-formed assignment.\nAt this point, the right-hand side is expected as an expression.\n"
    | 523 ->
        "Ill-formed iteration.\nAt this point, one of the following is expected:\n  * a variable denoting the index, if iterating over a numerical\n    interval;\n  * a variable denoting an element, if iterating over a list or a set;\n  * a variable denoting the key of a map, if iterating over a map.\n"
    | 524 ->
        "Ill-formed iteration.\nAt this point, one of the following is expected:\n  * the assignment symbol ':=' if iterating over a numerical interval;\n  * the keyword 'in' if iterating over a list or a set;\n  * a binding arrow '->' if iterating over a map.\n"
    | 525 ->
        "Ill-formed iteration over a set or a list.\nAt this point, one of the following is expected:\n  * the keyword 'set' if iterating over a set;\n  * the keyword 'list' if iterating over a list.\n"
    | 526 ->
        "Ill-formed iteration over a set.\nAt this point, the iterated set is expected as an expression.\n"
    | 529 ->
        "Ill-formed iteration over a list.\nAt this point, the iterated list is expected as an expression.\n"
    | 545 ->
        "Ill-formed iteration over a map.\nAt this point, if the expression is complete, the body of the loop is\nexpected as a block of statements (declarations and instructions).\n"
    | 532 ->
        "Ill-formed iteration over a numerical interval.\nAt this point, the expression for the initial value of the index is\nexpected.\n"
    | 534 ->
        "Ill-formed iteration over a numerical interval.\nAt this point, the final value of the index is expected as an\nexpression.\n"
    | 536 ->
        "Ill-formed iteration over a numerical interval.\nAt this point, the index increment (step) is expected as an\nexpression.\n"
    | 538 ->
        "Ill-formed iteration over a numerical interval.\nAt this point, if the step clause is complete, the loop body is\nexpected as a block of statements.\n"
    | 399 ->
        "Ill-formed selection of a value from a module.\nAt this point, the selection symbol '.' is expected, followed by either\n  * the qualified name of a value, like 'A.B.c.2.d';\n  * a value or function name.\n"
    | 547 ->
        "Ill-formed case instruction.\nAt this point, the analysed expression is expected, followed by the\nkeyword 'of'.\n"
    | 549 ->
        "Ill-formed case instruction.\nAt this point, an opening bracket '[' is expected.\n"
    | 550 ->
        "Ill-formed case instruction.\nAt this point, one of the following is expected:\n  * a clause, starting with a pattern;\n  * a vertical bar '|' followed by a clause.\nNote: A clause, here, is made of a pattern and an instruction or\na block of statements, separated by an arrow '->'.\n"
    | 687 | 692 ->
        "Ill-formed case expression.\nAt this point, if the clause is complete, one of the following is\nexpected:\n  * another clause;\n  * a closing bracket ']' if the case is complete.\nNote: A clause, here, is made of a pattern and an instruction or\na block of statements, separated by an arrow '->'.\n"
    | 579 | 574 ->
        "Ill-formed case instruction.\nAt this point, if the clause is complete, one of the following is\nexpected:\n  * another clause;\n  * a closing bracket ']' if the case is complete.\nNote: A clause, here, is made of a pattern and an instruction or\na block of statements, separated by an arrow '->'.\n"
    | _ ->
        raise Not_found
