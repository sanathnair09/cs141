my_length([], 0).
my_length([_|T], R) :- my_length(T, R1), R is R1 + 1.

my_member(X, [X|_]).
my_member(X, [_|T]) :- my_member(X, T).

my_append([], L, L).
my_append(L, [], L).
my_append([H|L1], L2, [H|R]) :- my_append(L1, L2, R).

my_reverse([], X, X).
my_reverse([H|T], R, X) :- my_reverse(T, R, [H|X]).
my_reverse(L, R) :- my_reverse(L, R, []).

my_nth([], _, []).
my_nth(L, 1, L).
my_nth([_|T], X, R) :- X1 is X-1, my_nth(T, X1, R).

my_remove(_, [], []). %! empty list
my_remove(X, [X|T], R) :- my_remove(X, T, R). %! item to remove is the first item
my_remove(X, [H|T], [H|R]) :- my_remove(X, T, R). %! else

my_subst(_, _, [], []).
my_subst(X, Y, [X|T], [Y|R]) :- my_subst(X, Y, T, R).
my_subst(X, Y, [H|T], [H|R]) :- my_subst(X, Y, T, R).

my_subset(_, [], []).
my_subset(P, [H|T], [H|R]) :- call(P, H), my_subset(P, T, R).
my_subset(P, [_|T], R) :- my_subset(P, T, R).

my_add(X,Y,R) :- my_add_helper(X,Y,0,R).

my_add_helper([], [], 0, []).
my_add_helper([], [], 1, [1]).
my_add_helper([], N2, C, [SUM|REST]) :- S is (N2 + C), S > 9, SUM is (S mod 10), REST is 1.
my_add_helper([], N2, C, SUM) :- SUM is (N2 + C).
my_add_helper(N1, [], C, [SUM|REST]) :- S is (N1 + C), S > 9, SUM is (S mod 10), REST is 1.
my_add_helper(N1, [], C, SUM) :- SUM is (N1 + C).
my_add_helper([H1|T1], [H2|T2], C, [SUM|REST]) :- S is (H1 + H2 + C), S > 9, SUM is (S mod 10), my_add_helper(T1, T2, 1, REST).
my_add_helper([H1|T1], [H2|T2], C, [SUM|REST]) :- SUM is (H1 + H2 + C), my_add_helper(T1, T2, 0, REST).

my_merge([], L2, L2).
my_merge(L1, [], L1).
my_merge([H1|T1], [H2|T2], [H1|R]) :- H1 =< H2, my_merge(T1, [H2|T2], R).
my_merge([H1|T1], [H2|T2], [H2|R]) :- my_merge([H1|T1], T2, R).

my_sublist([], _).
my_sublist([H|T1], [H|T2]) :- prefix(T1, T2).
my_sublist([H|T1], [_|T2]) :- my_sublist([H|T1], T2).

%! helper for my_sublist
prefix([], _).
prefix([H|T1], [H|T2]) :- prefix(T1, T2).

my_assoc(_, [], _) :- false.
my_assoc(A, [A|T], R) :- get_first(T, R).
my_assoc(A, [_|T], R) :- get_remaining(T, X), my_assoc(A, X, R).

get_first([H|_], H).
get_remaining([_|T], T).

my_replace(_, [], []).
my_replace(ALIST, [H1|T1], [H2|T2]) :-
    my_assoc(H1, ALIST, H2), my_replace(ALIST, T1, T2).
my_replace(ALIST, [H|T], [H|R]) :-  my_replace(ALIST, T, R).
