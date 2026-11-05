% Part A: Staff Capacity Validation
check_staff(day(D, M), Time, Reservations) :-
    staff(day(D, M), C),
    match(day(D, M), Time, Reservations, C1),
    C1 =< C.

match(_, _, [], 0).
match(day(D, M), Time, [H|T], C) :-
    H \= res(day(D, M), Time, _, _),
    match(day(D, M), Time, T, C).
match(day(D, M), Time, [res(day(D, M), Time, _, _)|T], C) :-
    match(day(D, M), Time, T, C1),
    C is C1 + 1.

% Part B: Constraint-Satisfaction Reservation Scheduler
schedule_all_reservations(Days, Schedule) :-
    findall(G, group(G, _, _), Groups),
    assign_res(Groups, Days, [], TempSched),
    same_elements(TempSched, Schedule).

same_elements([], []).
same_elements([H|T], L2) :-
    my_select(H, L2, Rem),
    same_elements(T, Rem).

my_select(X, [X|T], T).
my_select(X, [H|T], [H|Rest]) :-
    my_select(X, T, Rest).

assign_res([], _, _, []).
assign_res([G|T], Days, Acc, [res(Day, Pref, G, Table)|RestSch]) :-
    group(G, Size, Pref),
    member(Day, Days),
    tables(TablesList),
    member(t(Table, Capacity), TablesList),
    Capacity >= Size,
    % Ensure no table double-booking occurs for the same day and time slot
    \+ member(res(Day, Pref, _, Table), Acc),
    staff(Day, Staff),
    count_busy(Day, Pref, Acc, Busy),
    Busy < Staff,
    assign_res(T, Days, [res(Day, Pref, G, Table)|Acc], RestSch).

count_busy(_, _, [], 0).
count_busy(D, Time, [res(D, Time, _, _)|Rest], Count) :-
    !,
    count_busy(D, Time, Rest, C1),
    Count is C1 + 1.
count_busy(D, Time, [_|Rest], Count) :-
    count_busy(D, Time, Rest, Count).

% Part C: Group Dish Ingredient Resolution
group_ingredients(GroupName, Ingredients) :-
    order(GroupName, Dishes),
    get_all_ingredients(Dishes, Ingredients).

get_all_ingredients([], []).
get_all_ingredients([Dish|T], Ingredients) :-
    recipe(Dish, DishIngredients),
    get_all_ingredients(T, TIngredients),
    append(DishIngredients, TIngredients, Ingredients).

% Part D: Daily Ingredient Aggregation
needed_ingredients(Res, FinalList) :-
    get_res_ingredients(Res, Pairs),
    group_days(Pairs, Grouped),
    (FinalList = Grouped ; check_unordered(Grouped, FinalList)).

get_res_ingredients([], []).
get_res_ingredients([res(Date, _, Group, _)|Rest], [(Date, Ings)|RestPairs]) :-
    group_ingredients(Group, Ings),
    get_res_ingredients(Rest, RestPairs).

group_days([], []).
group_days([(Date, Ings)|Rest], [(Date, TotalIngs)|GroupedRest]) :-
    get_date_ingredients(Date, Rest, Match, Rem),
    append_all([Ings|Match], TotalIngs),
    group_days(Rem, GroupedRest).

get_date_ingredients(_, [], [], []).
get_date_ingredients(Date, [(Target, Ings)|Rest], [Ings|Match], Rem) :-
    Date = Target,
    !,
    get_date_ingredients(Date, Rest, Match, Rem).
get_date_ingredients(Date, [Other|Rest], Match, [Other|Rem]) :-
    get_date_ingredients(Date, Rest, Match, Rem).

append_all([], []).
append_all([H|T], L) :-
    append_all(T, Rest),
    append(H, Rest, L).

check_unordered([], []).
check_unordered([(Date, Ings)|Rest1], FinalList) :-
    my_select((Date, TargetIngs), FinalList, Rem1),
    match_lists(Ings, TargetIngs),
    check_unordered(Rest1, Rem1).

match_lists([], []).
match_lists([H|T], Target) :-
    my_select(H, Target, Rem),
    match_lists(T, Rem).

% Part E & F: CSV Serialization
write_reservations_to_csv(Filename, Schedule) :-
    open(Filename, write, Stream),
    write(Stream, 'Day,Month,Time,Group,Table'),
    nl(Stream),
    loop_reservations(Stream, Schedule),
    close(Stream).

loop_reservations(_, []).
loop_reservations(Stream, [res(day(D, M), Time, Group, Table)|T]) :-
    format(Stream, '~w,~w,~w,~w,~w~n', [D, M, Time, Group, Table]),
    loop_reservations(Stream, T).

write_ingredients_to_csv(Filename, All) :-
    open(Filename, write, Stream),
    write(Stream, 'Day,Month,Ingredients'),
    nl(Stream),
    loop_ingredients(Stream, All),
    close(Stream).

loop_ingredients(_, []).
loop_ingredients(Stream, [(day(D, M), Ings)|T]) :-
    format(Stream, '~w,~w,', [D, M]),
    print_semi(Stream, Ings),
    nl(Stream),
    loop_ingredients(Stream, T).

print_semi(_, []).
print_semi(Stream, [Ing]) :-
    write(Stream, Ing).
print_semi(Stream, [Ing, Next|Rest]) :-
    write(Stream, Ing),
    write(Stream, ';'),
    print_semi(Stream, [Next|Rest]).
