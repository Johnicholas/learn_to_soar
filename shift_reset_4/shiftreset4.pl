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
% and partly simply because I'm terrible at Prolog.

% registers:
%   exp -- stores the current expression
%   env -- stores the current environment (an association list)
%   cont -- stores the current continuation
%   val -- stores the current value
%   key -- stores the name we're looking up when we're looking up
%
% data map:
%   TODO
%
% TODO: replace bind with bindcap and bindclo?

% if
%   name is run
% then
%   propose evalexp with
%     exp = run's exp and with
%     env = empty and with
%     cont = hole
run(Exp, Returnto) :- !,
  evalexp(Exp, empty, hole, Returnto).

% if
%   name is evalexp and
%   exp is an int
% then
%   propose applycont with
%     cont = evalexp's cont and with
%     val = int's value
evalexp(int(N), _Env, Cont, Returnto) :- !,
  applycont(Cont, N, Returnto).

% if
%   name is evalexp and
%   exp is a getchar
% then
%   first
%     read an int
%   later
%     propose applycont with
%       cont = evalexp's cont and with
%       val = the int we just read
evalexp(getchar, _Env, Cont, Returnto) :- !,
  read(N),
  applycont(Cont, N, Returnto).

% if
%   name is evalexp and
%   exp is a var
% then
%   propose lookupenv with
%     env = evalexp's env and with
%     cont = evalexp's cont and with
%     key = var's key
evalexp(var(Key), Env, Cont, Returnto) :- !,
  lookupenv(Env, Cont, Key, Returnto).

% if
%   name is evalexp and
%   exp is a lam
% then
%   first
%     create a new closure with
%       key = lam's key and with
%       exp = lam's exp and with
%       env = evalexp's env
%   later
%     propose applycont with
%       cont = evalexp's cont
%       val = the new closure we just built
evalexp(lam(X, Exp), Env, Cont, Returnto) :- !,
  NewClosure = clo(X, Exp, Env),
  applycont(Cont, NewClosure, Returnto).

% if
%   name is evalexp and
%   exp is an app
% then
%   first
%     create a new appK1 with
%       exp = app's minor and with
%       env = evalexp's env and with
%       cont = evalexp's cont
%   later
%     propose evalexp with
%       exp = app's major and with
%       env = evalexp's env and with
%       cont = the appK1 we just built
evalexp(app(Major, Minor), Env, Cont, Returnto) :- !,
  NewCont = appK1(Minor, Env, Cont),
  evalexp(Major, Env, NewCont, Returnto).

% DEBUG
% you can't have a function application with only one argument, silly!
evalexp(app(X), Env, Cont, Returnto) :- !,
  print('evalexp*app1'), nl, trace.

% DEBUG
% Nor a function application with three arguments!
evalexp(app(X, Y, Z), Env, Cont, Returnto) :- !,
  print('evalexp*app3'), nl, trace.

% if
%   name is evalexp and
%   exp is a succ
% then
%   first
%     construct a new succK with
%       cont = evalexp's cont
%   later
%      propose evalexp with
%        exp = succ's exp and with
%        env = evalexp's env and with
%        cont = the succK we just built.
evalexp(succ(Exp), Env, Cont, Returnto) :- !,
  NewCont = succK(Cont),
  evalexp(Exp, Env, NewCont, Returnto).

% if
%   name is evalexp and
%   exp is a pred
% then
%   first
%     construct a new predK with
%       cont = evalexp's cont
%   later
%     propose evalexp with
%       exp = succ's exp and with
%       env = evalexp's env and with
%       cont = the predK we just built.
evalexp(pred(Exp), Env, Cont, Returnto) :- !,
  NewCont = predK(Cont),
  evalexp(Exp, Env, NewCont, Returnto).

