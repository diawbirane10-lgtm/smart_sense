# SmartSense

J’ai lancé ce projet personnel pour appliquer le module **Smart Capteurs & Actionneurs**. La carte utilise un STM32G431 pour émettre et acquérir des signaux infrarouges et ultrasonores, avec une mesure de température et une liaison vers un écran.

J’y ajoute une étude de **représentation d’état** du filtre analogique : commandabilité, observabilité et observateur de Luenberger. Elle est testée sous MATLAB, pas encore embarquée.

## Ouvrir les schémas

Dans **KiCad 10**, ouvrir [SmartSense_V1.kicad_pro](hardware/V1/SmartSense_V1.kicad_pro), puis le schéma principal. Les 29 feuilles et la bibliothèque de symboles sont incluses.

ERC sans violation. La carte n’est pas encore fabriquée ; le firmware et les essais restent à réaliser.

Le dépôt contient uniquement les schémas, sans PDF. Le PCB, le boîtier et le dossier de fabrication restent locaux.

[Mon portfolio](https://www.b-diaw.com)
