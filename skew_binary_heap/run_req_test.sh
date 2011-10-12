cat skew-binary-heap.req test-heap.req filtered_tests.req | req | sed 's/> //;/ok$/d' | diff -u - filtered_gold.txt