% if
%   name is evalexp and
%   exp is a minus
% then
%   first
%     construct a new minusK1 with
%       exp = minus's right and with
%       env = evalexp's env and with
%       cont = evalexp's cont
%   later
%     propose evalexp with
%       exp = minus's left and with
%       env = evalexp's env and with
%       cont = the minusK1 that we just built
evalexp(minus(Left, Right), Env, Cont, Returnto) :- !,
  NewCont = minusK1(Right, Env, Cont),
  evalexp(Left, Env, NewCont, Returnto).

% if
%   name is evalexp and
%   exp is an emit
% then
%   first
%     construct a new emitK with
%       cont = evalexp's cont
%   later
%     propose evalexp with
%       exp = emit's exp and with
%       env = emit's env and with
%       cont = the emitK that we just built
evalexp(emit(Exp), Env, Cont, Returnto) :- !,
  NewCont = emitK(Cont),
  evalexp(Exp, Env, NewCont, Returnto).

% if
%   name is evalexp and
%   exp is an ifzero
% then
%   first
%     construct a new ifzeroK with
%       true = ifzero's true and with
%       false = ifzero's false and with
%       env = evalexp's env and with
%       cont = evalexp's cont
%   later
%     propose evalexp with
%       exp = ifzero's test and with
%       env = evalexp's env and with
%       cont = the ifzeroK that we just built
evalexp(ifzero(Test, TrueBranch, FalseBranch), Env, Cont, Returnto) :- !,
  NewCont = ifzeroK(TrueBranch, FalseBranch, Env, Cont),
  evalexp(Test, Env, NewCont, Returnto).


% if
%   name is evalexp and
%   exp is a shift
% then
%   first
%     construct a new bind with 
%       key = shift's key and with
%       val = cap-tagged evalexp's cont and with
%       env = evalexp's env
%   later
%     propose evalexp with
%       exp = shift's exp and with
%       env = the bind that we just constructed and with
%       cont = hole
evalexp(shift(Key, Exp), Env, Cont, Returnto) :- !,
  NewEnv = bind(Key, cap(Cont), Env),
  evalexp(Exp, NewEnv, hole, Returnto).

% if
%   name is evalexp and
%   exp is a reset
% then
%   first
%     propose evalexp with
%       exp = reset's exp and with
%       env = evalexp's env and with
%       cont = hole
%   then
%     propose applycont with
%       cont = evalexp's cont and with
%       val = the result of evalexp that we just calculated
evalexp(reset(Exp), Env, Cont, Returnto) :- !,
  evalexp(Exp, Env, hole, Temp),
  applycont(Cont, Temp, Returnto).

% DEBUG
% Reset only takes one argument!
evalexp(reset(Foo, Bar), Env, Cont, Returnto) :- !,
  print('evalexp*reset2'), nl, trace.

% if
%   name is lookupenv and
%   env is a bind and
%   key matches bind's key
% then
%   propose applycont with
%     cont = lookupenv's cont and with
%     val = bind's val
lookupenv(bind(Key, Val, _Env), Cont, Key, Returnto) :- !,
  applycont(Cont, Val, Returnto).

% if
%   name is lookupenv and
%   env is a bind and
%   key doesn't match bind's key
% then
%   propose lookupenv with
%     env = bind's env and with
%     cont = lookupenv's cont and with
%     key = lookupenv's key
lookupenv(bind(Key1, _Val, Env), Cont, Key2, Returnto) :- Key1 \= Key2, !,
  lookupenv(Env, Cont, Key2, Returnto).

% DEBUG
% something very wrong has occurred
lookupenv(empty, Cont, Key2, Returnto) :- !,
  print('lookupenv*empty'), nl, trace.

% if
%   name is cont and
%   cont is hole
% then
%   return val
applycont(hole, Val, Returnto) :- !,
  Returnto = Val. % return, reducing size of stack

% if
%   name is cont and
%   cont is a appK1
% then
%   first
%     build an appK2 with
%       val = applycont's val and with
%       cont = appK1's cont
%   later
%     propose evalexp with
%       exp = appK1's exp and with
%       env = appK1's env and with
%       cont = the new cont that we just built
applycont(appK1(Exp, Env, Cont), Val, Returnto) :- !,
  NewCont = appK2(Val, Cont),
  evalexp(Exp, Env, NewCont, Returnto).

