module SkewBinHeap (Heap,empty,isEmpty,insert,merge,findMin,deleteMin) where

newtype Ord a => Heap a = Heap [Tree a]
data Ord a => Tree a = Node Int a [a] [Tree a]

rank :: Ord a => Tree a -> Int
rank (Node r x xs c) = r

root :: Ord a => Tree a -> a
root (Node r x xs c) = x

link :: Ord a => Tree a -> Tree a -> Tree a
link t1@(Node r x1 xs1 c1) t2@(Node _ x2 xs2 c2) =
    if x1 <= x2 then Node (r+1) x1 xs1 (t2:c1)
    else Node (r+1) x2 xs2 (t1:c2)

skewLink :: Ord a => a -> Tree a -> Tree a -> Tree a
skewLink x t1 t2 =
    let Node r y ys c = link t1 t2
    in if x <= y then Node r x (y:ys) c else Node r y (x:ys) c

insTree :: Ord a => Tree a -> [Tree a] -> [Tree a]
insTree t [] = [t]
insTree t ts@(t':ts') =
  if rank t < rank t' then t:ts else insTree (link t t') ts'

mrg :: Ord a => [Tree a] -> [Tree a] -> [Tree a]
mrg ts1 [] = ts1
mrg [] ts2 = ts2
mrg ts1@(t1:ts1') ts2@(t2:ts2')
    | rank t1 < rank t2 = t1 : mrg ts1' ts2
    | rank t2 < rank t1 = t2 : mrg ts1 ts2'
    | otherwise = insTree (link t1 t2) (mrg ts1' ts2')

normalize :: Ord a => [Tree a] -> [Tree a]
normalize [] = []
normalize (t:ts) = insTree t ts

removeMinTree :: Ord a => [Tree a] -> (Tree a,[Tree a])
removeMinTree [t] = (t, [])
removeMinTree (t:ts) = if root t < root t' then (t, ts) else (t', t : ts')
    where (t', ts') = removeMinTree ts

empty :: Ord a => Heap a
empty = Heap []

isEmpty :: Ord a => Heap a -> Bool
isEmpty (Heap ts) = null ts

insert :: Ord a => a -> Heap a -> Heap a
insert x (Heap (t1:t2:ts)) | rank t1 == rank t2 = 
   Heap (skewLink x t1 t2 : ts)
insert x (Heap ts) = Heap (Node 0 x [] [] : ts)

merge :: Ord a => Heap a -> Heap a -> Heap a
merge (Heap ts1) (Heap ts2) = Heap (mrg (normalize ts1) (normalize ts2))

findMin :: Ord a => Heap a -> a
findMin (Heap ts) = root t
   where (t, _) = removeMinTree ts

deleteMin :: Ord a => Heap a -> Heap a
deleteMin (Heap ts) = foldr insert (Heap ts') xs
   where (Node _ x xs ts1, ts2) = removeMinTree ts
         ts' = mrg (reverse ts1) (normalize ts2)
