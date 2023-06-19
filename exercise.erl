-module(exercise).
-export([start/0, guess/2, play/2]).

start() -> 
    spawn(?MODULE, play, [get_rand_num_list([], 4), 1]).

get_rand_num_list(NumList, Size) when length(NumList) == Size ->
    NumList;
get_rand_num_list(NumList, Size) ->
    RandNum = rand:uniform(9),
    case lists:member(RandNum, NumList) of
        true -> get_rand_num_list(NumList, Size);
        false -> get_rand_num_list([RandNum | NumList], Size)
    end.

check_guess(GuessList, RandomNumList) ->
    lists:foldl(fun(Guess, {Idx, Result}) ->
            case is_bull(Guess, RandomNumList, Idx) of
                true -> {Idx + 1, increment_bulls(Result)};
                false ->
                    case is_cow(Guess, RandomNumList) of
                        true -> {Idx + 1, increment_cows(Result)};
                        false -> {Idx + 1, Result}
                    end
            end
        end,
    {1, {{cows, 0}, {bulls, 0}}},
    GuessList).

is_bull(Guess, RandomNum, Idx) ->
    lists:nth(Idx, RandomNum) =:= Guess.

is_cow(Guess, RandomNum) ->
    lists:member(Guess, RandomNum).

increment_cows({{cows, CowCount}, BullTuple}) ->
    {{cows, CowCount + 1}, BullTuple}.

increment_bulls({CowTuple, {bulls, BullCount}}) ->
    {CowTuple, {bulls, BullCount + 1}}.

all_bulls(CheckResult, NumSize) ->
    element(2, element(2, CheckResult)) == NumSize.

% is_valid_input([]) -> true;
% is_valid_input([Head|Tail]) when Head > 0 andalso Head < 10 -> is_valid_input(Tail);
% is_valid_input(_) -> false.

format(NumGuesses, Guess, CheckResult) ->
    Bulls = element(2, element(2, CheckResult)),
    Cows = element(2, element(1, CheckResult)),
    io_lib:format("Guesses: ~p, Last guess: ~p, Bulls: ~p, Cows: ~p", [NumGuesses, Guess, Bulls, Cows]).

play(RandomNum, TurnNum) ->
    receive
        {generate, Size} -> play(get_rand_num_list([], Size), 0);
        {Client, {guess, Guess}} ->
            ParsedGuess = integer_to_list(Guess),
            % case is_valid_input(ParsedGuess) of
            %     false ->
            %         Client ! lists:flatten(io_lib:format("Invalid input", [])),
            %         play(RandomNum, TurnNum)
            % end,
            Result = element(2, check_guess(ParsedGuess, RandomNum)),
            case all_bulls(Result, length(RandomNum)) of
                true -> Client ! lists:flatten(io_lib:format("You win!", []));
                false ->
                    Client ! lists:flatten(format(TurnNum, Guess, Result)),
                    play(RandomNum, TurnNum + 1)
            end;
        _ ->
            io:format("Invalid input pattern~n", []),
            play(RandomNum, TurnNum)
    end.

guess(Server, Guess) -> 
    Server ! {self(), {guess, Guess}},
    receive
        Msg -> io:format("~p~n", [Msg])
    end.
