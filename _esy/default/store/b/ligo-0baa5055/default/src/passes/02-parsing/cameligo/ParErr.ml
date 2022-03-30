
(* This file was auto-generated based on "errors.msg.in". *)

(* Please note that the function [message] can raise [Not_found]. *)

let message =
  fun s ->
    match s with
    | 518 | 526 | 929 | 935 | 911 | 945 | 888 | 892 | 869 | 898 | 960 | 964 | 841 | 970 | 291 | 989 | 1030 | 1034 | 1011 | 1040 | 751 | 757 | 720 | 768 | 820 | 824 | 801 | 830 | 673 | 681 | 627 | 697 ->
        "Ill-formed functional expression.\nAt this point, if there are no more parameters, one of the following\nis expected:\n  * an arrow '->', followed by the body as an expression;\n  * a type annotation for the body, starting with a colon ':'.\n"
    | 462 | 474 | 486 | 501 ->
        "Ill-formed tuple declaration.\nAt this point, one of the following is expected:\n  * a comma ',' followed by another component as a pattern;\n  * the assignment symbol '=' followed by an expression;\n  * a type annotation starting with a colon ':';\n  * bound type parameters between parentheses, like '(type a b)'.\n"
    | 450 ->
        "Ill-formed tuple declaration.\nAt this point, if there are no more components, one of the following\nis expected:\n  * the assignment symbol '=' followed by an expression;\n  * a type annotation starting with a colon ':';\n  * bound type parameters between parentheses, like '(type a b)'.\n"
    | 1101 | 1089 ->
        "Ill-formed function declaration.\nAt this point, if there are no more parameters, one of the following\nis expected:\n  * the assignment symbol '=' followed by an expression;\n  * a type annotation starting with a colon ':'.\n"
    | 444 | 456 | 468 | 480 | 492 | 507 | 1146 ->
        "Ill-formed value declaration.\nAt this point, one of the following is expected:\n  * the assignment symbol '=' followed by an expression;\n  * a type annotation starting with a colon ':'.\n"
    | 254 ->
        "Ill-formed value declaration.\nAt this point, one of the following is expected:\n  * parameters as irrefutable patterns, e.g. variables, if defining a\n    function;\n  * the assignment symbol '=' followed by an expression;\n  * a type annotation starting with a colon ':';\n  * a comma ',' followed by another tuple component, if defining a\n    tuple.\n"
    | 229 | 232 | 154 | 240 | 243 | 246 | 251 ->
        "Ill-formed pattern.\nAt this point, one of the following is expected:\n  * a closing parenthesis ')', if the pattern is complete;\n  * a comma ',' followed by another component as a pattern, if\n    defining a tuple pattern;\n  * a type annotation starting with ':'.\n"
    | 202 | 162 | 164 | 189 | 193 | 196 | 199 ->
        "Ill-formed record pattern.\nAt this point, one of the following is expected:\n  * a comma ',' followed by a tuple component as a pattern, if the\n    field is a tuple;\n  * a semicolon ';' if the field is punned (that is, a variable with\n    the same name is implicitly the pattern);\n  * a closing brace '}' if the record pattern is complete.\n"
    | 113 ->
        "Ill-formed value declaration.\nAt this point, the keyword 'type' is expected, followed by type\nparameters and a closing parenthesis ')'.\n"
    | 1178 ->
        "Ill-formed expression.\nAt this point, if the expression is complete, the end of the input is\nexpected.\n"
    | 235 ->
        "Ill-formed typed pattern.\nAt this point, if the type annotation is complete, then a closing\nparenthesis ')' is expected.\n"
    | 1036 | 1032 | 966 | 962 | 932 | 894 | 890 | 826 | 822 | 760 | 754 | 765 | 771 | 828 | 832 | 896 | 900 | 942 | 948 | 968 | 972 | 986 | 992 | 1038 | 1042 | 701 | 693 | 529 | 677 | 685 | 521 | 938 ->
        "Ill-formed functional expression.\nAt this point, if the type of the body is complete, an arrow '->' is\nexpected, followed by the body as an expression.\n"
    | 63 | 308 ->
        "Ill-formed attributed sum type or record type.\nAt this point, if the attributes are complete, one of the following is\nexpected:\n  * an opening brace '{' followed by field declarations, if defining a\n    record type;\n  * a variant starting with a value constructor, if defining a sum\n    type (the attributes then apply to the variant, not the type);\n  * a vertical bar followed by a variant (the attributes then apply to\n    the sum type, not the variant).\n"
    | 39 | 300 ->
        "Ill-formed variant.\nAt this point, if the attributes of the variant are complete, a data\nconstructor is expected.\n"
    | 101 | 14 ->
        "Ill-formed type declaration.\nAt this point, a type expression is expected.\n"
    | 100 | 13 ->
        "Ill-formed type declaration.\nAt this point, the assignment symbol '=' is expected, followed by a\ntype expression.\n"
    | 54 ->
        "Ill-formed record type.\nAt this point, if the attribute is complete, an opening brace '{' is\nexpected.\n"
    | 1118 | 1122 ->
        "Ill-formed list of expressions.\nAt this point, one of the following is expected:\n  * a list element as an expression;\n  * a closing bracket ']' if the list is complete.\n"
    | 1064 ->
        "Ill-formed record update.\nAt this point, the expression assigned to the field is expected.\n"
    | 630 | 1014 | 723 | 345 | 804 | 872 ->
        "Ill-formed local type declaration.\nAt this point, an expression is expected.\n"
    | 280 | 257 ->
        "Ill-formed functional expression.\nAt this point, one of the following is expected:\n  * a parameter as an irrefutable pattern, e.g. a variable;\n  * an arrow '->' followed by the body as an expression.\n"
    | 725 | 806 | 845 | 874 | 914 | 1016 | 1158 | 632 | 349 ->
        "Ill-formed attributed expression.\nAt this point, if the attributes are complete, one of the following is\nexpected:\n  * a functional expression starting with the keyword 'fun';\n  * a local value declaration starting with the keyword 'let'.\n"
    | 577 | 581 ->
        "Ill-formed list of patterns.\nAt this point, one of the following is expected:\n  * a list element as a pattern;\n  * a closing bracket ']' if the list is complete.\n"
    | 574 ->
        "Ill-formed list pattern.\nAt this point, a pattern that matches as list is expected.\n"
    | 1127 | 1131 | 979 | 783 | 1000 | 536 | 608 ->
        "Ill-formed pattern matching.\nAt this point, a case is expected to start with a pattern.\n"
    | 255 | 256 | 258 | 260 | 262 | 264 | 266 | 282 | 284 | 286 | 289 | 524 ->
        "Ill-formed function parameters.\nAt this point, one of the following is expected:\n  * another parameter as an irrefutable pattern, e.g a variable;\n  * a type annotation starting with a colon ':' for the body;\n  * the assignment symbol '=' followed by an expression.\n"
    | 1102 | 1105 ->
        "Ill-formed function declaration.\nAt this point, the body of the function is expected as an expression.\n"
    | 1095 ->
        "Ill-formed polymorphic function declaration.\nAt this point, one of the following is expected:\n  * parameters as irrefutable patterns, e.g. variables;\n  * the assignment symbol '=' followed by the body as an expression;\n  * a type annotation starting with a colon ':' for the body.\n"
    | 25 ->
        "Ill-formed parenthesised expression.\nAt this point, an expression is expected.\nNote: Tuples of expressions do not require in general to be\nparenthesised, but parentheses improve readability.\n"
    | 271 ->
        "Ill-formed value declaration.\nAt this point, one of the following is expected:\n  * the keyword 'type' followed by type parameters and a closing\n    parenthesis ')';\n  * a closing parenthesis ')' if matching the unit pattern;\n  * a parameter as an irrefutable pattern followed by a closing\n    parenthesis ')'.\n"
    | 370 | 1024 | 882 | 640 | 733 | 814 ->
        "Ill-formed local module alias declaration.\nAt this point, an expression is expected.\n"
    | 368 | 1022 | 880 | 812 | 731 | 638 ->
        "Ill-formed local module declaration.\nAt this point, an expression is expected.\n"
    | 997 | 316 | 147 | 605 ->
        "Ill-formed match expression.\nAt this point, the expression whose value is being matched is\nexpected.\n"
    | 1028 | 958 | 927 | 886 | 818 | 749 | 516 | 1009 | 909 | 867 | 839 | 799 | 718 | 279 | 625 | 671 ->
        "Ill-formed functional expression.\nAt this point, one of the following is expected:\n  * parameters as irrefutable patterns, e.g. variables;\n  * bound type parameters between parentheses, like '(type a b)'.\n"
    | 1029 | 840 | 819 | 750 | 517 | 672 | 288 | 626 | 719 | 800 | 910 | 1010 | 868 | 887 | 928 | 959 ->
        "Ill-formed functional expression.\nAt this point, parameters are expected as irrefutable patterns,\ne.g. variables.\n"
    | 275 ->
        "Ill-formed record expression.\nAt this point, an expression is expected to be assigned to the field.\n"
    | 149 ->
        "Ill-formed list of expressions.\nAt this point, one of the following is expected:\n  * a list element as an expression;\n  * a closing bracket ']' if defining the empty list.\n"
    | 590 | 593 | 165 | 167 | 158 | 169 | 171 | 173 | 176 | 181 | 190 | 194 | 197 | 200 | 203 | 156 ->
        "Ill-formed tuple of patterns.\nAt this point, another component is expected as a pattern.\n"
    | 543 ->
        "Ill-formed list of patterns.\nAt this point, one of the following is expected:\n  * a list element as a pattern;\n  * a closing bracket ']' if matching the empty list.\n"
    | 145 ->
        "Ill-formed expression.\nAt this point, one of the following is expected:\n  * an expression, if defining a parenthesised expression;\n  * a closing parenthesis ')' if defining the unit value '()'.\n"
    | 143 ->
        "Ill-formed code injection.\nAt this point, the code is expected as an expression whose value is a\nverbatim string.\n"
    | 1087 | 272 | 1090 | 1093 | 122 | 442 | 353 | 445 | 448 | 451 | 454 | 457 | 460 | 463 | 466 | 469 | 472 | 475 | 478 | 481 | 484 | 487 | 490 | 493 | 496 | 502 | 505 | 508 | 511 | 1096 | 1099 | 1144 | 1147 | 1150 ->
        "Ill-formed value declaration.\nAt this point, an expression is expected.\n"
    | 177 ->
        "Ill-formed attributed variable in a pattern.\nAt this point, if the attribute is complete, an identifier is\nexpected.\n"
    | 546 ->
        "Ill-formed record pattern.\nAt this point, a pattern matching the field is expected.\n"
    | 161 ->
        "Ill-formed record pattern.\nAt this point, an irrefutable pattern matching the field is expected,\ne.g. a variable.\n"
    | 153 | 542 ->
        "Ill-formed pattern.\nAt this point, one of the following is expected:\n  * a pattern followed by a closing parenthesis ')';\n  * a closing parenthesis ')' if matching the unit value '()'.\n"
    | 110 ->
        "Ill-formed module declaration.\nAt this point, declarations are expected.\n"
    | 88 | 90 ->
        "Ill-formed parametric type expression.\nAt this point, a type argument is expected as a type expression.\n"
    | 1136 ->
        "Ill-formed typed expression.\nAt this point, a type expression is expected.\n"
    | 218 | 292 ->
        "Ill-formed type annotation.\nAt this point, a type expression is expected.\nNote: If you want a functional type, enclose it between parentheses.\n"
    | 77 | 81 ->
        "Ill-formed record type.\nAt this point one of the following is expected:\n  * a field declaration, starting with a field name;\n  * a closing brace '}' if the record is complete.\n"
    | 59 ->
        "Ill-formed record type.\nAt this point, if the attribute is complete, a field name is expected.\n"
    | 30 | 61 ->
        "Ill-formed record type.\nAt this point, the type of the field is expected.\n"
    | 60 | 29 ->
        "Ill-formed record type.\nAt this point, a type annotation for the field is expected, starting\nwith a colon ':'.\n"
    | 45 ->
        "Ill-formed type expression.\nAt this point, a type constructor is expected.\nNote: A type constructor is the analogue of a function name at the\ntype level. For example, 'list', 'map' and 'set' are type\nconstructors. Contrary to function names, type constructors are\nwritten after their arguments.\n"
    | 7 ->
        "Ill-formed parametric type declaration.\nAt this point, one of the following is expected:\n  * a comma ',' followed by another quoted type parameter, like 'a;\n  * a closing parenthesis ')' if there are no more parameters.\n"
    | 5 ->
        "Ill-formed parametric type declaration.\nAt this point, a comma ',' is expected, followed by another quoted\ntype parameter, like 'a.\n"
    | 4 | 8 | 6 ->
        "Ill-formed parametric type declaration.\nAt this point, a quoted type parameter is expected, like 'a.\n"
    | 583 ->
        "Ill-formed parenthesised pattern.\nAt this point, if the type annotation is complete, a closing\nparenthesis ')' is expected.\n"
    | 580 | 576 ->
        "Ill-formed list of patterns.\nAt this point, if the element as a pattern is complete, one of\nthe following is expected:\n  * a semicolon ';' followed by another pattern;\n  * a closing bracket ']' if the list is complete.\n"
    | 115 | 116 ->
        "Ill-formed type parameters.\nAt this point, one of the following is expected:\n  * a type parameter without a quote;\n  * a closing parenthesis ')' if there are no more parameters.\n"
    | 114 ->
        "Ill-formed type parameter.\nAt this point, a type parameter without a quote is expected.\n"
    | 210 | 214 | 562 | 566 ->
        "Ill-formed record pattern.\nAt this point, if the field pattern is complete, one of the following\nis expected:\n  * another field pattern starting with a field name;\n  * a closing brace '}' if the record pattern is complete.\n"
    | 565 | 561 | 209 | 213 ->
        "Ill-formed record pattern.\nAt this point, if the field pattern is complete, one of the following\nis expected:\n  * a semicolon ';' followed by another field pattern;\n  * a closing brace '}' if the record pattern is complete.\n"
    | 99 ->
        "Ill-formed parametric type declaration.\nAt this point, the name of the type being defined is expected.\n"
    | 2 ->
        "Ill-formed quoted type parameter.\nAt this point, an identifier is expected.\n"
    | 108 ->
        "Ill-formed module qualification.\nAt this point, a module name is expected.\n"
    | 369 | 639 | 732 | 813 | 881 | 1023 ->
        "Ill-formed local module declaration.\nAt this point, if the module to be aliased is fully qualified, the\nkeyword 'in' is expected, followed by an expression.\n"
    | 367 | 637 | 811 | 730 | 1021 | 879 ->
        "Ill-formed local module declaration.\nAt this point, the keyword 'in' is expected, followed by an\nexpression.\n"
    | 104 ->
        "Ill-formed module declaration.\nAt this point, the name of the module being declared or aliased is\nexpected.\n"
    | 105 ->
        "Ill-formed module declaration.\nAt this point, the assignment symbol '=' is expected to introduce\neither the qualified name of a module being aliased, or a module\nstructure.\n"
    | 106 ->
        "Ill-formed module declaration or module alias declaration.\nAt this point, one of the following is expected:\n  * the qualified name of a module being aliased;\n  * the keyword 'struct' followed by declarations, if\n    defining a module.\n"
    | 1165 ->
        "Ill-formed module declaration.\nAt this point, if the declaration is complete, one of the following is\nexpected:\n  * another declaration;\n  * the end of the file.\n"
    | 1173 | 1168 | 1170 ->
        "Ill-formed contract.\nAt this point, if the declaration is complete, one of the following is\nexpected:\n  * another declaration;\n  * the end of the file.\n"
    | 344 | 722 | 871 | 1013 | 629 | 803 ->
        "Ill-formed local type declaration.\nAt this point, if the type expression is complete, the keyword 'in' is\nexpected, followed by an expression.\n"
    | 1 ->
        "Ill-formed type declaration.\nAt this point, one of the following is expected:\n  * the name of the type being defined;\n  * a quoted type parameter, like 'a;\n  * a tuple of quoted type parameters, like ('a, 'b).\n"
    | 299 | 309 | 64 | 16 | 38 | 293 ->
        "Ill-formed variant of sum type.\nAt this point, a variant starting with a data constructor is expected.\n"
    | 73 | 70 ->
        "Ill-formed product type.\nAt this point, a type expression is expected.\nHint: If you want a sum type, put it between parentheses.\n"
    | 19 ->
        "Ill-formed selection of a type in a module.\nAt this point, the selection symbol '.' is expected, followed by the\nqualified name of a type.\n"
    | 295 | 18 ->
        "Ill-formed parameter of a variant.\nAt this point, a type expression is expected.\nNote: If you want a sum type, enclose it between parentheses.\n"
    | 51 ->
        "Ill-formed functional type.\nAt this point, a type expression is expected.\nNote: If you want a sum type, enclose it between parentheses.\n"
    | 86 ->
        "Ill-formed parenthesised type or argument to a type constructor.\nAt this point, one of the following is expected:\n  * a closing parenthesis if the type is complete;\n  * a comma ',' followed by another type expression, if defining the\n    argument to a type constructor.\n"
    | 89 ->
        "Ill-formed argument to a type constructor.\nAt this point, if the tuple component is complete, one of the\nfollowing is expected:\n  * a comma ',' followed by another component as a type expression;\n  * a closing parenthesis ')' if the tuple is complete.\n"
    | 28 | 55 ->
        "Ill-formed record type.\nAt this point, field declarations are expected, separated by\nsemicolons ';'.\n"
    | 80 | 76 ->
        "Ill-formed record type.\nAt this point, if the field is complete, one of the following is\nexpected:\n  * a semicolon ';' followed by another field declaration;\n  * a closing brace '}' if the record type is complete.\n"
    | 112 | 352 ->
        "Ill-formed value declaration.\nAt this point, one of the following is expected:\n  * a type annotation starting with a colon ':';\n  * the assignment symbol '=' followed by an expression;\n  * a comma ',' followed by another component as a pattern, if\n    defining a tuple.\n"
    | 586 | 237 ->
        "Ill-formed parenthesised pattern.\nAt this point, if the enclosed pattern is complete, one of the\nfollowing is expected:\n  * a type annotation starting with a colon ':', followed by a closing\n    parenthesis ')';\n  * a closing parenthesis ')'.\n"
    | 249 ->
        "Ill-formed parenthesised pattern.\nAt this point, if the enclosed pattern is complete, a closing\nparenthesis ')' is expected.\n"
    | 159 | 544 ->
        "Ill-formed record pattern.\nAt this point, field patterns are expected, separated by semicolons ';'.\n"
    | 160 | 545 ->
        "Ill-formed record pattern.\nAt this point, one of the following is expected:\n  * the assignment symbol '=' followed by a pattern;\n  * a semicolon ';' if the field is punned (that is, a variable with\n    the same name denotes implicitly the pattern);\n  * a closing brace '}' if the record pattern is complete.\n"
    | 1092 | 1104 | 1143 | 447 | 453 | 459 | 465 | 471 | 477 | 483 | 489 | 495 | 504 | 510 | 1086 | 1098 | 1149 | 441 ->
        "Ill-formed value declaration.\nAt this point, if the type annotation is complete, the assignment\nsymbol '=' is expected, followed by an expression.\n"
    | 127 ->
        "Ill-formed selection of a value from a module.\nAt this point, the selection symbol '.' is expected, followed by the\nqualified name of a value.\n"
    | 400 ->
        "Ill-formed list expression.\nAt this point, an expression of type list is expected.\n"
    | 429 | 426 ->
        "Ill-formed tuple of expressions.\nAt this point, another component is expected as an expression.\nHint: To check your understanding of the syntax, try and add\nparentheses around what you think is the expression.\n"
    | 148 | 144 | 403 | 434 | 381 | 383 | 415 | 413 | 411 | 409 | 407 | 405 | 398 | 359 | 396 | 357 | 355 | 320 | 342 | 361 | 363 | 365 ->
        "Ill-formed expression.\nAt this point, an expression is expected.\nHint: To check your understanding of the syntax, try and add\nparentheses around what you think is the expression.\n"
    | 1139 ->
        "Ill-formed code injection.\nAt this point, a closing bracket ']' is expected.\n"
    | 1134 ->
        "Ill formed parenthesised expression.\nAt this point, if the expression is complete, one of the following is\nexpected:\n  * a type annotation starting with a colon ':';\n  * a closing parenthesis ')'.\n"
    | 1132 ->
        "Ill-formed typed expression.\nAt this point, if the type annotation is complete, then a closing\nparenthesis ')' is expected.\n"
    | 1121 | 1117 ->
        "Ill-formed list of expressions.\nAt this point, if the list element is complete, one of the\nfollowing is expected:\n  * a semicolon ';' followed by more elements as expressions;\n  * a closing bracket ']' if the list is complete.\n"
    | 273 ->
        "Ill-formed record expression or update.\nAt this point, one of the following is expected:\n  * field assignments separated by semicolons ';', if defining a record;\n  * the qualified name of the record to update, otherwise.\n"
    | 1059 ->
        "Ill-formed record update.\nAt this point, assignments to fields (updates) are expected, separated\nby semicolons ';' and each starting with fully qualified field names.\n"
    | 1060 ->
        "Ill-formed record update.\nAt this point, one of the following is expected:\n  * the assignment symbol '=' if the field to update is fully\n    qualified;\n  * the selection symbol '.' to further qualify the field to update.\n"
    | 1073 | 1069 ->
        "Ill-formed record update.\nAt this point, one of the following is expected:\n  * more field assignments (updates) separated by semicolons ';';\n  * a closing brace '}' if the update is complete.\n"
    | 1063 ->
        "Ill-formed record update.\nAt this point, the assignment symbol '=' is expected, followed by an\nexpression (update).\n"
    | 274 ->
        "Ill-formed record expression or record update.\nAt this point, one of the following is expected:\n  * the assignment symbol '=' followed by an expression, if defining\n    a record (as opposed to a record update);\n  * the keyword 'with' followed by field updates (assignments);\n  * the selection symbol '.' if the record to update is not fully\n    qualified.\n"
    | 1079 ->
        "Ill-formed assignment to a field in a record.\nAt this point, the assignment symbol '=' is expected, followed by an\nexpression.\n"
    | 1072 | 1068 ->
        "Ill-formed record update.\nAt this point, if the expression assigned to the field (update) is\ncomplete, one of the following is expected:\n  * a semicolon ';' followed by another field assignment;\n  * a closing brace '}' if the update is complete.\n"
    | 1082 | 1077 ->
        "Ill-formed record expression.\nAt this point, if the expression assigned to the field is complete,\none of the following is expected:\n  * a semicolon ';' followed by another field assignment;\n  * a closing brace '}' if the record is complete.\n"
    | 1083 | 1078 ->
        "Ill-formed record expression.\nAt this point, one of the following is expected:\n  * more field assignments separated by semicolons ';';\n  * a closing brace '}' if the record is complete.\n"
    | 1058 ->
        "Ill-formed record update.\nAt this point, if the record is fully qualified, then the keyword\n'with' is expected, followed by field updates (assignments) separated\nby semicolons ';'.\n"
    | 130 | 134 ->
        "Ill-formed selection in a record or a tuple.\nAt this point, one of the following is expected:\n  * the name of a record field;\n  * the index of a component in a tuple, '0' denoting the first\n    component.\n"
    | 20 ->
        "Ill-formed selection of a type in a module.\nAt this point, the qualified name of a type is expected.\n"
    | 126 ->
        "Ill-formed selection of a value from a module.\nAt this point, the qualified name of a value is expected.\n"
    | 851 ->
        "Ill-formed sequence of expressions.\nAt this point, if the expression is complete, one of the following is\nexpected:\n  * a semicolon ';' followed by another expression;\n  * the keyword 'end' if the sequence is complete.\n"
    | 852 ->
        "Ill-formed sequence of expressions.\nAt this point, an expression of type 'unit' is expected.\nNote: The last expression in a sequence cannot be terminated by a\nsemicolon ';'.\n"
    | 607 | 534 | 999 | 1126 ->
        "Ill-formed pattern matching.\nAt this point, the first case is expected to start with a pattern or a\nvertical bar.\n"
    | 1128 | 596 | 609 ->
        "Ill-formed pattern matching.\nAt this point, if the pattern is complete, an arrow '->' is expected,\nfollowed by an expression.\n"
    | 978 | 782 ->
        "Ill-formed pattern matching.\nAt this point, if the case is complete, a vertical bar '|' is\nexpected, followed by another case starting with a pattern.\n"
    | 606 | 533 | 1125 | 998 ->
        "Ill-formed pattern matching.\nAt this point, if the expression is complete, then the keyword 'with'\nis expected, followed by matching cases.\n"
    | 1159 | 1017 | 1002 | 915 | 875 | 860 | 853 | 846 | 807 | 726 | 790 | 633 | 618 | 150 | 111 | 350 | 598 | 611 ->
        "Ill-formed value declaration.\nAt this point, one of the following is expected:\n  * a pattern, e.g. an identifier;\n  * the keyword 'rec' if defining a recursive function.\n"
    | 599 | 1018 | 1160 | 1003 | 916 | 876 | 861 | 854 | 847 | 808 | 791 | 727 | 634 | 1152 | 152 | 351 | 612 | 619 ->
        "Ill-formed recursive value declaration.\nAt this point, a pattern is expected, e.g. an identifier.\n"
    | 635 | 667 | 884 | 917 | 924 | 956 | 809 | 728 | 746 | 816 | 848 | 877 | 862 | 855 | 600 | 1004 | 613 | 1108 | 620 | 792 | 904 | 952 | 974 | 776 | 1049 | 1110 | 712 | 834 | 513 | 1019 | 1026 | 498 ->
        "Ill-formed local value declaration.\nAt this point, if the expression of the left-hand side is complete,\nthe keyword 'in' is expected, followed by an expression.\n"
    | 865 | 858 | 603 | 1007 | 616 | 995 | 623 | 795 ->
        "Ill-formed conditional expression.\nAt this point, if the condition is complete, the keyword 'then' is\nexpected, followed by an expression.\n"
    | 705 | 902 | 906 | 1045 | 1052 | 716 | 788 | 797 ->
        "Ill-formed complete conditional expression.\nAt this point, if the expression of the branch 'then' is complete, the\nkeyword 'else' is expected, followed by an expression.\n"
    | 0 ->
        "Ill-formed contract.\nAt this point, a declaration is expected.\n"
    | 1176 ->
        "Ill-formed expression.\nAt this point, an expression is expected.\n"
    | 918 | 878 | 863 | 925 | 953 | 957 | 975 | 1005 | 1020 | 1027 | 1050 | 1111 | 885 | 905 | 835 | 1109 | 499 | 514 | 601 | 614 | 621 | 636 | 668 | 713 | 729 | 747 | 777 | 793 | 810 | 817 | 849 | 856 ->
        "Ill-formed local value declaration.\nAt this point, an expression is expected.\n"
    | 859 | 996 | 796 | 604 | 617 | 624 | 866 | 1008 ->
        "Ill-formed conditional expression.\nAt this point, the 'then' branch is expected as an expression.\n"
    | 315 ->
        "Ill-formed sequence of expressions.\nAt this point, one of the following is expected:\n  * an expression of type 'unit';\n  * the keyword 'end' if the sequence is empty.\n"
    | 610 | 597 | 1129 ->
        "Ill-formed pattern matching.\nAt this point, the right-hand side of the current clause is expected\nas an expression.\n"
    | 1037 | 1035 | 1033 | 1031 | 967 | 965 | 963 | 961 | 939 | 936 | 933 | 930 | 895 | 893 | 891 | 889 | 827 | 825 | 823 | 821 | 761 | 758 | 755 | 752 | 519 | 522 | 527 | 530 | 674 | 678 | 682 | 686 | 971 | 990 | 698 | 769 | 831 | 899 | 946 | 1041 | 313 | 628 | 694 | 702 | 721 | 766 | 772 | 802 | 829 | 833 | 842 | 870 | 897 | 901 | 912 | 943 | 949 | 969 | 973 | 987 | 993 | 1012 | 1039 | 1043 ->
        "Ill-formed functional expression.\nAt this point, the body of the function is expected as an expression.\n"
    | 1053 | 903 | 798 | 717 | 706 | 789 | 1046 | 907 ->
        "Ill-formed conditional expression.\nAt this point, the expression of the 'else' branch is expected.\n"
    | 602 | 277 | 1006 | 864 | 857 | 794 | 622 | 615 ->
        "Ill-formed conditional expression.\nAt this point, the condition is expected as an expression.\n"
    | 983 ->
        "Ill-formed sequence of expressions.\nAt this point, if the expression is complete, one of the following is\nexpected:\n  * a semicolon ';' followed by another expression;\n  * the keyword 'end' if the sequence is complete.\n"
    | _ ->
        raise Not_found
