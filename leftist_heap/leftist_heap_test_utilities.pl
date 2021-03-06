% facts and rules useful for testing
leq(a, b, yes).
leq(b, a, no).
leq(a, c, yes).
leq(c, a, no).
leq(b, c, yes).
leq(c, b, no).
cba(X) :- !,
  insert(c, empty, C),
  insert(b, C, BC),
  insert(a, BC, ABC),
  X = cons(C, cons(BC, cons(ABC, nil))).
ecba(X) :- !,
  cba(CBA),
  X = cons(empty, CBA).

map(_Fun, nil, Out) :- !, 
  Out = nil.
map(Fun, cons(X, Xs), Out) :- !,
  call(Fun, X, First), % NOTE: call is a prolog primitive
  map(Fun, Xs, Rest),
  Out = cons(First, Rest).

deletethenfind(In, Out) :- !,
  deletemin(In, Temp),
  isempty(Temp, ComparisonResult),
  deletethenfindhelper(ComparisonResult, Temp, Out).

deletethenfindhelper(yes, _Temp, Out) :- !,
  Out = nothing.
deletethenfindhelper(no, Temp, Out) :- !,
  findmin(Temp, Result),
  Out = just(Result).

perms(X) :- !,
  insert(c, empty, C),
  insert(b, C, BC),
  insert(a, BC, ABC),
  insert(a, C, AC),
  insert(b, AC, BAC),
  insert(a, empty, A),
  insert(c, A, CA),
  insert(b, CA, BCA),
  insert(b, A, BA),
  insert(c, BA, CBA),
  insert(b, empty, B),
  insert(a, B, AB),
  insert(c, AB, CAB),
  insert(c, B, CB),
  insert(a, CB, ACB),
  X = cons(ABC, cons(BAC, cons(BCA, cons(CBA, cons(CAB, cons(ACB, nil)))))).

repeat(0, _X, Out) :- !,
  Out = nil.
repeat(N, X, Out) :- N > 0, !,
  Pred is N - 1,
  repeat(Pred, X, Rest),
  Out = cons(X, Rest).

listsequal(nil, nil, Out) :- !,
  Out = yes.
listsequal(nil, cons(X, Xs), Out) :- !,
  Out = no.
listsequal(cons(X, Xs), nil, Out) :- !,
  Out = no.
listsequal(cons(X, Xs), cons(Y, Ys), Out) :- X = Y, !,
  listsequal(Xs, Ys, Out).
listsequal(cons(X, Xs), cons(Y, Ys), Out) :- !,
  maybesequal(X, Y, Temp),
  listsequalhelper(Temp, Xs, Ys, Out).
listsequalhelper(yes, Xs, Ys, Out) :- !,
  listsequal(Xs, Ys, Out).
listsequalhelper(no, Xs, Ys, Out) :- !,
  Out = no.

maybesequal(X, Y, Out) :- X = Y, !,
  Out = yes.
maybesequal(nothing, just(X), Out) :- !,
  Out = no.
maybesequal(just(X), nothing, Out) :- !,
  Out = no.
maybesequal(just(X), just(Y), Out) :- X \= Y, !,
  Out = no.
maybesequal(just(X), just(Y), Out) :- X = Y, !,
  Out = yes.
