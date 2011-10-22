#include "cons.h"
#include "closure.h"
#include "list_of_lists.h"
#include "element.h"
#include <iostream>

// Constructor.
Cons::Cons(std::tr1::shared_ptr<Element> x, std::tr1::shared_ptr<List> xs)
  : x(x),
    xs(xs)
{
}

namespace { // anonymous

  // apply(InsertWithinHelper(?y), ?zs) == return(Cons(?y, ?zs))
  class InsertWithinCallback : public Closure {
  public:
    // Constructor
    explicit InsertWithinCallback(std::tr1::shared_ptr<Element> y) : y(y) {}
    
    // Closure
    std::tr1::shared_ptr<ListOfLists> apply(std::tr1::shared_ptr<List> zs) {
      std::tr1::shared_ptr<List> cons(new Cons(y, zs));
      return ListOfLists::mreturn(cons);
    }
  private:
    std::tr1::shared_ptr<Element> y;
  };

} // end of anonymous namespace

std::tr1::shared_ptr<ListOfLists> Cons::insertWithin(std::tr1::shared_ptr<Element> y) {
  std::tr1::shared_ptr<ListOfLists> recursive_result(insert(y, xs));
  std::tr1::shared_ptr<Closure> and_then(new InsertWithinCallback(x));
  return recursive_result->bind(and_then);
}

namespace { // anonymous

  // apply(BindCallback2, ?zs) == return(?zs)
  class BindCallback2 : public Closure {
  public:
    // Use the compiler-generated zero-argument constructor.
    
    // From Closure
    std::tr1::shared_ptr<ListOfLists> apply(std::tr1::shared_ptr<List> zs) {
      return ListOfLists::mreturn(zs);
    }
  };
  
  // apply(BindCallback1(?x), ?ys) == bind(insert(?x, ?ys), BindCallback2)
  class BindCallback1 : public Closure {
  public:
    // Constructor.
    explicit BindCallback1(std::tr1::shared_ptr<Element> x) : x(x) {}
    
    // From Closure.
    std::tr1::shared_ptr<ListOfLists> apply(std::tr1::shared_ptr<List> ys) {
      std::tr1::shared_ptr<Closure> step_three(new BindCallback2());
      return insert(x, ys)->bind(step_three);
    }
  private:
    std::tr1::shared_ptr<Element> x;
  };

} // end of anonymous namespace
  
std::tr1::shared_ptr<ListOfLists> Cons::perms() {
  std::tr1::shared_ptr<ListOfLists> rest_perms(xs->perms());
  std::tr1::shared_ptr<Closure> step_two(new BindCallback1(x));
  return rest_perms->bind(step_two);
}

void Cons::print(std::ostream& out) {
  x->print(out);
  out << " ";
  xs->print(out);
}

