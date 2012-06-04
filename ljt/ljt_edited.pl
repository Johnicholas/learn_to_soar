% -*- Prolog -*-
% Intuitionistic theorem prover
% Written by Roy Dyckhoff, Summer 1991    
% Modified (badly) by Johnicholas Hines, Summer 2012

% note that the order of this predicate very much matters
prove( A, Out ) :- provable(A), !,
  Out = true.
prove( A, Out ) :- !, Out = false.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SYNTAX
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Use of LWB concrete syntax from June 97
% provided that one uses bracketmode "full"

:- op(425,  fy,  ~ ).
:- op(450, yfx,  & ).    % left associative
:- op(450, yfx,  v ).    % left associative
:- op(500, xfx,  <-> ).  % non associative
:- op(500, xfy,  ->).    % right associative  
                %%% WARNING, this overwrites Prolog's ->

% inspv(A, NewA) ensures that NewA has all the atoms with pv/1 as an 
% explicit constructor, making the clauses more deterministic
% it also eliminates definitions of <-> and ~.

inspv( A v B, A1 v B1) :- !, 
  inspv(A, A1), inspv(B, B1).
inspv( A & B, A1 & B1) :- !, 
  inspv(A, A1), inspv(B, B1).
inspv( A -> B, A1 -> B1) :- !, 
  inspv(A, A1), inspv(B, B1).
inspv( A<->B, (A1->B1)&(B1->A1) ) :- !,   % removes definition of <->
  inspv(A, A1), inspv(B, B1).
inspv( ~A , A1->false ) :- !,       % removes definitions of negation
  inspv(A, A1).
% true not an atom 
inspv( true, true ) :- !.           
% false not an atom 
inspv( false, false ) :- !.         

inspv( A, pv(A) ).                  % when all else fails 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% UTILITIES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% AtomImps is an ordered list PL of pairs (A,LA) where LA is a list
% and A is an atom
% lists PL are ordered by @< relation on first conponent
% LA is list of formulae B 
% No attempt to avoid repetition in LA.

