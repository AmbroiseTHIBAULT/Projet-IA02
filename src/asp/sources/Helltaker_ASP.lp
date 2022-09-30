%%%Informations temporaries pour test
%% clingo -c horizon=10 -n0 Helltaker_ASP.lp
%%-n0 pour tous les modeles

% la taille du monde

%#const n = 6.
 
#const n = 10.


% pour la gestion de l'horizon
%step(0..horizon-1).

% l'environnement : un couloir dans un univers 2D
%cell(0..n-1, 0).

%%% l'init

%init(perso(1, 0)).
%init(block(0, 0)).
%init(block(2, 0)).
=======
init(perso(1, 0)).
init(block(0, 0)).
init(block(2, 0)).
init(ennemy(5,0)).
init(key(6,0)).
init(door(7,0)).
init(trap(8,0)).

%Si tous les pièges alternent
fluent(trap(X,Y),T + 1):-
    removed(trap(X,Y)T).

removed(piege(X,Y),T + 1):-
    fluent(trap(X,Y),T).

%puis soit init(trap(x_concret,y_concret)) si le piège commence activé, soit removed(trap(x_concret,y_concret)) si'il commence desactivé

%S'il y en a qui alternent et autres non, il faut faire une paire de ces règles pour chaque piège en remplaçant X, et Y par des valeurs concrètes pour ceux qui changent
%Ex: fluent(trap(5,3),T + 1):-  ...



%fluent(F, 0) :- init(F).

%%% la gestion du but
%goal(perso(3, 0)).




%problemes: kill_with_trap

%%%Règles générales
%les actions admises
action(left; right; up; down; pickup_key;
   open_door_left; open_door_right; open_door_up; open_door_down;
   turn_loss_trap;
   turn_loss_door_left; turn_loss_door_right; turn_loss_door_up; turn_loss_door_down;
   turn_loss_block_block_left; turn_loss_block_block_right; turn_loss_block_block_up; turn_loss_block_block_down;
   turn_loss_block_ennemy_left; turn_loss_block_ennemy_right; turn_loss_block_ennemy_up; turn_loss_block_ennemy_down;
   turn_loss_block_door_left; turn_loss_block_door_right; turn_loss_block_door_up; turn_loss_block_door_down;
   turn_loss_block_edge_left; turn_loss_block_edge_right; turn_loss_block_edge_up; turn_loss_block_edge_down;
   push_block_left; push_block_right; push_block_up; push_block_down;
   push_ennemy_left; push_ennemy_right; push_ennemy_up; push_ennemy_down;
   kill_with_block_left; kill_with_block_right; kill_with_block_up; kill_with_block_down;
   kill_with_edge_left; kill_with_edge_right; kill_with_edge_up; kill_with_edge_down;
   kill_with_ennemy_left; kill_with_ennemy_right; kill_with_ennemy_up; kill_with_ennemy_down;
   %kill_with_trap;
   kill_with_door_left; kill_with_door_right; kill_with_door_up; kill_with_door_down;
   nop).

achieved(T) :- fluent(F, T), goal(F).

:- achieved(T), T > horizon. % on doit finir avant l'horizon
:- not achieved(_). % on doit finir
:- achieved(T), do(Act, T), Act != nop. % la seule action possible une fois qu'on a fini : nop
:- do(nop, T), not achieved(T). % mais on ne peut faire nop qu'une fois qu'on a fini

%%% générateur d'actions..
{ do(Act, T): action(Act) } = 1 :- step(T).

%%% les actions
%%  action left
% préconditions
:-  do(left, T),
    fluent(perso(X, Y), T),
    not cell(X - 1, Y).

:-  do(left, T),
    fluent(perso(X, Y), T),
    fluent(block(X - 1, Y), T).

:-  do(left, T),
    fluent(perso(X, Y), T),
    fluent(ennemy(X - 1, Y), T).

:-  do(left, T),
    fluent(perso(X, Y), T),
    fluent(door(X - 1, Y), T).

% effets
fluent(perso(X - 1, Y), T + 1) :-
    do(left, T),
    fluent(perso(X, Y), T).

removed(perso(X, Y), T) :-
    do(left, T),
    fluent(perso(X, Y), T).

%% action right
% préconditions
:-  do(right, T),
    fluent(perso(X, Y), T),
    not cell(X + 1, Y).

:-  do(right, T),
    fluent(perso(X, Y), T),
    fluent(block(X + 1, Y), T).

:-  do(right, T),
    fluent(perso(X, Y), T),
    fluent(ennemy(X + 1, Y), T).

:-  do(right, T),
    fluent(perso(X, Y), T),
    fluent(door(X + 1, Y), T).

% effets
fluent(perso(X + 1, Y), T + 1) :-
    do(right, T),
    fluent(perso(X, Y), T).

removed(perso(X, Y), T) :-
    do(right, T),
    fluent(perso(X, Y), T).

