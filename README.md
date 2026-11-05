# SmartSense — schémas électroniques

Projet personnel : première application du module **Smart Capteurs & Actionneurs**. L'objectif est d'étudier une barrière infrarouge modulée, l'acquisition ultrasonore et la compensation en température, pilotées par un STM32G431, avec une liaison vers un afficheur pour la consultation des mesures.

Ce dépôt contient les **29 feuilles du schéma KiCad 10**, le projet et la bibliothèque locale de symboles. Une seule version active est conservée dans `hardware/V1/`. Aucun PDF, PCB ni fichier de fabrication n'est publié ici.

## Ouvrir le projet

1. Installer KiCad 10 avec ses bibliothèques standard.
2. Télécharger le dépôt complet.
3. Ouvrir `hardware/V1/SmartSense_V1.kicad_pro`, puis `SmartSense_V1.kicad_sch`.
4. Parcourir les fonctions dans le navigateur hiérarchique. Les étiquettes de même nom sont reliées électriquement.

La bibliothèque `SmartSenseV1.kicad_sym` et son `sym-lib-table` sont incluses. Les couleurs sont celles de KiCad ; les feuilles de l'interface écran sont au format A4 paysage pour faciliter la lecture.

## Révision V1-HMI — 5 novembre 2026

Les propriétés des symboles précisent les références d'achat des **116 composants** à monter. Le convertisseur TRACO TSR 1-4850WI fournit le 5 V / 1 A. La branche écran est filtrée et comporte une adaptation UART TXU0202 avec activation contrôlée ; J8 est le connecteur détrompé de l'afficheur. L'UART de service J7 est conservé.

Vérification native KiCad : **ERC sans violation**. Le PCB et le dossier de prototype PCBA associés restent locaux.

Il s'agit d'une conception de prototype. Le firmware de mesure et le projet d'interface Nextion restent à réaliser. Les performances, l'étalonnage, les marges d'alimentation, la thermique et la CEM doivent être vérifiés sur une carte assemblée. Aucun certificat industriel n'est revendiqué.

Portfolio : [www.b-diaw.com](https://www.b-diaw.com).
