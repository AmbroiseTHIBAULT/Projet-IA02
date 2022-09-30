from typing import List, Tuple
import subprocess
import sys
from helltaker_utils import grid_from_file, check_plan

from itertools import combinations
'''
Structures des grilles du prof
H: hero
D: demoness
#: wall
  : empty
B: block
K: key
L: lock
M: mob (skeleton)
S: spikes
T: trap (safe)
U: trap (unsafe)
O: block on spike
P: block on trap (safe)
Q: block on trap (unsafe)
'''
infosGrille=grid_from_file(sys.argv[1])
print(infosGrille)
"""
m : nb de LIGNES
n : nb de colonnes
"""

myLaby = {
    "walls": {(2, 2), (2, 3), (4, 3)},
    "board": {(x, y) for x in range(1, 5) for y in range(1, 5) if (x, y) not in {(2, 2), (2, 3), (4, 3)}},
    "initial": (2, 1),
    "final": (3, 4)}

Test = {
    "walls": {(3, 2), (3, 1), (3, 7), (1, 1), (1, 7), (3, 6), (1, 6), (3, 4), (2, 8), (3, 3), (1, 3), (3, 8), (1, 2), (1, 8), (2, 1), (3, 5), (1, 5), (1, 4)},
    "board": {(2, 5), (2, 4), (2, 7), (2, 3)},
    "initial": (2, 6),
    "final": (2, 2)}
myLabyTest = {
    "walls": {},
    "board": {},
    "initial": (0,0),
    "final": {},
    "pieges": {}
}

walls = set()
board = set()
pieges = set()
#initial = set()
final = set()
def grid_to_laby() :
    global infosGrille
    x = 1
    y = infosGrille["m"]
    for it in infosGrille["grid"]:
        x = 1
        print(it)
        for it2 in it:
            print(it2)
            if it2 == "#" : #ecas mur
                walls.add((x,y))

            elif it2 == "H" : #cas Perso
                myLabyTest["initial"] = (x,y)
                board.add((x,y))
                #initial.add((x,y))

            elif it2 == "D" : #cas demon, on met les voisins en sortie
                """
                final.add((x-1,y))
                final.add((x+1,y))
                final.add((x,y-1))
                final.add((x,y+1))
                """
                final.add((x,y))
                board.add((x,y))
                #final.add((x,y))

            elif it2 == " " : #cas ou il y'a rien
                board.add((x,y))

            elif it2 == "S" :#cas ou il y'a un piege
                pieges.add((x,y))
                board.add((x,y))
            x = x+1
        y = y-1
        myLabyTest["walls"] = walls
        myLabyTest["board"] = board
        myLabyTest["pieges"] = pieges
        #myLabyTest["initial"] = initial
        myLabyTest["final"] = final


"""
            elif infosGrille["grid"][ligne][col] == "D" : #cas Démonne, on met les voisins en sortie
                voisins=[(ligne-1,col),(ligne+1,col),(ligne,col+1),(ligne,col-1)]"""
grid_to_laby()

print(myLabyTest)

"""
Coordonnées (x,y)
(1,1) première case tout en bas à gauche
"""


def vocabulary(board, t_max):
    directions = 'gdhb'
    do_vars = [('do', t, a) for t in range(t_max) for a in directions]
    at_vars = [('at', t, c) for t in range(t_max + 1) for c in board]
    return {v: i + 1 for i, v in enumerate(do_vars + at_vars)}


def clauses_exactly_one_action(var2n, t_max):
    directions = 'gdhb'
    at_least_one_action = [[var2n[('do', t, a)] for a in directions] for t in range(t_max)]
    at_most_one_action = [[-var2n[('do', t, a1)], -var2n[('do', t, a2)]]
                          for t in range(t_max) for a1, a2 in combinations(directions, 2)]
    return at_least_one_action + at_most_one_action


def clauses_initial_state(var2n, board, initial):
    cl = []
    for c in board:
        if c == initial:
            cl.append([var2n[('at', 0, c)]])
        else:
            cl.append([-var2n[('at', 0, c)]])
    return cl


def succ(at, direction, board):
    x, y = at
    return {'g': (x - 1, y), 'd': (x + 1, y), 'h': (x, y + 1), 'b': (x, y - 1)}[direction]


def clauses_successor_from_given_position(var2n, board, t_max, position):
    directions = 'gdhb'
    Successors = {a: succ(position, a, board) for a in directions}
    # transitions impossibles, entre deux cases non voisines
    cl = [[-var2n[('at', t, position)], -var2n[('at', t + 1, c)]]
          for t in range(t_max) for c in board if not (c in Successors.values())]
    # actions interdites, qui feraient sortir du plateau (mur ou bord)
    cl += [[-var2n[('at', t, position)], -var2n[('do', t, a)]]
           for t in range(t_max) for a, c in Successors.items() if not (c in board)]
    # transitions possibles
    for a, c in Successors.items():
        if c in board:
            # at(t,position) AND do(t,a) -> at(t+1,c)
            cl += [[-var2n[('at', t, position)], -var2n[('do', t, a)], var2n[('at', t + 1, c)]]
                   for t in range(t_max)]
            # unicité de l'état à l'issue de l'action
            cl += [[-var2n[('at', t, position)], -var2n[('do', t, a)], -var2n[('at', t + 1, c1)]]
                   for t in range(t_max) for c1 in Successors.values() if c1 != c and c1 in board]
    return cl