%% action up
% préconditions
:-  do(up, T),
    fluent(perso(X, Y), T),
    not cell(X, Y + 1).

:-  do(up, T),
    fluent(perso(X, Y), T),
    fluent(block(X, Y + 1), T).

:-  do(up, T),
    fluent(perso(X, Y), T),
    fluent(ennemy(X, Y + 1), T).

:-  do(up, T),
    fluent(perso(X, Y), T),
    fluent(door(X, Y + 1), T).

% effets
fluent(perso(X, Y + 1), T + 1) :-
    do(up, T),
    fluent(perso(X, Y), T).

removed(perso(X, Y), T) :-
    do(up, T),
    fluent(perso(X, Y), T).

%% action down
% préconditions
:-  do(down, T),
    fluent(perso(X, Y), T),
    not cell(X, Y - 1).

:-  do(down, T),
    fluent(perso(X, Y), T),
    fluent(block(X, Y - 1), T).

:-  do(down, T),
    fluent(perso(X, Y), T),
    fluent(ennemy(X, Y - 1), T).

:-  do(down, T),
    fluent(perso(X, Y), T),
    fluent(door(X, Y - 1), T).

% effets
fluent(perso(X, Y - 1), T + 1) :-
    do(down, T),
    fluent(perso(X, Y), T).

removed(perso(X, Y), T) :-
    do(down, T),
    fluent(perso(X, Y), T).

%% action pickup_key
% préconditions
:-  do(pickup_key, T),
    fluent(perso(X, Y), T),
    not fluent(key(X, Y),T).

:-  do(pickup_key, T),
    fluent(perso(X, Y), T),
    fluent(block(X, Y), T).

:-  do(pickup_key, T),
    fluent(perso(X, Y), T),
    fluent(ennemy(X, Y), T).

% effets
removed(key(X, Y), T) :-
    do(pickup_key, T),
    fluent(perso(X, Y), T).

%%  action open_door_left
% préconditions
:-  do(open_door_left, T),
    fluent(perso(X, Y), T),
    not fluent(door(X - 1, Y), T).

:-  do(open_door_left, T),
    fluent(perso(X, Y), T),
    fluent(key(_, _), T).

% effets
fluent(perso(X - 1, Y), T + 1) :-
    do(open_door_left, T),
    fluent(perso(X, Y), T).

removed(perso(X, Y), T) :-
    do(open_door_left, T),
    fluent(perso(X, Y), T).

removed(door(X - 1, Y), T) :-
    do(open_door_left, T),
    fluent(perso(X, Y), T).

%%  action open_door_right
% précondition
:-  do(open_door_right, T),
    fluent(perso(X, Y), T),
    not fluent(door(X + 1, Y), T).

:-  do(open_door_right, T),
    fluent(perso(X, Y), T),
    fluent(key(_, _), T).

% effets
fluent(perso(X + 1, Y), T + 1) :-
    do(open_door_right, T),
    fluent(perso(X, Y), T).

removed(perso(X, Y), T) :-
    do(open_door_right, T),
    fluent(perso(X, Y), T).

removed(door(X + 1, Y), T) :-
    do(open_door_right, T),
    fluent(perso(X, Y), T).

%%  action open_door_up
% précondition
:-  do(open_door_up, T),
    fluent(perso(X, Y), T),
    not fluent(door(X, Y + 1), T).

:-  do(open_door_up, T),
    fluent(perso(X, Y), T),
    fluent(key(_, _), T).

% effets
fluent(perso(X, Y + 1), T + 1) :-
    do(open_door_up, T),
    fluent(perso(X, Y), T).

removed(perso(X, Y), T) :-
    do(open_door_up, T),
    fluent(perso(X, Y), T).

removed(door(X, Y + 1), T) :-
    do(open_door_up, T),
    fluent(perso(X, Y), T).

%%  action open_door_down
% précondition
:-  do(open_door_down, T),
    fluent(perso(X, Y), T),
    not fluent(door(X, Y - 1), T).

:-  do(open_door_down, T),
    fluent(perso(X, Y), T),
    fluent(key(_, _), T).

% effets
fluent(perso(X, Y - 1), T + 1) :-
    do(open_door_down, T),
    fluent(perso(X, Y), T).

removed(perso(X, Y), T) :-
    do(open_door_down, T),
    fluent(perso(X, Y), T).

removed(door(X, Y - 1), T) :-
    do(open_door_down, T),
    fluent(perso(X, Y), T).

%%  action turn_loss_trap
% préconditions
:-  do(turn_loss_trap, T),
    fluent(perso(X, Y), T),
    not fluent(trap(X, Y), T).

% effets
fluent(perso(X, Y), T + 1) :-
    do(turn_loss_trap, T),
    fluent(perso(X, Y), T).

removed(perso(X, Y), T) :-
    do(turn_loss_trap, T),
    fluent(perso(X, Y), T).

