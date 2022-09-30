from espace_etats import Etat


# cette fonction renvoie l'etat initial de la carte ainsi que les constantes de la carte sous la forme :
# etat_initial = ('Etat', ('perso', 'blocks', 'ennemis', 'pieges', 'cle', 'cle_possede', 'porte', 'coups_restants'))
# map_rules = {'sortie': {...}, 'murs': {...}, 'actions': actions}


def initialize_map(map_grid):

    etat_initial_dict = {'perso': (), 'ennemis': set(), 'pieges': set(), 'porte': (),
                         'blocks': set(), 'cle_possede': False, 'coups_restants': map_grid['max_steps']}

    map_rules = {'sortie': set(), 'demon': (), 'murs': set(),
                 'cle': (), 'actions': set()}

    coord_y = 1
    for ligne in reversed(map_grid['grid']):
        coord_x = 1

        for colonne in ligne:
            position = (coord_x, coord_y)

            if (colonne == 'H'):    # perso
                etat_initial_dict['perso'] = position

            if (colonne == 'D'):    # sorties
                map_rules['demon'] = ((coord_x, coord_y))
                map_rules['sortie'].add((coord_x-1, coord_y))
                map_rules['sortie'].add((coord_x+1, coord_y))
                map_rules['sortie'].add((coord_x, coord_y-1))
                map_rules['sortie'].add((coord_x, coord_y+1))

            if (colonne == '#'):    # murs
                map_rules['murs'].add(position)

            if (colonne == 'B'):    # blocks
                etat_initial_dict['blocks'].add(position)

            if (colonne == 'K'):    # cle
                map_rules['cle'] = position

            if (colonne == 'L'):    # porte
                etat_initial_dict['porte'] = position

            if (colonne == 'M'):    # ennemis
                etat_initial_dict['ennemis'].add(position)

            if (colonne == 'S'):    # piege statique
                etat_initial_dict['pieges'].add(('statique', position))

            if (colonne == 'T'):    # piege ouvert - ne fait pas de degats
                etat_initial_dict['pieges'].add(('ouvert', position))

            if (colonne == 'U'):    # piege ferme - fait des degats
                etat_initial_dict['pieges'].add(('ferme', position))

            if (colonne == 'O'):    # block sur un piege statique
                etat_initial_dict['pieges'].add(('statique', position))
                etat_initial_dict['blocks'].add(position)

            if (colonne == 'P'):    # block sur un piege ouvert
                etat_initial_dict['pieges'].add(('ouvert', position))
                etat_initial_dict['blocks'].add(position)

            if (colonne == 'Q'):    # block sur un piege ferme
                etat_initial_dict['pieges'].add(('ferme', position))
                etat_initial_dict['blocks'].add(position)

            coord_x += 1
        coord_y += 1

    liste_sorties = map_rules['sortie']
    liste_murs = map_rules['murs']

    # suppression des positions de sortie impossibles
    for pos in liste_murs:

        if (pos in liste_sorties):  # si la position de sortie est la meme qu'un mur
            map_rules['sortie'].remove(pos)
    # le fait de parcourir la liste de mur pour supprimer les sorties n'est pas logique mais
    # ca ne fonctionnait pas en parcourant la liste des sorties

    etat_initial = Etat(etat_initial_dict['perso'], frozenset(etat_initial_dict['blocks']), frozenset(etat_initial_dict['ennemis']),
                        frozenset(etat_initial_dict['pieges']), etat_initial_dict['cle_possede'], etat_initial_dict['porte'], etat_initial_dict['coups_restants'])

    return etat_initial, map_rules
