// Based on validity.py which is copyright (c) Feb 2000, by Denys
// Duchier, Universitaet des Saarlandes
//
// Transliterated (badly) from Python to C++ by Johnicholas Hines,
// but with the two-continuation model changed to the one-continuation model.
// (The failure continuation is the C++ stack.)

#include <cassert>
#include <stdio.h>
#include <string>
using std::string;
#include <tr1/memory>
using std::tr1::shared_ptr;
using std::tr1::dynamic_pointer_cast;
#define DOWNCAST dynamic_pointer_cast

class Todo;
typedef shared_ptr<Todo> TodoPtr;
class Exp;
typedef shared_ptr<Exp> ExpPtr;
class Env;
typedef shared_ptr<Env> EnvPtr;

struct Todo {
  Todo(ExpPtr q, bool desired, TodoPtr todo)
  : q(q), desired(desired), todo(todo) {}
  ExpPtr q;
  bool desired;
  TodoPtr todo;
};

struct Env {
  Env(string name, bool value, EnvPtr env)
  : name(name), value(value), env(env) {}
  string name;
  bool value;
  EnvPtr env;
};

struct Exp {
  virtual ~Exp() {}
};

struct And : public Exp {
 And(ExpPtr p, ExpPtr q) : p(p), q(q) {}
  ExpPtr p;
  ExpPtr q;
};

struct Or : public Exp {
  Or(ExpPtr p, ExpPtr q) : p(p), q(q) {}
  ExpPtr p;
  ExpPtr q;
};

struct Not : public Exp {
  Not(ExpPtr p) : p(p) {}
  ExpPtr p;
};

struct Var : public Exp {
  Var (string name) : name(name) {}
  string name;
};

EnvPtr go(ExpPtr initial_exp,
	  EnvPtr initial_env,
	  TodoPtr initial_todo,
	  bool initial_desired) {
  EnvPtr env = initial_env;
  ExpPtr exp = initial_exp;
  TodoPtr todo = initial_todo;
  bool desired = initial_desired;
  string name = "";
  EnvPtr env_iterator;
  
  while (true) {
    if (name != "") {
      if (env_iterator) {
	if (name == env_iterator->name) {
	  if (env_iterator->value == desired) {
	    printf("%s %d\n", __PRETTY_FUNCTION__, __LINE__);
	    name = "";
	  } else {
	    printf("%s %d\n", __PRETTY_FUNCTION__, __LINE__);
	    return EnvPtr();
	  }
	} else {
	  printf("%s %d\n", __PRETTY_FUNCTION__, __LINE__);
	  env_iterator = env_iterator->env;
	}
      } else {
	printf("%s %d\n", __PRETTY_FUNCTION__, __LINE__);
	EnvPtr new_env(new Env(name, desired, env));
	env = new_env;
	name = "";
      }
    }

    if (exp != NULL) {
      if (DOWNCAST<And>(exp)) {
	if (desired) {
	    printf("%s %d\n", __PRETTY_FUNCTION__, __LINE__);
	  todo = TodoPtr(new Todo(DOWNCAST<And>(exp)->q, desired, todo));
	  exp = DOWNCAST<And>(exp)->p;
	} else {
	  printf("%s %d\n", __PRETTY_FUNCTION__, __LINE__);
	  EnvPtr temp = go(DOWNCAST<And>(exp)->p, env, todo, desired);
	  if (temp) {
	    printf("%s %d\n", __PRETTY_FUNCTION__, __LINE__);
	    return temp;
	  } else {
	    printf("%s %d\n", __PRETTY_FUNCTION__, __LINE__);
	    exp = DOWNCAST<And>(exp)->q;
	  }
	}
      } else if (DOWNCAST<Or>(exp)) {
	if (desired) {
	  printf("%s %d\n", __PRETTY_FUNCTION__, __LINE__);
	  EnvPtr temp = go(DOWNCAST<Or>(exp)->p, env, todo, desired);
	  if (temp) {
	    printf("%s %d\n", __PRETTY_FUNCTION__, __LINE__);
	    return temp;
	  } else {
	    printf("%s %d\n", __PRETTY_FUNCTION__, __LINE__);
	    exp = DOWNCAST<Or>(exp)->q;
	  }
	} else {
	  printf("%s %d\n", __PRETTY_FUNCTION__, __LINE__);
	  todo = TodoPtr(new Todo(DOWNCAST<Or>(exp)->q, desired, todo));
	  exp = DOWNCAST<Or>(exp)->p;
	}
      } else if (DOWNCAST<Not>(exp)) {
	    printf("%s %d\n", __PRETTY_FUNCTION__, __LINE__);
	exp = DOWNCAST<Not>(exp)->p;
	if (desired) {
	  printf("%s %d\n", __PRETTY_FUNCTION__, __LINE__);
	  desired = false;
	} else {
	  printf("%s %d\n", __PRETTY_FUNCTION__, __LINE__);
	  desired = true;
	}
      } else if (DOWNCAST<Var>(exp)) {
	printf("%s %d\n", __PRETTY_FUNCTION__, __LINE__);
	name = DOWNCAST<Var>(exp)->name;
	env_iterator = env;
	exp = ExpPtr();
      } else {
	assert(false);
      }
    }

    if (name == "" and exp == NULL) {
      if (todo) {
	printf("%s %d\n", __PRETTY_FUNCTION__, __LINE__);
	exp = todo->q;
	desired = todo->desired;
	todo = todo->todo;
      } else {
	printf("%s %d\n", __PRETTY_FUNCTION__, __LINE__);
	return env;
      }
    }
  }
}

