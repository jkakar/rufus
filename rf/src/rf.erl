%% rf defines command-line tools for working with Rufus programs.
-module(rf).

%% API exports

-export([main/1]).

%% escript entry point

main(Args) ->
    application:start(rf),
    ExitCode = case Args of
        ["compile"|SubArgs] ->
            compile(SubArgs);
        ["compile:parse"|SubArgs] ->
            parse(SubArgs);
        ["compile:scan"|SubArgs] ->
            scan(SubArgs);
        ["version"|SubArgs] ->
            version(SubArgs);
        _ ->
            help(Args)
    end,
    application:stop(rf),
    erlang:halt(ExitCode).

%% Private API

help(_Args) ->
    io:format("rf provides tools for working with Rufus programs.~n"),
    io:format("~n"),
    io:format("Usage:~n"),
    io:format("~n"),
    io:format("    rf COMMAND [OPTION]...~n"),
    io:format("~n"),
    io:format("The commands are:~n"),
    io:format("~n"),
    io:format("    compile        Compile source code and then run it and print its output~n"),
    io:format("    compile:parse  Parse source code and print parse forms~n"),
    io:format("    compile:scan   Scan source code and print parse tokens~n"),
    io:format("    version        Print Rufus version~n"),
    io:format("~n"),
    io:format("Use \"rf help [command]\" for more information about that command~n"),
    io:format("~n"),
    io:format("Additional help topics:~n"),
    io:format("~n"),
    io:format("    spec            language specification~n"),
    io:format("~n"),
    io:format("Use \"rf help [topic]\" for more information about that topic~n"),
    io:format("~n"),
    0.

version(_Args) ->
    case application:get_key(rf, vsn) of
        {ok, Version} ->
            io:format("rufus version v~s~n", [Version]),
            0;
        Error ->
            io:format("Error: ~p~n", [Error]),
            -1
    end.

parse(_Args) ->
    RufusText = "
    package rand

    func Int() int {
        42
    }
",
    io:format("RufusText =>~n    ~s~n", [RufusText]),
    {ok, Tokens, _Lines} = rufus_scan:string(RufusText),
    io:format("Tokens =>~n~n    ~p~n~n", [Tokens]),
    case rufus_parse:parse(Tokens) of
        {ok, Forms} ->
            io:format("Forms =>~n~n    ~p~n", [Forms]),
            0;
        {error, {Line, _, [{ErrorPrefix, ErrorSuffix}, Token]}} ->
            Error = {error, {Line, {ErrorPrefix, ErrorSuffix}, Token}},
            io:format("Error =>~n~n    ~p~n", [Error]),
            -1;
        {error, {Line, _, [Error, Token]}} ->
            Error = {error, {Line, Error, Token}},
            io:format("Error =>~n~n    ~p~n", [Error]),
            -1
    end.

scan(_Args) ->
    RufusText = "
    package example

    func Greet(name string) string {
        \"Hello \" + name
    }
",
    io:format("RufusText =>~n    ~s~n", [RufusText]),
    {ok, Tokens, _Lines} = rufus_scan:string(RufusText),
    io:format("Tokens =>~n~n    ~p~n", [Tokens]),
    0.

compile(_Args) ->
    RufusText ="
    package example

    func Number() int {
        42
    }
",
    io:format("RufusText =>~n    ~s~n", [RufusText]),
    {ok, example} = rufus_compile:eval(RufusText),
    io:format("example:Number() =>~n~n    ~p~n", [example:'Number'()]),
    0.
