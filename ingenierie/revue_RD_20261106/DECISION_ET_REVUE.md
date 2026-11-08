# SmartSense — revue R&D (6–7 novembre 2026)

## Décision

**Poursuite conditionnelle en laboratoire.** La V1 est une plateforme de caractérisation de chaînes infrarouge et ultrasonore, **pas** un équipement ferroviaire qualifié. Aucune mesure physique n'a encore été réalisée ; ni fiabilité, ni portée, ni nouveauté scientifique ne sont établies.

## Question étudiée

Comment distinguer une perte de transmission du signal d'une dégradation de la chaîne de mesure ?

Dans le modèle simplifié `y = u × T × G + bruit`, les mesures d'amplitude seules n'identifient que le produit `T × G`. Une référence indépendante est donc à étudier sur banc. Ne jamais interpréter automatiquement un signal faible comme un obstacle.

## Conception V1

- **IR :** TSAL6200 externe, BPW34, TIA **10 kΩ // 100 pF**, filtres et ADC.
- **Ultrasons :** transducteurs Murata **40 kHz**, pilote DRV8837, chaîne analogique.
- **Calcul :** STM32G431CB, code C en cours d'intégration.
- **Mécanique :** console M2 de laboratoire ; ni étanchéité ni certification ferroviaire.

La géométrie de l'ouverture IR privilégie une barrière alignée ; elle ne mesure pas toute une zone autour d'un train.

## Vérifications réalisées

| Vérification | Résultat |
|---|---|
| ERC / DRC KiCad | Aucune violation signalée, suivant les règles et exclusions documentées dans les rapports |
| Connectivité PCB | 370 affectations net/pad vérifiées, 0 écart |
| PCB V1 | 4 couches, 156 empreintes, 1 097 segments, 88 vias |
| Tests du noyau C | 22 tests hôte réussis ; compilation objet ARM vérifiée |
| Modèles MATLAB / Simulink | Cohérence numérique de modèles idéalisés, non validation physique |

Modèles de petits signaux : **45,27 kV/A** pour l'IR à 10 kHz et **14,08** de gain tension US à 40 kHz. Ces valeurs excluent notamment les parasitiques réels et ne sont **pas des mesures sur carte**. Les résultats détaillés restent dans les fichiers JSON, CSV, figures et scripts versionnés.

## Essais bloquants

1. Vérifier alimentation, empreintes, montage et stabilité du TIA.
2. Mesurer lumière ambiante, bruit IR, émission/réception US et couplages.
3. Valider ADC/DMA, délais, pertes de blocs et reprise sur STM32.
4. Comparer seuil simple, I/Q et observateur sur des données physiques ; tester une référence indépendante.
5. Rapporter les erreurs, fausses alertes et limites de généralisation.

**Aucune commande de fabrication ni utilisation de sécurité n'est approuvée par cette revue.** Les normes ferroviaires, performances et éventuelle publication exigent de nouvelles preuves.

[Protocole d'essais](../PROTOCOLE_BANC.md) · [Reproduire la revue](REPRODUIRE.md) · [Sources](SOURCES.md) · [Résultats et preuves](./)
