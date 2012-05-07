% -*- Prolog -*-
%
% This is a register-machine-ish interpreter,
% for a lambda calculus with shift and reset,
% based on reading several papers, but particularly
% Oleg Kiselyov and Chung-chih Shan's
% Delimited Continuations in Operating Systems paper,
% and Biernacka et al's operational semantics of
% shift/reset.
%
% Terrible Prolog style is partly because I'm trying to think in Soar,
% (which to oversimplify is a forward-chaining production rule system
% so no backtracking is allowed,
% nor complicated uses of logical variables and unification),
% and partly because I'm just terrible at Prolog.

% registers:
%   name -- stores the name of the current state of the machine
%   exp -- stores the current expression
%   env -- stores the current environment (an association list)
%   cont -- stores the current continuation
%   value -- stores the current value
%   key -- stores the name we're looking up when we're looking up

% if
%   name is run
% then
%   change name to step and
%   (keep exp the same and)
%   set env to empty and
%   set cont to hole
run(Exp, Out) :- !,
  % print('run'), nl, backtrace(5),
  step(Exp, empty, hole, Out). % tail call

% if
%   name is step and
%   exp is an int
% then
%   change name to cont and
%   reject exp and
%   reject env and
%   (keep cont the same and)
%   set value to int's body
step(int(N), _Env, Cont, Out) :- !,
  % print('step*int'), nl, backtrace(5),
  cont(Cont, N, Out). % tail call

% if
%   name is step and
%   exp is a getchar
% then
%   first
%     read an int
%   then
%     change name to cont and
%     reject exp and
%     reject env and
%     (keep cont the same and)
%     set value to the read int
step(getchar, _Env, Cont, Out) :- !,
  % print('step*getchar'), nl, backtrace(5),
  read(N),
  cont(Cont, N, Out). % tail call

% if
%   name is step and
%   exp is a var
% then
%   change name to lookup and
%   reject exp and
%   (keep env the same and)
%   (keep cont the same and)
%   set key to var's body
step(var(K), Env, Cont, Out) :- !,
  % print('step*var'), nl, backtrace(5),
  lookup(Env, Cont, K, Out). % tail call

% if
%   name is step and
%   exp is a lam
% then
%   change name to cont and
%   reject exp and
%   reject env and
%   (keep cont the same and)
%   set value to a newly built closure of lam's key, lam's exp, and env
step(lam(X, Exp), Env, Cont, Out) :- !,
  % print('step*lam'), nl, backtrace(5),
  cont(Cont, clo(X, Exp, Env), Out). % tail call

% if
%   name is step and
%   exp is an app
% then
%   change exp to app's major and
%   (keep env the same and)
%   change cont to a newly built appK1 of app's minor, env, and cont
step(app(Major, Minor), Env, Cont, Out) :- !,
  % print('step*app'), nl, backtrace(5),
  step(Major, Env, appK1(Minor, Env, Cont), Out). % tail call

% DEBUG
% you can't have a function application with only one argument, silly!
step(app(X), Env, Cont, Out) :- !,
  print('step*app1'), nl, trace.

% DEBUG
% Nor a function application with three arguments!
step(app(X, Y, Z), Env, Cont, Out) :- !,
  print('step*app3'), nl, trace.

% if
%   name is step and
%   exp is a succ
% then
%   change exp to succ's exp
%   change cont to a newly built succK of cont
step(succ(Exp), Env, Cont, Out) :- !,
  % print('step*succ'), nl, backtrace(5),
  step(Exp, Env, succK(Cont), Out). % tail call

% if
%   name is step and
%   exp is a pred
% then
%   change exp to pred's exp
%   change cont to a newly built predK of cont
step(pred(Exp), Env, Cont, Out) :- !,
  % print('step*pred'), nl, backtrace(5),
  step(Exp, Env, predK(Cont), Out). % tail call

% if
%   name is step and
%   exp is a minus
% then
%   change exp to minus's left exp
%   change cont to a newly built minusK of minus's right exp and cont
step(minus(Left, Right), Env, Cont, Out) :- !,
  % print('step*minus'), nl, backtrace(5),
  step(Left, Env, minusK1(Right, Env, Cont), Out). % tail call

% if
%   name is step and
%   exp is an emit
% then
%   change exp to emit's exp
%   change cont to a newly built emitK of cont
step(emit(Exp), Env, Cont, Out) :- !,
  % print('step*emit'), nl, backtrace(5),
  step(Exp, Env, emitK(Cont), Out). % tail call