%%  action turn_loss_door_left
% préconditions
:-  do(turn_loss_door_left, T),
    fluent(perso(X, Y), T),
    not fluent(door(X - 1, Y),T).

:-  do(turn_loss_door_left, T),
    fluent(perso(X, Y), T),
    not fluent(key(_,_),T).

% effets
fluent(perso(X, Y), T + 1) :-
    do(turn_loss_door_left, T),
    fluent(perso(X, Y), T),
    fluent(door(X - 1, Y), T),
    fluent(key(_,_), T).

removed(perso(X, Y), T) :-
    do(turn_loss_door_left, T),
    fluent(perso(X, Y), T),
    fluent(door(X - 1, Y), T),
    fluent(key(_,_), T).

%%  action turn_loss_door_right
% préconditions
:-  do(turn_loss_door_right, T),
    fluent(perso(X, Y), T),
    not fluent(door(X + 1, Y),T).

:-  do(turn_loss_door_right, T),
    fluent(perso(X, Y), T),
    not fluent(key(_,_),T).

% effets
fluent(perso(X, Y), T + 1) :-
    do(turn_loss_door_right, T),
    fluent(perso(X, Y), T),
    fluent(door(X + 1, Y), T),
    fluent(key(_,_), T).

removed(perso(X, Y), T) :-
    do(turn_loss_door_right, T),
    fluent(perso(X, Y), T),
    fluent(door(X + 1, Y), T),
    fluent(key(_,_), T).

%%  action turn_loss_door_up
% préconditions
:-  do(turn_loss_door_up, T),
    fluent(perso(X, Y), T),
    not fluent(door(X, Y + 1),T).

:-  do(turn_loss_door_up, T),
    fluent(perso(X, Y), T),
    not fluent(key(_,_),T).

% effets
fluent(perso(X, Y), T + 1) :-
    do(turn_loss_door_up, T),
    fluent(perso(X, Y), T),
    fluent(door(X, Y + 1), T),
    fluent(key(_,_), T).

removed(perso(X, Y), T) :-
    do(turn_loss_door_up, T),
    fluent(perso(X, Y), T),
    fluent(door(X, Y + 1), T),
    fluent(key(_,_), T).

%%  action turn_loss_door_down
% préconditions
:-  do(turn_loss_door_down, T),
    fluent(perso(X, Y), T),
    not fluent(door(X, Y - 1),T).

:-  do(turn_loss_door_down, T),
    fluent(perso(X, Y), T),
    not fluent(key(_,_),T).

% effets
fluent(perso(X, Y), T + 1) :-
    do(turn_loss_door_down, T),
    fluent(perso(X, Y), T),
    fluent(door(X, Y - 1), T),
    fluent(key(_,_), T).

removed(perso(X, Y), T) :-
    do(turn_loss_door_down, T),
    fluent(perso(X, Y), T),
    fluent(door(X, Y - 1), T),
    fluent(key(_,_), T).

%%  action turn_loss_block_block_left
% préconditions
:-  do(turn_loss_block_block_left, T),
    fluent(perso(X, Y), T),
    not fluent(block(X - 1, Y),T).

:-  do(turn_loss_block_block_left, T),
    fluent(perso(X, Y), T),
    not fluent(block(X - 2,Y),T).

% effets
fluent(perso(X, Y), T + 1) :-
    do(turn_loss_block_block_left, T),
    fluent(perso(X, Y), T).

removed(perso(X, Y), T) :-
    do(turn_loss_block_block_left, T),
    fluent(perso(X, Y), T).

%%  action turn_loss_block_block_right
% préconditions
:-  do(turn_loss_block_block_right, T),
    fluent(perso(X, Y), T),
    not fluent(block(X + 1, Y),T).

:-  do(turn_loss_block_block_right, T),
    fluent(perso(X, Y), T),
    not fluent(block(X + 2,Y),T).

% effets
fluent(perso(X, Y), T + 1) :-
    do(turn_loss_block_block_right, T),
    fluent(perso(X, Y), T).

removed(perso(X, Y), T) :-
    do(turn_loss_block_block_right, T),
    fluent(perso(X, Y), T).

%%  action turn_loss_block_block_up
% préconditions
:-  do(turn_loss_block_block_up, T),
    fluent(perso(X, Y), T),
    not fluent(block(X, Y + 1),T).

:-  do(turn_loss_block_block_up, T),
    fluent(perso(X, Y), T),
    not fluent(block(X,Y + 2),T).

% effets
fluent(perso(X, Y), T + 1) :-
    do(turn_loss_block_block_up, T),
    fluent(perso(X, Y), T).

removed(perso(X, Y), T) :-
    do(turn_loss_block_block_up, T),
    fluent(perso(X, Y), T).

%%  action turn_loss_block_block_down
% préconditions
:-  do(turn_loss_block_block_down, T),
    fluent(perso(X, Y), T),
    not fluent(block(X, Y - 1),T).

