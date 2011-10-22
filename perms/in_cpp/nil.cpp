#include "nil.h"

#include "list_of_lists.h"
#include <iostream>

std::tr1::shared_ptr<ListOfLists> Nil::insertWithin(std::tr1::shared_ptr<Element> x) {
  return ListOfLists::mzero();
}

std::tr1::shared_ptr<ListOfLists> Nil::perms() {
  std::tr1::shared_ptr<List> nil(new Nil());
  return ListOfLists::mreturn(nil);
}

void Nil::print(std::ostream& out) {
  out << "\n";
}

