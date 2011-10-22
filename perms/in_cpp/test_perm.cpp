#include "nil.h"
#include "element.h"
#include "cons.h"
#include "list_of_lists.h"

#include <iostream>

typedef std::tr1::shared_ptr<List> ListPtr;
typedef std::tr1::shared_ptr<ListOfLists> ListOfListsPtr;
typedef std::tr1::shared_ptr<Element> ElementPtr;

int main(int argc, char* argv[]) {
  ListPtr nil(new Nil());
  ElementPtr baz(new Element("baz"));
  ListPtr list_baz(new Cons(baz, nil));
  ElementPtr bar(new Element("bar"));
  ListPtr list_bar_baz(new Cons(bar, list_baz));
  ElementPtr foo(new Element("foo"));
  ListPtr list_foo_bar_baz(new Cons(foo, list_bar_baz));
  ListOfListsPtr perms(list_foo_bar_baz->perms());
  perms->print(std::cout);
  return 0;
}
