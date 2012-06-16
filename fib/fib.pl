fib(0, Out) :- !,
  Out = 0.
fib(X, Out) :- X > 0, !,
  Y is X - 1,
  fib(Y, Part1),
  fibhelper(Y, Part2),
  Out is Part1 + Part2.
fibhelper(0, Out) :- !,
  Out = 1.
fibhelper(X, Out) :- X > 0, !,
  Y is X - 1,
  fib(Y, Out).