% if
%   name is step and
%   exp is an ifzero
% then
%   change exp to ifzero's test
%   change cont to a newly built ifzeroK of cont
step(ifzero(Test, TrueBranch, FalseBranch), Env, Cont, Out) :- !,
  % print('step*ifzero'), nl, backtrace(5),
  step(Test, Env, ifzeroK(TrueBranch, FalseBranch, Env, Cont), Out). % tail call


% if
%   name is step and
%   exp is a shift
% then
%   change exp to shift's exp
%   change cont to hole
%   change env to a newly built bind of shift's key, a newly built cap of cont, and env
step(shift(K, Exp), Env, Cont, Out) :- !,
  % print('step*shift'), nl, backtrace(5),
  step(Exp, bind(K, cap(Cont), Env), hole, Out).

% if
%   name is step and
%   exp is a reset
% then
%   first
%     run recursively reset's exp
%   then
%     change step to cont
%     reject exp and
%     reject env and
%     set value to Temp
step(reset(Exp), Env, Cont, Out) :- !,
  % print('step*reset'), nl, backtrace(5),
  step(Exp, Env, hole, Temp), % NOT A TAIL CALL! PUSHES ONTO PROLOG STACK!
  cont(Cont, Temp, Out). % tail call

% DEBUG
% Reset only takes one argument!
step(reset(Foo, Bar), Env, Cont, Out) :- !,
  print('step*reset2'), nl, trace.

% if
%   name is lookup and
%   env is a bind and
%   key matches bind's key
% then
%   change name to cont
%   reject env
%   reject key
%   set value to bind's value
lookup(bind(K, V, _Env), Cont, K, Out) :- !,
  % print('lookup*found'), nl, backtrace(5),
  cont(Cont, V, Out). % tail call

% if
%   name is lookup and
%   env is a bind and
%   key doesn't match bind's key
% then
%   change env to bind's Env
lookup(bind(K1, _V, Env), Cont, K2, Out) :- K1 \= K2, !,
  % print('lookup*not-found'), nl, backtrace(5),
  lookup(Env, Cont, K2, Out). % tail call

% if
%   name is lookup and
%   env is empty
% then
%   something very wrong has occurred
lookup(empty, Cont, K2, Out) :- !,
  print('lookup*empty'), nl, trace.

% if
%   name is cont and
%   cont is hole
% then
%   return value
cont(hole, Value, Out) :- !,
  % print('cont*hole'), nl, backtrace(5),
  Out = Value. % return, reducing size of stack

% if
%   name is cont and
%   cont is a appK1
% then
%   reject value
%   change name to step
%   set exp to appK1's exp
%   set env to appK1's env
%   change cont to a newly built appK2 with value and cont
cont(appK1(Exp, Env, Cont), Value, Out) :- !,
  % print('cont*appK1'), nl, backtrace(5),
  step(Exp, Env, appK2(Value, Cont), Out). % tail call

% if
%   name is cont and
%   cont is a appK2 of a closure
% then
%   change name to step
%   set exp to appK2's closure's Exp
%   reject value
%   set env to a newly built bind with appK2's closure's key, value, and appK2's closure's env
%   change cont to appK2's cont
cont(appK2(clo(X, Exp, Env), Cont), Value, Out) :- !,
  % print('cont*appK2*clo'), nl, backtrace(5),
  step(Exp, bind(X, Value, Env), Cont, Out). % tail call

% if
%   name is cont and
%   cont is a appK2 of a capture
% then
%   first
%     eval the captured continuation on the value
%   then
%     eval the rest of the continuation on the resulting value
cont(appK2(cap(ContPrime), Cont), Value, Out) :- !,
  % print('cont*appK2*cap'), nl, backtrace(5),
  cont(ContPrime, Value, Temp), % NOTE NOT A TAIL CALL! PUSHES ONTO THE PROLOG STACK!
  cont(Cont, Temp, Out). % tail call 

% DEBUG
% If the former two rules regarding cont*appK2 don't apply,
% then we've probably done something ridiculous like app(int(1), var(f)).
cont(appK2(Value1, Cont), Value2, Out) :- !,
  print('cont*appK2*value'), nl, trace.

% if
%   name is cont and
%   cont is a succK
% then
%   increment value
%   set cont to succK's cont
cont(succK(Cont), N, Out) :- !,
  % print('cont*succK'), nl, backtrace(5),
  M is N + 1,
  cont(Cont, M, Out). % tail call