:-  do(turn_loss_block_block_down, T),
    fluent(perso(X, Y), T),
    not fluent(block(X,Y - 2),T).

% effets
fluent(perso(X, Y), T + 1) :-
    do(turn_loss_block_block_down, T),
    fluent(perso(X, Y), T).

removed(perso(X, Y), T) :-
    do(turn_loss_block_block_down, T),
    fluent(perso(X, Y), T).

%%  action turn_loss_block_ennemy_left
% préconditions
:-  do(turn_loss_block_ennemy_left, T),
    fluent(perso(X, Y), T),
    not fluent(block(X - 1, Y),T).

:-  do(turn_loss_block_ennemy_left, T),
    fluent(perso(X, Y), T),
    not fluent(ennemy(X - 2,Y),T).

% effets
fluent(perso(X, Y), T + 1) :-
    do(turn_loss_block_ennemy_left, T),
    fluent(perso(X, Y), T).

removed(perso(X, Y), T) :-
    do(turn_loss_block_ennemy_left, T),
    fluent(perso(X, Y), T).

%%  action turn_loss_block_ennemy_right
% préconditions
:-  do(turn_loss_block_ennemy_right, T),
    fluent(perso(X, Y), T),
    not fluent(block(X + 1, Y),T).

:-  do(turn_loss_block_ennemy_right, T),
    fluent(perso(X, Y), T),
    not fluent(ennemy(X + 2,Y),T).

% effets
fluent(perso(X, Y), T + 1) :-
    do(turn_loss_block_ennemy_right, T),
    fluent(perso(X, Y), T).

removed(perso(X, Y), T) :-
    do(turn_loss_block_ennemy_right, T),
    fluent(perso(X, Y), T).

%%  action turn_loss_block_ennemy_up
% préconditions
:-  do(turn_loss_block_ennemy_up, T),
    fluent(perso(X, Y), T),
    not fluent(block(X, Y + 1),T).

:-  do(turn_loss_block_ennemy_up, T),
    fluent(perso(X, Y), T),
    not fluent(ennemy(X,Y + 2),T).

% effets
fluent(perso(X, Y), T + 1) :-
    do(turn_loss_block_ennemy_up, T),
    fluent(perso(X, Y), T).

removed(perso(X, Y), T) :-
    do(turn_loss_block_ennemy_up, T),
    fluent(perso(X, Y), T).

%%  action turn_loss_block_ennemy_down
% préconditions
:-  do(turn_loss_block_ennemy_down, T),
    fluent(perso(X, Y), T),
    not fluent(block(X, Y - 1),T).

:-  do(turn_loss_block_ennemy_down, T),
    fluent(perso(X, Y), T),
    not fluent(ennemy(X,Y - 2),T).

% effets
fluent(perso(X, Y), T + 1) :-
    do(turn_loss_block_ennemy_down, T),
    fluent(perso(X, Y), T).

removed(perso(X, Y), T) :-
    do(turn_loss_block_ennemy_down, T),
    fluent(perso(X, Y), T).

%%  action turn_loss_block_door_left
% préconditions
:-  do(turn_loss_block_door_left, T),
    fluent(perso(X, Y), T),
    not fluent(block(X - 1, Y),T).

:-  do(turn_loss_block_door_left, T),
    fluent(perso(X, Y), T),
    not fluent(door(X - 2,Y),T).

% effets
fluent(perso(X, Y), T + 1) :-
    do(turn_loss_block_door_left, T),
    fluent(perso(X, Y), T).

removed(perso(X, Y), T) :-
    do(turn_loss_block_door_left, T),
    fluent(perso(X, Y), T).

%%  action turn_loss_block_door_right
% préconditions
:-  do(turn_loss_block_door_right, T),
    fluent(perso(X, Y), T),
    not fluent(block(X + 1, Y),T).

:-  do(turn_loss_block_door_right, T),
    fluent(perso(X, Y), T),
    not fluent(door(X + 2,Y),T).

% effets
fluent(perso(X, Y), T + 1) :-
    do(turn_loss_block_door_right, T),
    fluent(perso(X, Y), T).

removed(perso(X, Y), T) :-
    do(turn_loss_block_door_right, T),
    fluent(perso(X, Y), T).

%%  action turn_loss_block_door_up
% préconditions
:-  do(turn_loss_block_door_up, T),
    fluent(perso(X, Y), T),
    not fluent(block(X, Y + 1),T).

:-  do(turn_loss_block_door_up, T),
    fluent(perso(X, Y), T),
    not fluent(door(X,Y + 2),T).

% effets
fluent(perso(X, Y), T + 1) :-
    do(turn_loss_block_door_up, T),
    fluent(perso(X, Y), T).

removed(perso(X, Y), T) :-
    do(turn_loss_block_door_up, T),
    fluent(perso(X, Y), T).

