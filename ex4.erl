-module(ex4).
-export([loop/1, start/2]).

start(N, K) ->
    PN = spawn(?MODULE, loop, [{N, self()}]),
    PN ! create_child,
    receive
        {last_alive, LastAlive} -> LastAlive ! {calc, K}
    end,
    receive
        {calc, S} -> io:format("Result: ~p~n", [S])
    end.

loop({0, Parent}) -> Parent ! {last_alive, Parent};
loop(State) ->
    receive
        create_child -> {N, Parent} = State,
                        Child = spawn(?MODULE, loop, [{N-1, self()}]),
                        io:format("N: ~p, Parent: ~p, Me: ~p, Child: ~p~n", [N, Parent, self(), Child])
                        Child ! create_child,
                        NewState = State;
        {calc, X} -> S = X*X,
                     io:format("Me: ~p, S: ~p~n", [self(), S]),
                     {_, Parent} = State,
                     Parent ! {calc, S},
                     NewState = State;
        {last_alive, LastAlive} -> {_, Parent} = State,
                                   Parent ! {last_alive, LastAlive},
                                   NewState = State;
        Any -> io:format("Any: ~p~n", [Any]),
               NewState = State
    end,
    loop(NewState).