% if
%   name is cont and
%   cont is a predK
% then
%   decrement value
%   set cont to predK's cont
cont(predK(Cont), N, Out) :- !,
  % print('cont*predK'), nl, backtrace(5),
  M is N - 1,
  cont(Cont, M, Out). % tail call

% if
%   name is cont and
%   cont is an emitK
% then
%   print a number
%   set cont to emitK's cont
cont(emitK(Cont), N, Out) :- !,
  % print('cont*emitK'), nl, backtrace(5),
  print(N), nl,
  cont(Cont, 1, Out). % tail call

% if
%   name is cont and
%   cont is an ifzeroK and
%   value is zero
% then
%   change name from cont to step
%   change exp to the true branch
%   change cont from ifzeroK to ifzeroK's Cont
cont(ifzeroK(TrueBranch, FalseBranch, Env, Cont), N, Out) :- N = 0, !,
  % print('cont*ifzeroKtrue'), nl, backtrace(5),
  step(TrueBranch, Env, Cont, Out). % tail call

% if
%   name is cont and
%   cont is an ifzeroK and
%   value is not zero
% then
%   change name from cont to step
%   set exp to the false branch
%   set env to the ifzeroK's env
%   change cont from ifzeroK to ifzeroK's Cont
cont(ifzeroK(TrueBranch, FalseBranch, Env, Cont), N, Out) :- N \= 0, !,
  % print('cont*ifzeroKfalse'), nl, backtrace(5),
  step(FalseBranch, Env, Cont, Out). % tail call

% if
%   name is cont and
%   cont is an minusK1 and
% then
%   change name from cont to step
%   change exp to the right exp
%   change cont from minusK1 to minusK2
cont(minusK1(RightExp, Env, Cont), N, Out) :- !,
  % print('cont*minusK1'), nl, backtrace(5),
  step(RightExp, Env, minusK2(N, Cont), Out). % tail call

% if
%   name is cont and
%   cont is an minusK2 and
% then
%   first
%     compute the answer now that you have both
%   then
%     change cont to minusK2's cont
%     change value to answer
cont(minusK2(N, Cont), M, Out) :- !,
  % print('cont*minusK2'), nl, backtrace(5),
  Answer is M - N,
  cont(Cont, Answer, Out). % tail call

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Okay, that's the end of the interpreter.
% Now we're on to the code written to run in the interpreter.
% I'm kindof feeling my way around here, so it's messy.

increment(X) :- !,
  X = lam(x, succ(var(x))).

true(X) :- !,
  X = lam(truebranch, lam(falsebranch, var(truebranch))).

false(X) :- !,
  X = lam(truebranch, lam(falsebranch, var(falsebranch))).

yhelper(X) :- !,
  X = lam(x, app(var(f), lam(v, app(app(var(x), var(x)), var(v))))).

y(X) :- !, yhelper(H),
  X = lam(f, app(H, H)).

emitloopbody(X) :- !,
  X = lam(f, lam(x, ifzero(var(x), int(1), app(lam(y, app(var(f), pred(var(x)))), emit(var(c)))))).

emitloop(X) :- !, y(Y), emitloopbody(Body),
  X = app(Y, Body).

emitblock(X) :- !, emitloop(Loop),
  X = app(lam(len, app(lam(c, app(Loop, var(len))), getchar)), getchar).

decompressbody(X) :- !, emitblock(EMITBLOCK),
  X = lam(rest, lam(notdone, ifzero(var(notdone),
    app(lam(x, int(1)), emit(int(0))),
    app(lam(c, 
    app(rest, ifzero(var(c), int(0), ifzero(minus(var(c), int(123)), app(lam(x, int(1)), EMITBLOCK), app(lam(x, int(1)), emit(var(c))))))), getchar)))).

dim(X) :- !, y(Y),
  X = app(Y, lam(recursefun, lam(x, lam(y, ifzero(var(y), var(x), ifzero(var(x), var(x), 
    app(app(var(recursefun), pred(var(x))), pred(var(y))))))))).

% technically this tests for between A and Z in ascii representation,
% not 'alpha' which should at least include lowercase.
isalpha(X) :- !, dim(D),
  X = lam(c, ifzero(app(app(D, int(65)), var(c)),
    ifzero(app(app(D, var(c)), int(90)), int(1), int(0)), int(0))).

