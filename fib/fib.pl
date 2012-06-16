fib(z, Out) :- !, Out = 0.
fib(s(X), Out) :- !, fib(X, Part1), fibhelper(X, Part2), Out is Part1 + Part2.
fibhelper(z, Out) !, Out = 1.
fibhelper(s(X), Out) :- !, fib(X, Out).