% if
%   name is cont and
%   cont is a appK2 of a closure
% then
%   first
%     build a new bind with
%       key = appK2's clo's key and with
%       val = applycont's val and with
%       env = appK2's env
%   later
%     propose evalexp with
%       exp = applyK2's exp and with
%       env = the new bind we just built and with
%       cont = appK2's cont
applycont(appK2(clo(Key, Exp, Env), Cont), Val, Returnto) :- !,
  NewEnv = bind(Key, Val, Env),
  evalexp(Exp, NewEnv, Cont, Returnto).

% if
%   name is cont and
%   cont is a appK2 of a capture
% then
%   first
%     eval the captured continuation on the val
%   then
%     eval the rest of the continuation on the resulting val
applycont(appK2(cap(ContPrime), Cont), Val, Returnto) :- !,
  applycont(ContPrime, Val, Temp), % NOTE NOT A TAIL CALL! PUSHES ONTO THE PROLOG STACK!
  applycont(Cont, Temp, Returnto). 

% DEBUG
% If the former two rules regarding cont*appK2 don't apply,
% then we've probably done something ridiculous like app(int(1), var(f)).
applycont(appK2(Val1, Cont), Val2, Returnto) :- !,
  print('cont*appK2*val'), nl, trace.

% if
%   name is cont and
%   cont is a succK
% then
%   increment val
%   set cont to succK's cont
applycont(succK(Cont), N, Returnto) :- !,
  M is N + 1,
  applycont(Cont, M, Returnto).

% if
%   name is cont and
%   cont is a predK
% then
%   decrement val
%   set cont to predK's cont
cont(predK(Cont), N, Returnto) :- !,
  M is N - 1,
  applycont(Cont, M, Returnto).

% if
%   name is cont and
%   cont is an emitK
% then
%   print a number
%   set cont to emitK's cont
applycont(emitK(Cont), N, Returnto) :- !,
  print(N), nl,
  applycont(Cont, 1, Returnto).

% if
%   name is cont and
%   cont is an ifzeroK and
%   val is zero
% then
%   propose evalexp with
%     exp = ifzeroK's true and with
%     env = ifzeroK's env and with
%     cont = ifzeroK's cont
applycont(ifzeroK(TrueBranch, FalseBranch, Env, Cont), N, Returnto) :- N = 0, !,
  evalexp(TrueBranch, Env, Cont, Returnto).

% if
%   name is cont and
%   cont is an ifzeroK and
%   val is not zero
% then
%   propose evalexp with
%     exp = ifzeroK's false and with
%     env = ifzeroK's env and with
%     cont = ifzeroK's cont
applycont(ifzeroK(TrueBranch, FalseBranch, Env, Cont), N, Returnto) :- N \= 0, !,
  evalexp(FalseBranch, Env, Cont, Returnto).

% if
%   name is cont and
%   cont is an minusK1 and
% then
%   first
%     construct a new minusK2 with
%       val = applycont's val and with
%       cont = applycont's cont
%   later
%     propose evalexp with
%       exp = minusK1's exp and with
%       env = minusK1's env and with
%       cont = the new minusK2 that we just built
applycont(minusK1(Exp, Env, Cont), N, Returnto) :- !,
  NewCont = minusK2(N, Cont),
  evalexp(Exp, Env, NewCont, Returnto).

% if
%   name is cont and
%   cont is an minusK2 and
% then
%   first
%     compute the answer now that you have both
%   later
%     propose applycont with
%       cont = minusK2's cont and with
%       val = the answer we just computed
applycont(minusK2(N, Cont), M, Returnto) :- !,
  Answer is M - N,
  applycont(Cont, Answer, Returnto).

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
                app(var(recursefun), var(d))
              ), emit(int(119))),
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
% catuntil copies to input to output until it sees a sentinel val (123)
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
                  app(var(recursefun), var(d))
                ), app(Service, app(Write, int(119)))),
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
