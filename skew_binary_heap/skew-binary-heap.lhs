This is derived from the implementation in Graeme Moss's Auburn thesis.

We're going to create a concept called a heap.
A heap is a container of arbitrary ORDERED things.

we're going to assume that there is a "lessThan"
and a "lessOrEqual" operators for these things
that we're containing.

> class OrderedForHeap a where
>   lessThan :: (a, a) -> Bool
>   lessOrEqual :: (a, a) -> Bool

One of the things that you can do is to create a new empty heap
another thing you can do is test whether a heap is empty
you can insert something into a heap
you can merge two heaps
you can find the minimum item in a heap
you can delete the minimum item in a heap

A heap is a list of trees.

> newtype OrderedForHeap a => Heap a = Heap (TreeList a)
> data OrderedForHeap a => TreeList a = TNil | TCons(Tree a, TreeList a)

A tree is formed of nodes
A node has
1. an int, called the rank
2. a single element, called the root
3. a list of elements, called xs
4. a list of trees, called c

> data OrderedForHeap a => Tree a = Node(Int, a, ElemList a, TreeList a)
> data OrderedForHeap a => ElemList a = ANil | ACons(a, ElemList a)

rank and root are accessor convenience methods.

> rank :: OrderedForHeap a => Tree a -> Int
> rank(Node(r, x, xs, c)) = r
> root :: OrderedForHeap a => Tree a -> a
> root(Node(r, x, xs, c)) = x

link takes two trees and links them together,
to form a new bigger tree

> link :: OrderedForHeap a => (Tree a, Tree a) -> Tree a
> link(Node(r, x1, xs1, c1), Node(ignored, x2, xs2, c2)) =
>  if lessOrEqual(x1, x2) then
>     Node(r + 1, x1, xs1, TCons(Node(ignored, x2, xs2, c2), c1)) else
>     Node(r + 1, x2, xs2, TCons(Node(r, x1, xs1, c1), c2))

skewLink takes a single element and two trees
to form a new bigger tree

> skewLink :: OrderedForHeap a => (a, Tree a, Tree a) -> Tree a
> skewLink(x, t1, t2) = skewLinkHelper(link(t1, t2), x)
> skewLinkHelper(Node(r, y, ys, c), x) =
>   if lessOrEqual(x, y) then
>      Node(r, x, ACons(y, ys), c) else
>      Node(r, y, ACons(x, ys), c)

insTree takes a single tree and a list of trees,
and inserts the single tree into the list, at appropriate spot for its rank

> insTree :: OrderedForHeap a => (Tree a, TreeList a) -> TreeList a
> insTree(t, TNil) = TCons(t, TNil)
> insTree(t, TCons(tprime, tsprime)) =
>   if rank(t) < rank(tprime) then
>      TCons(t, TCons(tprime, tsprime)) else
>      insTree(link(t, tprime), tsprime)

mergeHelper takes two lists of trees and merges them,
maintaining the invariant (TODO: what IS the invariant?)

> mergeHelper :: OrderedForHeap a => (TreeList a, TreeList a) -> TreeList a
> mergeHelper(ts1, TNil) = ts1
> mergeHelper(TNil, ts2) = ts2
> mergeHelper(TCons(t1, ts1prime), TCons(t2, ts2prime)) =
>   if rank(t1) < rank(t2) then
>      TCons(t1, mergeHelper(ts1prime, TCons(t2, ts2prime))) else (
>      if rank(t2) < rank(t1) then
>         TCons(t2, mergeHelper(TCons(t1, ts1prime), ts2prime)) else
>         insTree(link(t1, t2), mergeHelper(ts1prime, ts2prime)))

normalize takes a list of trees and enforces the invariant.

> normalize :: OrderedForHeap a => TreeList a -> TreeList a
> normalize(TNil) = TNil
> normalize(TCons(t, ts)) = insTree(t, ts)

removeMinTree takes a list of trees,
finds the one with the minimum root,
and returns a pair - the minimum tree and the list without that tree.
note: does not work on empty lists of trees.

> removeMinTree :: OrderedForHeap a => TreeList a -> (Tree a, TreeList a)
> removeMinTree(TCons(t, TNil)) = (t, TNil)
> removeMinTree(TCons(t, TCons(ts1, tss))) = removeMinTreeHelper(removeMinTree(TCons(ts1, tss)), t, TCons(ts1, tss))
> removeMinTreeHelper((tprime, tsprime), t, ts) =
>   if lessThan(root(t), root(tprime)) then
>      (t, ts) else
>      (t, TCons(t, tsprime))

empty constructs an empty heap

> empty :: OrderedForHeap a => Heap a
> empty = Heap(TNil)

isEmpty returns True if the heap is empty, and
False if the heap is nonempty

> isEmpty :: OrderedForHeap a => Heap a -> Bool
> isEmpty(Heap(TNil)) = True
> isEmpty(Heap(TCons(x, xs))) = False

insert inserts a single element into a heap

> insert :: OrderedForHeap a => (a, Heap a) -> Heap a
> insert(x, Heap(TNil)) = Heap(TCons(Node(0, x, ANil, TNil), TNil))
> insert(x, Heap(TCons(t, TNil))) = Heap(TCons(Node(0, x, ANil, TNil), TCons(t, TNil)))
> insert(x, Heap(TCons(t1, TCons(t2, ts)))) =
>   if rank(t1) == rank(t2) then
>      Heap(TCons(skewLink(x, t1, t2), ts)) else
>      Heap(TCons(Node(0, x, ANil, TNil), ts))

merge takes two heaps and combines them

> merge :: OrderedForHeap a => (Heap a, Heap a) -> Heap a
> merge(Heap(ts1), Heap(ts2)) = Heap(mergeHelper(normalize(ts1), normalize(ts2)))

findMin returns the minimum element of a heap

> findMin :: OrderedForHeap a => Heap a -> a
> findMin(Heap(ts)) = findMinHelper(removeMinTree(ts))
> findMinHelper((t, ignored)) = root(t)

deleteMin takes a heap and returns a nearly identical heap,
but missing the first heap's minimum element.
note: don't run it on empty heaps.

> deleteMin :: OrderedForHeap a => Heap a -> Heap a
> deleteMin(Heap(ts)) = deleteMinHelper(removeMinTree(ts))
> deleteMinHelper((Node(ignored, x, xs, ts1), ts2)) =
>   insertAll(xs, Heap(mergeHelper(reverseTreeList(ts1), normalize(ts2))))

> reverseTreeList(xs) = reverseHelper(xs, TNil)

> reverseHelper(TNil, accum) = accum
> reverseHelper(TCons(x, xs), accum) = reverseHelper(xs, TCons(x, accum))

> insertAll(ANil, heap) = heap
> insertAll(ACons(x, xs), heap) = insertAll(xs, insert(x, heap))

A few little things for testing:

> data Test = Test Int deriving Eq

> instance OrderedForHeap Test where 
>   lessThan(Test x, Test y) = x < y
>   lessOrEqual(Test x, Test y) = x <= y

