This is an SEC interpreter, and corresponding SEC compiler and vm from
Ager et al's "From Interpreter to Compiler and Virtual Machine".

Aside: We could be generic in the type of names, but for concreteness,
let's use Char.

> data Term = Lit Int | Var Char | Lam (Char, Term) | App (Term, Term) | Succ Term deriving Show
> data Stack = Nil | Cons (Val, Stack) deriving Show
> data Val = Closure (Char, Env, Term) | IntVal Int deriving Show
> data Env = Mt | Extend (Char, Val, Env) deriving Show
> data StackEnv = Pair (Stack, Env) deriving Show
> mymain :: Term -> Val
> mymain term = mainhelper (eval Nil Mt term)
> mainhelper (Pair (Cons (val, Nil), ignored)) = val

> eval s e (Lit n) = Pair (Cons (IntVal n, s), e)
> eval s e (Var x) = Pair (Cons (mylookup e x, s), e)
> eval s e (Lam (x, t)) = Pair (Cons (Closure (x, e, t), s), e)
> eval s e (App (t0, t1)) = evalapphelper1 (eval s e t1) t0
> eval s e (Succ t) = evalsucchelper (eval s e t)

> mylookup (Extend (x, v, e)) y = if x == y then v else mylookup e y

> evalapphelper1 (Pair (sprime, eprime)) t0 = evalapphelper2 (eval sprime eprime t0)
> evalapphelper2 (Pair (Cons (Closure (fx, fe, ft), Cons(v, s)), e)) =
>     evalapphelper3 (applyclosure fx fe ft (Cons(v, Nil)) e) s e
> applyclosure fx fe ft (Cons (v, sprime)) eprime = eval Nil (Extend (fx, v, fe)) ft
> evalapphelper3 (Pair (Cons (v, Nil), ignored)) s e = Pair (Cons (v, s), e)

> evalsucchelper (Pair (Cons (IntVal n, s), e)) = Pair (Cons (IntVal (n + 1), s), e)

this compiler is also from Ager et al., but it doesn't handle Lit or Succ
t denotes terms
i denotes instructions
c denotes lists of instructions
e denotes environments
v denotes expressible values
s denotes stacks of expressible values
t ::= Var(name) | Lam(name, t) | App(t, t)
i ::= Access(name) | Close(name, c) | Call
v ::= Val(name, c, e)

compile(Var(?x)) == Cons(Access(?x), Nil)
compile(Lam(?x, ?t)) == Cons(Close(?x, compile(?t)), Nil)
compile(App(?t0, ?t1)) == append(compile(?t1), append(compile(?t0), Cons(Call, Nil)))
append(Nil, ?ys) == ?ys
append(Cons(?x, ?xs), ?ys) == Cons(?x, append(?xs, ?ys))

this machine is also from Ager et al.
the initial transition:

machine_main(?c) == sec(Nil, Mt, ?c)

the state machine:

sec(?s, ?e, Cons(Access(?x), ?c)) ==
    sec(Cons(lookup(?e, ?x), ?s), ?e, ?c)
sec(?s, ?e, Cons(Close(?x, ?cprime), ?c)) ==
    sec(Cons(Val(?x, ?cprime, ?e), ?s), ?e, ?c)
sec(Cons(Val(?x, ?cprime, ?eprime), Cons(?v, ?s)), ?e, Cons(Call, ?c)) ==
    sec(?s, Extend(?x, ?v, ?eprime), append(?cprime, ?c))
sec(Cons(?v, ?s), ?e, Nil) == ?v
