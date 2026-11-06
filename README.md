# SmartSense

J’ai lancé ce projet personnel pour appliquer le module **Smart Capteurs & Actionneurs**. La carte utilise un STM32G431 pour émettre et acquérir des signaux infrarouges et ultrasonores, avec une mesure de température et une liaison vers un écran.

J’y ajoute une étude de **représentation d’état** du filtre analogique : commandabilité, observabilité et observateur de Luenberger. Elle est testée sous MATLAB, pas encore embarquée.

## Ouvrir le projet

Dans **KiCad 10**, ouvrir [SmartSense_V1.kicad_pro](hardware/V1/SmartSense_V1.kicad_pro), puis le schéma principal. Les 29 feuilles, le PCB routé et les bibliothèques locales sont inclus. Ouvrir `SmartSense_V1.kicad_pcb` pour la carte.

ERC et DRC sans violation. La carte n’est pas encore fabriquée ; le firmware et les essais restent à réaliser.

Aucun PDF dans le dépôt. Le boîtier et le dossier de fabrication restent locaux. Pour charger un programme dans la carte : [programmation et interfaces](PROGRAMMATION.md).

[Mon portfolio](https://www.b-diaw.com)
