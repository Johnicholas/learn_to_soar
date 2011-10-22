#ifndef LIST_OF_LISTS_H
#define LIST_OF_LISTS_H

#include <tr1/memory>
#include <iosfwd>

// forward declaration
class List;
class Closure;

// An interface    
class ListOfLists {
public:
  // Factory Method.
  // mzero() == LolNil
  static std::tr1::shared_ptr<ListOfLists> mzero();

  // Factory Method
  // mreturn(?x) == LolCons(?x, LolNil())
  static std::tr1::shared_ptr<ListOfLists> mreturn(std::tr1::shared_ptr<List> x);

  virtual std::tr1::shared_ptr<ListOfLists> bind(std::tr1::shared_ptr<Closure>) = 0;

  virtual std::tr1::shared_ptr<ListOfLists> mplus(std::tr1::shared_ptr<ListOfLists> ys) = 0;

  virtual void print(std::ostream& out) = 0;

  // Destructor.
  virtual ~ListOfLists() {}
protected:
  // Constructor.
  ListOfLists() {}
};

#endif
