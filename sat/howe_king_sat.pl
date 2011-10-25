% this sat solver is taken completely from
% Howe and King's "A Pearl on Sat Solving in Prolog"

sat(Clauses, Vars) :-
  problem_setup(Clauses), elim_var(Vars).

elim_var([]).
elim_var([Var | Vars]) :-
  elim_var(Vars), assign(Var).

assign(t).
assign(f).

problem_setup([]).
problem_setup([Clause | Clauses]) :-
  clause_setup(Clause),
  problem_setup(Clauses).

clause_setup([Pol-Var | Pairs]) :-
  set_watch(Pairs, Var, Pol).


set_watch([], Var, Pol) :-
  Var = Pol.
set_watch([Pol2-Var2 | Pairs], Var1, Pol1) :-
  when(;(nonvar(Var1),nonvar(Var2)),watch(Var1, Pol1, Var2, Pol2, Pairs)).


watch(Var1, Pol1, Var2, Pol2, Pairs) :-
  nonvar(Var1) ->
    update_watch(Var1, Pol1, Var2, Pol2, Pairs);
    update_watch(Var2, Pol2, Var1, Pol1, Pairs).
update_watch(Var1, Pol1, Var2, Pol2, Pairs) :-
  Var1 == Pol1 -> true; set_watch(Pairs, Var2, Pol2).


