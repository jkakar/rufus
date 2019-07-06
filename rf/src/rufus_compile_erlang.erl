%% rufus_compile_erlang transforms Rufus's abstract form into Erlang's abstract
%% form.
-module(rufus_compile_erlang).

-include_lib("rufus_type.hrl").

%% API exports

-export([forms/1]).

%% API

%% forms transforms RufusForms into Erlang forms that can be compiled with
%% compile:forms/1 and then loaded with code:load_binary/3.
-spec forms(list(rufus_form())) -> {ok, list(erlang_form())}.
forms(RufusForms) ->
    forms([], RufusForms).

%% Private API

-spec forms(list(erlang_form()), list(rufus_form())) -> {ok, list(erlang_form())}.
forms(Acc, [{module, #{line := Line, spec := Name}}|T]) ->
    Form = {attribute, Line, module, Name},
    forms([Form|Acc], T);
forms(Acc, [{bool_lit, _Context} = BoolLit|T]) ->
    Form = box(BoolLit),
    forms([Form|Acc], T);
forms(Acc, [{float_lit, _Context} = FloatLit|T]) ->
    Form = box(FloatLit),
    forms([Form|Acc], T);
forms(Acc, [{int_lit, _Context} = IntLit|T]) ->
    Form = box(IntLit),
    forms([Form|Acc], T);
forms(Acc, [{string_lit, _Context} = StringLit|T]) ->
    Form = box(StringLit),
    forms([Form|Acc], T);
forms(Acc, [{identifier, #{line := Line, spec := Name, locals := Locals}}|T]) ->
    Type = maps:get(Name, Locals),
    Form = case type_spec(Type) of
        float ->
            {var, Line, Name};
        int ->
            {var, Line, Name};
        _ ->
            {tuple, Line, [{atom, Line, type_spec(Type)}, {var, Line, Name}]}
    end,
    forms([Form|Acc], T);
forms(Acc, [{func, #{line := Line, spec := Name, args := Args, exprs := Exprs}}|T]) ->
    {ok, ArgsForms} = forms([], Args),
    {ok, GuardForms} = guards([], Args),
    {ok, ExprForms} = forms([], Exprs),
    FunctionForms = [{clause, Line, ArgsForms, GuardForms, ExprForms}],
    ExportForms = {attribute, Line, export, [{Name, length(Args)}]},
    Forms = {function, Line, Name, length(Args), FunctionForms},
    forms([Forms|[ExportForms|Acc]], T);
forms(Acc, [{arg, #{line := Line, spec := Name, type := Type}}|T]) ->
    Form = case type_spec(Type) of
        float ->
            {var, Line, Name};
        int ->
            {var, Line, Name};
        _ ->
            {tuple, Line, [{atom, Line, type_spec(Type)}, {var, Line, Name}]}
    end,
    forms([Form|Acc], T);
forms(Acc, [{binary_op, #{line := Line, op := Op, left := Left, right := Right}}|T]) ->
    {ok, [LeftExpr]} = forms([], [Left]),
    {ok, [RightExpr]} = forms([], [Right]),
    Form = {op, Line, Op, LeftExpr, RightExpr},
    forms([Form|Acc], T);
forms(Acc, []) ->
    {ok, lists:reverse(Acc)};
forms(Acc, _Unhandled) ->
    io:format("unhandled form ->~n~p~n", [_Unhandled]),
    {ok, lists:reverse(Acc)}.

% guards generates function guards for floats and integers.
-spec guards(list(erlang_form()) | list(list()), list(arg_form())) -> {ok, list(erlang_form())}.
guards(Acc, [{arg, #{line := Line, spec := Name, type := {type, #{spec := float}}}}|T]) ->
    GuardExpr = [{call, Line, {remote, Line, {atom, Line, erlang}, {atom, Line, is_float}}, [{var, Line, Name}]}],
    guards([GuardExpr|Acc], T);
guards(Acc, [{arg, #{line := Line, spec := Name, type := {type, #{spec := int}}}}|T]) ->
    GuardExpr = [{call, Line, {remote, Line, {atom, Line, erlang}, {atom, Line, is_integer}}, [{var, Line, Name}]}],
    guards([GuardExpr|Acc], T);
guards(Acc, [_|T]) ->
    guards(Acc, T);
guards(Acc, []) ->
    %% TODO(jkakar): Should we be reversing Acc here? Does ordering affect guard
    %% behavior?
    {ok, Acc}.

%% box converts Rufus forms for primitive values into Erlang forms.
-spec box(bool_lit_form() | float_lit_form() | int_lit_form() | string_lit_form()) -> erlang3_form().
box({bool_lit, #{line := Line, spec := Value}}) ->
    {tuple, Line, [{atom, Line, bool}, {atom, Line, Value}]};
box({float_lit, #{line := Line, spec := Value}}) ->
    {float, Line, Value};
box({int_lit, #{line := Line, spec := Value}}) ->
    {integer, Line, Value};
box({string_lit, #{line := Line, spec := Value}}) ->
    StringExpr = {bin_element, Line, {string, Line, binary_to_list(Value)}, default, default},
    {tuple, Line, [{atom, Line, string}, {bin, Line, [StringExpr]}]}.

%% type_spec unpacks the name of the type from a type form.
-spec type_spec(type_form()) -> type_spec().
type_spec({type, #{spec := Type}}) ->
    Type.
