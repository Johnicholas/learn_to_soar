
> data Elem = A | B | C deriving Show
> data Peano = Z | S( Peano ) deriving Show
> data List a = Nil | Cons( a, List a ) deriving Show

> index :: List a -> Peano -> Maybe a
> index Nil _ = Nothing
> index (Cons(x, _)) Z = Just x
> index (Cons(x, xs)) (S(n)) = index xs n

