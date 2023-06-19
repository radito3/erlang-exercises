-module(bulls_and_cows).

-export([play/0]).

play() -> play(generate_secret_number(), 1).

% internal

play(SecretNumber, 7) ->
	io:format("you lose! good day sir!~nthe answer was ~p, you dummy~n", [SecretNumber]);
play(SecretNumber, TurnCount) ->
	io:format("Turn ~p of 7~n", [TurnCount]),
	UserGuess = get_users_guess(),
	EvaluatedGuess = evaluate_guess(UserGuess, SecretNumber),
	case is_winner(EvaluatedGuess) of
		true -> io:format("you win! well done~n");
		false ->
			print_cows_and_bulls_info(EvaluatedGuess),
			play(SecretNumber, TurnCount + 1)
	end.

generate_secret_number() -> generate_secret_number([]).

generate_secret_number(NumberList) when length(NumberList) =:= 4 ->
	NumberList;
generate_secret_number(NumberList) ->
	NumberToAdd = rand:uniform(9),
	case lists:member(NumberToAdd, NumberList) of
		true -> generate_secret_number(NumberList);
		false -> generate_secret_number([NumberToAdd | NumberList])
	end.

get_users_guess() ->
	try
		{ok, Input} = io:fread("please enter guess (four distinct numbers between 1 and 9): ", "~d~d~d~d"),
		case all_numbers_between_one_and_nine(Input) of
			true -> Input;
			false ->
				io:format("All numbers must be between 1 and 9, inclusive~nGuess again~n"),
				get_users_guess()
		end
	catch
		error:{badmatch, {error, {fread, integer}}} -> io:format("please enter only digits, you schmuck!~n"),
		get_users_guess()
	end.

all_numbers_between_one_and_nine([]) -> true;
all_numbers_between_one_and_nine([H|T]) when H > 0 andalso H < 10 -> all_numbers_between_one_and_nine(T);
all_numbers_between_one_and_nine(_) -> false.

print_cows_and_bulls_info([{cows, CowNumber}, {bulls, BullNumber}]) ->
	io:format("You have ~p cows and ~p bulls~n", [CowNumber, BullNumber]).

evaluate_guess(Guess, NumberList) ->
	element(2,
		lists:foldl(
			fun(IndividualGuess, {Index, CowsAndBullsCount}) ->
				case is_bull(IndividualGuess, Index, NumberList) of
					true ->
						{Index + 1, increment_bulls(CowsAndBullsCount)};
					false ->
						case is_cow(IndividualGuess, NumberList) of
							true -> {Index + 1, increment_cows(CowsAndBullsCount)};
							false -> {Index + 1, CowsAndBullsCount}
						end
					end
				end,
			{1, [{cows, 0}, {bulls, 0}]},
			Guess
		)
	).

is_bull(Guess, Pos, SecretList) -> lists:nth(Pos, SecretList) =:= Guess.
is_cow(Guess, NumberList) -> lists:member(Guess, NumberList).

increment_cows([{cows, CowCount}, BullTuple]) -> [{cows, CowCount + 1}, BullTuple].
increment_bulls([CowTuple, {bulls, BullCount}]) -> [CowTuple, {bulls, BullCount + 1}].

is_winner([{cows, 0}, {bulls, 4}]) -> true;
is_winner(_) -> false.