% restofword is supposed to take a character,
% and keep getting new characters and emitting them so long as they're alphabetic
% until it finds a nonalphabetic character. Then it emits a 119 ('w') to indicate 'word'
% and stops. It's a helper for parser, not a thing in itself.
restofword(X) :- !, isalpha(ISALPHA), y(Y),
X = app(Y, lam(recursefun2,
      lam(c,
        app(lam(ignored,
          app(lam(d,
            ifzero(app(ISALPHA, var(d)),
              app(lam(ignored,
                app(lam(ignored,
                  app(var(recursefun), getchar)
                ), emit(int(119)))
              ), emit(var(d))),
              app(var(recursefun2), var(d)))
          ), getchar)
        ), emit(var(c)))))).

% this "parser" (actually more like a lexer?) reads numbers until it sees a sentinel (123),
% and classifies them into contiguous sequences of uppercase alpha (A-Z) 
% or a single character of anything else by suffixing them with 119 ('w') for 'word'
% or 112 'p' for 'punctuation'.
parser(X) :- !, isalpha(ISALPHA), y(Y), restofword(RESTOFWORD),
X = app(Y, lam(recursefun, 
     lam(c, 
       ifzero(minus(var(c), int(123)),
         int(1),
         ifzero(app(ISALPHA, var(c)),
           app(lam(ignored,
             app(lam(ignored,
               app(var(recursefun), getchar)
             ), emit(int(112)))
           ), emit(var(c))),
	   app(RESTOFWORD, var(c))
     ))))).

% requests are a data structure
% requests include exit, read, and write
% exit contains no continuation
% read contains a continuation that that accepts a character,
% yields anther request (usually exit)
% and may issue more requests.
% " a continuation that accepts a character and yields another request"
% might look like app(lam(ignored, emit([char])), shift(k, Exit))
% app(lam(ignored, emit(shift(k, Read(k)))), Exit)
% write contains a character to write,
% and a continuation that accepts nothing.
% service(req) == shift(k, app(var(req), var(k)))
service(X) :- !,
  X = lam(req, shift(k, app(var(req), var(k)))).

% datatype Req = Exit | Read(k) | Write(char, k)
% a reqconsumer needs three branches
% I think this is the Scott encoding?
reqexit(X) :- !,
  X = lam(k, lam(e, lam(r, lam(w, var(e))))).
reqread(X) :- !,
  X = lam(k, lam(e, lam(r, lam(w, app(var(r), var(k)))))).
reqwrite(X) :- !,
  X = lam(c, lam(k, lam(e, lam(r, lam(w, 
    app(app(var(w), var(c)), var(k))))))).

% cat2 is a process
% cat2 reads a character, writes it, reads another character, writes it, and then exits.
cat2(X) :- !, reqread(Read), reqwrite(Write), reqexit(Exit), service(Service),
  X = app(lam(c,
        app(lam(ignored,
          app(lam(d,
            app(lam(ignored,
              app(Service, Exit)
            ), app(Service, app(Write, var(d))))
          ), app(Service, Read))
        ), app(Service, app(Write, var(c))))
      ), app(Service, Read)).

