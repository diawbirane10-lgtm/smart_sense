# SmartSense

**Prototype R&D de capteurs industriels — en cours.**

SmartSense est une plateforme de laboratoire pour l'acquisition et le diagnostic de signaux **infrarouges modulés** et **ultrasonores (40 kHz)**. Elle utilise un **STM32G431**, une chaîne analogique dédiée et un **PCB 4 couches** conçu avec KiCad.

## État du projet

| Réalisé | À faire |
|---|---|
| Schémas et PCB KiCad V1 (ERC/DRC : 0 violation signalée) | Fabrication et assemblage de la carte |
| Noyau C : 22 tests réussis sur PC, compilation ARM vérifiée | Intégration firmware et essais sur STM32 |
| Modèles et simulations MATLAB/Simulink | Mesures et validation sur banc |

**Important :** aucun essai physique n'a encore été réalisé. Le prototype n'est pas qualifié pour une application ferroviaire ou de sécurité.

## Fichiers principaux

- [Conception KiCad V1](hardware/V1/SmartSense_V1.kicad_pro) — ouvrir avec **KiCad 10**.
- [Études MATLAB/Simulink](etudes/README.md)
- [Firmware C](firmware/README.md) et [programmation STM32](PROGRAMMATION.md)
- [Prototype et prochaines étapes](ingenierie/PROTOTYPE.md)
- [Revue R&D et limites](ingenierie/revue_RD_20261106/DECISION_ET_REVUE.md)

[Portfolio](https://b-diaw.com)
