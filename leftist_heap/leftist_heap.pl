% -*- Prolog -*-
% leftist heaps implementation
% adapted from markus mottl's ocaml version
% of chris okasaki's code

rank(empty, Out) :- !,
  Out = 0.
rank(tree(Rank, _Elem, _Left, _Right), Out) :- !,
  Out = Rank.

maketree(Elem, A, B, Out) :- !,
  rank(A, RankA),
  rank(B, RankB), 
  maketreehelper(RankA, RankB, Elem, A, B, Out).

maketreehelper(RankA, RankB, Elem, A, B, Out) :- RankA >= RankB, !,
  NewRank is RankB + 1,
  Out = tree(NewRank, Elem, A, B).
maketreehelper(RankA, RankB, Elem, A, B, Out) :- RankA < RankB, !,
  NewRank is RankA + 1,
  Out = tree(NewRank, Elem, B, A).

isempty(empty, Out) :- !,
  Out = yes.
isempty(tree(_Rank, _Elem, _Left, _Right), Out) :- !,
  Out = no.

merge(empty, Right, Out) :- !,
  Out = Right.
merge(Left, empty, Out) :- !,
  Out = Left.
merge(tree(R1, X1, A1, B1), tree(R2, X2, A2, B2), Out) :- !,
  leq(X1, X2, ComparisonResult),
  mergehelper(ComparisonResult, tree(R1, X1, A1, B1), tree(R2, X2, A2, B2), Out).

mergehelper(yes, tree(_R1, X1, A1, B1), tree(R2, X2, A2, B2), Out) :- !,
  merge(B1, tree(R2, X2, A2, B2), Temp),
  maketree(X1, A1, Temp, Out).
mergehelper(no, tree(R1, X1, A1, B1), tree(_R2, X2, A2, B2), Out) :- !,
  merge(tree(R1, X1, A1, B1), B2, Temp),
  maketree(X2, A2, Temp, Out).

insert(Elem, Heap, Out) :- !,
  merge(tree(1, Elem, empty, empty), Heap, Out).

findmin(tree(_Rank, Elem, _Left, _Right), Out) :- !,
  Out = Elem.

deletemin(tree(_Rank, _Elem, Left, Right), Out) :- !,
  merge(Left, Right, Out).
