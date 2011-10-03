% -*- Prolog -*-

% my_length(+List, -Peano)
my_length(nil, Out) :- !, Out = z.
my_length(cons(_X, Xs), Out) :- !, my_length(Xs, RecursiveResult), Out = s(RecursiveResult).

