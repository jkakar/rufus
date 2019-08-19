-module(rufus_tokenize_test).

-include_lib("eunit/include/eunit.hrl").

%% Automatic semicolon insertion.

string_inserts_semicolon_after_last_identifier_in_source_text_test() ->
    {ok, Tokens} = rufus_tokenize:string("module empty"),
    ?assertEqual([
     {module, 1},
     {identifier, 1, "empty"},
     {';', 1}
    ], Tokens).

string_inserts_semicolon_after_last_identifier_in_line_test() ->
    {ok, Tokens} = rufus_tokenize:string("module empty\n"),
    ?assertEqual([
     {module, 1},
     {identifier, 1, "empty"},
     {';', 1}
    ], Tokens).

string_inserts_semicolon_after_last_atom_lit_in_source_text_test() ->
    {ok, Tokens} = rufus_tokenize:string("const Name = :rufus"),
    ?assertEqual([
     {const, 1},
     {identifier, 1, "Name"},
     {'=', 1},
     {atom_lit, 1, rufus},
     {';', 1}
    ], Tokens).

string_inserts_semicolon_after_last_atom_lit_in_line_test() ->
    {ok, Tokens} = rufus_tokenize:string("const Name = :rufus\n"),
    ?assertEqual([
     {const, 1},
     {identifier, 1, "Name"},
     {'=', 1},
     {atom_lit, 1, rufus},
     {';', 1}
    ], Tokens).

string_inserts_semicolon_after_last_bool_lit_in_source_text_test() ->
    {ok, Tokens} = rufus_tokenize:string("const Bool = true"),
    ?assertEqual([
     {const, 1},
     {identifier, 1, "Bool"},
     {'=', 1},
     {bool_lit, 1, true},
     {';', 1}
    ], Tokens).

string_inserts_semicolon_after_last_bool_lit_in_line_test() ->
    {ok, Tokens} = rufus_tokenize:string("const Bool = true\n"),
    ?assertEqual([
     {const, 1},
     {identifier, 1, "Bool"},
     {'=', 1},
     {bool_lit, 1, true},
     {';', 1}
    ], Tokens).

string_inserts_semicolon_after_last_float_lit_in_source_text_test() ->
    {ok, Tokens} = rufus_tokenize:string("const Pi = 3.1415"),
    ?assertEqual([
     {const, 1},
     {identifier, 1, "Pi"},
     {'=', 1},
     {float_lit, 1, 3.1415},
     {';', 1}
    ], Tokens).

string_inserts_semicolon_after_last_float_lit_in_line_test() ->
    {ok, Tokens} = rufus_tokenize:string("const Pi = 3.1415\n"),
    ?assertEqual([
     {const, 1},
     {identifier, 1, "Pi"},
     {'=', 1},
     {float_lit, 1, 3.1415},
     {';', 1}
    ], Tokens).

string_inserts_semicolon_after_last_int_lit_in_source_text_test() ->
    {ok, Tokens} = rufus_tokenize:string("const FortyTwo = 42"),
    ?assertEqual([
     {const, 1},
     {identifier, 1, "FortyTwo"},
     {'=', 1},
     {int_lit, 1, 42},
     {';', 1}
    ], Tokens).

string_inserts_semicolon_after_last_int_lit_in_line_test() ->
    {ok, Tokens} = rufus_tokenize:string("const FortyTwo = 42\n"),
    ?assertEqual([
     {const, 1},
     {identifier, 1, "FortyTwo"},
     {'=', 1},
     {int_lit, 1, 42},
     {';', 1}
    ], Tokens).

string_inserts_semicolon_after_last_string_lit_in_source_text_test() ->
    {ok, Tokens} = rufus_tokenize:string("const Name = \"Rufus\""),
    ?assertEqual([
     {const, 1},
     {identifier, 1, "Name"},
     {'=', 1},
     {string_lit, 1, "Rufus"},
     {';', 1}
    ], Tokens).

string_inserts_semicolon_after_last_string_lit_in_line_test() ->
    {ok, Tokens} = rufus_tokenize:string("const Name = \"Rufus\"\n"),
    ?assertEqual([
     {const, 1},
     {identifier, 1, "Name"},
     {'=', 1},
     {string_lit, 1, "Rufus"},
     {';', 1}
    ], Tokens).

string_inserts_semicolon_after_last_closing_paren_in_source_text_test() ->
    {ok, Tokens} = rufus_tokenize:string("Name()"),
    ?assertEqual([
     {identifier, 1, "Name"},
     {'(', 1},
     {')', 1},
     {';', 1}
    ], Tokens).

string_inserts_semicolon_after_last_closing_paren_in_line_test() ->
    {ok, Tokens} = rufus_tokenize:string("Name()\n"),
    ?assertEqual([
     {identifier, 1, "Name"},
     {'(', 1},
     {')', 1},
     {';', 1}
    ], Tokens).

string_inserts_semicolon_before_last_closing_brace_in_source_text_test() ->
    {ok, Tokens} = rufus_tokenize:string("func Name() string { \"Rufus\" }"),
    ?assertEqual([
     {func, 1},
     {identifier, 1, "Name"},
     {'(', 1},
     {')', 1},
     {string, 1},
     {'{', 1},
     {string_lit, 1, "Rufus"},
     {';', 1},
     {'}', 1}
    ], Tokens).

string_inserts_semicolon_before_last_closing_brace_in_line_test() ->
    {ok, Tokens} = rufus_tokenize:string("func Name() string { \"Rufus\" }\n"),
    ?assertEqual([
     {func, 1},
     {identifier, 1, "Name"},
     {'(', 1},
     {')', 1},
     {string, 1},
     {'{', 1},
     {string_lit, 1, "Rufus"},
     {';', 1},
     {'}', 1}
    ], Tokens).

string_inserts_semicolon_before_last_closing_brace_never_emits_duplicate_semicolons_test() ->
    {ok, Tokens} = rufus_tokenize:string("
    func Name() string {
        \"Rufus\"
    }
    "),
    ?assertEqual([
     {func, 2},
     {identifier, 2, "Name"},
     {'(', 2},
     {')', 2},
     {string, 2},
     {'{', 2},
     {string_lit, 3, "Rufus"},
     {';', 3},
     {'}', 4}
    ], Tokens).

%% Arbitrary whitespace.

string_with_extra_newlines_test() ->
    {ok, Tokens} = rufus_tokenize:string("\n\n\nconst Name = :rufus\n\n\n"),
    ?assertEqual([
     {const, 4},
     {identifier, 4, "Name"},
     {'=', 4},
     {atom_lit, 4, rufus},
     {';', 4}
    ], Tokens).

string_with_newline_in_expression_after_operator_test() ->
    {ok, Tokens} = rufus_tokenize:string("const Name =\n :rufus"),
    ?assertEqual([
     {const, 1},
     {identifier, 1, "Name"},
     {'=', 1},
     {atom_lit, 2, rufus},
     {';', 2}
    ], Tokens).

string_with_newline_in_expression_after_reserved_word_test() ->
    {ok, Tokens} = rufus_tokenize:string("const\n Name = :rufus"),
    ?assertEqual([
     {const, 1},
     {identifier, 2, "Name"},
     {'=', 2},
     {atom_lit, 2, rufus},
     {';', 2}
    ], Tokens).
