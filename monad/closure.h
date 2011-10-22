#ifndef CLOSURE_H
#define CLOSURE_H

#include <tr1/memory>

// An interface used by ListOfLists's bind
class Closure {
public:
  virtual std::tr1::shared_ptr<ListOfLists> apply(std::tr1::shared_ptr<List>) = 0;

  // Destructor.
  virtual ~Closure() {}
protected:
  // Constructor.
  Closure() {}
};

#endif
