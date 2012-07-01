% -*- Prolog -*-
m(X, Y, Out) :- X > 0, !,
  HalfX is X div 2,
  TwiceY is Y * 2,
  m(HalfX, TwiceY, Temp),
  Odd is X mod 2,
  Out is Temp + Y * Odd.
m(0, Y, Out) :- !,
  Out = 0.

% just for testing
test(X, Y) :-
  m(X, Y, ToTest),
  Expected is X * Y,
  write('saw: '), write(X),
  write(' expected: '), write(Expected),
  nl,
  ToTest = Expected.

