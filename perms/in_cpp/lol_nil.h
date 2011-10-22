#ifndef LOL_NIL_H
#define LOL_NIL_H

#include "list_of_lists.h"

class LolNil : public ListOfLists {
public:
  // From ListOfLists
  // bind(LolNil, ?f) == LolNil
  std::tr1::shared_ptr<ListOfLists> bind(std::tr1::shared_ptr<Closure> f);

  // From ListOfLists
  // mplus(LolNil, ?ys) == ?ys
  std::tr1::shared_ptr<ListOfLists> mplus(std::tr1::shared_ptr<ListOfLists> ys);

  // From ListOfLists
  void print(std::ostream& out);

private:
  // nothing
};

#endif
