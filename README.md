# SmartSense

J’ai lancé ce projet personnel pour appliquer le module **Smart Capteurs & Actionneurs**. Mon premier objectif est une barrière infrarouge modulée que je peux caractériser sur un banc de laboratoire. La carte STM32G431 comprend aussi une voie ultrasonore, une mesure de température et une liaison écran.

Je travaille la **représentation d’état** avec deux modèles : le filtre analogique et un observateur du signal ADC. La détection I/Q sert de référence. Le noyau C passe 22 tests et compile pour le Cortex-M4F ; il reste à intégrer les pilotes et à l’essayer sur la carte.

## Ouvrir le projet

Dans **KiCad 10**, ouvrir [SmartSense_V1.kicad_pro](hardware/V1/SmartSense_V1.kicad_pro). Schémas, PCB routé et bibliothèques sont inclus. ERC et DRC sans violation. La carte n’est pas encore fabriquée.

[Démarche et essais](ingenierie/PROTOTYPE.md) · [Code C et temps réel](firmware/README.md) · [Programmation](PROGRAMMATION.md)

Aucun PDF. Le boîtier et le dossier de fabrication restent locaux.

[Mon portfolio](https://www.b-diaw.com)
