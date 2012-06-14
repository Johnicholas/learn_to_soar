// This is a simple calculator,
// useful as an example of an interpreter,
// based extremely loosely on Andrej Bauer's 'calc' in his PL Zoo.
//
// The language has a grammar:
//   an expression can be Numeral containing a primitive int
//   an expression can be Plus containing two expressions
//   an expression can be Minus containing two expressions
//   an expression can be Times containing two expressions
//   an expression can be Divide containing two expressions
//   an expression can be Negate contianing one expression
//
// There is another grammar for the cont:
//   a cont can be Halt
//   a cont can be PlusK1 of an exp and a cont
//   a cont can be PlusK2 of an int and a cont
//   a cont can be MinusK1 of an exp and a cont
//   a cont can be MinusK2 of an int and a cont
//   a cont can be TimesK1 of an exp and a cont
//   a cont can be TimesK2 of an int and a cont
//   a cont can be DivideK1 of an exp and a cont
//   a cont can be DivideK2 of an int and a cont
//
// This is "the same" interpreter, but it is converted into
// continuation passing style, which means that every recursive call
// is a tail call, and we manage an explicit continuation "stack",
// pushing a 'todo' reminder onto it whenever we would have done
// some sort of sequenced computation.
//
// Notice that, because every call is a tail call,
// we can manually do the tail-call optimization,
// replacing recursion with mutation.
// Now the body of the 'calc' function looks, if you squint,
// like a Soar decision cycle (the while(true) loop),
// with a pattern matching network (the ifelse tree),
// and operator applications (the assignments).
// It's recognizably a problem space with fifteen simple operators.
// Unfortunately, it is very flat - it no longer has the nice
// ragged-left-edge that we could chunk over.
//
// Aside: Since everything in this world (derived from the original
// term-rewriting implementation) is acyclic, we can stop leaking
// memory just by using reference counting.

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

class Halt : public Cont {
public:
Halt() {}
};

class PlusK1 : public Cont {
public:
  PlusK1(Exp* exp, Cont* cont) : exp(exp), cont(cont) {}
  Exp* exp;
  Cont* cont;
};

class PlusK2 : public Cont {
public:
  PlusK2(int v, Cont* cont) : v(v), cont(cont) {}
  int v;
  Cont* cont;
};

class MinusK1 : public Cont {
public:
  MinusK1(Exp* exp, Cont* cont) : exp(exp), cont(cont) {}
  Exp* exp;
  Cont* cont;
};

class MinusK2 : public Cont {
public:
  MinusK2(int v, Cont* cont) : v(v), cont(cont) {}
  int v;
  Cont* cont;
};

class TimesK1 : public Cont {
public:
  TimesK1(Exp* exp, Cont* cont) : exp(exp), cont(cont) {}
  Exp* exp;
  Cont* cont;
};

class TimesK2 : public Cont {
public:
  TimesK2(int v, Cont* cont) : v(v), cont(cont) {}
  int v;
  Cont* cont;
};

class DivideK1 : public Cont {
public:
  DivideK1(Exp* exp, Cont* cont) : exp(exp), cont(cont) {}
  Exp* exp;
  Cont* cont;
};

class DivideK2 : public Cont {
public:
  DivideK2(int v, Cont* cont) : v(v), cont(cont) {}
  int v;
  Cont* cont;
};

void print_indented(int indent, const char* to_print) {
  for (int i= 0; i < indent; ++i) {
    printf(" ");
  }
  printf("%s\n", to_print);
}

