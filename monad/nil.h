#ifndef NIL_H
#define NIL_H

#include "list.h"

class Nil : public List {
public:
  // From List.
  // You can't insert an element within an empty list; fail.
  // insertWithin(Nil, ?x) == mzero()
  std::tr1::shared_ptr<ListOfLists> insertWithin(std::tr1::shared_ptr<Element> x);

  // From List.
  // There is only one permutation of the empty list - the empty list.
  // perms(Nil) == return(Nil)
  std::tr1::shared_ptr<ListOfLists> perms();

  // From List
  void print(std::ostream& out);

private:
  // nothing
};

#endif
