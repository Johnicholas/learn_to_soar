% -*- Prolog -*-

% index(+List, +Peano, -Out)
index(nil, _N, Out) :- !, Out = nothing.
index(cons(X, _Xs), z, Out) :- !, Out = just(X).
index(cons(_X, Xs), s(N), Out) :- !, index(Xs, N, Out).


