# Reproduire les vérifications R&D

1. **KiCad 10 :** exécuter `verifier_kicad.py --project CHEMIN/SmartSense_V1.kicad_pro` avec le Python de KiCad. Consulter les rapports ERC/DRC et `AUDIT_NATIF.json`, y compris les exclusions configurées.
2. **MATLAB :** ajouter `etudes/` au chemin, exécuter `revue_rd` puis `verifier_simulink_rd`. Graine de simulation : **61106**. Les résultats portent sur des modèles, pas sur le matériel.
3. **Firmware :** lancer les tests indiqués dans [firmware/README.md](../../../firmware/README.md) et noter la version du compilateur.
4. **Mécanique :** ouvrir les fichiers Fusion du projet ; contrôler les interférences et l'ajustement réel avant assemblage.
5. **Après toute modification :** refaire les vérifications concernées et conserver les nouveaux rapports.

Les essais physiques répertoriés dans `TESTS.csv` restent **à faire**. Le manifeste `MANIFESTE_SHA256.json` relie les éléments archivés.
