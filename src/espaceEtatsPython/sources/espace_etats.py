from collections import namedtuple

Action = namedtuple('Action', ('verbe', 'direction'))
Etat = namedtuple('Etat', ('perso', 'blocks', 'ennemis',
                  'pieges', 'cle_possede', 'porte', 'coups_restants'))

actions = {'m'+d: Action('move', d) for d in 'hbgd'} | {
    'p'+d: Action('push', d) for d in 'hbgd'}


##################################################################################################################
#                                                                                                                #
#                                              Fonction principale                                               #
#                                                                                                                #
##################################################################################################################


# retourne le plan, qui est une suite de caracteres pour indiquer la direction
def recherche_plan(etat_initial, map_rules, debug=False, verbose=False):
    map_rules['actions'] = actions
    s_end, save = search_with_parent(etat_initial, goal_factory(map_rules), succ_factory(map_rules),
                                     remove_head, insert_tail)

    if debug:
        if verbose:
            affichage_final(s_end, save, True)
        else:
            affichage_final(s_end, save, False)

    result = ""
    for etat, action in dict2path(s_end, save):
        if action:
            result += action.direction

    return result


# affichage de la solution
def affichage_final(etat_final, chemin_parcouru, debug=True):
    idxEtat = 1
    for etat, action in dict2path(etat_final, chemin_parcouru):

        if debug:
            print(
                f"etat n{idxEtat}: coups_restants={etat.coups_restants} --> {etat}")
        else:
            print(
                f"etat n{idxEtat}: coups_restants={etat.coups_restants} --> {etat.perso}")

        if (action != None):
            print(f"    ==> {action.verbe}_{action.direction}")
        if(action == None):
            print("***** Fin trouvee, parcours termine *****")

        idxEtat += 1

##################################################################################################################
#                                                                                                                #
#                                  Fonction generation d'etats suivants                                          #
#                                                                                                                #
##################################################################################################################


# Fonction principale de generation d'un etat a partir de
# l'etat courant [etat] et d'une action donnee [action]
def do_fn(action, etat, map_rules):

    free = free_factory(map_rules)

    x0 = etat['perso']                       # position courante du perso
    blocks = etat['blocks']                  # liste des blocks
    ennemis = etat['ennemis']                # liste des ennemis
    pieges = etat['pieges']                  # liste des pieges
    cle_possede = etat['cle_possede']        # booleen de la possession de cle
    porte = etat['porte']                    # position de la porte
    coups_restants = etat['coups_restants']  # int du nombre de coups restants

    # si le compteur de coups restants ne permet pas de jouer un nouveau coup
    if (coups_restants <= 0):
        return None

    # recuperation de la coordonnee de la case accessible depuis l
    # a position courante du joueur dans la direction donnee par l'action
    x1 = one_step(x0, action.direction)

    # si la position vers laquelle on se deplace n'est pas un mur alors notre mouvement est compte et les pieges vont bouger
    # (si la position vers laquelle on se deplace est un mur )
    if free(x1):
        pieges = swap_etat_pieges(etat)
        ennemis = tuer_ennemis_sur_pieges(etat)

    # gestion d'une action de deplacement
    if action.verbe == 'move':
        if free(x1) and not(x1 in blocks) and not(x1 in ennemis):

            if (x1 == porte):  # si on veut se deplacer sur la porte
                if cle_possede == True:
                    return {'perso': x1, 'blocks': blocks, 'ennemis': etat['ennemis'],
                            'pieges': etat['pieges'], 'cle_possede': cle_possede, 'porte': porte, 'coups_restants': coups_restants-1}
                else:   # si on a pas la cle alors on ne peut pas se deplacer dans la position ou est la porte mais on perd un coup quand meme
                    return None

            if (x1 == map_rules['cle']):  # on recupere la cle
                return {'perso': x1, 'blocks': blocks, 'ennemis': etat['ennemis'],
                        'pieges': etat['pieges'], 'cle_possede': True, 'porte': porte, 'coups_restants': coups_restants-1}

            # on marche sur un piege statique ou un piege deploye
            if (('statique', x1) in pieges) or (('ferme', x1) in pieges):
                return {'perso': x1, 'blocks': blocks, 'ennemis': etat['ennemis'],
                        'pieges': etat['pieges'], 'cle_possede': cle_possede, 'porte': porte, 'coups_restants': coups_restants-2}

            # sinon si aucune des conditions precedentes n'est vraie alors c'est un deplacement normal
            return {'perso': x1, 'blocks': blocks, 'ennemis': etat['ennemis'],
                    'pieges': etat['pieges'], 'cle_possede': cle_possede, 'porte': porte, 'coups_restants': coups_restants-1}

        else:
            return None

    # gestion d'une action push
    if action.verbe == 'push':

        x2 = one_step(x1, action.direction)

        # utise pour regarder si on pousse depuis un piege qui doit nous faire des degats
        malusDeplacementPiege = 0
        if position_in_pieges(x0, pieges):
            malusDeplacementPiege = 1

        if x1 in blocks and not(x2 in ennemis) and not (x2 in blocks) and not (x2 in map_rules['murs']) and (x2 != map_rules['demon']) and (x2 != porte):
            # x2 est position finale du block, il doit être libre, ne pas être un bloc et ne pas etre mur
            return {'perso': x0, 'blocks': modif_liste_blocks(etat, x2, x1), 'ennemis': etat['ennemis'],
                    'pieges': etat['pieges'], 'cle_possede': cle_possede, 'porte': porte, 'coups_restants': coups_restants-1-malusDeplacementPiege}
        # ou pousse un ennemi mais on le tue pas
        if x1 in ennemis and free(x2) and not (x2 in blocks):
            return {'perso': x0, 'blocks': blocks, 'ennemis': modif_liste_ennemis(etat, x2, x1),
                    'pieges': etat['pieges'], 'cle_possede': cle_possede, 'porte': porte, 'coups_restants': coups_restants-1-malusDeplacementPiege}

        # on pousse un ennemis et on le tue (contre un mur, sur un piege ou contre un block)
        # TODO verifier que le piege est ouvert ou ferme => (x2 in pieges)
        if x1 in ennemis and (not free(x2) or (x2 in blocks) or (x2 in liste_piege_fait_degats(pieges)) or (x2 == porte)):
            return {'perso': x0, 'blocks': blocks, 'ennemis': modif_liste_ennemis(etat, None, x1),
                    'pieges': etat['pieges'], 'cle_possede': cle_possede, 'porte': porte, 'coups_restants': coups_restants-1-malusDeplacementPiege}
        else:
            return None

    return None


