#include "list_of_lists.h"
#include "lol_nil.h"
#include "lol_cons.h"

std::tr1::shared_ptr<ListOfLists> ListOfLists::mzero() {
  std::tr1::shared_ptr<ListOfLists> answer(new LolNil());
  return answer;
}

std::tr1::shared_ptr<ListOfLists> ListOfLists::mreturn(std::tr1::shared_ptr<List> x) {
  std::tr1::shared_ptr<ListOfLists> terminator(new LolNil());
  std::tr1::shared_ptr<ListOfLists> answer(new LolCons(x, terminator));
  return answer;
}
