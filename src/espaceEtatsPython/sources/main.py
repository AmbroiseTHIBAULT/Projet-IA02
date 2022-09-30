import sys
from parser import initialize_map
import espace_etats as ea
from helltaker_utils import grid_from_file, check_plan

from tests import test_maps

""" 
    options pour executer le main :
    python3 main.py <pathToMap> [-d | -v | -t]
    
    -d : debug simple 
    -v : debug plus complet avec details de chaque etat
    -t : execution des tests unitaires pour chaque map
"""


def main():

    # tests unitaires pour parcours en largeur de chaque map
    if '-t' in sys.argv:
        test_maps()

    # recuperation du nom du fichier depuis la ligne de commande
    filename = sys.argv[1]
    # recuperation de al grille et de toutes les infos
    infos = grid_from_file(filename)

    etat_initial, map_rules = initialize_map(infos)

    # execution avec debug complet
    if '-v' in sys.argv:
        execution_avec_debug(etat_initial, map_rules, True)

    # execution avec debug complet
    elif '-d' in sys.argv:
        execution_avec_debug(etat_initial, map_rules, False)

    # execution sans debug
    else:
        execution_sans_debug(etat_initial, map_rules)


#############################################
#                                           #
#       Gestion du contexte d'execution     #
#                                           #
#############################################


def execution_sans_debug(etat_initial, map_rules):

    plan_result = ea.recherche_plan(etat_initial, map_rules)

    # affichage du résultat
    if check_plan(plan_result):
        print("[OK]", plan_result)
    else:
        print("[Err]", plan_result, file=sys.stderr)
        sys.exit(2)


def execution_avec_debug(etat_initial, map_rules, verbose=False):  # affichages pour debug

    print("\n======== ETAT INITIAL ========")
    for etat_v in etat_initial._asdict():
        print(f"{etat_v} {etat_initial._asdict()[etat_v]}")

    print("\n======== MAP RULES ========")
    for map_v in map_rules:
        print(f"{map_v} {map_rules[map_v]}")

    plan_result = ea.recherche_plan(etat_initial, map_rules, True, verbose)

    # affichage du résultat
    if check_plan(plan_result):
        print("[OK]", plan_result)
    else:
        print("[Err]", plan_result, file=sys.stderr)
        sys.exit(2)


if __name__ == "__main__":
    main()
