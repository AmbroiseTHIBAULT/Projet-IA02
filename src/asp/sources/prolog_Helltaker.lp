between(Min, Max, X):-
	X <= Max,
	X >= Min.

notIn(_,[]).
notIn(X,[H|T]):-
	X\=H,
	notIn(X,T).

remove(X, [X|T], T).
remove(X, [Y|T], [Y|L]) :-
	dif(X,Y),
	remove(X, T, L).

%Definition de la carte
/*case(X,Y):-
	between(2,3,X),
	between(3,3,Y).
case(X,Y):-
	between(4,6,X),
	between(2,4,Y).
case(X,Y):-
	between(5,6,X),
	between(5,5,Y).
case(X,Y):-
	between(2,2,X),
	between(5,6,Y).
case(X,Y):-
	between(4,6,X),
	between(6,6,Y).
case(X,Y):-
	between(2,7,X),
	between(7,8,Y).*/



%Etat inital
start(etat(perso(pos(1,1)), blocs([pos(2,2),pos(3,3)]), ennemis([pos(1,2),pos(2,3)]), pieges([]), porte([]), cle([]), partieNonFinie(int(15)))).

goal(pos(5,5)).

succ(left, pos(X0,Y), pos(X1,Y)):-
	case(X0,Y),
	case(X1,Y),
	X1 is X0-1.
succ(right, pos(X0,Y), pos(X1,Y)):-
	case(X0,Y),
	case(X1,Y),
	X1 is X0+1.
succ(down, pos(X,Y0), pos(X,Y1)):-
	case(X,Y0),
	case(X,Y1),
	Y1 is Y0-1.
succ(up, pos(X,Y0), pos(X,Y1)):-
	case(X,Y0),
	case(X,Y1),
	Y1 is Y0+1.

%Actions
do(action(move,D), etat(perso(X,Y),blocs(L_bloc),ennemis(L_enne),pieges(L_piege),porte(L_porte),cle(L_cle),partieNonFinie(int(N))),
	etat(perso(X1,Y1),blocs(L_bloc),ennemis(L_enne),pieges(L_piege),porte(L_porte),cle(L_cle),partieNonFinie(int(N1)))):-
		N1 is N-1.
		succ(D, pos(X,Y), pos(X1,Y1)),
		notIn(pos(X,Y1),L_bloc),
		notIn(pos(X,Y1),L_enne),
		notIn(pos(X,Y1),L_piege), 		%A reconsiderer si le piege alterne
		notIn(pos(X,Y1),L_porte).

