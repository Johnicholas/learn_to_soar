// This is a simple calculator,
// perhaps useful as an example of an interpreter,
// based on Andrej Bauer's 'calc' in is PL Zoo.
//
// I understand this is terrible C++ code,
// I understand it will leak memory all over
// (if we are not using something like Bohm's conservative gc),
// I understand that it is not good OO.
// That's not the point.
// The point is to gesture at what this would look like in C,
// without actually writing enums or unions.
// I can go very far into the realm of disgusting, but one
// has to draw the line somewhere for the sake of readability.
// This also illustrates the idea of writing,
// in mainstream languages,
// models of a Soar agent - not the Architecture+Agent,
// but just the agent that you're trying to build.
//
// You can generate output with the characteristic ragged left edge,
// and you can use code coverage tools to help design unit tests.

#include <cassert>
#include <cstdio>

class Exp {
protected:
  Exp() {}
public:
  virtual ~Exp() {}
};

class Numeral : public Exp {
public:
  Numeral(int n) : n(n) {}
  int n;
};

class Plus : public Exp {
public:
  Plus(Exp* left, Exp* right) : left(left), right(right) {}
  Exp* left;
  Exp* right;
};

class Minus : public Exp {
public:
  Minus(Exp* left, Exp* right) : left(left), right(right) {}
  Exp* left;
  Exp* right;
};

class Times : public Exp {
public:
  Times(Exp* left, Exp* right) : left(left), right(right) {}
  Exp* left;
  Exp* right;
};

class Divide : public Exp {
public:
  Divide(Exp* left, Exp* right) : left(left), right(right) {}
  Exp* left;
  Exp* right;
};

class Negate : public Exp {
public:
  Negate(Exp* exp) : exp(exp) {}
  Exp* exp;
};

void print_indented(int indent, const char* to_print) {
  for (int i= 0; i < indent; ++i) {
    printf("   ");
  }
  printf("(%s)\n", to_print);
}

int calc(Exp* exp, int indent) {
  print_indented(indent, "calc");
  if (dynamic_cast<Numeral*>(exp)) {
    print_indented(indent+1, "numeral");
    Numeral* numeral= dynamic_cast<Numeral*>(exp);
    return numeral->n;
  } else if (dynamic_cast<Plus*>(exp)) {
    print_indented(indent+1, "plus");
    Plus* plus= dynamic_cast<Plus*>(exp);
    int v1 = calc(plus->left, indent+2);
    // notice gap here
    int v2 = calc(plus->right, indent+2);
    return v1 + v2;
  } else if (dynamic_cast<Minus*>(exp)) {
    print_indented(indent+1, "minus");
    Minus* minus= dynamic_cast<Minus*>(exp);
    int v1 = calc(minus->left, indent+2);
    // notice gap here
    int v2 = calc(minus->right, indent+2);
    return v1 - v2;
  } else if (dynamic_cast<Times*>(exp)) {
    print_indented(indent+1, "times");
    Times* times= dynamic_cast<Times*>(exp);
    int v1 = calc(times->left, indent+2);
    // notice gap here
    int v2 = calc(times->right, indent+2);
    return v1 * v2;
  } else if (dynamic_cast<Divide*>(exp)) {
    print_indented(indent+1, "divide");
    Divide* divide= dynamic_cast<Divide*>(exp);
    int v1 = calc(divide->left, indent+2);
    // notice gap here
    int v2 = calc(divide->right, indent+2);
    return v1 / v2;
  } else if (dynamic_cast<Negate*>(exp)) {
    print_indented(indent+1, "negate");
    Negate* negate= dynamic_cast<Negate*>(exp);
    int v = calc(new Minus(new Numeral(0), negate->exp), indent+2);
    return v;
  } else {
    assert(false);
  }
}

int main(int argc, char* argv[]) {
  printf("test 1\n");
  assert(calc(new Plus(new Numeral(2), new Numeral(2)), 0) == 4);
  printf("test 2\n");
  assert(calc(new Times(new Numeral(3), new Numeral(3)), 0) == 9);
  printf("test 3\n");
  assert(calc(new Plus(new Negate(new Numeral(2)),
		       new Numeral(2)), 0) == 0);
  printf("test 4\n");
  assert(calc(new Times(new Negate(new Numeral(3)),
			new Negate(new Numeral(3))), 0) == 9);
  printf("test 5\n");
  assert(calc(new Divide(new Negate(new Numeral(3)),
			 new Negate(new Numeral(3))), 0) == 1);
  return 0;
}
