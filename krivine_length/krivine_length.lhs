How do we use an interpreter to get things done?

Here's the krivine machine, a little interpreter.

> data Exp = V(Char) | L(Char, Exp) | A(Exp, Exp) | Q(String) deriving Show
> data Closure = Closure(Exp, Env) deriving Show
> data Env = Empty | Extend(Char, Closure, Env) deriving Show
> data Stack = Nil | Cons(Closure, Stack) deriving Show
> ev :: (Exp, Env, Stack) -> Maybe String
> ev (V n1, Extend (n2, Closure (c, e1), e2), s) =  if n1 == n2 then ev (c, e1, s) else ev (V n1, e2, s) 
> ev (V n, Empty, s) = error "Unbound variable"
> ev (L (formal, body), e, Cons (actual, stack)) = ev (body, Extend (formal, actual, e), stack)
> ev (L (formal, body), e, Nil) = error "Insufficient arguments"
> ev (A (f, x), e, s) = ev (f, e, Cons (Closure (x, e), s))
> ev (Q (a), e, Nil) = Just a
> ev (Q (a), e, Cons (actual, stack)) = error "Nonfunction applied to argument"
> start :: Exp -> Maybe String
> start code = ev (code, Empty, Nil)

We want to avoid writing the "tediously long" implementation of length (two lines):

x data Peano = Z | S( Peano )
x data List a = Nil | Cons( a, List a )
x length :: List a -> Peano
x length Nil = Z
x length (Cons _ xs) = S (length xs)

Instead, we want to define length in "only one" line, by running the interpreter on something, like so:

x length l = start(App(length_term, l))

Now the first thing the length term will need to do is pattern match or inspect,
to decide whether the input is Nil or not.
That's not possible in this language,
though maybe that could be possible with another little interpreter.
So instead we have to fake it by accepting a list-shaped term instead of a list,
and applying the list-shaped term to something.

This is a standard Scott encoding, a.k.a. the visitor design pattern:

> nil c1 c2 = c1

> nil_term = L('a', L('b', V('a')))

> cons h t c1 c2 = c2 h t

> cons_term = L('h', L('t', L('c', L('d', A(A(V('d'), V('h')), V('t'))))))

The second thing that the length term will need to do is to construct something.
Again, we can't really construct a Peano term in the host language,
though again maybe that could be possible with another little interpreter.
Again, we fake it by returning a list-shaped term.

This is another standard Scott encoding:

> z c1 c2 = c1

> z_term = L('a', L('b', V('a')))

> s x1 c1 c2 = c2 x1

> s_term = L('a', L('b', L('c', A(V('c'), V('a')))))

Length is a recursive function,
and there is no explicit recursion available,
but we can use a fixed-point combinator.

Note: fix and similar recursive functions are not typeable in Haskell.
x> fix f = (\x -> (x x)) (\x -> f (x x))
x> to_int peano = peano 0 (\pred -> 1 + (to_int pred))
x> int_length list = list 0 (\h -> (\t -> (+) 1 (my_length t)))

> fix_term = L('f', A(L('x', A(V('x'), V('x'))), L('x', A(V('f'), A(V('x'), V('x'))))))

To define a recursive function,
we assume (wishful thinking) that we're going to get a total function
that does whatever we are trying to do. 
Then we use that function to write a function that does one step of progress,
and then delegates to the total function.

> almost_length total_length list = list z (\h -> (\t -> s (total_length t)))

> almost_length_term = L('o', L('l', A(A(V('l'), z_term),  L('h', L('t', A(s_term, A(V('o'), V('t'))))))))

Then we can define the actual term by taking the fixpoint of the almost one.

> length_term = A(fix_term, almost_length_term)

This is the whole gory thing:

A (L ('f',A (L ('x',A (V 'x',V 'x')),
             L ('x',A (V 'f',A (V 'x',V 'x'))))),
   L ('o',L ('l',A (A (V 'l',L ('a',L ('b',V 'a'))),
                    L ('h',L ('t',A (L ('a',L ('b',L ('c',A (V 'c',V 'a')))),
                                     A (V 'o',V 't'))))))))

To facilitate transliterating into Soar notation, we could add a number to every constructor.

A01 (L02 ('f', A03 (L04 ('x', A05 (V06 'x', V07 'x')),
                    L08 ('x', A09 (V10 'f', A11 (V12 'x', V13 'x'))))),
     L14 ('o', L15 ('l', A16 (A17 (V18 'l', L19 ('a', L20 ('b', V21 'a'))),
                              L22 ('h', L23 ('t', A24 (L25 ('a', L26 ('b', L27 ('c', A28 (V29 'c', V30 'a')))),
                                                       A31 (V32 'o', V33 't'))))))))

Transliterating a bit into Soar notation, it would look something like this:
  (<a01> ^head app ^fun <l02> ^arg <l14>)
  (<l02> ^head lambda ^name |f| ^body <a03>)
  (<a03> ^head app ^fun <l04> ^arg <l08>)
  (<l04> ^head lambda ^name |x| ^body <a05>)
  (<a05> ^head app ^fun <v06> ^arg <v07>)
  (<v06> ^head sym ^name |x|)
  (<v07> ^head sym ^name |x|)
  ...
But we don't want to do that transformation by hand.

Here is half of a clumsy attempt at implementing that transformation automatically:
It should probably use some sort of gensym monad.

x> to_soar :: Exp -> String
x> to_soar exp = to_soar_helper exp 1
x> to_soar_helper :: Num t => (Exp, t) -> (String, String, t) 
x> to_soar_helper (V x) n = ("<v" ++ (show n) ++ ">", "(<v" ++ (show n) ++ "> ^head sym ^name |" ++ [x] ++ "|)", n+1)
x> to_soar_helper (L (formal, body)) n = ("<l" ++ (show n) ++ ">",
x>     "(<l" ++
x>     (show n) ++
x>     "> ^head lambda ^name |" ++
x>     [formal] ++
x>     "| ^body <TODO>)\n" ++
x>     (to_soar_helper body (n+1))
x> to_soar_helper (A (fun, arg)) n = 
x>     "(<a" ++
x>     (show n) ++
x>     "> ^head app ^fun <" ++ 
x>     "TODO" ++ 
x>     "> ^arg <" ++ 
x>     "TODO" ++
x>     ">)\n" ++
x>     (to_soar_helper fun n) ++ -- TODO: n isn't the right thing here, it should be n+1
x>     "\n" ++
x>     (to_soar_helper arg n) -- TODO: n isn't the right thing here, it should be at least n+2 or much larger
x> to_soar_helper (Q x) n = "(<q" ++ (show n) ++ "> ^head quote ^quoted |" ++ x ++ "|) "


