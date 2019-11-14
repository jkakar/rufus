-module(rufus_form_test).

-include_lib("eunit/include/eunit.hrl").

annotate_test() ->
    Form = {identifier, #{spec => n, line => 13}},
    TypeForm = rufus_form:make_type(integer, 13),
    Expected = {identifier, #{spec => n, line => 13, type => TypeForm}},
    ?assertEqual(Expected, rufus_form:annotate(Form, type, TypeForm)).

globals_without_func_forms_test() ->
    RufusText = "module empty",
    {ok, Tokens} = rufus_tokenize:string(RufusText),
    {ok, Forms} = rufus_parse:parse(Tokens),
    ?assertEqual({ok, #{}}, rufus_form:globals(Forms)).

globals_test() ->
    RufusText = "
    module example
    func Echo(n string) string { n }
    func Number() int { 42 }
    ",
    {ok, Tokens} = rufus_tokenize:string(RufusText),
    {ok, Forms} = rufus_parse:parse(Tokens),
    Echo1 = {func, #{params => [{param, #{line => 3,
                                          spec => n,
                                          type => {type, #{line => 3,
                                                           source => rufus_text,
                                                           spec => string}}}}],
                     exprs => [{identifier, #{line => 3,
                                              spec => n}}],
                     line => 3,
                     return_type => {type, #{line => 3,
                                             source => rufus_text,
                                             spec => string}},
                     spec => 'Echo'}},
    Number0 = {func, #{params => [],
                       exprs => [{int_lit, #{line => 4,
                                             spec => 42,
                                             type => {type, #{line => 4,
                                                              source => inferred,
                                                              spec => int}}}}],
                       line => 4,
                       return_type => {type, #{line => 4,
                                               source => rufus_text,
                                               spec => int}},
                       spec => 'Number'}},
    ?assertEqual({ok, #{'Echo' => [Echo1], 'Number' => [Number0]}}, rufus_form:globals(Forms)).

globals_with_multiple_function_heads_test() ->
    RufusText = "
    module example
    func Echo(n string) string { n }
    func Echo(n int) int { n }
    ",
    {ok, Tokens} = rufus_tokenize:string(RufusText),
    {ok, Forms} = rufus_parse:parse(Tokens),
    EchoString = {func, #{params => [{param, #{line => 3,
                                               spec => n,
                                               type => {type, #{line => 3,
                                                                source => rufus_text,
                                                                spec => string}}}}],
                          exprs => [{identifier, #{line => 3,
                                                   spec => n}}],
                          line => 3,
                          return_type => {type, #{line => 3,
                                                  source => rufus_text,
                                                  spec => string}},
                          spec => 'Echo'}},
    EchoInt = {func, #{params => [{param, #{line => 4,
                                            spec => n,
                                            type => {type, #{line => 4,
                                                             source => rufus_text,
                                                             spec => int}}}}],
                       exprs => [{identifier, #{line => 4,
                                                spec => n}}],
                       line => 4,
                       return_type => {type, #{line => 4,
                                               source => rufus_text,
                                               spec => int}},
                       spec => 'Echo'}},
    ?assertEqual({ok, #{'Echo' => [EchoString, EchoInt]}}, rufus_form:globals(Forms)).

line_test() ->
    Form = {identifier, #{spec => n, line => 13}},
    ?assertEqual(13, rufus_form:line(Form)).

return_type_test() ->
    ReturnType = rufus_form:make_type(string, 13),
    Form = rufus_form:make_func('Ping', [], ReturnType, [], 13),
    ?assertEqual(ReturnType, rufus_form:return_type(Form)).

source_test() ->
    Type = rufus_form:make_type(int, 19),
    ?assertEqual(rufus_text, rufus_form:source(Type)),
    InferredType = rufus_form:make_inferred_type(int, 27),
    ?assertEqual(inferred, rufus_form:source(InferredType)).

spec_test() ->
    Form = {identifier, #{spec => n, line => 13}},
    ?assertEqual(n, rufus_form:spec(Form)).

type_test() ->
    Type = rufus_form:make_inferred_type(int, 27),
    Form = {int_lit, #{spec => 42, type => Type, line => 7}},
    ?assertEqual(Type, rufus_form:type(Form)).

type_spec_with_rufus_form_test() ->
    Type = rufus_form:make_inferred_type(int, 27),
    Form = {int_lit, #{spec => 42, type => Type, line => 7}},
    ?assertEqual(int, rufus_form:type_spec(Form)).

type_spec_with_type_form_test() ->
    Type = rufus_form:make_inferred_type(int, 27),
    ?assertEqual(int, rufus_form:type_spec(Type)).

type_spec_with_locals_test() ->
    Locals = #{t => rufus_form:make_type(string, 3)},
    Form = {identifier, #{line => 3, locals => Locals, spec => t}},
    ?assertEqual(string, rufus_form:type_spec(Form)).

type_spec_with_unknown_form_test() ->
    Locals = #{other => rufus_form:make_type(string, 3)},
    Form = {identifier, #{line => 3, locals => Locals, spec => unknown}},
    ?assertEqual({error, unknown_form, #{form => Form}}, rufus_form:type_spec(Form)).

make_module_test() ->
    ?assertEqual({module, #{spec => example, line => 1}}, rufus_form:make_module(example, 1)).

make_import_test() ->
    ?assertEqual({import, #{spec => "example", line => 3}}, rufus_form:make_import("example", 3)).

make_identifier_test() ->
    ?assertEqual({identifier, #{spec => n, line => 13}}, rufus_form:make_identifier(n, 13)).

make_literal_test() ->
    ?assertEqual({bool_lit, #{spec => true, line => 7, type => rufus_form:make_inferred_type(bool, 7)}},
                 rufus_form:make_literal(bool, true, 7)),
    ?assertEqual({float_lit, #{spec => "37.103", line => 92, type => rufus_form:make_inferred_type(float, 92)}},
                 rufus_form:make_literal(float, "37.103", 92)),
    ?assertEqual({int_lit, #{spec => "42", line => 5, type => rufus_form:make_inferred_type(int, 5)}},
                 rufus_form:make_literal(int, "42", 5)),
    ?assertEqual({string_lit, #{spec => <<"hello">>, line => 9, type => rufus_form:make_inferred_type(string, 9)}},
                 rufus_form:make_literal(string, <<"hello">>, 9)).

make_binary_op_test() ->
    Operand = {int_lit, #{spec => 2, line => 4}},
    ?assertEqual({binary_op, #{op => '+', left => Operand, right => Operand, line => 4}},
                 rufus_form:make_binary_op('+', Operand, Operand, 4)).

make_func_test() ->
    Type = rufus_form:make_type(bool, 81),
    ?assertEqual({func, #{spec => 'True', params => [], return_type => Type, exprs => [], line => 81}},
                 rufus_form:make_func('True', [], Type, [], 81)).

make_param_test() ->
    Type = rufus_form:make_type(int, 52),
    ?assertEqual({param, #{spec => n, type => Type, line => 52}}, rufus_form:make_param(n, Type, 52)).

make_inferred_type_test() ->
    ?assertEqual({type, #{spec => int, source => inferred, line => 4}}, rufus_form:make_inferred_type(int, 4)).

make_type_test() ->
    ?assertEqual({type, #{spec => float, source => rufus_text, line => 37}}, rufus_form:make_type(float, 37)).

make_match_test() ->
    Left = rufus_form:make_identifier(n, 3),
    Right = rufus_form:make_identifier(m, 3),
    ?assertEqual({match, #{left => Left, right => Right, line => 3}},
                 rufus_form:make_match(Left, Right, 3)).
