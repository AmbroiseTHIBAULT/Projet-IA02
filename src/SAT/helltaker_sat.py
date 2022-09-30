"""
Code des cellules :
 0 : Sortie
 1 : Mur
 2 : Perso
 3 : Porte
 4 : Block
 5 : Soldat
 6 : PiegeFixe
 7 : PiegePasFixeActif
 8 : PiegePasFixeAttente
 9 : Clé
 10 : aCle 


si on a un tableau 9*9 
<lig><col><chrono><code cellule>
(0,0,0,0) -> 1
(0,0,0,1) -> 2
......
(0,0,0,10) -> 11
(0,0,1,0) -> 12
(0,0,1,1) -> 13
......
(0,0,9,10) -> 9*11 + 10+1
(0,1,0,0) -> 1*11*11 + 1
.......
(1,0,0,0) -> 1*11*11*11 + 1
(9,9,35,10) -> 9*11*11*11 + 9*11*11 + 35*11 + 10+1

(i, j, chrono, code) -> 11*11*11 i + 11*11j + 11*chrono + code + 1

"""

from typing import List, Tuple
import itertools
import subprocess
import sys
from helltaker_utils import grid_from_file, check_plan

Variable = int
Literal = int
Clause = List[Literal]
Model = List[Literal]
Clause_Base = List[Clause]
Grid = List[List[int]]

empty_grid: Grid = [
    [0, 0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0, 0],
]

fluents = {'perso': (2, 2), 'soldat': [(4, 4), (3, 4), (6, 5), (6, 1), (6, 4), (2, 3), (6, 3)],
           'piegePasFixeActive': [(1, 1), (2, 1)], 'piegePasFixeAttente': [], 'porte': (5, 5),
           'block': [(1, 2), (2, 1)], 'cle': (7, 4)}  # fluents
# constantes
map_constantes = {'sortie': [(7, 4), (2, 1)], 'murs': [(4, 0), (5, 7), (8, 0)], 'piegesFixe': []}

######################################## INITIALISATION ################################

infosGrille = grid_from_file(sys.argv[1])

nb_vars = infosGrille["max_steps"] * 10 * infosGrille["n"] * infosGrille["m"] + infosGrille[
    "max_steps"] * 4  # nb total de coups * nb variable par case * largeur * hauteur + nb total de coups * nb de mouvements possibles par coup (droite, gauche, haut, bas = 4)
listeClauses = []


########################## STRUCTURE PROGRAMME #######"

# 1) Lire fichier avec grid_from_file. On aura toutes les données (largeur, hauteur, chrono, carte)
# 2) A partir de la grille, on génère les fait de de base.
# 3) On génère toutes les règles indépendamment de la grille. On les met dans une liste
# 4) On ecrit le DIMACS et on exécute avec gophersat (//Sudoku)
# 5) Du retour, on prend les mouvement pour chaque chrono. On en fait une chaine de caractère "HGBD"
# 6) On teste la chaine avec check_plan


# VARIABLES :
# de 1 à nb total de coups*4 : variables de mouvement : on se base là dessus pour avoir le plan à la fin
# de nb total de coups*4+1 à nb total de coups*10*largeur*hauteur+nb total de coups*4  : variables pour les etats des cases


######################################################################################################

# Données dans Sudoku
def write_dimacs_file(dimacs: str, filename: str):  # écrit dans le DIMACS : write_dimacs_file(dimacsex1,"sudoku1.cnf")
    with open(filename, "w", newline="") as cnf:
        cnf.write(dimacs)


def exec_gophersat(  # execute gophersat) : modelex1=exec_gophersat("sudoku1.cnf","../gophersat")
        filename: str, cmd: str = "gophersat", encoding: str = "utf8"
) -> Tuple[bool, List[int]]:
    result = subprocess.run(
        [cmd, filename], capture_output=True, check=True, encoding=encoding
    )
    string = str(result.stdout)
    lines = string.splitlines()

    if lines[1] != "s SATISFIABLE":
        return False, []

    model = lines[2][2:].split(" ")

    return True, [int(x) for x in model]


