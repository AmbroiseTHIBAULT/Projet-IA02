import pythonASP
import sys
from helltaker_utils import grid_from_file
from pprint import pprint
test = 'nombre(0..10).paire(X,Y):-nombre(X),nombre(Y),X*X + Y*Y = 10.'



# recuperation du nom du fichier depuis la ligne de commande
#filename = '../levels/' + sys.argv[1]
# recuperation de al grille et de toutes les infos
#infos = grid_from_file(filename)


def giveStrAspInit(filename):
    dict = grid_from_file(filename)
    strStep = f'step(0..{dict["max_steps"]}-1).\n'
    strCell = f'cell(0..{dict["n"]}-1, 0..{dict["m"]}-1).\n'
    tabStrInit = []

    nLigne = 0
    for ligne in dict["grid"]:
        nCol = 0
        for element in ligne:
            if element == ' ' or element == '#':
                nCol = nCol + 1
            else:
                if element == 'H':
                    tabStrInit.append(f'init(perso({nCol}, {dict["m"]-1 - nLigne})).\n')
                if element == 'B':
                    tabStrInit.append(f'init(block({nCol}, {dict["m"] - 1 - nLigne})).\n')
                if element == 'M':
                    tabStrInit.append(f'init(ennemy({nCol}, {dict["m"] - 1 - nLigne})).\n')
                if element == 'K':
                    tabStrInit.append(f'init(key({nCol}, {dict["m"] - 1 - nLigne})).\n')
                if element == 'L':
                    tabStrInit.append(f'init(door({nCol}, {dict["m"] - 1 - nLigne})).\n')
                if element == 'S':
                    tabStrInit.append(f'init(trap({nCol}, {dict["m"] - 1 - nLigne})).\n')
                if element == 'D':
                    tabStrInit.append(f'goal(perso({nCol}, {dict["m"] - 1 - nLigne})).\n')
                nCol = nCol + 1
        nLigne = nLigne + 1

    strFinal = strStep + strCell
    for uneString in tabStrInit:
        strFinal = strFinal + uneString
    return strFinal

print("\n ******** La string ********\n")
#print(giveStrAspInit("level.txt"))

solutions = pythonASP.solve(test)
print(solutions)