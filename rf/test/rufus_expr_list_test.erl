-module(rufus_expr_list_test).

-include_lib("eunit/include/eunit.hrl").

typecheck_and_annotate_with_function_returning_an_empty_list_of_ints_test() ->
    RufusText = "
    module example
    func Numbers() list[int] { list[int]{} }
    ",
    {ok, Tokens} = rufus_tokenize:string(RufusText),
    {ok, Forms} = rufus_parse:parse(Tokens),
    {ok, AnnotatedForms} = rufus_expr:typecheck_and_annotate(Forms),
    Expected = [{module, #{line => 2,
                           spec => example}},
                {func, #{exprs => [{list_lit, #{elements => [],
                                                line => 3,
                                                type => {type, #{collection_type => list,
                                                                 element_type => {type, #{line => 3,
                                                                                          source => rufus_text,
                                                                                          spec => int}},
                                                                 line => 3,
                                                                 source => rufus_text,
                                                                 spec => 'list[int]'}}}}],
                         line => 3,
                         params => [],
                         return_type => {type, #{collection_type => list,
                                                 element_type => {type, #{line => 3,
                                                                          source => rufus_text,
                                                                          spec => int}},
                                                 line => 3,
                                                 source => rufus_text,
                                                 spec => 'list[int]'}},
                         spec => 'Numbers'}}],
    ?assertEqual(Expected, AnnotatedForms).

typecheck_and_annotate_with_function_returning_a_list_of_one_int_test() ->
    RufusText = "
    module example
    func Numbers() list[int] { list[int]{10} }
    ",
    {ok, Tokens} = rufus_tokenize:string(RufusText),
    {ok, Forms} = rufus_parse:parse(Tokens),
    {ok, AnnotatedForms} = rufus_expr:typecheck_and_annotate(Forms),
    Expected = [{module, #{line => 2,
                           spec => example}},
                {func, #{exprs => [{list_lit, #{elements => [{int_lit, #{line => 3,
                                                                         spec => 10,
                                                                         type => {type, #{line => 3,
                                                                                          source => inferred,
                                                                                          spec => int}}}}],
                                                line => 3,
                                                type => {type, #{collection_type => list,
                                                                 element_type => {type, #{line => 3,
                                                                                          source => rufus_text,
                                                                                          spec => int}},
                                                                 line => 3,
                                                                 source => rufus_text,
                                                                 spec => 'list[int]'}}}}],
                         line => 3,
                         params => [],
                         return_type => {type, #{collection_type => list,
                                                 element_type => {type, #{line => 3,
                                                                          source => rufus_text,
                                                                          spec => int}},
                                                 line => 3,
                                                 source => rufus_text,
                                                 spec => 'list[int]'}},
                         spec => 'Numbers'}}],
    ?assertEqual(Expected, AnnotatedForms).

typecheck_and_annotate_with_function_returning_a_list_of_one_int_binary_op_test() ->
    RufusText = "
    module example
    func Numbers() list[int] { list[int]{10 + 2} }
    ",
    {ok, Tokens} = rufus_tokenize:string(RufusText),
    {ok, Forms} = rufus_parse:parse(Tokens),
    {ok, AnnotatedForms} = rufus_expr:typecheck_and_annotate(Forms),
    Expected = [{module, #{line => 2,
                           spec => example}},
                {func, #{exprs => [{list_lit, #{elements => [{binary_op, #{left => {int_lit, #{line => 3,
                                                                                               spec => 10,
                                                                                               type => {type, #{line => 3,
                                                                                                                source => inferred,
                                                                                                                spec => int}}}},
                                                                           line => 3,
                                                                           op => '+',
                                                                           right => {int_lit, #{line => 3,
                                                                                                spec => 2,
                                                                                                type => {type, #{line => 3,
                                                                                                                 source => inferred,
                                                                                                                 spec => int}}}},
                                                                           type => {type, #{line => 3,
                                                                                            source => inferred,
                                                                                            spec => int}}}}],
                                                line => 3,
                                                type => {type, #{collection_type => list,
                                                                 element_type => {type, #{line => 3,
                                                                                          source => rufus_text,
                                                                                          spec => int}},
                                                                 line => 3,
                                                                 source => rufus_text,
                                                                 spec => 'list[int]'}}}}],
                         line => 3,
                         params => [],
                         return_type => {type, #{collection_type => list,
                                                 element_type => {type, #{line => 3,
                                                                          source => rufus_text,
                                                                          spec => int}},
                                                 line => 3,
                                                 source => rufus_text,
                                                 spec => 'list[int]'}},
                         spec => 'Numbers'}}],
    ?assertEqual(Expected, AnnotatedForms).