# Faite dans Sudoku
def clauses_to_dimacs(clauses: List[List[int]], nb_vars: int) -> str:
    res = ""
    res = res + "c Projet IA02\n"
    res = res + "c Helltaker\nc\n"
    res = res + "p cnf " + str(nb_vars) + " " + str(len(clauses)) + "\n"

    for clause in clauses:

        for i in clause:
            res = res + str(i) + " "
        res = res + "0 \n"

    return res


def cell_to_variable(ligne: int, col: int, chrono: int, codeC: int) -> int:
    return 11 * 11 * 11 * ligne + 11 * 11 * col + 11 * chrono + (codeC + 1)


def variable_to_cell(var: int) -> Tuple[int, int, int, int]:
    ligne = (var - 1) // 1331
    col = ((var - 1) % 1331) // 121
    chrono = (((var - 1) % 1331) % 121) // 11
    codeC = var - (ligne * 1331 + col * 121 + chrono * 11 + 1)
    return (ligne, col, chrono, codeC)


# Variables de mouvements 
##Actions en var
def action_to_variable(Coups: int, a: str) -> int:
    res = 0

    for nb in range(1, Coups):
        res = res + 4

    # on se place au coup cherché
    if a == "H":
        res = res + 1
    elif a == "D":
        res = res + 2
    elif a == "B":
        res = res + 3
    elif a == "G":
        res = res + 4

    return res


# On différencie ainsi l'action aller en haut au premier coup de l'action aller en haut au deuxieme coup (valuers de 1 et 5 respectivement)

# opération inverse
def variable_to_action(var: int) -> Tuple[int, str]:
    nb = var // 4 + 1
    a = var - 4 * (nb - 1)
    if a == 1:
        return (nb, "H")
    elif a == 2:
        return (nb, "D")
    elif a == 3:
        return (nb, "B")
    elif a == 4:
        return (nb, "G")


def at_leat_one_action(nbActionsInit: int) -> List[List[int]]:
    liste = []
    actions = ["H", "D", "B", "G"]
    for coups in range(1, nbActionsInit + 1):
        clause = []
        for a in actions:
            clause.append(action_to_variable(coups, a))
        liste.append(clause)

    return liste


def unique_action(nbActionsInit: int) -> List[List[int]]:
    liste = []
    actions = ["H", "D", "B", "G"]
    for nb in range(1, nbActionsInit + 1):
        vars = range(1 + (nb - 1) * 4, 1 + nb * 4)  # ensemble de nos variables actions pour le coup nb
        for i in itertools.combinations(vars, 2):
            l = []
            l.append(-1 * i[0])
            l.append(-1 * i[1])
            liste.append(l)
    return liste


def create_regles_constantes(largeur: int, hauteur: int, nbCoupsInit: int) -> List[List[int]]:
    liste = []

    ### Regles faciles

    # un mur reste un mur, une sortie reste une sortie
    for i in range(0, hauteur):
        for j in range(0, largeur):
            for nb in range(1, nbCoupsInit + 1):  
                for type in [0, 1]:
                    clause = []
                    clause.append(-1 * (cell_to_variable(i, j, nb, type)))
                    clause.append((cell_to_variable(i, j, nb - 1, type)))
                    liste.append(clause)
    return liste


def regles_mouvD():
# TO DO


def regles_mouvG():
# TO DO


def regles_mouvH():
# TO DO

def regles_mouvB():
# TO DO


# Ca nous sera utile à la fin pour nous donner la solution en sortie
####################################################
"""
i=action_to_variable(24,"H")
print(i)
j=variable_to_action(i)
print(j)
"""


def generate_problem(grid: List[List[int]]) -> List[List[int]]:
    baseClause = []
    baseClause = baseClause  # + create_column_constraints()
    baseClause = baseClause  # + create_cell_constraints()
    baseClause = baseClause  # + create_line_constraints()
    baseClause = baseClause  # + create_value_contraints(grid)
    return baseClause


def main():
    clauses = generate_problem(empty_grid)
    chaine = clauses_to_dimacs(clauses, len(clauses))
    write_dimacs_file(chaine, "helltaker.cnf")
    test = exec_gophersat("sudoku.cnf", "chemin_vers_gophersat")
