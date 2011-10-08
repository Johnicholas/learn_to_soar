% -*- Prolog -*-
% This is an SEC interpreter, and corresponding SEC compiler and vm from
% Ager et al's "From Interpreter to Compiler and Virtual Machine"

main(Term, Out) :- !, eval(nil, mt, Term, AlmostDone), mainhelper(AlmostDone, Out) .
mainhelper(pair(cons(Val, nil), _), Out) :- !, Out = Val .

eval(S, E, lit(N), Out) :- !, Out = pair(cons(int(N), S), E) .
eval(S, E, var(X), Out) :- !, lookup(E, X, Val), Out = pair(cons(Val, S), E) .
eval(S, E, lam(X, T), Out) :- !, Out = pair(cons(closure(X, E, T), S), E) .
eval(S1, E1, app(T0, T1), Out) :- !,
    eval(S1, E1, T1, O1),
    O1 = pair(Sprime, Eprime), 
    eval(Sprime, Eprime, T0, O2),
    O2 = pair(cons(closure(Fx, Fe, Ft), cons(V1, S)), E),
    eval(nil, extend(Fx, V1, Fe), Ft, O3),
    O3 = pair(cons(V, nil), _Ignored),
    Out = pair(cons(V, S), E) .
eval(S, E, succ(T), Out) :- !,
    eval(S, E, T, O1),
    O1 = pair(cons(int(N), S2), E2),
    SN is N + 1,
    Out = pair(cons(int(SN), S2), E2) .

lookup(extend(X, V, _E), Y, Val) :- X = Y, !, Val = V .
lookup(extend(X, _V, E), Y, Val) :- X \= Y, !, lookup(E, Y, Val) .

% this compiler is also from Ager et al., but it doesnt handle Lit or Succ
% T denotes terms
% I denotes instructions
% C denotes lists of instructions
% E denotes environments
% V denotes expressible values
% S denotes stacks of expressible values
% T ::= var(Name) | lam(Name, T) | app(T, T)
% I ::= access(Name) | close(Name, C) | call
% V ::= val(Name, C, E)

% compile(+term, -list of instructions)
compile(var(X), Out) :- !, Out = cons(access(X), nil) .
compile(lam(X, T), Out) :- !, compile(T, Compiled), Out = cons(close(X, Compiled), nil) .
compile(app(T0, T1), Out) :- !,
    compile(T1, T1Compiled), 
    compile(T0, T0Compiled),
    myappend(T0Compiled, cons(call, nil), T0CompiledCall),
    myappend(T1Compiled, T0CompiledCall, Out) .

% myappend(+list of instructions, +list of instructions, -list of instructions)
myappend(nil, Ys, Out) :- !, Out = Ys .
myappend(cons(X, Xs), Ys, Out) :- !, myappend(Xs, Ys, RecurseOut), Out = cons(X, RecurseOut) .

% this machine is also from Ager et al.
% initial transition
% machine_main(+list of instructions, -expressible value)
machine_main(C, Out) :- !, sec(nil, mt, C, Out) .
% state machine
% sec(+stack of expressible values, +environment, -expressible value)
sec(S, E, cons(access(X), C), Out) :- !, lookup(E, X, Val), sec(cons(Val, S), E, C, Out) .
sec(S, E, cons(close(X, Cprime), C), Out) :- !, sec(cons(val(X, Cprime, E), S), E, C, Out) .
sec(cons(val(X, CPrime, EPrime), cons(V, S)), _E, cons(call, C), Out) :- !,
    myappend(CPrime, C, COut),
    sec(S, extend(X, V, EPrime), COut, Out) .
sec(cons(V, _S), _E, nil, Out) :- !, Out = V .