do(action(move,D), etat(perso(X,Y),blocs(L_bloc),ennemis(L_enne),pieges(L_piege),porte(L_porte),cle(L_cle),partieNonFinie(int(N))),
	etat(perso(X1,Y1),blocs(L_bloc),ennemis(L_enne),pieges(L_piege),porte(L_porte),cle(L_cle1),partieNonFinie(int(N1)))):-
		N1 is N-1.
		succ(D, pos(X,Y), pos(X1,Y1)),		%trouve la cle -> cle et piege peuvent coexster?
		notIn(pos(X,Y1),L_bloc),
		notIn(pos(X,Y1),L_enne),
		notIn(pos(X,Y1),L_piege), 		%A reconsiderer si le piege alterne
		notIn(pos(X,Y1),L_porte),
		remove(pos(X1,Y1,L_cle,L_cle1).

do(action(move,D), etat(perso(X,Y),blocs(L_bloc),ennemis(L_enne),pieges(L_piege),porte(L_porte),cle([]),partieNonFinie(int(N))),
	etat(perso(X1,Y1),blocs(L_bloc),ennemis(L_enne),pieges(L_piege),porte(L_porte1),cle([]),partieNonFinie(int(N1)))):-
		N1 is N-1.
		succ(D, pos(X,Y), pos(X1,Y1)),		%ouvre la porte
		notIn(pos(X,Y1),L_bloc),
		notIn(pos(X,Y1),L_enne),
		notIn(pos(X,Y1),L_piege),
		remove(pos(X1,Y1),L_porte, L_porte1).

do(action(move,D), etat(perso(X,Y),blocs(L_bloc),ennemis(L_enne),pieges(L_piege),porte(L_porte),cle(L_cle),partieNonFinie(int(N))),
	etat(perso(X1,Y1),blocs(L_bloc),ennemis(L_enne),pieges(L_piege),porte(L_porte),cle(L_cle),partieNonFinie(int(N1)))):-
		N1 is N-2.				%le perso tombe dans un piege
		succ(D, pos(X,Y), pos(X1,Y1)),
		notIn(pos(X,Y1),L_bloc),
		notIn(pos(X,Y1),L_enne),
		notIn(pos(X,Y1),L_porte).

do(action(pushBloc,D), etat(perso(X,Y),blocs(L_bloc),ennemis(L_enne),pieges(L_piege),porte(L_porte),cle(L_cle)),
	etat(perso(X,Y),blocs(pos(X2,Y2)|L_bloc1),ennemis(L_enne),pieges(L_piege),porte(L_porte),cle(L_cle))):-
		succ(D, pos(X,Y), pos(X1,Y1)),
		succ(D, pos(X1,Y1), pos(X2,Y2)),
		notIn(pos(X2,Y2),L_bloc),
		notIn(pos(X2,Y2),L_enne),
		notIn(pos(X2,Y2),L_porte),
		remove(pos(X1,Y1), L_bloc, L_bloc1).

do(action(pushEnnemi,D), etat(perso(X,Y),blocs(L_bloc),ennemis(L_enne),pieges(L_piege),porte(L_porte),cle(L_cle)),
	etat(perso(X,Y),blocs(L_bloc),ennemis(pos(X2,Y2)|L_enne1),pieges(L_piege),porte(L_porte),cle(L_cle))):-
		succ(D, pos(X,Y), pos(X1,Y1)),
		succ(D, pos(X1,Y1), pos(X2,Y2)),
		notIn(pos(X2,Y2),L_bloc),
		notIn(pos(X2,Y2),L_enne),
		notIn(pos(X2,Y2),L_porte),
		remove(pos(X1,Y1), L_enne, L_enne1).

Action( pushBloc(direction(d),position(x,y)),
PRECOND: PartieNonFinie(int(n)) ∧ Perso(position(x,y)) ∧ Case(position(x1,y1)) ∧ (x1=succ(direction(d), x)) ∧ (y1=succ(direction(d), y)) ∧
Bloc(position(x1,y1)) ∧ ¬Ennemi(position(x1,y1)) ∧ ¬Porte(position(x1,y1)) ∧ ¬Piege(position(x1,y1)) ∧ Case(position(x2,y2)) ∧ (x=succ(direction(d), x1)) ∧ (y2=succ(direction(d), y1)) ∧ ¬Ennemi(position(x2,y2)) ∧ ¬Porte(position(x2,y2)) ∧ ¬Bloc(position(x2,y2))
EFFECT : PartieNonFinie(moinUn(int(n)) ∧ Bloc(position(x2,y2))


Action( pushEnnemi()
PRECOND: PartieNonFinie(int(n)) ∧ Perso(position(x,y))  ∧ Case(position(x1,y1)) ∧ (x1=succ(direction(d), x)) ∧ (y1=succ(direction(d), y)) ∧  Ennemi(position(x1,y1))¬Block(position(x1,y1)) ∧ ¬Porte(position(x1,y1)) ∧ ¬Piege(position(x1,y1))∧ Case(position(x2,y2)) ∧ (x=succ(direction(d), x1)) ∧ (y2=succ(direction(d), y1)) ∧ ¬Ennemi(position(x2,y2)) ∧ ¬Porte(position(x2,y2)) ∧ ¬Bloc(position(x2,y2))

EFFECT :  PartieNonFinie(moinUn(int(n)) ∧ Ennemi(position(x2,y2))


Action( killParBloc(direction(d),position(x,y)),
PRECOND: PartieNonFinie(int(n)) ∧ Perso(position(x,y)) ∧ Ennemi(position(x1,y1)) ∧ Bloc(position(x2,y2)) ∧
(x1=succ(direction(d), x)) ∧ (y1=succ(direction(d), y)) ∧
(x2=succ(direction(d), x1)) ∧ (y2=succ(direction(d), y1))

EFFECT : PartieNonFinie(moinUn(int(n)) ∧ ¬Ennemi(position(x1,y1))





Action( killParBord(direction(d),position(x,y)),
PRECOND: PartieNonFinie(int(n)) ∧ Perso(position(x,y)) ∧ Ennemi(position(x1,y1)) ∧ ¬Case(position(x2,y2)) ∧ (x1=succ(direction(d), x)) ∧ (y1=succ(direction(d), y)) ∧ (x2=succ(direction(d), x)) ∧ (y2=succ(direction(d), y)) ∧ ¬Bloc(position(x1,y1)) ∧ Ennemi(position(x1,y1))
EFFECT :  PartieNonFinie(moinUn(int(n)) ∧ ¬Ennemi(position(x1,y1))


Action(killParPiege(direction(d),position(x,y)),
PRECOND: PartieNonFinie(int(n)) ∧ Perso(position(x,y)) ∧ Ennemi(position(x1,y1)) ∧ Piege(position(x2,y2)) ∧
(x1=succ(direction(d), x)) ∧ (y1=succ(direction(d), y)) ∧
(x2=succ(direction(d), x1)) ∧ (y2=succ(direction(d), y1))
EFFECT : PartieNonFinie(moinUn(int(n)) ∧ ¬Ennemi(position(x1,y1))


Action( killParPiege2(position(x,y)),
PRECOND: PartieNonFinie(int(n))  ∧ Ennemi(position(x,y)) ∧ ¬Porte(position(x1,y1)) ∧ Piege(position(x,y))
EFFECT :  ¬Ennemi(position(x,y))


Action( Echec(),
PRECOND: PartieNonFinie(int(n)) ∧ (x=0)
EFFECT : ¬PartieNonFinie(int(x))






planValide([],[_],0).
planValide([A|AL], [S1,S2|EL],N):-
	N1 is N-1,
	do(A,S1,S2),
	planValide(AL, [S2|EL], N1).
