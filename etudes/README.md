# Études MATLAB/Simulink

Deux modèles complémentaires :

- `etude_etat_smartsense.m` : modèle d'état du filtre analogique (commandabilité, observabilité). Il suppose l'entrée `PHOTO_LP` connue, alors qu'elle n'est pas directement mesurée.
- `observateur_ir.m` : observateur discret du signal ADC à **10 kHz**, échantillonné à **200 kéch/s**. Il estime les composantes en quadrature et le biais. La détection **I/Q** reste la référence de comparaison.

Les simulations utilisent des signaux synthétiques ; les écarts numériques entre implémentations ne prouvent **aucune performance sur la carte physique**.

**Exécution :** MATLAB et Control System Toolbox. Consulter `resultats/` pour les fichiers générés et [la reproduction des vérifications](../ingenierie/revue_RD_20261106/REPRODUIRE.md).
