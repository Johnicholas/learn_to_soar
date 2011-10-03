This is a a simple CPS-transformed normal-order lambda-calculus interpreter,
roughly speaking the Krivine machine,
though I hesitate to say that it IS the Krivine machine;
I am an amateur.

An expression can be:
1. a symbol,
2. a quoted value,
3. a lambda, or
4. a function application.

The type of expressions is, in principle, polymorphic,
they are parameterized by a type of names,
and a type of quoted values.

However, the syntax for such polymorphism is fairly Haskell-centric.
So instead we use chars (for example, 'x', 'y', 'z') for names,
and strings for quoted values.

> data Exp = Sym Char | Quote String | Lambda Char Exp | App Exp Exp deriving Show
> data Closure = Closure Exp Env deriving Show
> data Env = Empty | Extend Char Closure Env deriving Show
> data Stack = Nil | Cons Closure Stack deriving Show

> ev :: (Exp, Env, Stack) -> Maybe String

To eval a symbol, look it up in the environment.

> ev (Sym n1, Extend n2 (Closure c e1) e2, s) = if n1 == n2 then ev (c, e1, s) else ev (Sym n1, e2, s)

If there's nothing in the environment, that's a problem.

> ev (Sym n1, Empty, s) = Nothing

To eval a quote, return whatever is inside.

> ev (Quote x, e, Nil) = Just x

If someone is trying to apply a quote to something, that's a problem.

> ev (Quote x, e, Cons actual stack) = Nothing

To eval a lambda, extend the environment,
binding the value on top of the stack
to the formal parameter,
and continuing into the body.

> ev (Lambda formal body, e, Cons actual stack) = ev (body, Extend formal actual e, stack)

If there's nothing in the stack, that's a problem.

> ev (Lambda formal body, e, Nil) = Nothing

To eval an application, push the argument,
together with the environment we'll need to eval it,
onto the stack for later.

> ev (App f x, e, stack) = ev (f, e, Cons (Closure x e) stack)

To start, use the empty environment and empty stack.

> start :: Exp -> Maybe String
> start code = ev (code, Empty, Nil)





