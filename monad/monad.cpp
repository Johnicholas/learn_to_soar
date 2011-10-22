// This is based on an example in
// Fischer, Kisleyov, and Shan's "Purely Functional Lazy Non-deterministic Programming"

class Closure {
public:
  virtual ListOfLists apply(List) = 0;
  virtual ~Closure() {}
protected:
  Closure() {}
};

class List {
public:
  virtual ListOfLists insertWithin(Element x)= 0;
  virtual ListOfLists perm()= 0;

  // Destructor.
  virtual ~List() {}
protected:
  // Constructor.
  List() {}
};

// insert(?x, ?xs) == mplus(return(Cons(?x, ?xs)), insertWithin(?xs, ?x))
ListOfLists insert(Element x, List xs) {
  List cons = new Cons(x, xs);
  ListOfLists lolcons = mreturn(cons);
  ListOfLists lolrest = xs->insertWithin(x);
  return mplus(lolcons, lolrest);
}

class Nil : public List {
public:
  // From List.
  // You can't insert an element within an empty list; fail.
  // insertWithin(Nil, ?x) == mzero()
  ListOfLists insertWithin(Element x) {
    return mzero();
  }

  // From List.
  // There is only one permutation of the empty list - the empty list.
  // perm(Nil) == return(Nil)
  ListOfLists perm() {
    List nil= new Nil();
    return mreturn(nil);
  }

private:
  // nothing
};

class Cons : public List {
public:
  // Constructor.
  Cons(Element x, List xs) : x(x), xs(xs) {}

  // From List
  // To insert an element definitely within (not at the front) of a list,
  // recurse, finding all the ways it can be put deep inside,
  // and then put the front element at the front.
  // insertWithin(Cons(?x, ?xs), ?y) == bind(insert(?y, ?xs), InsertWithinHelper(?x))
  ListOfLists insertWithin(Element y) {
    ListOfLists recursive_result = insert(y, xs);

    // apply(InsertWithinHelper(?y), ?zs) == return(Cons(?y, ?zs))
    class InsertWithinCallback : public Closure {
    public:
      // Constructor
      explicit InsertWithinCallback(Element y) : y(y) {}
      
      // Closure
      ListOfLists apply(List zs) {
	List cons = new NonEmptyList(y, zs);
	return mreturn(cons);
      }
    private:
      Element y;
    } and_then;

    return recursive_result->bind(and_then);
  }

  // perm(Cons(?x, ?xs)) == bind(perm(?xs), BindCallback1(?x))
  ListOfLists perm() {

    // apply(BindCallback1(?x), ?ys) == bind(insert(?x, ?ys), BindCallback2)
    class BindCallback1 : public Closure {
    public:
      // Constructor.
      explicit BindCallback1(Element x) : x(x) {}
      
      // From Closure.
      ListOfLists apply(List ys) {

	// apply(BindCallback2, ?zs) == return(?zs)
	class BindCallback2 : public Closure {
	public:
	  // Use the compiler-generated zero-argument constructor.
	  
	  // From Closure
	  ListOfLists apply(List zs) {
	    return mreturn(zs);
	  }
	} step_three;

	return insert(x, ys)->bind(step_three);
      }
    private:
      Element x;
    } step_two;

    return xs.perm()->bind(step_two);
  }

private:
  Element x;
  List xs;
};

// An interface    
class ListOfLists {
public:
  // Factory Method.
  // mzero() == LolNil
  static ListOfLists mzero() {
    ListOfLists answer= new LolNil();
    return answer;
  }

  // Factory Method
  // mreturn(?x) == LolCons(?x, LolNil())
  static ListOfLists mreturn(List x) {
    ListOfLists terminator= new LolNil();
    ListOfLists answer= new LolCons(x, terminator);
    return answer;
  }

  virtual ListOfLists bind(Closure) = 0;

  virtual ListOfLists mplus(ListOfLists ys) = 0;

  // Destructor.
  virtual ~ListOfLists() {}
protected:
  // Constructor.
  ListOfLists() {}
};

class LolNil : public ListOfLists {
public:
  // From ListOfLists
  // bind(LolNil, ?f) == LolNil
  ListOfLists bind(Closure f) {
    ListOfLists answer= new LolNil();
    return answer;
  }

  // From ListOfLists
  // mplus(LolNil, ?ys) == ?ys
  ListOfLists mplus(ListOfLists ys) {
    return ys;
  }

private:
  // nothing
};

class LolCons : public ListOfLists {
public:
  // Constructor
  LolCons(List x, ListOfLists xs) : x(x), xs(xs) {}

  // From ListOfLists
  // bind(LolCons(?x, ?xs), ?f) == mplus(apply(?f, ?x), bind(?xs, ?f))
  ListOfLists bind(Closure f) {
    ListOfLists first_half = f->apply(x);
    ListOfLists second_half = xs->bind(f);
    return mplus(first_half, second_half);
  }

  // From ListOfLists
  // mplus(LolCons(?x, ?xs), ?ys) == LolCons(?x, mplus(?xs, ?ys))
  ListOfLists mplus(ListOfLists ys) {
    ListOfLists answer= new LolCons(x, xs->mplus(ys));
    return answer;
  }

private:
  List x;
  ListOfLists xs;
};




// here are the rules for the list monadplus


# a test
perm(Cons(foo, Cons(bar, Cons(baz, Nil))))


