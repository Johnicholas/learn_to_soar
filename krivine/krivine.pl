% -*- Prolog -*-

% a simple CPS-transformed normal-order lambda-calculus interpreter,
% roughly speaking the Krivine machine, though I hesitate to say
% that it IS the Krivine machine; I am an amateur.

% an expression can be a symbol, a quote, a lambda, or a function application
% exp ::= sym(name) | quote(quoted) | lambda(name, exp) | app(exp, exp)

% the value of a symbol is looked up in the environment
ev(sym(N1), extend(N2, closure(C, E1), _E2), S, Out) :- N1 = N2, !, ev(C, E1, S, Out).
ev(sym(N1), extend(N2, _C, E2), S, Out) :- N1 \= N2, !, ev(sym(N1), E2, S, Out).

% take the quotes off and return whatever is inside.
ev(quote(X), _E, _S, Out) :- !, Out = X.

% we bind it to the formal parameter and continue into the body.
ev(lambda(Formal, Body), E, cons(Actual, Stack), Out) 
  :- !, ev(Body, extend(Formal, Actual, E), Stack, Out).

% We just push the argument, together with
% the environment we'll need to eval it,
% onto the stack for later.
ev(app(F, X), E, Stack, Out) :- !, ev(F, E, cons(closure(X, E), Stack), Out).

% to start, use the empty environment and empty stack
start(Code, Out) :- !, ev(Code, empty, nil, Out).