%%  action turn_loss_block_door_down
% préconditions
:-  do(turn_loss_block_door_down, T),
    fluent(perso(X, Y), T),
    not fluent(block(X, Y - 1),T).

:-  do(turn_loss_block_door_down, T),
    fluent(perso(X, Y), T),
    not fluent(door(X,Y - 2),T).

% effets
fluent(perso(X, Y), T + 1) :-
    do(turn_loss_block_door_down, T),
    fluent(perso(X, Y), T).

removed(perso(X, Y), T) :-
    do(turn_loss_block_door_down, T),
    fluent(perso(X, Y), T).

%%  action turn_loss_block_edge_left
% préconditions
:-  do(turn_loss_block_edge_left, T),
    fluent(perso(X, Y), T),
    not fluent(block(X - 1, Y),T).

:-  do(turn_loss_block_edge_left, T),
    fluent(perso(X, Y), T),
    fluent(cell(X - 2,Y),T).

:-  do(turn_loss_block_edge_left, T),
    fluent(perso(X, Y), T),
    not fluent(cell(X - 1,Y),T).

% effets
fluent(perso(X, Y), T + 1) :-
    do(turn_loss_block_edge_left, T),
    fluent(perso(X, Y), T).

removed(perso(X, Y), T) :-
    do(turn_loss_block_edge_left, T),
    fluent(perso(X, Y), T).

%%  action turn_loss_block_edge_right
% préconditions
:-  do(turn_loss_block_edge_right, T),
    fluent(perso(X, Y), T),
    not fluent(block(X + 1, Y),T).

:-  do(turn_loss_block_edge_right, T),
    fluent(perso(X, Y), T),
    fluent(cell(X + 2,Y),T).

:-  do(turn_loss_block_edge_right, T),
    fluent(perso(X, Y), T),
    not fluent(cell(X + 1, Y),T).

% effets
fluent(perso(X, Y), T + 1) :-
    do(turn_loss_block_edge_right, T),
    fluent(perso(X, Y), T).

removed(perso(X, Y), T) :-
    do(turn_loss_block_edge_right, T),
    fluent(perso(X, Y), T).

%%  action turn_loss_block_edge_up
% préconditions
:-  do(turn_loss_block_edge_up, T),
    fluent(perso(X, Y), T),
    not fluent(block(X, Y + 1),T).

:-  do(turn_loss_block_edge_up, T),
    fluent(perso(X, Y), T),
    fluent(edge(X,Y + 2),T).

:-  do(turn_loss_block_edge_up, T),
    fluent(perso(X, Y), T),
    not fluent(cell(X, Y + 1),T).

% effets
fluent(perso(X, Y), T + 1) :-
    do(turn_loss_block_edge_up, T),
    fluent(perso(X, Y), T).

removed(perso(X, Y), T) :-
    do(turn_loss_block_edge_up, T),
    fluent(perso(X, Y), T).

%%  action turn_loss_block_edge_down
% préconditions
:-  do(turn_loss_block_edge_down, T),
    fluent(perso(X, Y), T),
    not fluent(block(X, Y - 1),T).

:-  do(turn_loss_block_edge_down, T),
    fluent(perso(X, Y), T),
    fluent(cell(X,Y - 2),T).

:-  do(turn_loss_block_edge_down, T),
    fluent(perso(X, Y), T),
    not fluent(cell(X, Y - 1),T).

% effets
fluent(perso(X, Y), T + 1) :-
    do(turn_loss_block_edge_down, T),
    fluent(perso(X, Y), T).

removed(perso(X, Y), T) :-
    do(turn_loss_block_edge_down, T),
    fluent(perso(X, Y), T).

%% action push_block_left
% préconditions
:-  do(push_block_left, T),
    fluent(perso(X, Y), T),
    not fluent(block(X - 1, Y), T).

:-  do(push_block_left, T),
    fluent(perso(X, Y), T),
    not cell(X - 2, Y).

:-  do(push_block_left, T),
    fluent(perso(X, Y), T),
    fluent(block(X - 2, Y), T).

:-  do(push_block_left, T),
    fluent(perso(X, Y), T),
    fluent(ennemy(X - 2, Y), T).

:-  do(push_block_left, T),
    fluent(perso(X, Y), T),
    fluent(door(X - 2, Y), T).

% effets
fluent(block(X - 2, Y), T + 1) :-
    do(push_block_left, T),
    fluent(perso(X, Y), T).

removed(block(X - 1, Y), T) :-
    do(push_block_left, T),
    fluent(perso(X, Y), T).

%% action push_block_right
% préconditions
:-  do(push_block_right, T),
    fluent(perso(X, Y), T),
    not fluent(block(X + 1, Y), T).

:-  do(push_block_right, T),
    fluent(perso(X, Y), T),
    not cell(X + 2, Y).

