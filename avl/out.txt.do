redo-ifchange avl.req test-comparisons.req ten-thousand-tests.txt
cat avl.req test-comparisons.req ten-thousand-tests.txt | req | sed '/ok$/d;s/> //g'
