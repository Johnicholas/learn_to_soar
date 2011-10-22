#ifndef LOL_CONS_H
#define LOL_CONS_H

#include "list_of_lists.h"

class LolCons : public ListOfLists {
public:
  // Constructor
  LolCons(std::tr1::shared_ptr<List> x, std::tr1::shared_ptr<ListOfLists> xs);

  // From ListOfLists
  // bind(LolCons(?x, ?xs), ?f) == mplus(apply(?f, ?x), bind(?xs, ?f))
  std::tr1::shared_ptr<ListOfLists> bind(std::tr1::shared_ptr<Closure> f);

  // From ListOfLists
  // mplus(LolCons(?x, ?xs), ?ys) == LolCons(?x, mplus(?xs, ?ys))
  std::tr1::shared_ptr<ListOfLists> mplus(std::tr1::shared_ptr<ListOfLists> ys);

  void print(std::ostream& out);

private:
  std::tr1::shared_ptr<List> x;
  std::tr1::shared_ptr<ListOfLists> xs;
};

#endif