% meaning( []) = true
% meaning( ( Pair | Rest|) = meaning( Pair) & meaning(Rest)
% meaning( (A,Bs) ) = A -> conjunction(Bs)

% extract( AtomImps, A,  Bs, RestImps)
% called with AtomImps and A known (an Atom); returns Bs and RestImps
% thus  meaning(AtomImps) ==  meaning(A->Bs) & meaning(RestImps)

% I'm not sure how this works if the query or ordered list isn't fully ground.
% I mean, I think it probably works if the Prolog people know what they're doing,
% and they do, but I don't know HOW it works.
% do you think the query or ordered list is fully ground in this case?
extract( [ ], _, OutBs, OutRestImps) :-
  OutBs = [],
  OutRestImps = [].

% still worth looking
extract( [ (A1, Bs1) | AtomImps ], A, OutBs, OutRestImps ) :-
  A @> A1,
  extract(AtomImps, A, Bs, RestImps),
  OutBs = Bs,
  OutRestImps = [ (A1, Bs1) | RestImps ].

% Found it
extract( [ (A, Bs) | RestImps ], A, OutBs, OutRestImps) :-
  OutBs = Bs,
  OutRestImps = RestImps.

% gone too far
% Not there, return empty list
extract( [ (A1, Bs), RestImps ], A, OutBs, OutAtomImps) :-
  A @< A1,                                    
  OutBs = [],
  OutAtomImps = [ (A1, Bs), RestImps ].

% insert( AtomImps, A -> B, AtomImps1)
% where A is an atom

insert( [], A -> B,  Out) :-
  Out = [ (A, [B]) ].

% Needs to go further in
insert( [ (A1, Bs1) | AtomImps ], A -> B, Out ) :-
   A @> A1,   
   insert(AtomImps, A -> B, AtomImps2),
   Out = [ (A1, Bs1) | AtomImps2 ].
% Here!
insert( [ (A, Bs) | AtomImps ], A -> B, Out ) :-
   Out = [ (A, [B | Bs ]) | AtomImps ].
% Needs to go before Pair
insert( [ Pair | AtomImps ], A -> B, Out ) :-
   Pair = (A1, _), 
   A @< A1,   
   Out = [(A, [B]), Pair | AtomImps].

% ===============================

% change this to switch heuristics off...
heuristics(on).  

order(  NestImps, _, _,  NestImps ) :- 
  heuristics(off). 

order(  NestImps, G, AtomImps,  NewNestImps ) :- 
  heuristics(on), 
  order0(  NestImps, G, AtomImps, [], NewNestImps).

order0( [], G, AtomImps, Bads, Bads1 ) :-
  order1(Bads, G, AtomImps, [], Bads1).

order0( [ A | In], G, AtomImps, Bads,  [ A | Out] ) :-
  good_for(A, G), 
  !, 
  order0( In, G, AtomImps, Bads , Out ).

order0( [ A | In], G, AtomImps, Bads,  Out ) :-
  % not so good_for(A, G),
  order0( In, G, AtomImps, [ A | Bads], Out ).

good_for(_ -> false, _).
good_for(_ -> G, G).


order1( [], _, _, NewBads, NewBads ).

order1( [ A | In], G, AtomImps, NewBads, [ A | Out] ) :-
  nice_for(A, G, AtomImps), 
  !,
  order1(In, G, AtomImps, NewBads, Out).

order1( [ A | In], G, AtomImps, NewBads,  Out ) :-
  % not so nice_for(A, G, AtomImps),
  order1( In, G, AtomImps, [ A | NewBads], Out ).

nice_for( _ -> pv(B) , G, AtomImps) :-
  on( (pv(B), Bs), AtomImps), 
  !, % no need to see if pv(B) is in NestImps in any other way
  (on( G, Bs); on(false, Bs)),
  !.

% ===============================

% select(List, Element, Remainder)
% ALL the backtracking is done here....

select( [X | L], X,  L).
select( [Y | L], X,  [Y | M]) :- 
  select(L,X, M).


on( A, [ A | _ ] ).
on( A, [ _ | Rest] ) :- on(A, Rest).

on1( A, L ) :-
   on(A, L),
  !.

on3( A, L, Res ) :-
  on1(A, L),
  !, 
  Res = true.
on3(_, _, false).
 
/*
append( [], L, L ).
append( [ H | T], L, [ H | TL] ) :-
	append(T, L, TL).

*/

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MAIN PROGRAM
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% ==============================
provable( A ) :-    
  inspv(A, A1), 
  redant1(A1 -> false, [], [], [], [], false),   % check classical provability
  redsucc(A1, [], [], []), !.

% ==============================
 

% AtomImps is a list as described above
% NestImps is a list of formulae of the form (C->D)->B
% where if B = false, then D=false
% Atoms is a list of atoms

redant( [ ], AtomImps, NestImps, Atoms,  G) :-
  redsucc(G, AtomImps, NestImps, Atoms).
redant( [ A | L], AtomImps, NestImps, Atoms, G) :-  
  redant1(A, L, AtomImps, NestImps, Atoms, G).

% ------------------------------

redant1(  pv(A), _, _, _, _, pv(A)  ).

redant1( pv(A),  L, AtomImps, NestImps, Atoms, G) :- 
   \+ G = pv(A) ,
  extract(AtomImps, pv(A), Bs, RestAtomImps), 
  append(Bs, L, BsL), 
  redant( BsL, RestAtomImps, NestImps, [pv(A)|Atoms], G ).

redant1( true, L, AtomImps, NestImps, Atoms, G ) :- 
  redant( L, AtomImps, NestImps, Atoms, G).

redant1( false, _, _, _, _, _ ).

redant1( A & B, L, AtomImps, NestImps, Atoms, G ) :- 
  redant1(A, [B | L], AtomImps, NestImps, Atoms, G).

redant1( A v B, L, AtomImps, NestImps, Atoms, G ) :- 
  redant1( A, L, AtomImps, NestImps, Atoms,  G),
  redant1( B, L, AtomImps, NestImps, Atoms,  G).

redant1( A -> B, L, AtomImps, NestImps, Atoms, G ) :-
  redantimp(A, B, L, AtomImps, NestImps, Atoms, G). 


% ------------------------------
% redantimp

redantimp( pv(A), B, L, AtomImps, NestImps, Atoms, G ) :-
  redantimpatom( pv(A), B, L, AtomImps, NestImps, Atoms, G).

redantimp( true, B, L, AtomImps, NestImps, Atoms, G ) :- 
  redant1(B, L, AtomImps, NestImps, Atoms, G).

redantimp( false, _, L, AtomImps, NestImps, Atoms, G ) :- 
  redant( L, AtomImps, NestImps, Atoms, G).

redantimp( C & D, B, L, AtomImps, NestImps, Atoms,  G ) :-  
  redantimp(C, (D -> B), L, AtomImps, NestImps, Atoms, G).

redantimp( C v D, B, L, AtomImps, NestImps, Atoms,  G ) :-
  redantimp(C, B, [ (D -> B) | L ], AtomImps, NestImps, Atoms, G).

redantimp( C -> D, B, L, AtomImps, NestImps, Atoms,  G ) :-
  redantimpimp( C, D, B, L, AtomImps, NestImps, Atoms, G).

% ------------------------------
% redantimpimp 

redantimpimp( C, false, false, L, AtomImps, NestImps, Atoms, G ) :- 
  redant(L, AtomImps, [ (C -> false) -> false | NestImps ], Atoms, G).

    % next clause exploits ~(C->D) eq  (~~C & ~D)
    % which isn't helpful when D = false

redantimpimp( C, D, false, L, AtomImps, NestImps, Atoms, G) :-
  \+(D = false),  
  redantimpimp( C, false, false,  [ D -> false | L] , AtomImps, NestImps, Atoms, G).

redantimpimp( C, D, B, L, AtomImps, NestImps, Atoms, G) :- 
  \+ (B = false), 
  redant(L, AtomImps, [ (C -> D) -> B | NestImps ], Atoms, G).

%-----------------------------------------------
%redantimpatom

redantimpatom( A, B, L, AtomImps, NestImps, Atoms, G ) :-
  on3(A, Atoms, Res), 
  redantimpatomres(Res,  A, B, L, AtomImps, NestImps, Atoms, G ).

redantimpatomres( true, _, B, L, AtomImps, NestImps, Atoms, G ) :- 
  % A is on Atoms: reduce using rule ->L1
  redant1(B, L, AtomImps, NestImps, Atoms, G).

redantimpatomres( false,  A, B, L, AtomImps, NestImps, Atoms, G ) :-
  % A is atom but not on Atoms, add A->B to AtomImps
  insert(AtomImps, A -> B, AtomImps1), 
  redant(L, AtomImps1, NestImps, Atoms, G).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% redsucc(Goal, AtomImps, NestImps, Atoms)

% All conjunctions or disjunctions on the left 
% have been reduced before 'redsucc' is called

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

redsucc( true, _, _, _  ).

redsucc( false, AtomImps, NestImps, Atoms ) :- 
     % we could now use a classical decision procedure, but 
     % present data structures are organised differently...
  inconsis( AtomImps, NestImps, Atoms).

redsucc( pv(A), AtomImps, NestImps, Atoms ) :- 
  on3(pv(A), Atoms,  Res),
  redsuccpv(Res,  pv(A), AtomImps, NestImps, Atoms).

redsuccpv( true, _, _, _, _ ).
redsuccpv(false,  pv(A), AtomImps, NestImps, Atoms ) :-
  posin(pv(A), AtomImps, NestImps),                     % MAJOR PRUNING HERE
  redsucc_choice( pv(A), AtomImps, NestImps, Atoms).

redsucc( A & B, AtomImps, NestImps, Atoms ) :- 
  redsucc(A, AtomImps, NestImps, Atoms),
  redsucc(B, AtomImps, NestImps, Atoms).

  % next clause deals with succedent (A v B) by pushing the
  % non-determinism into the treatment of implication on the left
  % note trick for creating a new variable

redsucc( A v B, AtomImps, NestImps, Atoms ) :- 
  P = pv( (AtomImps, NestImps, Atoms) ),
  redant( [ A -> P, B -> P ], AtomImps, NestImps, Atoms, P). 

redsucc( A -> B, AtomImps, NestImps, Atoms ) :-
  redant1(A, [], AtomImps, NestImps, Atoms, B).

%----------------------------------------

% Now we have the hard part; maybe lots of formulae 
% of form (C->D)->B  in Imps to choose from!
% Which one to take first? We need some heuristics:
% first we take those where the minor premiss is trivial;
% next we take those where B is an atom and B->G is in AtomImps
% next we try to choose B a disjunction (even if G isn't)
% finally we choose the others

redsucc_choice( G, AtomImps, NestImps, Atoms ) :- 
  order(NestImps, G, AtomImps,  OrdImps),
  select(OrdImps, ( (C->D) -> B), Rest),
  redant3(C, D, B, AtomImps, Rest, Atoms, G),
  !.  % MAIN CUT here

redant3( C, D, B, AtomImps, NestImps, Atoms, G ) :-
  redant1(D->B, [], AtomImps, NestImps, Atoms, C->D), %  Left Premiss
  !,  % CUT here; rule is semi-invertible
   redant1(B, [], AtomImps, NestImps, Atoms, G).            % Right Premiss

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Pruning utilities

posin( G, AtomImps, NestImps ) :-
  % G occurs strictly positively on LHS
  posin1( AtomImps, G ), 
  ! ;
  posin2( NestImps, G ). 

posin1( [ ( _, Bs ) | AtomImps ], G ) :-
  posin2( Bs, G ), 
  ! ; 
  posin1( AtomImps, G ).
  
posin2( [ B | Bs ], G ) :-
  posin3( B,G ), 
  ! ;
  posin2( Bs, G).

posin3( A v B,G ) :-
  posin3(A,G), 
  posin3(B,G).

posin3( A & B,G ) :-
  posin3(A,G), 
  ! ;
  posin3(B,G).

posin3( _ -> B, G ) :-
  posin3(B,G).
 
posin3( false, _ ).
posin3( G, G ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Classical ATP utility

% from now on, goal is always = false...

inconsis( AtomImps, [ (C->D)->B |  Rest], Atoms ) :-  
  inconsis1(B, AtomImps, Rest, Atoms, C, D).

inconsis1( false, AtomImps, NestImps, Atoms, C, _  ) :- 
    % _ = false by construction, so can be ignored.
    % uses ((( C -> false) -> false) -> false) eq (C -> false)
  redant1( C, [], AtomImps, NestImps, Atoms, false).  

inconsis1( B, AtomImps, NestImps, Atoms, C, D ) :- 
  \+ B = false,  % so can exploit ~((C->D)->B) eq  ~~(C->D) & ~B
  redantimpimp( C, D, false, [], AtomImps, NestImps, Atoms, false ), 
  redant1( B, [], AtomImps, NestImps, Atoms, false ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% END
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

 
   

