% -*- Prolog -*-
% This is a simple calculator,
% useful as an example of an interpreter,
% based extremely loosely on Andrej Bauer's 'calc' in his PL Zoo.
%
% The language has a grammar:
%   an expression can be Numeral containing a primitive int
%   an expression can be Plus containing two expressions
%   an expression can be Minus containing two expressions
%   an expression can be Times containing two expressions
%   an expression can be Divide containing two expressions
%   an expression can be Negate contianing one expression
%
% There is another grammar for the cont:
%   a cont can be Halt
%   a cont can be PlusK1 of an exp and a cont
%   a cont can be PlusK2 of an int and a cont
%   a cont can be MinusK1 of an exp and a cont
%   a cont can be MinusK2 of an int and a cont
%   a cont can be TimesK1 of an exp and a cont
%   a cont can be TimesK2 of an int and a cont
%   a cont can be DivideK1 of an exp and a cont
%   a cont can be DivideK2 of an int and a cont
%
% This is "the same" interpreter, but it is converted into
% continuation passing style, which means that every recursive call
% is a tail call, and we manage an explicit continuation stack,
% pushing an object onto it whenever we would have done
% some sort of sequenced computation.

step(numeral(N), K, Out) :- !,
  continue(K, N, Out).
step(plus(E1, E2), K, Out) :- !,
  step(E1, plusk1(E2, K), Out).
step(minus(E1, E2), K, Out) :- !,
  step(E1, minusk1(E2, K), Out).
step(times(E1, E2), K, Out) :- !,
  step(E1, timesk1(E2, K), Out).
step(divide(E1, E2), K, Out) :- !,
  step(E1, dividek1(E2, K), Out).
step(negate(E), K, Out) :- !,
  step(minus(numeral(0), E), K, Out).
continue(plusk1(E2, K), V, Out) :- !,
  step(E2, plusk2(V, K), Out).
continue(plusk2(V1, K), V2, Out) :- !,
  V is V1 + V2, continue(K, V, Out).
continue(minusk1(E2, K), V, Out) :- !,
  step(E2, minusk2(V, K), Out).
continue(minusk2(V1, K), V2, Out) :- !,
  V is V1 - V2, continue(K, V, Out).
continue(timesk1(E2, K), V, Out) :- !,
  step(E2, timesk2(V, K), Out).
continue(timesk2(V1, K), V2, Out) :- !,
  V is V1 * V2, continue(K, V, Out).
continue(dividek1(E2, K), V, Out) :- !,
  step(E2, dividek2(V, K), Out).
continue(dividek2(V1, K), V2, Out) :- !,
  V is V1 / V2, continue(K, V, Out).
continue(halt, V, Out) :- !,
  Out = V.
run(E, Out) :- !,
  step(E, halt, Out).
