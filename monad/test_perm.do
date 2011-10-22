# DEPENDENCIES should be the .o files
DEPENDENCIES="nil.o \
  element.o \
  cons.o \
  list_of_lists.o \
  list.o \
  lol_cons.o \
  lol_nil.o"
redo-ifchange test_perm.cpp $DEPENDENCIES
g++ -o $3 test_perm.cpp $DEPENDENCIES

