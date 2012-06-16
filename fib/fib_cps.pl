fibtop(X, Out) :- !, fibspace(X, halt, Out).
fibspace(0, K, Out) :- !, applycont(K, 0, Out).
fibspace(X, K, Out) :- X > 0, !, Y is X - 1, fibspace(Y, fibhelperandsum(Y, K), Out).

applycont(halt, V, Out) :- !, Out = V.
applycont(fibhelperandsum(X, K), V, Out) :- !, fibhelper(X, sum(V, K), Out).
applycont(sum(V1, K), V2, Out) :- !, V is V1 + V2, applycont(K, V, Out).

fibhelper(0, K, Out) :- !, applycont(K, 1, Out).
fibhelper(X, K, Out) :- X > 0, !, Y is X - 1, fibspace(Y, K, Out).

