redo-ifchange ten-thousand-tests.txt out.txt gold.txt
diff -u <$(paste ten-thousand-tests.txt out.txt) <$(paste ten-thousand-tests.txt gold.txt) || true




