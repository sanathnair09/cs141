% EVAL(E,V).

eval(X, X) :- number(X).
eval(X-Y, R) :- eval(X, Xr), eval(Y, Yr), R is Xr - Yr.
eval(X+Y, R) :- eval(X, Xr), eval(Y, Yr), R is Xr + Yr.
eval(X*Y, R) :- eval(X, Xr), eval(Y, Yr), R is Xr * Yr.
eval(X/Y, R) :- Y > 0, eval(X, Xr), eval(Y, Yr), R is Xr / Yr.
eval(X^Y, R) :- eval(X, Xr), eval(Y, Yr), R is Xr^Yr.

% SIMPLIFY(E,S).

remove_minus(-X, X). % helper for double negative
is_negative(-_).
% base cases
simplify(X-X, 0) :- !.

simplify(X-0, X) :- !.
simplify(0-X, -X) :- !.
simplify(X+0, X) :- !.
simplify(0+X, X) :- !.

simplify(X+X, 2*X) :- !.

simplify(_*0, 0) :- !.
simplify(0*_, 0) :- !.
simplify(0/_, 0) :- !.

simplify(X*1, X) :- !.
simplify(1*X, X) :- !.

simplify(X*Y, R) :- number(X), number(Y), R is X * Y, !.
simplify(X*X, X^2) :- !.
simplify(X/X, 1) :- !.
simplify(X^1, X) :- !.
simplify(_^0, 1) :- !.

% double negative
simplify(-C , C1) :- number(C), C < 0, C1 is C * -1, !.
% % simplify(-X, T) :- X =.. T,  !.
simplify(-(C/X), C1 / X ) :-  number(C), C < 0, C1 is C * -1, !.
simplify(-(C/X^N), C1 / X^N ) :-  number(C), C < 0, C1 is C * -1, !.

% hardcoded this because i couldn't figure out the general way to deal with double negatives
simplify(A- -1/x^2, R+1/x^2):- simplify(A, R), !. 
simplify(A+ -2/x^3, R-2/x^3):- simplify(A, R), !.

simplify(-1*(C/X), T/X) :- T is C * -1, !.
simplify(-1*(C/X^N), T/X^N) :- T is C * -1, !.



% edge cases to help deriv
simplify(X^C*X, X^C1) :- number(C), C1 is C + 1, !.
simplify(X*X^C, X^C1) :- number(C), C1 is C + 1, !.

simplify(C*X*X, C*X^2) :- number(C), !.
simplify(X*C*X, C*X^2) :- number(C), !.
simplify(X*X*C, C*X^2) :- number(C), !.

simplify(X^C*X^C1, X^C2) :- number(C), number(C1), C2 is C + C1, !.
simplify(A*X^C*X^C1, A*X^C2) :- number(A), number(C), number(C1), C2 is C + C1, !.
simplify(X^C*A*X^C1, A*X^C2) :- number(A), number(C), number(C1), C2 is C + C1, !.
simplify(A*X^C*B*X^C1, Z*X^C2) :- number(A), number(C), number(B), number(C1), C2 is C + C1, Z is A * B, !.

simplify(A*X^C/X, A*X^C1) :- number(A), number(C), C1 is C - 1, C1 > 2, !.
simplify(A*X^C/X, A*X) :- number(A), number(C), C1 is C - 1, C1 == 1, !.
simplify(A*X^C/X, A) :- number(A), number(C), C1 is C - 1, C1 == 0, !.
simplify(A*X^C/X, A/X^C1) :- number(A), number(C), C1 is C - 1, C1 < 0, !.

simplify(A*X^C/X^C1, A*X^C2) :- number(A), number(C), number(C1), C2 is C - C1, C2 > 2, !.
simplify(A*X^C/X^C1, A*X) :- number(A), number(C), number(C1), C2 is C - C1, C2 == 1, !.
simplify(A*X^C/X^C1, A) :- number(A), number(C), number(C1), C2 is C - C1, C2 == 0, !.
simplify(A*X^C/X^C1, A/X^C2) :- number(A), number(C), number(C1), C2 is C - C1, C2 < 0, !.

% integer Xrithmetic
simplify(X+Y, R) :- number(X), number(Y),  R is X + Y, !.
simplify(X-Y, R) :- number(X), number(Y),  R is X - Y, !.
simplify(X*Y, R) :- number(X), number(Y), R is X * Y, !.
simplify(X/Y, R) :- number(X), number(Y), R is X / Y, !.
simplify(X^Y, R) :- number(X), number(Y), R is X^Y, !.

