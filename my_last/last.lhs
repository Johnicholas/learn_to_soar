
I don't really understand Haskell generic polymorphism,
and I'm not really writing in Haskell anyway,
so I'm going to be unduly concrete.

> data List a = Nil | Cons( a, List a ) deriving Show

> my_last :: List a -> Maybe a
> my_last Nil = Nothing
> my_last (Cons(x, xs)) = my_last_helper xs x

> my_last_helper :: List a -> a -> Maybe a
> my_last_helper Nil x = Just(x)
> my_last_helper (Cons(x, xs)) y = my_last_helper xs x

