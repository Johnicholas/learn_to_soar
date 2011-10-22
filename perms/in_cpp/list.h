#ifndef LIST_H
#define LIST_H

#include <tr1/memory>
#include <iosfwd>

// forward declaration
class Element;
class ListOfLists;

// An interface.
class List {
public:
  virtual std::tr1::shared_ptr<ListOfLists> insertWithin(std::tr1::shared_ptr<Element>) = 0;
  virtual std::tr1::shared_ptr<ListOfLists> perms() = 0;

  virtual void print(std::ostream& out) = 0;

  // Destructor.
  virtual ~List() {}
protected:
  // Constructor.
  List() {}
};

std::tr1::shared_ptr<ListOfLists> insert(std::tr1::shared_ptr<Element> x, std::tr1::shared_ptr<List> xs);

#endif
