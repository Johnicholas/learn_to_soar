#include "list.h"
#include "cons.h"
#include "list_of_lists.h"

std::tr1::shared_ptr<ListOfLists> insert(std::tr1::shared_ptr<Element> x, std::tr1::shared_ptr<List> xs) {
  std::tr1::shared_ptr<List> cons(new Cons(x, xs));
  std::tr1::shared_ptr<ListOfLists> lolcons(ListOfLists::mreturn(cons));
  std::tr1::shared_ptr<ListOfLists> lolrest(xs->insertWithin(x));
  return lolcons->mplus(lolrest);
}
