cat skew-binomial-heap.req test-heap.req filtered-tests.req | req | sed 's/> //;/ok$/d' | paste filtered-tests.req - | diff -u - <(paste filtered-tests.req filtered-gold.txt)