:-  do(push_block_right, T),
    fluent(perso(X, Y), T),
    fluent(block(X + 2, Y), T).

:-  do(push_block_right, T),
    fluent(perso(X, Y), T),
    fluent(ennemy(X + 2, Y), T).

:-  do(push_block_right, T),
    fluent(perso(X, Y), T),
    fluent(door(X + 2, Y), T).

% effets
fluent(block(X + 2, Y), T + 1) :-
    do(push_block_right, T),
    fluent(perso(X, Y), T).

removed(block(X + 1, Y), T) :-
    do(push_block_right, T),
    fluent(perso(X, Y), T).

%% action push_block_up
% préconditions
:-  do(push_block_up, T),
    fluent(perso(X, Y), T),
    not fluent(block(X, Y + 1), T).

:-  do(push_block_up, T),
    fluent(perso(X, Y), T),
    not cell(X, Y + 2).

:-  do(push_block_up, T),
    fluent(perso(X, Y), T),
    fluent(block(X, Y + 2), T).

:-  do(push_block_up, T),
    fluent(perso(X, Y), T),
    fluent(ennemy(X, Y + 2), T).

:-  do(push_block_up, T),
    fluent(perso(X, Y), T),
    fluent(door(X, Y + 2), T).

% effets
fluent(block(X, Y + 2), T + 1) :-
    do(push_block_up, T),
    fluent(perso(X, Y), T).

removed(block(X, Y + 1), T) :-
    do(push_block_up, T),
    fluent(perso(X, Y), T).

%% action push_block_down
% préconditions
:-  do(push_block_down, T),
    fluent(perso(X, Y), T),
    not fluent(block(X, Y - 1), T).

:-  do(push_block_down, T),
    fluent(perso(X, Y), T),
    not cell(X, Y - 2).

:-  do(push_block_down, T),
    fluent(perso(X, Y), T),
    fluent(block(X, Y - 2), T).

:-  do(push_block_down, T),
    fluent(perso(X, Y), T),
    fluent(ennemy(X, Y - 2), T).

:-  do(push_block_down, T),
    fluent(perso(X, Y), T),
    fluent(door(X, Y - 2), T).

% effets
fluent(block(X, Y - 2), T + 1) :-
    do(push_block_down, T),
    fluent(perso(X, Y), T).

removed(block(X, Y - 1), T) :-
    do(push_block_down, T),
    fluent(perso(X, Y), T).

%% action push_ennemy_left
% préconditions
:-  do(push_ennemy_left, T),
    fluent(perso(X, Y), T),
    not fluent(ennemy(X - 1, Y), T).

:-  do(push_ennemy_left, T),
    fluent(perso(X, Y), T),
    not cell(X - 2, Y).

:-  do(push_ennemy_left, T),
    fluent(perso(X, Y), T),
    fluent(block(X - 2, Y), T).

:-  do(push_ennemy_left, T),
    fluent(perso(X, Y), T),
    fluent(ennemy(X - 2, Y), T).

:-  do(push_ennemy_left, T),
    fluent(perso(X, Y), T),
    fluent(door(X - 2, Y), T).

% effets
fluent(ennemy(X - 2, Y), T + 1) :-
    do(push_ennemy_left, T),
    fluent(perso(X, Y), T).

removed(ennemy(X - 1, Y), T) :-
    do(push_ennemy_left, T),
    fluent(perso(X, Y), T).

%% action push_ennemy_right
% préconditions
:-  do(push_ennemy_right, T),
    fluent(perso(X, Y), T),
    not fluent(ennemy(X + 1, Y), T).

:-  do(push_ennemy_right, T),
    fluent(perso(X, Y), T),
    not cell(X + 2, Y).

:-  do(push_ennemy_right, T),
    fluent(perso(X, Y), T),
    fluent(block(X + 2, Y), T).

:-  do(push_ennemy_right, T),
    fluent(perso(X, Y), T),
    fluent(ennemy(X + 2, Y), T).

:-  do(push_ennemy_right, T),
    fluent(perso(X, Y), T),
    fluent(door(X + 2, Y), T).

% effets
fluent(ennemy(X + 2, Y), T + 1) :-
    do(push_ennemy_right, T),
    fluent(perso(X, Y), T).

removed(ennemy(X + 1, Y), T) :-
    do(push_ennemy_right, T),
    fluent(perso(X, Y), T).

%% action push_ennemy_up
% préconditions
:-  do(push_ennemy_up, T),
    fluent(perso(X, Y), T),
    not fluent(ennemy(X, Y + 1), T).

:-  do(push_ennemy_up, T),
    fluent(perso(X, Y), T),
    not cell(X, Y + 2).

:-  do(push_ennemy_up, T),
    fluent(perso(X, Y), T),
    fluent(block(X, Y + 2), T).

:-  do(push_ennemy_up, T),
    fluent(perso(X, Y), T),
    fluent(ennemy(X, Y + 2), T).

