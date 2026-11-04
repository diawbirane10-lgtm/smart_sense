# SmartSense — schémas électroniques

Projet personnel d’application du module **Smart Capteurs & Actionneurs** : barrière infrarouge modulée et acquisition ultrasonore avec STM32G431.

Ce dépôt contient uniquement les schémas KiCad et les bibliothèques de symboles nécessaires. Les PDF, le PCB et les fichiers de fabrication sont conservés localement pour le moment.

## Ouvrir la version actuelle

1. Installer KiCad 10 et ses bibliothèques standard.
2. Télécharger le dépôt complet.
3. Ouvrir `hardware/V1/SmartSense_V1.kicad_pro`, puis le schéma principal `SmartSense_V1.kicad_sch`.
4. Naviguer dans les sous-feuilles depuis la racine ou le navigateur hiérarchique.

Les étiquettes portant le même nom désignent la même connexion électrique. La bibliothèque locale `SmartSenseV1.kicad_sym` et `sym-lib-table` accompagnent les feuilles.

Le dépôt contient une seule version active dans `hardware/V1/`. Les anciennes versions restent accessibles dans l’historique Git.

Il s’agit d’une conception de prototype. Les performances réelles, la stabilité analogique et la CEM nécessitent des essais sur matériel ; aucune certification industrielle n’est revendiquée.

Les références fabricant des 103 composants à monter sont précisées dans les propriétés des symboles. Le connecteur SWD est fixé au Harwin M50-3500542. Vérification ERC de cette révision : zéro violation. Le dossier de fabrication reste local.
