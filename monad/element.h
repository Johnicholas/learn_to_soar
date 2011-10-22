#ifndef ELEMENT_H
#define ELEMENT_H

#include <string>
#include <iosfwd>

class Element {
 public:
  // Constructor.
  Element(std::string name);

  void print(std::ostream& out);

 private:
  std::string name;
};

#endif