typecheck_and_annotate_with_function_returning_a_list_of_int_with_mismatched_element_type_test() ->
    RufusText = "
    module example
    func Numbers() list[int] { list[int]{1, 42.0, 6} }
    ",
    {ok, Tokens} = rufus_tokenize:string(RufusText),
    {ok, Forms} = rufus_parse:parse(Tokens),
    Data = #{form => {list_lit, #{elements => [{int_lit, #{line => 3,
                                                           spec => 1,
                                                           type => {type, #{line => 3,
                                                                            source => inferred,
                                                                            spec => int}}}},
                                               {float_lit, #{line => 3,
                                                             spec => 42.0,
                                                             type => {type, #{line => 3,
                                                                              source => inferred,
                                                                              spec => float}}}},
                                               {int_lit, #{line => 3,
                                                           spec => 6,
                                                           type => {type, #{line => 3,
                                                                            source => inferred,
                                                                            spec => int}}}}],
                                  line => 3,
                                  type => {type, #{collection_type => list,
                                                   element_type => {type, #{line => 3,
                                                                            source => rufus_text,
                                                                            spec => int}},
                                                   line => 3,
                                                   source => rufus_text,
                                                   spec => 'list[int]'}}}}},
    ?assertEqual({error, unexpected_element_type, Data}, rufus_expr:typecheck_and_annotate(Forms)).

typecheck_and_annotate_with_function_taking_a_list_and_returning_a_list_test() ->
    RufusText = "
    module example
    func Echo(numbers list[int]) list[int] { numbers }
    ",
    {ok, Tokens} = rufus_tokenize:string(RufusText),
    {ok, Forms} = rufus_parse:parse(Tokens),
    {ok, AnnotatedForms} = rufus_expr:typecheck_and_annotate(Forms),
    Expected = [{module, #{line => 2,
                           spec => example}},
                {func, #{exprs => [{identifier, #{line => 3,
                                                  spec => numbers,
                                                  type => {type, #{collection_type => list,
                                                                   element_type => {type, #{line => 3,
                                                                                            source => rufus_text,
                                                                                            spec => int}},
                                                                   line => 3,
                                                                   source => rufus_text,
                                                                   spec => 'list[int]'}}}}],
                         line => 3,
                         params => [{param, #{line => 3,
                                              spec => numbers,
                                              type => {type, #{collection_type => list,
                                                               element_type => {type, #{line => 3,
                                                                                        source => rufus_text,
                                                                                        spec => int}},
                                                               line => 3,
                                                               source => rufus_text,
                                                               spec => 'list[int]'}}}}],
                         return_type => {type, #{collection_type => list,
                                                 element_type => {type, #{line => 3,
                                                                          source => rufus_text,
                                                                          spec => int}},
                                                 line => 3,
                                                 source => rufus_text,
                                                 spec => 'list[int]'}},
                         spec => 'Echo'}}],
    ?assertEqual(Expected, AnnotatedForms).

typecheck_and_annotate_with_function_taking_an_int_and_returning_a_list_of_int_test() ->
    RufusText = "
    module example
    func ToList(n int) list[int] { list[int]{n} }
    ",
    {ok, Tokens} = rufus_tokenize:string(RufusText),
    {ok, Forms} = rufus_parse:parse(Tokens),
    {ok, AnnotatedForms} = rufus_expr:typecheck_and_annotate(Forms),
    Expected = [{module, #{line => 2,
                           spec => example}},
                {func, #{exprs => [{list_lit, #{elements => [{identifier, #{line => 3,
                                                                            spec => n,
                                                                            type => {type, #{line => 3,
                                                                                             source => rufus_text,
                                                                                             spec => int}}}}],
                                                line => 3,
                                                type => {type, #{collection_type => list,
                                                                 element_type => {type, #{line => 3,
                                                                                          source => rufus_text,
                                                                                          spec => int}},
                                                                 line => 3,
                                                                 source => rufus_text,
                                                                 spec => 'list[int]'}}}}],
                         line => 3,
                         params => [{param, #{line => 3,
                                              spec => n,
                                              type => {type, #{line => 3,
                                                               source => rufus_text,
                                                               spec => int}}}}],
                         return_type => {type, #{collection_type => list,
                                                 element_type => {type, #{line => 3,
                                                                          source => rufus_text,
                                                                          spec => int}},
                                                 line => 3,
                                                 source => rufus_text,
                                                 spec => 'list[int]'}},
                         spec => 'ToList'}}],
    ?assertEqual(Expected, AnnotatedForms).

typecheck_and_annotate_with_function_returning_a_list_of_int_with_an_unknown_variable_as_an_element_test() ->
    RufusText = "
    module example
    func Numbers() list[int] { list[int]{unknown} }
    ",
    {ok, Tokens} = rufus_tokenize:string(RufusText),
    {ok, Forms} = rufus_parse:parse(Tokens),
    Data = #{form => {identifier, #{line => 3,
                                    locals => #{},
                                    spec => unknown}},
             globals => #{'Numbers' => [{func, #{exprs => [{list_lit, #{elements => [{identifier, #{line => 3,
                                                                                                    spec => unknown}}],
                                                                        line => 3,
                                                                        type => {type, #{collection_type => list,
                                                                                         element_type => {type, #{line => 3,
                                                                                                                  source => rufus_text,
                                                                                                                  spec => int}},
                                                                                         line => 3,
                                                                                         source => rufus_text,
                                                                                         spec => 'list[int]'}}}}],
                                                 line => 3,
                                                 params => [],
                                                 return_type => {type, #{collection_type => list,
                                                                         element_type => {type, #{line => 3,
                                                                                                  source => rufus_text,
                                                                                                  spec => int}},
                                                                         line => 3,
                                                                         source => rufus_text,
                                                                         spec => 'list[int]'}},
                                                 spec => 'Numbers'}}]},
             locals => #{}},
    ?assertEqual({error, unknown_identifier, Data}, rufus_expr:typecheck_and_annotate(Forms)).
