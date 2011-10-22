#ifndef CONS_H
#define CONS_H

#include "list.h"

class Cons : public List {
public:
  // Constructor.
  Cons(std::tr1::shared_ptr<Element> x, std::tr1::shared_ptr<List> xs);

  // From List
  // To insert an element definitely within (not at the front) of a list,
  // recurse, finding all the ways it can be put deep inside,
  // and then put the front element at the front.
  // insertWithin(Cons(?x, ?xs), ?y) == bind(insert(?y, ?xs), InsertWithinHelper(?x))
  std::tr1::shared_ptr<ListOfLists> insertWithin(std::tr1::shared_ptr<Element> y);

  // From List
  // perms(Cons(?x, ?xs)) == bind(perms(?xs), BindCallback1(?x))
  std::tr1::shared_ptr<ListOfLists> perms();

  // From List
  void print(std::ostream& out);

private:
  std::tr1::shared_ptr<Element> x;
  std::tr1::shared_ptr<List> xs;
};

#endif
