/* utilities to help testing */
sum(nil, Out) :- !,
  Out = 0.
sum(Xs, Out) :- Xs \= nil, !,
  uncons(Xs, UnconsDone),
  pair(X, Xs2) = UnconsDone,
  sum(Xs2, SumDone),
  Out is X + SumDone.

lookupeach(X, Out) :- !,
  lookupeachhelper(0, X, Out).
lookupeachhelper(N, X, Out) :- N < 11, !,
  lookup(N, X, LookupDone),
  M is N + 1,
  lookupeachhelper(M, X, HelperDone),
  Out = [LookupDone|HelperDone].
lookupeachhelper(N, X, Out) :- N >= 11, !,
  Out = [].
