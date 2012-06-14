% -*- Prolog -*-
% This is a simple calculator,
% useful as an example of an interpreter,
% based on Andrej Bauer's 'calc' in his PL Zoo.
%
% This is terrible Prolog style, but there's a reason for it.
% I'm not actually trying to talk about or fluently in Prolog,
% I'm trying to use Prolog as a stepping stone to get to Soar.
%
% The language has a grammar:
%   an expression can be Numeral containing a primitive int
%   an expression can be Plus containing two expressions
%   an expression can be Minus containing two expressions
%   an expression can be Times containing two expressions
%   an expression can be Divide containing two expressions
%   an expression can be Negate contianing one expression
%
% This is so-called 'big step semantics'
% where a function call takes an expression all the way to a value
% usually by recursing on the subexpressions of the expression

calc(numeral(N), Out) :- !,
  Out = N.
calc(plus(E1, E2), Out) :- !,
  calc(E1, V1),
  calc(E2, V2),
  Out is V1 + V2.
calc(minus(E1, E2), Out) :- !,
  calc(E1, V1),
  calc(E2, V2),
  Out is V1 - V2.
calc(times(E1, E2), Out) :- !,
  calc(E1, V1),
  calc(E2, V2),
  Out is V1 * V2.
calc(divide(E1, E2), Out) :- !,
  calc(E1, V1),
  calc(E2, V2),
  Out is V1 / V2.
calc(negate(E), Out) :- !,
  calc(minus(numeral(0), E), Out).

% Note that, in contrast to the functional or term-rewriting
% implementation, Prolog names more variables - it names the output
% variable, as if were doing pass-by-reference in C,
% and it names the intermediate results and explicitly sequences them
% (the term rewriting system might implicitly sequence them in
% for example left-to-right or right-to-left order).
% Soar is like Prolog in that it has more names and more explicit
% sequencing.
%
% Note that the negate rule has another peculiarity;
% it doesn't have any sequencing. 
% It's not clear in 