##################################################################################################################
#                                                                                                                #
#                              Fonctions auxiliaires pour generer etats suivants                                 #
#                                                                                                                #
##################################################################################################################


def tuer_ennemis_sur_pieges(etat):
    liste_ennemis = etat['ennemis']
    liste_pieges = etat['pieges']

    new_liste_ennemis = set()

    for ennemi in liste_ennemis:
        vivant = True
        # on regarde si l'ennemi courant est sur un piege qui fait des degats
        for piege in liste_pieges:
            if piege in liste_piege_fait_degats(liste_pieges) and (ennemi == piege[1]):
                vivant = False

        # si l'ennemi n'est pas sur un piege qui fait des degats alors on ne le tue pas
        # et on le laisse dans la liste des ennemis
        if vivant:
            new_liste_ennemis.add(ennemi)

    etat['ennemis'] = frozenset(new_liste_ennemis)
    return frozenset(new_liste_ennemis)


def liste_piege_fait_degats(list_pieges):
    ret = set()
    for piege in list_pieges:
        if (piege[0] == 'statique' or piege[0] == 'ferme'):
            ret.add(piege)

    return ret


def position_in_pieges(position, liste_pieges):
    for piege in liste_pieges:
        if piege[1] == position and (piege[0] == 'statique' or piege[0] == 'ferme'):
            return True

    return False


def modif_liste_ennemis(etat, ennemiAjout, ennemiRetirer):
    ennemiModif = set(etat['ennemis'])

    if ennemiAjout:
        ennemiModif.add(ennemiAjout)
    if ennemiRetirer:
        ennemiModif.remove(ennemiRetirer)

    return frozenset(ennemiModif)


def modif_liste_blocks(etat, blockAjout, blockRetirer):
    blocksModif = set(etat['blocks'])

    if blockAjout:
        blocksModif.add(blockAjout)
    if blockRetirer:
        blocksModif.remove(blockRetirer)

    return frozenset(blocksModif)


def swap_etat_pieges(etat):
    piegesModif = set()
    for piege in etat['pieges']:
        # si le piege est ferme on l'ouvre
        if piege[0] == 'ferme':
            piegesModif.add(('ouvert', piege[1]))

        # si le piege est ouvert on l'ouvre
        elif piege[0] == 'ouvert':
            piegesModif.add(('ferme', piege[1]))

        # si le piege est statique on ne change pas son etat
        else:
            piegesModif.add((piege[0], piege[1]))

    etat['pieges'] = frozenset(piegesModif)
    return frozenset(piegesModif)


# on modifie la position en fonction de la direction
def one_step(position, direction):  # direction peut être 'u' ou 'd' ou 'l' ou 'r'
    i, j = position
    return {'h': (i, j+1), 'b': (i, j-1), 'g': (i-1, j), 'd': (i+1, j)}[direction]


# fonction qui regarde si la position donnee est dans la liste des murs
def free_factory(map_rules):
    def free(position):
        return not(position in map_rules['murs'])
    return free


##################################################################################################################
#                                                                                                                #
#                                            Fonctions recherche etats                                           #
#                                                                                                                #
##################################################################################################################


def search_with_parent(s0, goals, succ,
                       remove, insert):
    l = [s0]
    save = {s0: None}
    s = s0
    while l:
        # s prend la valeur otee de la liste et l prend le reste de la liste
        s, l = remove(l)
        for s2, a in succ(s).items():
            if not s2 in save:
                save[s2] = (s, a)
                if goals(s2):
                    return s2, save  # renvoie un tuple avec (s2, save)
                insert(s2, l)
    return None, save  # renvoie un tuple avec (None, save)


def dict2path(s, d):
    l = [(s, None)]
    while not d[s] is None:
        parent, a = d[s]
        l.append((parent, a))
        s = parent
    l.reverse()
    return l


# return true si l'etat courant du perso est le meme qu'une position de sortie
def goal_factory(map_rules):
    def goals(etat):
        return etat.perso in map_rules.get('sortie')
    return goals


def succ_factory(map_rules):
    def succ(etat):
        for x in etat:
            l = [(do_fn(a, etat._asdict(), map_rules), a)
                 for a in actions.values()]
        return {Etat(**x): a for x, a in l if x}
    return succ


def insert_tail(s, l):  # fonctions pour parcours en largeur
    l.append(s)
    return l


def remove_head(l):
    return l.pop(0), l
