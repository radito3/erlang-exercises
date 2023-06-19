-module(test).
-export([start/1, proc/3]).

start(Sysproc) ->
    process_flag(trap_exit, Sysproc),
    io:format("shell pid: ~p~n", [self()]),
    Pid1 = spawn_link(test, proc, [self(), a, true]),
    Pid2 = spawn_link(test, proc, [self(), b, true]),
    Pid3 = spawn_link(test, proc, [self(), c, false]),
    Pid4 = spawn_link(test, proc, [self(), d, false]),
    io:format("procs: ~p ~p ~p ~p~n", [Pid1, Pid2, Pid3, Pid4]),
    exit(Pid1, kill),
    exit(Pid3, kill).

proc(Shell, Tag, Sysproc) ->
    process_flag(trap_exit, Sysproc),
    receive
        after 5000 ->
            Shell ! {hello_from, Tag, self()}
    end.