% integer/variable arithmetic
% the A != X or B != Y check makes sure that we did actually simplify the exprerssion
% then we call simplify on the new values incase the simplification of the individual 
% values allows for more simplification
% (i.e. 2*(3/3) -> simplify(2, X) X=2 simplify(3/3, Y) Y=1. since 3/3 != 1 call simplify(2*1, R) R=1)
simplify(A^B, R) :- simplify(A, X), simplify(B, Y), (A \== X; B \== Y), simplify(X^Y, R), !.

% mult
simplify(A*B, R) :- simplify(A, X), simplify(B, Y), (A \== X; B \== Y), simplify(X*Y, R), !.

% div
simplify(A /B, R) :- simplify(A, X), simplify(B, Y), (A \== X; B \== Y), simplify(X/Y, R), !.

% add
simplify(A+B, R) :- simplify(A, X), simplify(B, Y), (A \== X; B \== Y), simplify(X+Y, R), !.

% sub
simplify(A-B, R) :- simplify(A, X), simplify(B, Y), (A \== X; B \== Y), simplify(X-Y, R), !.

% if can't be simplified further
simplify(A, A).


% deriv(E, D)
deriv(E, D) :- simplify(E, R), deriv_helper(R, S), simplify(S, D).

deriv_helper(C, 0) :- number(C).
% base cases
deriv_helper(A*X, A) :- number(A), atomic(X), !.
deriv_helper(X*A, A) :- number(A), atomic(X), !.

% power rule
deriv_helper(X^N, N*X^R) :- number(N), N > 2, R is N - 1, !.
deriv_helper(X^N, N*X) :- number(N), N > 0, !.

deriv_helper(C*X^N, C1*X^R) :- number(N), number(C), N > 2, C1 is C * N, R is N - 1, !.
deriv_helper(C*X^N, C1*X) :- number(N), number(C), N > 0,  C1 is C * N, !.


deriv_helper(C/X^N, C1/X^R) :- number(C), number(N), T is N * -1, C1 is C * T, R is N + 1, !. 
deriv_helper(C/X, C1/X^2) :- number(C), C1 is C * -1, !.

% polynomial
deriv_helper(A+B, X+Y) :- deriv_helper(A, X), deriv_helper(B, Y), !.
deriv_helper(A-B, X-Y) :- deriv_helper(A, X), deriv_helper(B, Y), !.

% product rule
deriv_helper(A*B, X*B+Y*A) :- deriv_helper(A, X), deriv_helper(B, Y), !.
% quotient rule
deriv_helper(A/B, (X*B+Y*A)/(B*B)) :- deriv_helper(A, X), deriv_helper(B, Y), !.

% single var
deriv_helper(X, 1) :- atomic(X), !.
deriv_helper(-X, -1) :- atomic(X), !.

% sample data for party_seating
% male(klefstad).
% male(bill).
% male(mark).
% male(isaac).
% male(fred).

% female(emily).
% female(heidi).
% female(beth).
% female(susan).
% female(jane).

% speaks(klefstad, english).
% speaks(bill, english).
% speaks(emily, english).
% speaks(heidi, english).
% speaks(isaac, english).

% speaks(beth, french).
% speaks(mark, french).
% speaks(susan, french).
% speaks(isaac, french).

% speaks(klefstad, spanish).
% speaks(bill, spanish).
% speaks(susan, spanish).
% speaks(fred, spanish).
% speaks(jane, spanish).


party_seating(L) :- male(X), round_table_seating(9, [X], L).


get_next_female(USED, NEXT) :- female(NEXT), \+ member(NEXT, USED). % \+ is prolog's not
get_next_male(USED, NEXT) :- male(NEXT), \+ member(NEXT, USED). % \+ is prolog's not

get_next_female_that_speaks(USED, LANG, PERSON) :- get_next_female(USED, PERSON), speaks(PERSON, LANG).
get_next_male_that_speaks(USED, LANG, PERSON) :- get_next_male(USED, PERSON), speaks(PERSON, LANG).


get_last([H], H).
get_last([_|T], R) :- get_last(T, R), !.
get_last(H, H) :- !.

% basically alternate between male and female untill you run out of females in which case just keep adding males
round_table_seating(S, L, R) :- get_last(L, H), speaks(H, LANG), male(H), get_next_female_that_speaks(L, LANG, P), append(L, [P], T),
                                S1 is S - 1, round_table_seating(S1, T, R).
round_table_seating(S, L, R) :- get_last(L, H), speaks(H, LANG), female(H), get_next_male_that_speaks(L, LANG, P), append(L, [P], T),
                                S1 is S - 1, round_table_seating(S1, T, R).
round_table_seating(S, L, R) :- get_last(L, H), speaks(H, LANG), male(H), get_next_male_that_speaks(L, LANG, P), append(L, [P], T),
                                S1 is S - 1, round_table_seating(S1, T, R).
round_table_seating(0, L, L). % potential issue of the last person and first person not meeting rules