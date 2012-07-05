% -*- Prolog -*-
% Based on a set of slides by Ralf Hinze:
% "number systems and data structures"
% The data structure might originally be by Chris Okasaki?

cons(X, nil, Out) :- !,
  Out = one(X, nil).
cons(X, zero(Xs), Out) :- !,
  Out = one(X, Xs).
cons(X1, one(X2, Xs), Out) :- !,
  cons(pair(X1, X2), Xs, RecursiveResult),
  Out = zero(RecursiveResult).

uncons(one(X, nil), Out) :- !,
  Out = pair(X, nil).
uncons(one(X, Xs), Out) :- !,
  Out = pair(X, zero(Xs)).
uncons(zero(X), Out) :- !,
  uncons(X, RecursiveResult),
  pair(pair(X1, X2), Xs) = RecursiveResult,
  Out = pair(X1, one(X2, Xs)).

lookup(N, one(X, _Xs), Out) :- N = 0, !,
  Out = X.
lookup(N, one(_X, Xs), Out) :- N > 0, !,
  M is N - 1,
  lookup(M, zero(Xs), Out).
lookup(N, zero(Xs), Out) :- OnesBit is N mod 2, OnesBit = 0, !,
  M is N div 2,
  lookup(M, Xs, RecursiveResult),
  pair(Out, _) = RecursiveResult.
lookup(N, zero(Xs), Out) :- OnesBit is N mod 2, OnesBit = 1, !,
  M is N div 2,
  lookup(M, Xs, RecursiveResult),
  pair(_, Out) = RecursiveResult.

toseq([], Out) :- !,
  Out = nil.
toseq([X|Xs], Out) :- !,
  toseq(Xs, Rest),
  cons(X, Rest, Out).