% cat is a process, you read it something like:
% fixpoint of lam(recurse, 
%   let input = service Read in
%   let _ = service (Write input) in
%   recurse
cat(X) :- !, reqread(Read), reqwrite(Write), service(Service), y(Y),
  X = app(Y, lam(recurse,
      app(lam(input, 
        app(lam(ignored, 
          var(recurse)
        ), app(Service, app(Write, var(input))))
      ), app(Service, Read)))).

% catuntil is a process
% catuntil copies to input to output until it sees a sentinel value (123)
% it's something like:
% let rec catuntil input = 
%   if input == 123 then
%     service Exit
%   else
%     let _ = service (Write input) in
%       recurse (service Read)
catuntil(X) :- !, reqread(Read), reqwrite(Write), reqexit(Exit), service(Service), y(Y),
  X = app(Y, lam(recurse, lam(input, 
        ifzero(minus(var(input), int(123)),
          app(Service, Exit),
          app(lam(ignored, 
            app(var(recurse), app(Service, Read))
          ), app(Service, app(Write, var(input))))
        )
      ))).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This is the previous "parser" rewritten as a process
% We replace 'getchar' with app(Service, Read)
% and emit(foo) with app(Service, app(Write, foo))
%
% The parser process can be run on its own like so:
%
% parser_service(Parser), interpret(Interpret),
% run(app(Interpret, reset(app(Parser, getchar))), Answer).

restofword_service(X) :- !, isalpha(ISALPHA), y(Y), service(Service), reqread(Read), reqwrite(Write),
  X = app(Y, lam(recursefun2,
        lam(c,
          app(lam(ignored,
            app(lam(d,
              ifzero(app(ISALPHA, var(d)),
                app(lam(ignored,
                  app(lam(ignored,
                    app(var(recursefun), app(Service, Read))
                  ), app(Service, app(Write, int(119))))
                ), app(Service, app(Write, var(d)))),
                app(var(recursefun2), var(d)))
            ), app(Service, Read))
          ), app(Service, app(Write, var(c))))))).

parser_service(X) :- !,
  isalpha(ISALPHA), y(Y), restofword_service(RESTOFWORD),
  service(Service), reqread(Read), reqwrite(Write), reqexit(Exit),
  X = app(Y, lam(recursefun, 
       lam(c, 
         ifzero(minus(var(c), int(123)),
           app(Service, Exit),
           ifzero(app(ISALPHA, var(c)),
             app(lam(ignored,
               app(lam(ignored,
                 app(var(recursefun), app(Service, Read))
               ), app(Service, app(Write, int(112))))
             ), app(Service, app(Write, var(c)))),
  	   app(RESTOFWORD, var(c))
       ))))).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This is the decompressor process.
%
% It does something like run length decompression,
% with 123 as a sentinel value, so a run of 4 3s is coded as 123 4 3
% and a literal 123 is coded as 123 1 123
%
% The decompressor process can be run on its own like so:
%
% decompress_service(Decompress), interpret(Interpret),
% run(app(Interpret, reset(app(Decompress, getchar))), Answer).

emitblock_service(X) :- !, y(Y), service(Service), reqread(Read), reqwrite(Write),
  X = app(lam(len, app(lam(c, app(app(Y, lam(f, lam(x, ifzero(var(x), int(1), app(lam(y, app(var(f), pred(var(x)))), app(Service, app(Write, var(c)))))))), var(len))), app(Service, Read))), app(Service, Read)).

decompress_service(X) :- !, 
  y(Y), emitblock_service(BLOCK), service(Service), reqread(Read), reqwrite(Write), reqexit(Exit),
  X = app(Y, lam(f, lam(x, ifzero(var(x), app(Service, Exit),
  	ifzero(minus(var(x), int(123)), 
  	app(lam(y, app(var(f), app(Service, Read))), BLOCK),
  	app(lam(y, app(var(f), app(Service, Read))), app(Service, app(Write, var(x))))))))).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% interpret lets you run a single process
%
% It obeys requests to exit, read, or write,
% and then immediately resumes the computation (for read and write, obviously not exit).
interpret(X) :- !, y(Y),
  X = app(Y, lam(recurse, lam(to_interpret, 
    app(app(app(var(to_interpret), 
  	int(1)), % exit 
  	lam(k, app(var(recurse), reset(app(var(k), getchar))))), % read
  	lam(c, lam(k, app(var(recurse), reset(app(var(k), emit(var(c))))))))))). % write

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% This is the "operating system" section
% it's not much of an operating system,
% just a pipe between a producer (the "former") and a consumer (the "latter")
%
% Oleg Kiselyov was able to write something like an operating system (ZipperFS)
% in 500 lines of Haskell. I am not Oleg Kiselyov.
%
% You can pipe the decompression service 
% parser_service(Parser), decompress_service(Decompress), pipe(Pipe),
% run(app(app(Pipe, reset(app(Decompress, getchar))), Parser), Answer).

% writeblock is a helper for pipe - it pumps the "latter" process,
% emitting as many characters as possible.
writeblock(X) :- !, y(Y), 
  X = app(Y, lam(recurse2, lam(former2, lam(latter2,
    app(app(app(var(latter2),
  	int(1)), % latter exits - whole thing exits
        lam(k, app(app(var(recurse), reset(app(var(former2), int(1)))), var(k)))), % read from former
  	lam(c, lam(k, app(app(var(recurse2), var(former2)), reset(app(var(k), emit(var(c)))))))) % write
)))).

% pipe is like interpret for two processes
% it implements read and write differently for the two processes
% the first process reads via getchar, and writes into the second process
% the second process emits and reads from the first process.
pipe(X) :- !, y(Y), writeblock(Writeblock),
  X = app(Y, lam(recurse, lam(former, lam(latter,
    app(app(app(var(former),
  	int(1)), % former exits - whole thing exits
        lam(k, app(app(var(recurse), reset(app(var(k), getchar))), var(latter)))), % former reads - getchar
        lam(c, lam(k, app(app(Writeblock, var(k)), reset(app(var(latter), var(c))))))) % pipe to latter
)))).