:-  do(push_ennemy_up, T),
    fluent(perso(X, Y), T),
    fluent(door(X, Y + 2), T).

% effets
fluent(ennemy(X, Y + 2), T + 1) :-
    do(push_ennemy_up, T),
    fluent(perso(X, Y), T).

removed(ennemy(X, Y + 1), T) :-
    do(push_ennemy_up, T),
    fluent(perso(X, Y), T).

%% action push_ennemy_down
% préconditions
:-  do(push_ennemy_down, T),
    fluent(perso(X, Y), T),
    not fluent(ennemy(X, Y - 1), T).

:-  do(push_ennemy_down, T),
    fluent(perso(X, Y), T),
    not cell(X, Y - 2).

:-  do(push_ennemy_down, T),
    fluent(perso(X, Y), T),
    fluent(block(X, Y - 2), T).

:-  do(push_ennemy_down, T),
    fluent(perso(X, Y), T),
    fluent(ennemy(X, Y - 2), T).

:-  do(push_ennemy_down, T),
    fluent(perso(X, Y), T),
    fluent(door(X, Y - 2), T).

% effets
fluent(ennemy(X, Y - 2), T + 1) :-
    do(push_ennemy_down, T),
    fluent(perso(X, Y), T).

removed(ennemy(X, Y - 1), T) :-
    do(push_ennemy_down, T),
    fluent(perso(X, Y), T).

%% action kill_with_block_left
% préconditions
:-  do(kill_with_block_left, T),
    fluent(perso(X, Y), T),
    not fluent(ennemy(X - 1, Y), T).

:-  do(kill_with_block_left, T),
    fluent(perso(X, Y), T),
    not fluent(block(X - 2, Y), T).

% effets
removed(ennemy(X - 1, Y), T) :-
    do(kill_with_block_left, T),
    fluent(perso(X, Y), T).

%% action kill_with_block_right
% préconditions
:-  do(kill_with_block_right, T),
    fluent(perso(X, Y), T),
    not fluent(ennemy(X + 1, Y), T).

:-  do(kill_with_block_right, T),
    fluent(perso(X, Y), T),
    not fluent(block(X + 2, Y), T).

% effets
removed(ennemy(X + 1, Y), T) :-
    do(kill_with_block_right, T),
    fluent(perso(X, Y), T).

%% action kill_with_block_up
% préconditions
:-  do(kill_with_block_up, T),
    fluent(perso(X, Y), T),
    not fluent(ennemy(X, Y + 1), T).

:-  do(kill_with_block_up, T),
    fluent(perso(X, Y), T),
    not fluent(block(X, Y + 2), T).

% effets
removed(ennemy(X, Y + 1), T) :-
    do(kill_with_block_up, T),
    fluent(perso(X, Y), T).

%% action kill_with_block_down
% préconditions
:-  do(kill_with_block_down, T),
    fluent(perso(X, Y), T),
    not fluent(ennemy(X, Y - 1), T).

:-  do(kill_with_block_down, T),
    fluent(perso(X, Y), T),
    not fluent(block(X, Y - 2), T).

% effets
removed(ennemy(X, Y - 1), T) :-
    do(kill_with_block_down, T),
    fluent(perso(X, Y), T).

%% action kill_with_edge_left
% préconditions
:-  do(kill_with_edge_left, T),
    fluent(perso(X, Y), T),
    not fluent(ennemy(X - 1, Y), T).

:-  do(kill_with_edge_left, T),
    fluent(perso(X, Y), T),
    cell(X - 2, Y).

% effets
removed(ennemy(X - 1, Y), T) :-
    do(kill_with_edge_left, T),
    fluent(perso(X, Y), T).

%% action kill_with_edge_right
% préconditions
:-  do(kill_with_edge_right, T),
    fluent(perso(X, Y), T),
    not fluent(ennemy(X + 1, Y), T).

:-  do(kill_with_edge_right, T),
    fluent(perso(X, Y), T),
    cell(X + 2, Y).

% effets
removed(ennemy(X + 1, Y), T) :-
    do(kill_with_edge_right, T),
    fluent(perso(X, Y), T).

%% action kill_with_edge_up
% préconditions
:-  do(kill_with_edge_up, T),
    fluent(perso(X, Y), T),
    not fluent(ennemy(X, Y + 1), T).

:-  do(kill_with_edge_up, T),
    fluent(perso(X, Y), T),
    cell(X, Y + 2).

% effets
removed(ennemy(X, Y + 1), T) :-
    do(kill_with_edge_up, T),
    fluent(perso(X, Y), T).

%% action kill_with_edge_down
% préconditions
:-  do(kill_with_edge_down, T),
    fluent(perso(X, Y), T),
    not fluent(ennemy(X, Y - 1), T).

:-  do(kill_with_edge_down, T),
    fluent(perso(X, Y), T),
    cell(X, Y - 2).