int run(Exp* initial_exp, int indent) {
  print_indented(indent, "run");
  indent += 1;
  Exp* exp = initial_exp;
  Cont* cont = new Halt();
  int* v = NULL;

  while (true) {
    if (dynamic_cast<Numeral*>(exp) and cont) {
      print_indented(indent, "run*numeral");
      Numeral* numeral = dynamic_cast<Numeral*>(exp);

      v = new int(numeral->n);
      exp = NULL;
    } else if(dynamic_cast<Plus*>(exp) and cont) {    
      print_indented(indent, "run*plus");
      Plus* plus = dynamic_cast<Plus*>(exp);

      cont = new PlusK1(plus->right, cont);
      exp = plus->left;
    } else if (dynamic_cast<Minus*>(exp) and cont) {
      print_indented(indent, "run*minus");
      Minus* minus = dynamic_cast<Minus*>(exp);

      cont = new MinusK1(minus->right, cont);
      exp = minus->left;
    } else if (dynamic_cast<Times*>(exp) and cont) {
      print_indented(indent, "run*times");
      Times* times = dynamic_cast<Times*>(exp);

      cont = new TimesK1(times->right, cont);
      exp = times->left;
    } else if (dynamic_cast<Divide*>(exp) and cont) {
      print_indented(indent, "run*divide");
      Divide* divide = dynamic_cast<Divide*>(exp);

      cont = new DivideK1(divide->right, cont);
      exp = divide->left;
    } else if (dynamic_cast<Negate*>(exp) and cont) {
      print_indented(indent, "run*negate");
      Negate* negate = dynamic_cast<Negate*>(exp);

      exp = new Minus(new Numeral(0), negate->exp);
    } else if (dynamic_cast<PlusK1*>(cont) and v) {
      print_indented(indent, "run*plusk1");
      PlusK1* plusk1 = dynamic_cast<PlusK1*>(cont);

      exp = plusk1->exp;
      cont = new PlusK2(*v, plusk1->cont);
      v = NULL;
    } else if (dynamic_cast<PlusK2*>(cont) and v) {
      print_indented(indent, "run*plusk2");
      PlusK2* plusk2 = dynamic_cast<PlusK2*>(cont);

      *v = plusk2->v + *v;
      cont = plusk2->cont;
    } else if (dynamic_cast<MinusK1*>(cont) and v) {
      print_indented(indent, "run*minusk1");
      MinusK1* minusk1 = dynamic_cast<MinusK1*>(cont);

      exp = minusk1->exp;
      cont = new MinusK2(*v, minusk1->cont);
      v = NULL;
    } else if (dynamic_cast<MinusK2*>(cont) and v) {
      print_indented(indent, "run*minusk2");
      MinusK2* minusk2 = dynamic_cast<MinusK2*>(cont);

      *v = minusk2->v - *v;
      cont = minusk2->cont;
    } else if (dynamic_cast<TimesK1*>(cont) and v) {
      print_indented(indent, "run*timesk1");
      TimesK1* timesk1 = dynamic_cast<TimesK1*>(cont);

      exp = timesk1->exp;
      cont = new TimesK2(*v, timesk1->cont);
      v = NULL;
    } else if (dynamic_cast<TimesK2*>(cont) and v) {
      print_indented(indent, "run*timesk2");
      TimesK2* timesk2 = dynamic_cast<TimesK2*>(cont);

      *v = timesk2->v * (*v);
      cont = timesk2->cont;
    } else if (dynamic_cast<DivideK1*>(cont) and v) {
      print_indented(indent, "run*dividek1");
      DivideK1* dividek1 = dynamic_cast<DivideK1*>(cont);

      exp = dividek1->exp;
      cont = new DivideK2(*v, dividek1->cont);
      v = NULL;
    } else if (dynamic_cast<DivideK2*>(cont) and v) {
      print_indented(indent, "run*dividek2");
      DivideK2* dividek2 = dynamic_cast<DivideK2*>(cont);

      *v = dividek2->v / *v;
      cont = dividek2->cont;
    } else if (dynamic_cast<Halt*>(cont) and v) {
      print_indented(indent, "run*halt");

      return *v;
    } else {
      assert(false);
    }
  }
}
      
int main(int argc, char* argv[]) {
  assert(run(new Plus(new Numeral(2), new Numeral(2)), 0) == 4);
  assert(run(new Times(new Numeral(3), new Numeral(3)), 0) == 9);
  assert(run(new Plus(new Negate(new Numeral(2)),
		      new Numeral(2)), 0) == 0);
  assert(run(new Times(new Negate(new Numeral(3)),
		       new Negate(new Numeral(3))), 0) == 9);
  assert(run(new Divide(new Negate(new Numeral(9)),
			new Negate(new Numeral(3))), 0) == 3);
  return 0;
}
