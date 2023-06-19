-module(sup).
-export([start/1, loop_sup/1, loop_worker/1]).

loop_worker(ID) ->
    receive
        {kill} -> 1/0;
        Any -> io:format("worker received any: ~p~n", [Any])
    end,
    loop_worker(ID).

start(N) ->
    Pool = [{X, fun loop_worker/1, spawn(sup, loop_worker, [X])} || X <- lists:seq(1, N)],
    io:format("worker pool: ~p~n", [Pool]),
    _Sup = spawn(sup, loop_sup, [{Pool}]).

% HW: change state to be {[{WorkerId, WorkerFunc, WorkerPid}, ...]}

%State = {[{WorkerId, WorkerPid}, ...]}
loop_sup(_State = {Pool}) ->
    receive
        start_link -> process_flag(trap_exit, true),
                      [link(P) || {_Id, _Fn, P} <- Pool],
                      NewPool = Pool;
        {'EXIT', Pid, _Reason} -> case lists:keyfind(Pid, 3, Pool) of
                                    {ID, WorkerFunc, _Pid} -> io:format("a linked worker has died~n"),
                                            NewWorkerPid = spawn_link(sup, fun(Id) -> WorkerFunc(Id) end, [ID]),
                                            NewPool = lists:keyreplace(Pid, 3, Pool, {ID, fun loop_worker/1, NewWorkerPid}),
                                            io:format("new pool: ~p~n", [NewPool]);
                                    false -> io:format("a foreign worker has died~n"),
                                            NewPool = Pool
                                  end;
        Any -> io:format("any: ~p~n", [Any]),
                NewPool = Pool
    end,
    loop_sup({NewPool}).
    