% -*- Prolog -*-
% Is this a strategy for transliterating SAT into Prolog that could be carried through to Soar?

% p cnf 4 8

% -2 3 4 0
c1(X1, X2, X3, X4) :- X2 = f.
c1(X1, X2, X3, X4) :- X3 = t.
c1(X1, X2, X3, X4) :- X4 = t.

% 1 3 -4 0
c2(X1, X2, X3, X4) :- X1 = t.
c2(X1, X2, X3, X4) :- X3 = t.
c2(X1, X2, X3, X4) :- X4 = f.

% -1 2 4 0
c3(X1, X2, X3, X4) :- X1 = f.
c3(X1, X2, X3, X4) :- X2 = t.
c3(X1, X2, X3, X4) :- X4 = t.

% -1 2 3 0
c4(X1, X2, X3, X4) :- X1 = f.
c4(X1, X2, X3, X4) :- X2 = t.
c4(X1, X2, X3, X4) :- X3 = t.

% 2 3 -4 0
c5(X1, X2, X3, X4) :- X2 = t.
c5(X1, X2, X3, X4) :- X3 = t.
c5(X1, X2, X3, X4) :- X4 = f.

% -1 -3 4 0
c6(X1, X2, X3, X4) :- X1 = f.
c6(X1, X2, X3, X4) :- X3 = f.
c6(X1, X2, X3, X4) :- X4 = t.

% 1 2 4 0
c7(X1, X2, X3, X4) :- X1 = t.
c7(X1, X2, X3, X4) :- X2 = t.
c7(X1, X2, X3, X4) :- X4 = t.

% 1 -2 -3 0
c8(X1, X2, X3, X4) :- X1 = t.
c8(X1, X2, X3, X4) :- X2 = f.
c8(X1, X2, X3, X4) :- X3 = f.

sat(X1, X2, X3, X4) :- 
  c1(X1, X2, X3, X4), 
  c2(X1, X2, X3, X4), 
  c3(X1, X2, X3, X4), 
  c4(X1, X2, X3, X4), 
  c5(X1, X2, X3, X4), 
  c6(X1, X2, X3, X4), 
  c7(X1, X2, X3, X4), 
  c8(X1, X2, X3, X4).

