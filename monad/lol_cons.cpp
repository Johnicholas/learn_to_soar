#include "lol_cons.h"
#include "closure.h"
#include "list.h"

// Constructor
LolCons::LolCons(std::tr1::shared_ptr<List> x, std::tr1::shared_ptr<ListOfLists> xs)
  : x(x),
    xs(xs)
{
}

std::tr1::shared_ptr<ListOfLists> LolCons::bind(std::tr1::shared_ptr<Closure> f) {
  std::tr1::shared_ptr<ListOfLists> first_half(f->apply(x));
  std::tr1::shared_ptr<ListOfLists> second_half(xs->bind(f));
  return first_half->mplus(second_half);
}

std::tr1::shared_ptr<ListOfLists> LolCons::mplus(std::tr1::shared_ptr<ListOfLists> ys) {
  std::tr1::shared_ptr<ListOfLists> recursive_result(xs->mplus(ys));
  std::tr1::shared_ptr<ListOfLists> answer(new LolCons(x, recursive_result));
  return answer;
}

void LolCons::print(std::ostream& out) {
  x->print(out);
  xs->print(out);
}