EnvPtr isvalid(ExpPtr exp) {
  assert(exp);
  return go(exp, EnvPtr(), TodoPtr(), false);
}

void print(EnvPtr to_print) {
  if (to_print) {
    printf("no: ");
    EnvPtr i;
    for (i= to_print; i; i= i->env) {
      printf("%s=%s ", i->name.c_str(), i->value?"t":"f");
    }
  } else {
    printf("yes");
  }
}

void print(ExpPtr to_print) {
  if (DOWNCAST<And>(to_print)) {
    printf("AND(");
    print(DOWNCAST<And>(to_print)->p);
    printf(", ");
    print(DOWNCAST<And>(to_print)->q);
    printf(")");
  } else if (DOWNCAST<Or>(to_print)) {
    printf("OR(");
    print(DOWNCAST<Or>(to_print)->p);
    printf(", ");
    print(DOWNCAST<Or>(to_print)->q);
    printf(")");
  } else if (DOWNCAST<Not>(to_print)) {
    printf("NOT(");
    print(DOWNCAST<Not>(to_print)->p);
    printf(")");
  } else if (DOWNCAST<Var>(to_print)) {
    printf("VAR(\"%s\")", DOWNCAST<Var>(to_print)->name.c_str());
  } else {
    assert(0);
  }
}

//////////////////////////////////////////////////////////////// End of library

#include <stdio.h>

bool test(ExpPtr to_test) {
  print(to_test);
  printf("\n");
  EnvPtr witness = isvalid(to_test);
  bool answer = not witness;
  print(witness);
  printf("\n");
  return answer;
}

// NOTE: using temporary shared_ptrs like this is NOT EXCEPTION-SAFE!
#define VAR(x) ExpPtr(new Var(x))
#define AND(p, q) ExpPtr(new And(p, q))
#define OR(p, q) ExpPtr(new Or(p, q))
#define NOT(p) ExpPtr(new Not(p))

int main(int argc, char* argv[]) {
  /*
  assert(test(VAR("p")) == false);
  printf("\n");
  assert(test(AND(VAR("p"), VAR("p"))) == false);
  printf("\n");
  assert(test(AND(VAR("p"), VAR("q"))) == false);
  printf("\n");
  assert(test(OR(VAR("p"), VAR("p"))) == false);
  printf("\n");
  assert(test(OR(VAR("p"), VAR("q"))) == false);
  printf("\n");
  */
  assert(test(OR(NOT(VAR("p")), VAR("q"))) == false);
  printf("\n");
  /*
  assert(test(OR(NOT(VAR("p")), VAR("p"))) == true);
  printf("\n");
  assert(test(OR(NOT(OR(VAR("p"), VAR("q"))),
		 OR(NOT(AND(OR(NOT(VAR("p")),
			       VAR("r")),
			    OR(NOT(VAR("q")),
			       VAR("r")))),
		    VAR("r")))) == true);
  printf("\n");
  assert(test(OR(NOT(OR(VAR("x"), VAR("q"))),
		 OR(NOT(AND(OR(NOT(VAR("p")),
			       VAR("r")),
			    OR(NOT(VAR("q")),
			       VAR("r")))),
		    VAR("r"
			))))
	 == false);
  printf("\n");
  assert(test(OR(NOT(OR(VAR("p"), VAR("x"))),
		 OR(NOT(AND(OR(NOT(VAR("p")),
			       VAR("r")),
			    OR(NOT(VAR("q")),
			       VAR("r")))),
		    VAR("r")))) == false);
  printf("\n");
  assert(test(OR(NOT(OR(VAR("p"), VAR("q"))),
		 OR(NOT(AND(OR(NOT(VAR("x")),
			       VAR("r")),
			    OR(NOT(VAR("q")),
			       VAR("r")))),

		    VAR("r")))) == false);
  printf("\n");
  assert(test(OR(NOT(OR(VAR("p"), VAR("q"))),
		 OR(NOT(AND(OR(NOT(VAR("p")),
			       VAR("x")),
			    OR(NOT(VAR("q")),
			       VAR("r")))),
		    VAR("r")))) == false);
  printf("\n");
  assert(test(OR(NOT(OR(VAR("p"), VAR("q"))),
		 OR(NOT(AND(OR(NOT(VAR("p")),
			       VAR("r")),
			    OR(NOT(VAR("x")),
			       VAR("r")))),
		    VAR("r")))) == false);
  printf("\n");
  assert(test(OR(NOT(OR(VAR("p"), VAR("q"))),
		 OR(NOT(AND(OR(NOT(VAR("p")),
			       VAR("r")),
			    OR(NOT(VAR("q")),
			       VAR("x")))),
		    VAR("r")))) == false);
  printf("\n");
  assert(test(OR(NOT(OR(VAR("p"), VAR("q"))),
		 OR(NOT(AND(OR(NOT(VAR("p")),
			       VAR("r")),
			    OR(NOT(VAR("q")),
			       VAR("r")))),
		    VAR("x")))) == false);
  */
  return 0;
}