% effets
removed(ennemy(X, Y - 1), T) :-
    do(kill_with_edge_down, T),
    fluent(perso(X, Y), T).

%% action kill_with_ennemy_left
% préconditions
:-  do(kill_with_ennemy_left, T),
    fluent(perso(X, Y), T),
    not fluent(ennemy(X - 1, Y), T).

:-  do(kill_with_ennemy_left, T),
    fluent(perso(X, Y), T),
    not fluent(ennemy(X - 2, Y),T).

% effets
removed(ennemy(X - 1, Y), T) :-
    do(kill_with_ennemy_left, T),
    fluent(perso(X, Y), T).

%% action kill_with_ennemy_right
% préconditions
:-  do(kill_with_ennemy_right, T),
    fluent(perso(X, Y), T),
    not fluent(ennemy(X + 1, Y), T).

:-  do(kill_with_ennemy_right, T),
    fluent(perso(X, Y), T),
    not fluent(ennemy(X + 2, Y),T).

% effets
removed(ennemy(X + 1, Y), T) :-
    do(kill_with_ennemy_right, T),
    fluent(perso(X, Y), T).

%% action kill_with_ennemy_up
% préconditions
:-  do(kill_with_ennemy_up, T),
    fluent(perso(X, Y), T),
    not fluent(ennemy(X, Y + 1), T).

:-  do(kill_with_ennemy_up, T),
    fluent(perso(X, Y), T),
    not fluent(ennemy(X, Y + 2),T).

% effets
removed(ennemy(X, Y + 1), T) :-
    do(kill_with_ennemy_up, T),
    fluent(perso(X, Y), T).

%% action kill_with_ennemy_down
% préconditions
:-  do(kill_with_ennemy_down, T),
    fluent(perso(X, Y), T),
    not fluent(ennemy(X, Y - 1), T).

:-  do(kill_with_ennemy_down, T),
    fluent(perso(X, Y), T),
    not fluent(ennemy(X, Y - 2),T).

% effets
removed(ennemy(X, Y - 1), T) :-
    do(kill_with_ennemy_down, T),
    fluent(perso(X, Y), T).

%% action kill_with_door_left
% préconditions
:-  do(kill_with_door_left, T),
    fluent(perso(X, Y), T),
    not fluent(ennemy(X - 1, Y), T).

:-  do(kill_with_door_left, T),
    fluent(perso(X, Y), T),
    not fluent(door(X - 2, Y),T).

% effets
removed(ennemy(X - 1, Y), T) :-
    do(kill_with_door_left, T),
    fluent(perso(X, Y), T).

%% action kill_with_door_right
% préconditions
:-  do(kill_with_door_right, T),
    fluent(perso(X, Y), T),
    not fluent(ennemy(X + 1, Y), T).

:-  do(kill_with_door_right, T),
    fluent(perso(X, Y), T),
    not fluent(door(X + 2, Y),T).

% effets
removed(ennemy(X + 1, Y), T) :-
    do(kill_with_door_right, T),
    fluent(perso(X, Y), T).

%% action kill_with_door_up
% préconditions
:-  do(kill_with_door_up, T),
    fluent(perso(X, Y), T),
    not fluent(ennemy(X, Y + 1), T).

:-  do(kill_with_door_up, T),
    fluent(perso(X, Y), T),
    not fluent(door(X, Y + 2),T).

% effets
removed(ennemy(X, Y + 1), T) :-
    do(kill_with_door_up, T),
    fluent(perso(X, Y), T).

%% action kill_with_door_down
% préconditions
:-  do(kill_with_door_down, T),
    fluent(perso(X, Y), T),
    not fluent(ennemy(X, Y - 1), T).

:-  do(kill_with_door_down, T),
    fluent(perso(X, Y), T),
    not fluent(door(X, Y - 2),T).

% effets
removed(ennemy(X, Y - 1), T) :-
    do(kill_with_door_down, T),
    fluent(perso(X, Y), T).

%% action kill_with_trap                      %bug: apparemment clingo l'execute meme sans ennemi ou piege
% préconditions
:-  do(kill_with_trap, T),
    fluent(ennemy(X, Y), T),
    not fluent(trap(X, Y), T).

:-  do(kill_with_trap, T),
    not fluent(ennemy(X, Y), T),
    fluent(trap(X, Y), T).

% effets
removed(ennemy(X, Y), T) :-
    do(kill_with_trap, T),
    fluent(ennemy(X, Y), T),
    fluent(trap(X,Y),T).

%%% Frame Problem
% les fluents qui n'ont pas été supprimés restent à leur valeur
fluent(F, T + 1) :-
    fluent(F, T),
    T + 1 < horizon,
    not removed(F, T).

% après la fin, plus rien ne bouge
fluent(F, T + 1) :-
    fluent(F, T),
    achieved(T),
    T + 1 <= horizon.

#show do/2.
