// This is a simple calculator,
// useful as an example of an interpreter,
// based extremely loosely on Andrej Bauer's 'calc' in his PL Zoo.
//
// I understand this is terrible C++ code,
// I understand it will leak memory continuously
// (unless we use something like Bohm conservative gc),
// I understand it is not good OO style.
// The point is to gesture at what this would look like in C,
// without actually writing enums and unions.
// 
// This continuation_calculator has manual tail-call
// optimization applied, which means (since it's 
// in continuation-passing style), that it's very flat.

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

class Cont {
protected:
  Cont() {}
public:
  virtual ~Cont() {}
};

class Plusk1 : public Cont {
public:
  Plusk1(Exp* exp, Cont* k) : exp(exp), k(k) {}
  Exp* exp;
  Cont* k;
};

class Plusk2 : public Cont {
public:
  Plusk2(int v, Cont* k) : v(v), k(k) {}
  int v;
  Cont* k;
};

class Minusk1 : public Cont {
public:
  Minusk1(Exp* exp, Cont* k) : exp(exp), k(k) {}
  Exp* exp;
  Cont* k;
};

class Minusk2 : public Cont {
public:
  Minusk2(int v, Cont* k) : v(v), k(k) {}
  int v;
  Cont* k;
};

class Timesk1 : public Cont {
public:
  Timesk1(Exp* exp, Cont* k) : exp(exp), k(k) {}
  Exp* exp;
  Cont* k;
};

class Timesk2 : public Cont {
public:
  Timesk2(int v, Cont* k) : v(v), k(k) {}
  int v;
  Cont* k;
};

class Dividek1 : public Cont {
public:
  Dividek1(Exp* exp, Cont* k) : exp(exp), k(k) {}
  Exp* exp;
  Cont* k;
};

class Dividek2 : public Cont {
public:
  Dividek2(int v, Cont* k) : v(v), k(k) {}
  int v;
  Cont* k;
};

class Halt : public Cont {
public:
  Halt() {}
};


void print_indented(int indent, const char* to_print) {
  for (int i= 0; i < indent; ++i) {
    printf("   ");
  }
  printf("(%s)\n", to_print);
}

int calc(Exp* initial_exp, int indent) {
  Exp* exp = initial_exp;
  Cont* k = new Halt();
  bool v_is_here = false;
  int v;
  print_indented(indent, "calc");

  while (true) {
    if (dynamic_cast<Numeral*>(exp) and k) {
      print_indented(indent+1, "numeral");
      v_is_here = true;
      v = dynamic_cast<Numeral*>(exp)->n;
      exp = NULL;
      continue;
    }

    if (dynamic_cast<Plus*>(exp) and k) {
      print_indented(indent+1, "plus");
      k = new Plusk1(dynamic_cast<Plus*>(exp)->right, k);
      exp = dynamic_cast<Plus*>(exp)->left;
      continue;
    }

    if (dynamic_cast<Minus*>(exp) and k) {
      print_indented(indent+1, "minus");
      k = new Minusk1(dynamic_cast<Minus*>(exp)->right, k);
      exp = dynamic_cast<Minus*>(exp)->left;
      continue;
    }

    if (dynamic_cast<Times*>(exp) and k) {
      print_indented(indent+1, "times");
      k = new Timesk1(dynamic_cast<Times*>(exp)->right, k);
      exp = dynamic_cast<Times*>(exp)->left;
      continue;
    }

    if (dynamic_cast<Divide*>(exp) and k) {
      print_indented(indent+1, "divide");
      k = new Dividek1(dynamic_cast<Divide*>(exp)->right, k);
      exp = dynamic_cast<Divide*>(exp)->left;
      continue;
    }

    if (dynamic_cast<Negate*>(exp) and k) {
      print_indented(indent+1, "negate");
      exp = new Minus(new Numeral(0), dynamic_cast<Negate*>(exp)->exp);
      continue;
    }

    if (dynamic_cast<Plusk1*>(k) and v_is_here) {
      print_indented(indent+1, "plusk1");
      exp = dynamic_cast<Plusk1*>(k)->exp;
      k = new Plusk2(v, dynamic_cast<Plusk1*>(k)->k);
      v_is_here = false;
      continue;
    }

    if (dynamic_cast<Plusk2*>(k) and v_is_here) {
      print_indented(indent+1, "plusk2");
      v = dynamic_cast<Plusk2*>(k)->v + v;
      k = dynamic_cast<Plusk2*>(k)->k;
      continue;
    }

    if (dynamic_cast<Minusk1*>(k) and v_is_here) {
      print_indented(indent+1, "minusk1");
      exp = dynamic_cast<Minusk1*>(k)->exp;
      k = new Minusk2(v, dynamic_cast<Minusk1*>(k)->k);
      v_is_here = false;
      continue;
    }

    if (dynamic_cast<Minusk2*>(k) and v_is_here) {
      print_indented(indent+1, "minusk2");
      v = dynamic_cast<Minusk2*>(k)->v - v;
      k = dynamic_cast<Minusk2*>(k)->k;
      continue;
    }

    if (dynamic_cast<Timesk1*>(k) and v_is_here) {
      print_indented(indent+1, "timesk1");
      exp = dynamic_cast<Timesk1*>(k)->exp;
      k = new Timesk2(v, dynamic_cast<Timesk1*>(k)->k);
      v_is_here = false;
      continue;
    }

    if (dynamic_cast<Timesk2*>(k) and v_is_here) {
      print_indented(indent+1, "timesk2");
      v = dynamic_cast<Timesk2*>(k)->v * v;
      k = dynamic_cast<Timesk2*>(k)->k;
      continue;
    }

    if (dynamic_cast<Dividek1*>(k) and v_is_here) {
      print_indented(indent+1, "dividek1");
      exp = dynamic_cast<Dividek1*>(k)->exp;
      k = new Dividek2(v, dynamic_cast<Dividek1*>(k)->k);
      v_is_here = false;
      continue;
    }

    if (dynamic_cast<Dividek2*>(k) and v_is_here) {
      print_indented(indent+1, "dividek2");
      v = dynamic_cast<Dividek2*>(k)->v / v;
      k = dynamic_cast<Dividek2*>(k)->k;
      continue;
    }

    if (dynamic_cast<Halt*>(k) and v_is_here) {
      print_indented(indent+1, "halt");
      return v;
    }
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
