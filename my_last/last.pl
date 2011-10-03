% -*- Prolog -*-

% my_last computes the last of a lispish linear list
% my_last(+List, -MaybeElem)
my_last(nil, Out) :- !, Out = nothing.
my_last(cons(X,Xs), Out) :- !, my_last_helper(Xs, X, Out).
% my_last_helper(+List, +Elem, -MaybeElem)
my_last_helper(nil, X, Out) :- !, Out = just(X).
my_last_helper(cons(X,Xs), _Y, Out) :- !, my_last_helper(Xs, X, Out).
