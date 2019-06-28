%% Context container

-type context() :: #{atom() := any()}.

%% Result types

-type ok_tuple() :: {ok, any()}.
-type error_tuple() :: {error, any()}.

%% Rufus source text

-type rufus_text() :: string().

%% State storage

-type locals() :: context().

%% Types

-type type_spec() :: atom().
-type type_form() :: {type, context()}.

%% Modules

-type module_form() :: {module, context()}.

%% Scalar literals

-type bool_lit_form() :: {bool_lit, context()}.
-type float_lit_form() :: {float_lit, context()}.
-type int_lit_form() :: {int_lit, context()}.
-type string_lit_form() :: {string_lit, context()}.

%% Expressions

-type func_form() :: {func, context()}.
-type arg_form() :: {arg, context()}.
-type identifier_form() :: {identifier, context()}.
-type binary_op_form() :: {binary_op, context()}.

%% Rufus forms

-type rufus_form() ::
        arg_form()
      | binary_op_form()
      | bool_lit_form()
      | float_lit_form()
      | func_form()
      | identifier_form()
      | int_lit_form()
      | module_form()
      | string_lit_form()
      | type_form().

%% Errors

-type unknown_variable_error() :: unknown_variable.
-type unmatched_return_type_error() :: unmatched_return_type.
-type unmatched_operand_type_error() :: unmatched_operand_type.
-type unsupported_operand_type_error() :: unsupported_operand_type.
-type rufus_error() ::
        unknown_variable_error()
      | unmatched_return_type_error()
      | unmatched_operand_type_error()
      | unsupported_operand_type_error().

%% Erlang forms

-type erlang3_form() :: {_, _, _}.
-type erlang4_form() :: {_, _, _, _}.
-type erlang5_form() :: {_, _, _, _, _}.
-type erlang_form() ::
        erlang3_form()
      | erlang4_form()
      | erlang5_form().
