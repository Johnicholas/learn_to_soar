#include "lol_nil.h"

std::tr1::shared_ptr<ListOfLists> LolNil::bind(std::tr1::shared_ptr<Closure> f) {
  std::tr1::shared_ptr<ListOfLists> answer(new LolNil());
  return answer;
}

std::tr1::shared_ptr<ListOfLists> LolNil::mplus(std::tr1::shared_ptr<ListOfLists> ys) {
  return ys;
}

void LolNil::print(std::ostream& out) {
  // do nothing
}

