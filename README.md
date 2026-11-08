# SmartSense

J’ai lancé ce projet personnel pour appliquer le module **Smart Capteurs & Actionneurs**. Je commence par caractériser une barrière infrarouge modulée sur banc, puis j’étudie ce qui permet de distinguer une perturbation de mesure d’une dégradation du capteur. La carte STM32G431 comprend aussi une voie ultrasonore, une mesure de température et une liaison écran.

Je travaille la **représentation d’état** avec deux modèles : le filtre analogique et un observateur du signal ADC. La détection I/Q sert de référence. Le noyau C passe 22 tests et compile pour le Cortex-M4F ; il reste à intégrer les pilotes et à l’essayer sur la carte.

La [revue R&D](ingenierie/revue_RD_20261106/DECISION_ET_REVUE.md) expose les limites de la V1 et le plan d’essais. La perspective ferroviaire motive la recherche ; cette carte reste un prototype de laboratoire. Les résultats MATLAB et Simulink sont des simulations, sans mesures de carte à ce stade.

## Ouvrir le projet

Dans **KiCad 10**, ouvrir [SmartSense_V1.kicad_pro](hardware/V1/SmartSense_V1.kicad_pro). Schémas, PCB routé et bibliothèques sont inclus. ERC et DRC sans violation. La carte n’est pas encore fabriquée.

[Démarche et essais](ingenierie/PROTOTYPE.md) · [Code C et temps réel](firmware/README.md) · [Programmation](PROGRAMMATION.md)



[Mon portfolio](https://www.b-diaw.com)
