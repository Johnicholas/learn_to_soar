[ljt_edited].

prove(a -> a, Answer), !, Answer = true.

prove(a -> b -> a, Answer), !, Answer = true.

prove((a -> b -> c) -> (a -> b) -> (a -> c), Answer), !, Answer = true.

prove(true & ((p(1) <-> p(2)) -> p(1) & p(2) & p(3) & p(4) & p(5)) & ((p(2) <-> p(3)) -> p(1) & p(2) & p(3) & p(4) & p(5)) & ((p(3) <-> p(4)) -> p(1) & p(2) & p(3) & p(4) & p(5)) & ((p(4) <-> p(5)) -> p(1) & p(2) & p(3) & p(4) & p(5)) & ((p(5) <-> p(1)) -> p(1) & p(2) & p(3) & p(4) & p(5)) -> p(1) & p(2) & p(3) & p(4) & p(5), Answer), !, Answer = true.

prove(true & ((p(1) <-> p(2)) -> p(1) & p(2) & p(3) & p(4)) & ((p(2) <-> p(3)) -> p(1) & p(2) & p(3) & p(4)) & ((p(3) <-> p(4)) -> p(1) & p(2) & p(3) & p(4)) & ((p(4) <-> p(1)) -> p(1) & p(2) & p(3) & p(4)) -> p(0) v p(1) & p(2) & p(3) & p(4) v ~p(0), Answer), !, Answer = false.

prove((o(1, 1) v o(1, 2) v o(1, 3)) & (o(2, 1) v o(2, 2) v o(2, 3)) & (o(3, 1) v o(3, 2) v o(3, 3)) & (o(4, 1) v o(4, 2) v o(4, 3)) -> o(1, 1) & o(2, 1) v o(1, 1) & o(3, 1) v o(1, 1) & o(4, 1) v o(2, 1) & o(3, 1) v o(2, 1) & o(4, 1) v o(3, 1) & o(4, 1) v o(1, 2) & o(2, 2) v o(1, 2) & o(3, 2) v o(1, 2) & o(4, 2) v o(2, 2) & o(3, 2) v o(2, 2) & o(4, 2) v o(3, 2) & o(4, 2) v o(1, 3) & o(2, 3) v o(1, 3) & o(3, 3) v o(1, 3) & o(4, 3) v o(2, 3) & o(3, 3) v o(2, 3) & o(4, 3) v o(3, 3) & o(4, 3), Answer), !, Answer = false.

prove((o(1, 1) v ~ ~o(1, 2)) & (o(2, 1) v ~ ~o(2, 2)) & (o(3, 1) v ~ ~o(3, 2)) -> o(1, 1) & o(2, 1) v o(1, 1) & o(3, 1) v o(2, 1) & o(3, 1) v o(1, 2) & o(2, 2) v o(1, 2) & o(3, 2) v o(2, 2) & o(3, 2), Answer), !, Answer = false.

prove((p(1)&p(2)&p(3) v ((p(1)->f) v (p(2)->f) v (p(3)->f))->f)->f, Answer), !, Answer = true.
prove((p(1)&p(2)&p(3) v ((~ ~p(1)->f) v (p(2)->f) v (p(3)->f))->f)->f, Answer), !, Answer = false.

prove(p(3)&(p(1)->p(1)->p(0))&(p(2)->p(2)->p(1))&(p(3)->p(3)->p(2))->p(0), Answer), !, Answer = true.
prove(~ ~p(3) & (p(1)->p(1)->p(0))&(p(2)->p(2)->p(1))&(p(3)->p(3)->p(2))->p(0), Answer), !, Answer = false.

prove(((a(0) -> f) & ((b(3) -> b(0)) -> a(3)) & ((b(0) -> a(1)) -> a(0)) & ((b(1) -> a(2)) -> a(1)) & ((b(2) -> a(3)) -> a(2)) -> f)  &  (((b(2) -> a(3)) -> a(2)) & (((b(1) -> a(2)) -> a(1)) & (((b(0) -> a(1)) -> a(0)) & (((b(3) -> b(0)) -> a(3)) & (a(0) -> f)))) -> f), Answer), !, Answer = true.

prove((a(0) -> f) & ((~ ~b(3) -> b(0)) -> a(3)) & ((~ ~b(0) -> a(1)) -> a(0)) & ((~ ~b(1) -> a(2)) -> a(1)) & ((~ ~b(2) -> a(3)) -> a(2)) -> f, Answer), !, Answer = false.

prove(((a(1)<->a(2))<->a(3))<->(a(3)<->(a(2)<->a(1))), Answer), !, Answer = true.

prove(((~ ~a(1)<->a(2))<->a(3))<->(a(3)<->(a(2)<->a(1))), Answer), !, Answer = false.
