from parser import initialize_map
import espace_etats as ea
from helltaker_utils import grid_from_file
import time

map1 = "bgbbgggggbgbbddhhddddbd"
map2 = "hhdhhhhdddbddbbbbggb"
map3 = "gggggbbbbgghbddddddddhhhhhh"
map4 = "bbbdbbdddhgghhdbbdddb"
map5 = "bbbbdddddhbhhhhgghhh"
map6 = "gbddbbggbggbbddddhhbggbbbdddhhddddbbggbb"
map7 = "hhbgghhdbbbggghhhhddhbddddhhddhh"
map9 = "dhhddddbddghhhddddbbddhhdggghhhgh"


def test_maps():
    test_map1()
    test_map2()
    test_map3()
    test_map4()
    test_map5()
    test_map6()
    test_map7()
    test_map9()


def test_map9():
    filename = "../levels/level9.txt"
    infos = grid_from_file(filename)
    etat_initial, map_rules = initialize_map(infos)
    t_debut = time.time()
    result = ea.recherche_plan(etat_initial, map_rules)
    t_fin = time.time()-t_debut
    print(
        f"map9 {t_fin} [attendu: {map9}, obtenu: {result}] ==> {result == map9}")


def test_map7():
    filename = "../levels/level7.txt"
    infos = grid_from_file(filename)
    etat_initial, map_rules = initialize_map(infos)
    t_debut = time.time()
    result = ea.recherche_plan(etat_initial, map_rules)
    t_fin = time.time()-t_debut
    print(
        f"map7 {t_fin} [attendu: {map7}, obtenu: {result}] ==> {result == map7}")


def test_map6():
    filename = "../levels/level6.txt"
    infos = grid_from_file(filename)
    etat_initial, map_rules = initialize_map(infos)
    t_debut = time.time()
    result = ea.recherche_plan(etat_initial, map_rules)
    t_fin = time.time()-t_debut
    print(
        f"map6 {t_fin} [attendu: {map6}, obtenu: {result}] ==> {result == map6}")


def test_map5():
    filename = "../levels/level5.txt"
    infos = grid_from_file(filename)
    etat_initial, map_rules = initialize_map(infos)
    t_debut = time.time()
    result = ea.recherche_plan(etat_initial, map_rules)
    t_fin = time.time()-t_debut
    print(
        f"map5 {t_fin} [attendu: {map5}, obtenu: {result}] ==> {result == map5}")


def test_map4():
    filename = "../levels/level4.txt"
    infos = grid_from_file(filename)
    etat_initial, map_rules = initialize_map(infos)
    t_debut = time.time()
    result = ea.recherche_plan(etat_initial, map_rules)
    t_fin = time.time()-t_debut
    print(
        f"map4 {t_fin} [attendu: {map4}, obtenu: {result}] ==> {result == map4}")


def test_map3():
    filename = "../levels/level3.txt"
    infos = grid_from_file(filename)
    etat_initial, map_rules = initialize_map(infos)
    t_debut = time.time()
    result = ea.recherche_plan(etat_initial, map_rules)
    t_fin = time.time()-t_debut
    print(
        f"map3 {t_fin} [attendu: {map3}, obtenu: {result}] ==> {result == map3}")


def test_map2():
    filename = "../levels/level2.txt"
    infos = grid_from_file(filename)
    etat_initial, map_rules = initialize_map(infos)
    t_debut = time.time()
    result = ea.recherche_plan(etat_initial, map_rules)
    t_fin = time.time()-t_debut
    print(
        f"map2 {t_fin} [attendu: {map2}, obtenu: {result}] ==> {result == map2}")


def test_map1():
    filename = "../levels/level1.txt"
    infos = grid_from_file(filename)
    etat_initial, map_rules = initialize_map(infos)
    t_debut = time.time()
    result = ea.recherche_plan(etat_initial, map_rules)
    t_fin = time.time()-t_debut
    print(
        f"map1 {t_fin} [attendu: {map1}, obtenu: {result}] ==> {result == map1}")
