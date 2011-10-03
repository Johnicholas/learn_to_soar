
> data List a = Nil | Cons a (List a) deriving Show
> data Peano = Z | S Peano deriving Show

> my_length :: List a -> Peano
> my_length Nil = Z
> my_length (Cons _ xs) = S (my_length xs)
