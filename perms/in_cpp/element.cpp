#include "element.h"
#include <iostream>

// Constructor.
Element::Element(std::string name) : name(name) {
}

void Element::print(std::ostream& out) {
  out << name;
}
