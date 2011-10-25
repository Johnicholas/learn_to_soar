This is directly from Bird's "Introduction to Functional Programming using Haskell",
just some names changed to help my eyes see the similarities to what I was doing before.

> data Avl a = Null | Bin Int a (Avl a) (Avl a)

> makenode x l r = Bin ((max (height l) (height r)) + 1) x l r

> height Null = 0
> height (Bin h x l r) = h

> slope (Bin h x l r) = (height l) - (height r)


> rebalance x l r
>   | (hr + 1 < hl) && (slope l < 0) = ror (makenode x (rol l) r)
>   | (hr + 1 < hl) = ror (makenode x l r)
>   | (hl + 1 < hr) && (0 < slope r) = rol (makenode x l (ror r))
>   | (hl + 1 < hr) = rol (makenode x l r)
>   | otherwise = makenode x l r
>   where hl = height l; hr = height r


> ror (Bin h1 x1 (Bin h2 x2 ll lr) r) = makenode x2 ll (makenode x1 lr r)

> rol (Bin h1 x1 l (Bin h2 x2 rl rr)) = makenode x2 (makenode x1 l rl) rr

