# SmartSense — prototype de laboratoire

## Périmètre

- **Infrarouge :** barrière modulée, émetteur externe et photodiode ; premier essai prévu à **100 mm** en intérieur.
- **Ultrason :** émission/réception à **40 kHz**, sans précision de distance revendiquée.
- **Température :** acquisition par thermistance.
- **Traitement :** STM32G431, détection I/Q et observateur de signal ; affichage secondaire et captures sur PC.

Schémas, PCB routé, modèles et noyau C sont disponibles. **La carte n'est pas fabriquée ; aucun essai physique n'est terminé.**

## Points de vigilance

| Sujet | Vérification indispensable |
|---|---|
| Saturation optique du TIA | Mesurer **TP10**, même si l'ADC semble valide |
| Signal faible (obstacle ou panne) | Ne pas attribuer de cause sans référence indépendante |
| ADC/DMA et temps réel | Vérifier horodatage, pertes de blocs, invalidation |
| Couplage IR/US/écran | Comparer bruit et alimentation avec chaque fonction active |
| PCB et mécanique | Contrôler alimentation, empreintes, câbles et montage réel |

Les vérifications ERC/DRC ne remplacent pas les essais électriques, CEM et mécaniques.

## Suite

1. Assembler et alimenter la carte sous contrôle.
2. Intégrer le firmware STM32.
3. Exécuter le [protocole de banc](PROTOCOLE_BANC.md) et enregistrer les résultats.
4. Mettre à jour [les exigences](EXIGENCES.csv) et [la revue R&D](revue_RD_20261106/DECISION_ET_REVUE.md).

**Usage :** prototype de laboratoire, sans qualification ferroviaire ni fonction de sécurité. [Références](SOURCES.md).
