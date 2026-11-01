# SmartSense — schémas électroniques

Projet académique du module **Smart Capteurs & Actionneurs** : barrière infrarouge modulée et acquisition ultrasonore pour un convoyeur de blocs en béton.

## Dossier de revue V0.3

- [PDF en couleurs, vues agrandies, Libertinus Serif — 22 pages](docs/SmartSense_Schemas_Revue_V0_3.pdf)
- [Projet KiCad 10](hardware/Smart_Sense.kicad_pro)
- [Rapport ERC](validation/ERC_KiCad10.json)
- [Vérification des 127 raccordements](validation/connexions.json)

Le projet comporte **10 feuilles hiérarchiques et 48 composants**. Aucun PCB n’est réalisé. Les schémas se connectent par noms de signaux : étiquettes globales entre feuilles, locales au sein d’une feuille. Les vues PDF fractionnées conservent les mêmes repères et connexions.

## Ouvrir le projet

1. Installer KiCad 10 et ses bibliothèques standard.
2. Télécharger le dépôt et ouvrir `hardware/Smart_Sense.kicad_pro`.
3. Ouvrir le schéma et naviguer dans les sous-feuilles.

La bibliothèque locale et `sym-lib-table` accompagnent le projet. Libertinus Serif peut être installée pour retrouver la typographie dans KiCad ; elle est incorporée au PDF.

## Organisation des feuilles

| Feuille | Fonction |
| --- | --- |
| Vue générale | Architecture et accès aux sous-feuilles |
| 01 | Entrée 24 V conceptuelle et conversion 5 V |
| 02 | Régulation 3,3 V et référence analogique 1,65 V |
| 03 | Émission IR modulée à 10 kHz |
| 04 | Photodiode et transimpédance |
| 05 | Filtrage et sortie ADC photo |
| 06 | Émission ultrasonore 40 kHz |
| 07 | Réception ultrasonore et premier gain |
| 08 | Filtrage US et deuxième gain |
| 09 | Interface dédiée MCU et NTC |

## État des vérifications

KiCad 10.0.5 : **0 violation ERC**. La comparaison de la netlist exportée avec les connexions attendues porte sur **127 affectations broche/signal, sans écart**. Le brochage OPA320 DBV est défini dans la bibliothèque locale. Le symbole du connecteur MCU est espacé pour améliorer la lisibilité ; sa numérotation reste 1 à 12.

Ces contrôles ne démontrent pas la stabilité analogique ni les performances réelles. L’entrée 24 V, la coordination fusible/TVS, la protection contre inversion, les références DC/DC et LDO, la saturation des récepteurs et l’adaptation ADC restent à valider. Les blocs d’alimentation ont des bornes logiques, pas un brochage fabricant. Le connecteur MCU n’est pas un connecteur Nucleo directement compatible. Aucune interface automate 24 V ou fonctionnalité IA validée n’est revendiquée.

Les fichiers `data/` conservent les exigences et identifiants du dossier initial Fusion/EAGLE fourni pour cette reprise. Leurs broches logiques se distinguent des numéros physiques du projet KiCad ; la correspondance actuelle figure dans `validation/composants_et_connexions.json`.

## Sources

- Dossier SmartSense initial du 28 octobre 2026 fourni pour la reprise du projet.
- [TI OPA320, SBOS513F](https://www.ti.com/lit/gpn/opa320).
- [TI DRV8837, SLVSBA4F](https://www.ti.com/lit/ds/symlink/drv8837.pdf).
- Bibliothèques standard KiCad installées et symboles locaux inclus.