"""
def clauses_successor_from_given_position(var2n, board, t_max, position, pieges):
    directions = 'gdhb'
    Successors = {a: succ(position, a, board) for a in directions}
    # transitions impossibles, entre deux cases non voisines

    cl = [[-var2n[('at', t, position)], -var2n[('at', t + 2, c)]]
          for t in range(t_max-1) for c in pieges if not (c in Successors.values())]
    cl = [[-var2n[('at', t, position)], -var2n[('at', t + 1, c)]]
          for t in range(t_max) for c in board if not (c in Successors.values() and not(c in pieges))]
    # actions interdites, qui feraient sortir du plateau (mur ou bord)
    cl += [[-var2n[('at', t, position)], -var2n[('do', t, a)]]
           for t in range(t_max) for a, c in Successors.items() if not (c in board)]
    # transitions possibles
    for a, c in Successors.items():
        if c in pieges :
            # at(t,position) AND do(t,a) -> at(t+1,c)
            cl += [[-var2n[('at', t, position)], -var2n[('do', t, a)], var2n[('at', t + 2, c)]]
                    for t in range(t_max-1)]
            # unicité de l'état à l'issue de l'action
            cl += [[-var2n[('at', t, position)], -var2n[('do', t, a)], -var2n[('at', t + 2, c1)]]
                    for t in range(t_max-1) for c1 in Successors.values() if c1 != c and c1 in board]
        elif c in board:
            # at(t,position) AND do(t,a) -> at(t+1,c)
            cl += [[-var2n[('at', t, position)], -var2n[('do', t, a)], var2n[('at', t + 1, c)]]
                   for t in range(t_max)]
            # unicité de l'état à l'issue de l'action
            cl += [[-var2n[('at', t, position)], -var2n[('do', t, a)], -var2n[('at', t + 1, c1)]]
                   for t in range(t_max) for c1 in Successors.values() if c1 != c and c1 in board]
    return cl


def sat_laby1(board, initial, final, t_max, pieges):
    var2n = vocabulary(board, t_max)
    clauses = clauses_exactly_one_action(var2n, t_max) + clauses_initial_state(var2n, board, initial)
    for c in board:
        clauses += clauses_successor_from_given_position(var2n, board, t_max, c, pieges)
    tmp = []
    for f in final:
        tmp.append(var2n[('at', t_max, f)])
    clauses.append(tmp)
    return var2n, clauses

"""
def sat_laby1(board, initial, final, t_max):
    var2n = vocabulary(board, t_max)
    clauses = clauses_exactly_one_action(var2n, t_max) + clauses_initial_state(var2n, board, initial)
    for c in board:
        clauses += clauses_successor_from_given_position(var2n, board, t_max, c)
    tmp = []
    for f in final:
        tmp.append(var2n[('at', t_max, f)])
    clauses.append(tmp)
    return var2n, clauses
def clauses_to_dimacs(clauses: List[List[int]], nb_vars: int) -> str:
    chaine = ""

    chaine += f"p cnf {nb_vars} {len(clauses)}\n"
    print(chaine)
    for clause in clauses:
        # print(f"clause: {clause}")
        if type(clause) is int:
            chaine += f"{clause}"
        else:
            for var in clause:
                chaine += f"{var}"
                if clause[len(clause)-1] != var:
                    chaine += " "
        chaine += " 0\n"
    return chaine

def write_dimacs_file(dimacs: str, filename: str):
    with open(filename, "w", newline="") as cnf:
        cnf.write(dimacs)

def exec_gophersat(filename: str, cmd: str = "./gophersat", encoding: str = "utf8") -> Tuple[bool, List[int]]:
    result = subprocess.run(
        [cmd, filename], capture_output=True, check=True, encoding=encoding
    )
    string = str(result.stdout)
    lines = string.splitlines()

    if lines[1] != "s SATISFIABLE":
        return False, []

    model = lines[2][2:].split(" ")

    return True, [int(x) for x in model]

def solve_laby1(laby, t_max):
    for t in range(1, t_max):
        #v2n, cl = sat_laby1(laby["board"], laby["initial"], laby["final"], t, laby["pieges"])
        v2n, cl = sat_laby1(laby["board"], laby["initial"], laby["final"], t)
        n2v = {i: v for v, i in v2n.items()}
        dimacs = clauses_to_dimacs(cl, len(v2n))
        filename = f'laby1_{t!s}.cnf'
        write_dimacs_file(dimacs, filename)
        sat, model = exec_gophersat(filename)
        if sat:
            #print('plan de taille', t)
            return [n2v[i] for i in model if i > 0 and n2v[i][0] == 'do']
            # si on veut juste retourner les directions
            #return [n2v[i] for i in model if i > 0 and n2v[i][0] == 'do']
        else:
            print('pas de plan de taille', t)

print(solve_laby1(myLabyTest, 10))
