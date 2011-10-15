redo-ifchange test-set.grammar
seq 0 10000 | random_string -g test-set.grammar | req | sed 's/> //g;/ok$/d'
