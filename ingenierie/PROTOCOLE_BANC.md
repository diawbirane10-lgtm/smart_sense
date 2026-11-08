# SmartSense — essais de laboratoire prévus

**Statut : à réaliser.** Enregistrer pour chaque essai : révision carte, firmware, instruments, réglages, données brutes et observations. En cas de modification matérielle, reprendre les essais concernés.

| Étape | Vérifications |
|---|---|
| 1. Alimentation | Démarrer à 24 V avec limitation de courant et écran débranché ; relever +5 V (TP6), +3V3_A (TP7), +3V3_D (TP8), 1,65 V (TP9). Comparer ensuite à 18 V et 30 V. Arrêter en cas de surintensité. |
| 2. STM32 | Programmer par J6, contrôler IR 10 kHz, cadence ADC, DMA, reset, watchdog et calcul **< 1 ms** par bloc de 2 ms. |
| 3. IR | Émetteur aligné à **100 mm**, ultrason désactivé ; mesurer **TP10** (TIA) et **TP11** (ADC) libre/occulté, selon plusieurs éclairages. Rechercher toute saturation analogique. |
| 4. Détection | Enregistrer au moins **200 blocs libres et 200 occultés**, puis 200 transitions. Mesurer séparation, bruit, fausses décisions et latence ; objectif de conception inférieur à 100 ms. |
| 5. Interférences | Répéter les mesures IR avec écran puis ultrasons actifs ; comparer bruit, amplitude et alimentation. |
| 6. Ultrasons / NTC | Caractériser le 40 kHz sans présumer une précision de distance ; comparer la température à une référence (cible initiale ±2 °C de 20 à 40 °C). |
| 7. Mécanique | Vérifier alignement, connecteurs, câbles, accessibilité SWD et fermeture sans pincement. |

Ces objectifs ne sont **pas des performances démontrées** ni des essais de conformité. Les transducteurs ouverts retenus ne sont pas destinés à l'extérieur.

Mettre à jour [EXIGENCES.csv](EXIGENCES.csv) et les preuves uniquement après exécution et sauvegarde des mesures.
